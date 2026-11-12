package store

import (
	"context"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
)

var ErrBadGenre = errors.New("bad genre")

// ---------- Dashboard ----------

type TopGame struct {
	ID          int64   `json:"id"`
	Title       string  `json:"title"`
	Image       *string `json:"image"`
	VoteCount   int64   `json:"voteCount"`
	VoteAverage float64 `json:"voteAverage"`
}

type Stats struct {
	Games         int64     `json:"games"`
	Members       int64     `json:"members"`
	Admins        int64     `json:"admins"`
	Votes         int64     `json:"votes"`
	WishlistItems int64     `json:"wishlistItems"`
	NewestMembers []Member  `json:"newestMembers"`
	TopVoted      []TopGame `json:"topVoted"`
}

func (s *Store) Stats(ctx context.Context) (Stats, error) {
	var st Stats
	err := s.Pool.QueryRow(ctx,
		`SELECT (SELECT count(*) FROM games),
                (SELECT count(*) FROM members),
                (SELECT count(*) FROM members WHERE role = 'admin'),
                (SELECT count(*) FROM votes),
                (SELECT count(*) FROM wishlist_items)`).
		Scan(&st.Games, &st.Members, &st.Admins, &st.Votes, &st.WishlistItems)
	if err != nil {
		return st, err
	}

	rows, err := s.Pool.Query(ctx,
		`SELECT id, email, display_name, role, created_at
         FROM members ORDER BY created_at DESC, id DESC LIMIT 5`)
	if err != nil {
		return st, err
	}
	st.NewestMembers = []Member{}
	for rows.Next() {
		var m Member
		if err := rows.Scan(&m.ID, &m.Email, &m.DisplayName, &m.Role, &m.CreatedAt); err != nil {
			rows.Close()
			return st, err
		}
		st.NewestMembers = append(st.NewestMembers, m)
	}
	rows.Close()
	if err := rows.Err(); err != nil {
		return st, err
	}

	rows, err = s.Pool.Query(ctx,
		`SELECT g.id, g.title, g.image_url, vs.vote_count, vs.vote_average::float8
         FROM game_vote_stats vs
         JOIN games g ON g.id = vs.game_id
         ORDER BY vs.vote_average DESC, vs.vote_count DESC, g.title
         LIMIT 5`)
	if err != nil {
		return st, err
	}
	defer rows.Close()
	st.TopVoted = []TopGame{}
	for rows.Next() {
		var t TopGame
		if err := rows.Scan(&t.ID, &t.Title, &t.Image, &t.VoteCount, &t.VoteAverage); err != nil {
			return st, err
		}
		st.TopVoted = append(st.TopVoted, t)
	}
	return st, rows.Err()
}

// ---------- แนวเกม (ใช้ทำปุ่มกรอง/dropdown) ----------

type Genre struct {
	ID     int     `json:"id"`
	NameEn string  `json:"nameEn"`
	NameTh *string `json:"nameTh"`
}

