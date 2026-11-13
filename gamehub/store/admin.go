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
	Title         string         `json:"title"`
	ImageURL      *string        `json:"imageUrl"` // รูปปก
	Description   *string        `json:"description"`
	GenreIDs      []int          `json:"genreIds"`      // หลายแนว ตัวแรก = แนวหลัก
	PlayerModeIDs []int          `json:"playerModeIds"` // หลายโหมด
	Images        []string       `json:"images"`        // รูปเพิ่มเติม
	Platforms     []GamePlatform `json:"platforms"`
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

func (s *Store) intList(ctx context.Context, query string, gameID int64) ([]int, error) {
	rows, err := s.Pool.Query(ctx, query, gameID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []int{}
	for rows.Next() {
		var n int
		if err := rows.Scan(&n); err != nil {
			return nil, err
		}
		out = append(out, n)
	}
	return out, rows.Err()
}

func (s *Store) AdminGetGame(ctx context.Context, id int64) (AdminGame, error) {
	var g AdminGame
	err := s.Pool.QueryRow(ctx,
		`SELECT g.id, g.title, g.image_url, g.description, g.updated_at,
                (SELECT count(*) FROM reviews        WHERE game_id = g.id),
                (SELECT count(*) FROM votes          WHERE game_id = g.id),
                (SELECT count(*) FROM wishlist_items WHERE game_id = g.id)
         FROM games g WHERE g.id = $1`, id).
		Scan(&g.ID, &g.Title, &g.ImageURL, &g.Description, &g.UpdatedAt,
			&g.Impact.Reviews, &g.Impact.Votes, &g.Impact.Wishlist)
	if errors.Is(err, pgx.ErrNoRows) {
		return g, ErrNotFound
	}
	if err != nil {
		return g, err
	}
	if g.GenreIDs, err = s.intList(ctx,
		`SELECT genre_id FROM game_genres WHERE game_id = $1 ORDER BY position`, id); err != nil {
		return g, err
	}
	if g.PlayerModeIDs, err = s.intList(ctx,
		`SELECT mode_id FROM game_player_modes WHERE game_id = $1 ORDER BY mode_id`, id); err != nil {
		return g, err
	}
	if g.Images, err = s.gameImages(ctx, id); err != nil {
		return g, err
	}
	g.Platforms, err = s.gamePlatforms(ctx, id)
	return g, err
}

// setGenres แทนที่แนวทั้งหมด ตัวแรกในรายการได้ position 0 (แนวหลัก)
func setGenres(ctx context.Context, tx pgx.Tx, gameID int64, ids []int) error {
	if _, err := tx.Exec(ctx, `DELETE FROM game_genres WHERE game_id = $1`, gameID); err != nil {
		return err
	}
	seen := map[int]bool{}
	pos := 0
	for _, gid := range ids {
		if seen[gid] {
			continue
		}
		seen[gid] = true
		_, err := tx.Exec(ctx,
			`INSERT INTO game_genres (game_id, genre_id, position) VALUES ($1, $2, $3)`,
			gameID, gid, pos)
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) && pgErr.Code == "23503" {
			return ErrBadGenre
		}
		if err != nil {
			return err
		}
		pos++
	}
	return nil
}

// setPlayerModes แทนที่โหมดผู้เล่นทั้งหมด และสรุปเป็นข้อความลงช่อง games.players
func setPlayerModes(ctx context.Context, tx pgx.Tx, gameID int64, ids []int) error {
	if _, err := tx.Exec(ctx, `DELETE FROM game_player_modes WHERE game_id = $1`, gameID); err != nil {
		return err
	}
	seen := map[int]bool{}
	for _, mid := range ids {
		if seen[mid] {
			continue
		}
		seen[mid] = true
		_, err := tx.Exec(ctx,
			`INSERT INTO game_player_modes (game_id, mode_id) VALUES ($1, $2)`, gameID, mid)
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) && pgErr.Code == "23503" {
			return ErrBadGenre
		}
		if err != nil {
			return err
		}
	}
	_, err := tx.Exec(ctx,
		`UPDATE games SET players = (
            SELECT string_agg(pm.name_th, ', ' ORDER BY pm.id)
              FROM game_player_modes gm JOIN player_modes pm ON pm.id = gm.mode_id
             WHERE gm.game_id = $1) WHERE id = $1`, gameID)
	return err
}

// setImages แทนที่รูปเพิ่มเติมทั้งหมด
func setImages(ctx context.Context, tx pgx.Tx, gameID int64, urls []string) error {
	if _, err := tx.Exec(ctx, `DELETE FROM game_images WHERE game_id = $1`, gameID); err != nil {
		return err
	}
	for i, u := range urls {
		if _, err := tx.Exec(ctx,
			`INSERT INTO game_images (game_id, url, position) VALUES ($1, $2, $3)`, gameID, u, i); err != nil {
			return err
		}
	}
	return nil
}

// setPlatforms แทนที่แพลตฟอร์มทั้งหมด แล้วสรุปราคาต่ำสุด (หลังลด) กลับไปที่ games
func setPlatforms(ctx context.Context, tx pgx.Tx, gameID int64, ps []GamePlatform) error {
	if _, err := tx.Exec(ctx, `DELETE FROM game_platforms WHERE game_id = $1`, gameID); err != nil {
		return err
	}
	for _, p := range ps {
		if _, err := tx.Exec(ctx,
			`INSERT INTO game_platforms (game_id, platform, price, discount_percent, download_url)
             VALUES ($1, $2, $3, $4, $5)`,
			gameID, p.Platform, p.Price, p.DiscountPercent, p.DownloadURL); err != nil {
			return err
		}
	}
	_, err := tx.Exec(ctx,
		`UPDATE games SET
            price = coalesce((SELECT min(round(price * (100 - discount_percent) / 100.0, 2))
                                FROM game_platforms WHERE game_id = $1), 0),
            platform = (SELECT string_agg(platform, ', ' ORDER BY platform)
                          FROM game_platforms WHERE game_id = $1),
            download_url = (SELECT download_url FROM game_platforms WHERE game_id = $1
                             ORDER BY price, platform LIMIT 1)
         WHERE id = $1`, gameID)
	return err
}

func applyRelations(ctx context.Context, tx pgx.Tx, id int64, in GameInput) error {
	if err := setGenres(ctx, tx, id, in.GenreIDs); err != nil {
		return err
	}
	if err := setPlayerModes(ctx, tx, id, in.PlayerModeIDs); err != nil {
		return err
	}
	if err := setImages(ctx, tx, id, in.Images); err != nil {
		return err
	}
	return setPlatforms(ctx, tx, id, in.Platforms)
}

func (s *Store) CreateGame(ctx context.Context, in GameInput) (AdminGame, error) {
	tx, err := s.Pool.Begin(ctx)
	if err != nil {
		return AdminGame{}, err
	}
	defer tx.Rollback(ctx)

	var id int64
	err = tx.QueryRow(ctx,
		`INSERT INTO games (title, image_url, description) VALUES ($1, $2, $3) RETURNING id`,
		in.Title, in.ImageURL, in.Description).Scan(&id)
	if err != nil {
		return AdminGame{}, err
	}
	if err := applyRelations(ctx, tx, id, in); err != nil {
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
		`UPDATE games SET title = $2, image_url = $3, description = $4, updated_at = now()
         WHERE id = $1`, id, in.Title, in.ImageURL, in.Description)
	if err != nil {
		return AdminGame{}, err
	}
	if tag.RowsAffected() == 0 {
		return AdminGame{}, ErrNotFound
	}
	if err := applyRelations(ctx, tx, id, in); err != nil {
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