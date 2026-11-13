package store

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
)

type Game struct {
	ID          int64    `json:"id"`
	Title       string   `json:"title"`
	Image       *string  `json:"image"`
	Price       float64  `json:"price"` // ราคาเริ่มต้น (ต่ำสุดหลังหักส่วนลดของทุกแพลตฟอร์ม)
	Players     *string  `json:"players"`
	Platform    *string  `json:"platform"`
	Genre       *string  `json:"genre"`       // แนวหลัก (position 0)
	Genres      []string `json:"genres"`      // ทุกแนว
	PlayerModes []string `json:"playerModes"` // ทุกโหมดผู้เล่น
	Rating      float64  `json:"rating"`
}

const allGenresSQL = `array(SELECT coalesce(ge.name_th, ge.name_en)
                              FROM game_genres gg JOIN genres ge ON ge.id = gg.genre_id
                             WHERE gg.game_id = g.id ORDER BY gg.position)`

const allModesSQL = `array(SELECT pm.name_th
                             FROM game_player_modes gm JOIN player_modes pm ON pm.id = gm.mode_id
                            WHERE gm.game_id = g.id ORDER BY pm.id)`

const mainGenreSQL = `(SELECT coalesce(ge.name_th, ge.name_en) FROM game_genres gg
                         JOIN genres ge ON ge.id = gg.genre_id
                        WHERE gg.game_id = g.id AND gg.position = 0)`

// SearchGames: q = ชื่อ, genre = ชื่อแนว (อังกฤษ), mode = ชื่อโหมดผู้เล่น (อังกฤษ),
// sort = "" (แนะนำ) | price_asc | price_desc | name
func (s *Store) SearchGames(ctx context.Context, q, genre, mode, sort string) ([]Game, error) {
	rows, err := s.Pool.Query(ctx,
		`SELECT g.id, g.title, g.image_url, g.price::float8, g.players, g.platform,
                `+mainGenreSQL+`,
                `+allGenresSQL+`,
                `+allModesSQL+`,
                coalesce(vs.vote_average, 0)::float8
         FROM games g
         LEFT JOIN game_vote_stats vs ON vs.game_id = g.id
         WHERE lower(g.title) LIKE '%' || lower($1::text) || '%'
           AND ($2::text = '' OR EXISTS (
                 SELECT 1 FROM game_genres gg JOIN genres ge ON ge.id = gg.genre_id
                  WHERE gg.game_id = g.id AND lower(ge.name_en) = lower($2::text)))
           AND ($3::text = '' OR EXISTS (
                 SELECT 1 FROM game_player_modes gm JOIN player_modes pm ON pm.id = gm.mode_id
                  WHERE gm.game_id = g.id AND lower(pm.name_en) = lower($3::text)))
         ORDER BY
           CASE WHEN $4::text = 'price_asc'  THEN g.price END ASC,
           CASE WHEN $4::text = 'price_desc' THEN g.price END DESC,
           CASE WHEN $4::text = 'name'       THEN g.title END ASC,
           CASE WHEN $4::text = ''           THEN coalesce(vs.vote_average, 0) END DESC,
           g.created_at DESC, g.id DESC`,
		q, genre, mode, sort)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []Game{}
	for rows.Next() {
		var g Game
		if err := rows.Scan(&g.ID, &g.Title, &g.Image, &g.Price, &g.Players, &g.Platform,
			&g.Genre, &g.Genres, &g.PlayerModes, &g.Rating); err != nil {
			return nil, err
		}
		out = append(out, g)
	}
	return out, rows.Err()
}

// GamePlatform: ราคา ส่วนลด และลิงก์ดาวน์โหลดของเกมหนึ่งเรื่องบนหนึ่งแพลตฟอร์ม
type GamePlatform struct {
	Platform        string  `json:"platform"`
	Price           float64 `json:"price"`           // ราคาเดิม
	DiscountPercent int     `json:"discountPercent"` // 0-100
	DownloadURL     *string `json:"downloadUrl"`
}

func (s *Store) gamePlatforms(ctx context.Context, gameID int64) ([]GamePlatform, error) {
	rows, err := s.Pool.Query(ctx,
		`SELECT platform, price::float8, discount_percent, download_url
         FROM game_platforms WHERE game_id = $1 ORDER BY platform`, gameID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []GamePlatform{}
	for rows.Next() {
		var p GamePlatform
		if err := rows.Scan(&p.Platform, &p.Price, &p.DiscountPercent, &p.DownloadURL); err != nil {
			return nil, err
		}
		out = append(out, p)
	}
	return out, rows.Err()
}

func (s *Store) gameImages(ctx context.Context, gameID int64) ([]string, error) {
	rows, err := s.Pool.Query(ctx,
		`SELECT url FROM game_images WHERE game_id = $1 ORDER BY position, id`, gameID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []string{}
	for rows.Next() {
		var u string
		if err := rows.Scan(&u); err != nil {
			return nil, err
		}
		out = append(out, u)
	}
	return out, rows.Err()
}

// GameDetail: เกมหนึ่งเรื่องพร้อมรายละเอียดเต็ม
type GameDetail struct {
	Game
	Description *string        `json:"description"`
	ReviewCount int64          `json:"reviewCount"`
	Images      []string       `json:"images"`
	Platforms   []GamePlatform `json:"platforms"`
}

func (s *Store) GetGame(ctx context.Context, id int64) (GameDetail, error) {
	var g GameDetail
	err := s.Pool.QueryRow(ctx,
		`SELECT g.id, g.title, g.image_url, g.price::float8, g.players, g.platform,
                `+mainGenreSQL+`,
                `+allGenresSQL+`,
                `+allModesSQL+`,
                coalesce(vs.vote_average, 0)::float8,
                g.description,
                (SELECT count(*) FROM reviews r WHERE r.game_id = g.id)
         FROM games g
         LEFT JOIN game_vote_stats vs ON vs.game_id = g.id
         WHERE g.id = $1`, id).
		Scan(&g.ID, &g.Title, &g.Image, &g.Price, &g.Players, &g.Platform,
			&g.Genre, &g.Genres, &g.PlayerModes, &g.Rating, &g.Description, &g.ReviewCount)
	if errors.Is(err, pgx.ErrNoRows) {
		return g, ErrNotFound
	}
	if err != nil {
		return g, err
	}
	if g.Images, err = s.gameImages(ctx, id); err != nil {
		return g, err
	}
	g.Platforms, err = s.gamePlatforms(ctx, id)
	return g, err
}

// PlayerMode: ตัวเลือกโหมดผู้เล่น (ใช้ทำ checkbox)
type PlayerMode struct {
	ID     int    `json:"id"`
	NameEn string `json:"nameEn"`
	NameTh string `json:"nameTh"`
}

func (s *Store) ListPlayerModes(ctx context.Context) ([]PlayerMode, error) {
	rows, err := s.Pool.Query(ctx, `SELECT id, name_en, name_th FROM player_modes ORDER BY id`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []PlayerMode{}
	for rows.Next() {
		var m PlayerMode
		if err := rows.Scan(&m.ID, &m.NameEn, &m.NameTh); err != nil {
			return nil, err
		}
		out = append(out, m)
	}
	return out, rows.Err()
}