func (s *Store) ListGenres(ctx context.Context) ([]Genre, error) {
	rows, err := s.Pool.Query(ctx, `SELECT id, name_en, name_th FROM genres ORDER BY id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []Genre{}
	for rows.Next() {
		var g Genre
		if err := rows.Scan(&g.ID, &g.NameEn, &g.NameTh); err != nil {
			return nil, err
		}
		out = append(out, g)
	}
	return out, rows.Err()
}

// ---------- เกม: มุมมองของ admin ----------

type GameInput struct {
	Title       string  `json:"title"`
	ImageURL    *string `json:"imageUrl"`
	Price       float64 `json:"price"`
	Description *string `json:"description"`
	Players     *string `json:"players"`
	DownloadURL *string `json:"downloadUrl"`
	Platform    *string `json:"platform"`
	GenreID     *int    `json:"genreId"` // แนวหลัก (position 0) หรือ null
}

// Impact บอกว่าถ้าลบเกมนี้ ข้อมูลสมาชิกจะหายตามไปเท่าไร (ON DELETE CASCADE)
type Impact struct {
	Reviews  int64 `json:"reviews"`
	Votes    int64 `json:"votes"`
	Wishlist int64 `json:"wishlist"`
}

type AdminGame struct {
	ID int64 `json:"id"`
	GameInput
	UpdatedAt time.Time `json:"updatedAt"`
	Impact    Impact    `json:"impact"`
}

func (s *Store) AdminGetGame(ctx context.Context, id int64) (AdminGame, error) {
	var g AdminGame
	err := s.Pool.QueryRow(ctx,
		`SELECT g.id, g.title, g.image_url, g.price::float8, g.description, g.players,
                g.download_url, g.platform,
                (SELECT genre_id FROM game_genres WHERE game_id = g.id AND position = 0),
                g.updated_at,
                (SELECT count(*) FROM reviews        WHERE game_id = g.id),
                (SELECT count(*) FROM votes          WHERE game_id = g.id),
                (SELECT count(*) FROM wishlist_items WHERE game_id = g.id)
         FROM games g WHERE g.id = $1`, id).
		Scan(&g.ID, &g.Title, &g.ImageURL, &g.Price, &g.Description, &g.Players,
			&g.DownloadURL, &g.Platform, &g.GenreID, &g.UpdatedAt,
			&g.Impact.Reviews, &g.Impact.Votes, &g.Impact.Wishlist)
	if errors.Is(err, pgx.ErrNoRows) {
		return g, ErrNotFound
	}
	return g, err
}

func setMainGenre(ctx context.Context, tx pgx.Tx, gameID int64, genreID *int) error {
	if genreID == nil {
		_, err := tx.Exec(ctx, `DELETE FROM game_genres WHERE game_id = $1 AND position = 0`, gameID)
		return err
	}
	if _, err := tx.Exec(ctx,
		`DELETE FROM game_genres WHERE game_id = $1 AND (position = 0 OR genre_id = $2)`,
		gameID, *genreID); err != nil {
		return err
	}
	_, err := tx.Exec(ctx,
		`INSERT INTO game_genres (game_id, genre_id, position) VALUES ($1, $2, 0)`,
		gameID, *genreID)
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) && pgErr.Code == "23503" {
		return ErrBadGenre
	}
	return err
}

func (s *Store) CreateGame(ctx context.Context, in GameInput) (AdminGame, error) {
	tx, err := s.Pool.Begin(ctx)
	if err != nil {
		return AdminGame{}, err
	}
	defer tx.Rollback(ctx)

	var id int64
	err = tx.QueryRow(ctx,
		`INSERT INTO games (title, image_url, price, description, players, download_url, platform)
         VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id`,
		in.Title, in.ImageURL, in.Price, in.Description, in.Players, in.DownloadURL, in.Platform).Scan(&id)
	if err != nil {
		return AdminGame{}, err
	}
	if err := setMainGenre(ctx, tx, id, in.GenreID); err != nil {
		return AdminGame{}, err
	}
	if err := tx.Commit(ctx); err != nil {
		return AdminGame{}, err
	}
	return s.AdminGetGame(ctx, id)
}

func (s *Store) UpdateGame(ctx context.Context, id int64, in GameInput) (AdminGame, error) {
	tx, err := s.Pool.Begin(ctx)
	if err != nil {
		return AdminGame{}, err
	}
	defer tx.Rollback(ctx)

	tag, err := tx.Exec(ctx,
		`UPDATE games
         SET title = $2, image_url = $3, price = $4, description = $5, players = $6,
             download_url = $7, platform = $8, updated_at = now()
         WHERE id = $1`,
		id, in.Title, in.ImageURL, in.Price, in.Description, in.Players, in.DownloadURL, in.Platform)
	if err != nil {
		return AdminGame{}, err
	}
	if tag.RowsAffected() == 0 {
		return AdminGame{}, ErrNotFound
	}
	if err := setMainGenre(ctx, tx, id, in.GenreID); err != nil {
		return AdminGame{}, err
	}
	if err := tx.Commit(ctx); err != nil {
		return AdminGame{}, err
	}
	return s.AdminGetGame(ctx, id)
}

func (s *Store) DeleteGame(ctx context.Context, id int64) error {
	tag, err := s.Pool.Exec(ctx, `DELETE FROM games WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}