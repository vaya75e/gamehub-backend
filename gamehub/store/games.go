package store

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
)

type Game struct {
	ID       int64   `json:"id"`
	Title    string  `json:"title"`
	Image    *string `json:"image"`
	Price    float64 `json:"price"`
	Players  *string `json:"players"`
	Platform *string `json:"platform"`
	Genre    *string `json:"genre"`
	Rating   float64 `json:"rating"`
}

// SearchGames: q = ชื่อ, genre = ชื่อแนว (อังกฤษ), players = ข้อความจำนวนผู้เล่น,
// sort = "" (แนะนำ) | newest | price_asc | price_desc | name
// ค่าจากผู้ใช้ทุกตัวเดินทางผ่าน $1..$4 แยกจากคำสั่งเสมอ
func (s *Store) SearchGames(ctx context.Context, q, genre, players, sort string) ([]Game, error) {
	rows, err := s.Pool.Query(ctx,
		`SELECT g.id, g.title, g.image_url, g.price::float8, g.players, g.platform,
                (SELECT coalesce(ge.name_th, ge.name_en) FROM game_genres gg
                   JOIN genres ge ON ge.id = gg.genre_id
                  WHERE gg.game_id = g.id AND gg.position = 0),
                coalesce(vs.vote_average, 0)::float8
         FROM games g
         LEFT JOIN game_vote_stats vs ON vs.game_id = g.id
         WHERE lower(g.title) LIKE '%' || lower($1::text) || '%'
           AND ($2::text = '' OR EXISTS (
                 SELECT 1 FROM game_genres gg JOIN genres ge ON ge.id = gg.genre_id
                  WHERE gg.game_id = g.id AND lower(ge.name_en) = lower($2::text)))
           AND ($3::text = '' OR g.players ILIKE '%' || $3::text || '%')
         ORDER BY
           CASE WHEN $4::text = 'price_asc'  THEN g.price END ASC,
           CASE WHEN $4::text = 'price_desc' THEN g.price END DESC,
           CASE WHEN $4::text = 'name'       THEN g.title END ASC,
           CASE WHEN $4::text = ''           THEN coalesce(vs.vote_average, 0) END DESC,
           g.created_at DESC, g.id DESC`,
		q, genre, players, sort)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []Game{}
	for rows.Next() {
		var g Game
		if err := rows.Scan(&g.ID, &g.Title, &g.Image, &g.Price, &g.Players,
			&g.Platform, &g.Genre, &g.Rating); err != nil {
			return nil, err
		}
		out = append(out, g)
	}
	return out, rows.Err()
}

// GameDetail คือเกมหนึ่งเรื่องพร้อมรายละเอียดและช่องทางดาวน์โหลด
type GameDetail struct {
	Game
	Description *string `json:"description"`
	DownloadURL *string `json:"downloadUrl"`
}

func (s *Store) GetGame(ctx context.Context, id int64) (GameDetail, error) {
	var g GameDetail
	err := s.Pool.QueryRow(ctx,
		`SELECT g.id, g.title, g.image_url, g.price::float8, g.players, g.platform,
                (SELECT coalesce(ge.name_th, ge.name_en) FROM game_genres gg
                   JOIN genres ge ON ge.id = gg.genre_id
                  WHERE gg.game_id = g.id AND gg.position = 0),
                coalesce(vs.vote_average, 0)::float8,
                g.description, g.download_url
         FROM games g
         LEFT JOIN game_vote_stats vs ON vs.game_id = g.id
         WHERE g.id = $1`, id).
		Scan(&g.ID, &g.Title, &g.Image, &g.Price, &g.Players, &g.Platform,
			&g.Genre, &g.Rating, &g.Description, &g.DownloadURL)
	if errors.Is(err, pgx.ErrNoRows) {
		return g, ErrNotFound
	}
	return g, err
}