package store

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
)

// Game ข้อมูลเกมที่ใช้แสดงในหน้ารายการเกม
type Game struct {
	ID       int64   `json:"id"`
	Title    string  `json:"title"`
	Image    *string `json:"image"`
	Price    float64 `json:"price"`
	Players  *string `json:"players"`
	Platform *string `json:"platform"`
	Genre    *string `json:"genre"`
	Rating   float64 `json:"rating"`

	IsFeatured bool `json:"isFeatured"`
	IsNew      bool `json:"isNew"`
	IsPopular  bool `json:"isPopular"`
}

// GameImages รูปปกและรูป Gallery
type GameImages struct {
	Cover   string   `json:"cover"`
	Gallery []string `json:"gallery"`
}

// DownloadLink ช่องทางดาวน์โหลดเกม
type DownloadLink struct {
	Platform string  `json:"platform"`
	Price    float64 `json:"price"`
	URL      string  `json:"url"`
}

// SearchGames ค้นหาและแสดงรายการเกม
func (s *Store) SearchGames(
	ctx context.Context,
	q, genre, players, sort string,
) ([]Game, error) {

	rows, err := s.Pool.Query(ctx, `
		SELECT
			g.id,
			g.title,
			g.cover_url,
			COALESCE((
				SELECT MIN(dl.price)
				FROM game_download_links dl
				WHERE dl.game_id = g.id
			), 0)::float8,
			g.players,
			(
				SELECT dl.platform
				FROM game_download_links dl
				WHERE dl.game_id = g.id
				ORDER BY dl.id
				LIMIT 1
			),
			(
				SELECT ge.name
				FROM game_genres gg
				JOIN genres ge ON ge.id = gg.genre_id
				WHERE gg.game_id = g.id
				ORDER BY gg.position
				LIMIT 1
			),
			COALESCE(vs.vote_average, 0)::float8,
			g.is_featured,
			g.is_new,
			g.is_popular
		FROM games g
		LEFT JOIN game_vote_stats vs ON vs.game_id = g.id
		WHERE lower(g.title) LIKE '%' || lower($1::text) || '%'
			AND (
				$2::text = ''
				OR EXISTS (
					SELECT 1
					FROM game_genres gg
					JOIN genres ge ON ge.id = gg.genre_id
					WHERE gg.game_id = g.id
						AND lower(ge.name) = lower($2::text)
				)
			)
			AND (
				$3::text = ''
				OR g.players ILIKE '%' || $3::text || '%'
				OR EXISTS (
					SELECT 1
					FROM game_player_types gpt
					JOIN player_types pt ON pt.id = gpt.player_type_id
					WHERE gpt.game_id = g.id
						AND pt.name ILIKE '%' || $3::text || '%'
				)
			)
		ORDER BY
			CASE WHEN $4::text = 'price_asc'
				THEN COALESCE((
					SELECT MIN(dl.price)
					FROM game_download_links dl
					WHERE dl.game_id = g.id
				), 0) END ASC,
			CASE WHEN $4::text = 'price_desc'
				THEN COALESCE((
					SELECT MIN(dl.price)
					FROM game_download_links dl
					WHERE dl.game_id = g.id
				), 0) END DESC,
			CASE WHEN $4::text = 'name'
				THEN g.title END ASC,
			CASE WHEN $4::text = ''
				THEN COALESCE(vs.vote_average, 0) END DESC,
			g.created_at DESC,
			g.id DESC
	`, q, genre, players, sort)

	if err != nil {
		return nil, err
	}
	defer rows.Close()

	out := []Game{}

	for rows.Next() {
		var g Game

		err := rows.Scan(
			&g.ID,
			&g.Title,
			&g.Image,
			&g.Price,
			&g.Players,
			&g.Platform,
			&g.Genre,
			&g.Rating,
			&g.IsFeatured,
			&g.IsNew,
			&g.IsPopular,
		)
		if err != nil {
			return nil, err
		}

		out = append(out, g)
	}

	return out, rows.Err()
}

// GameDetail ข้อมูลเกมพร้อมรายละเอียด รูปภาพ และช่องทางดาวน์โหลด
type GameDetail struct {
	Game

	Description   *string        `json:"description"`
	DownloadURL   *string        `json:"downloadUrl"`
	Images        GameImages     `json:"images"`
	DownloadLinks []DownloadLink `json:"downloadLinks"`
	Genres        []string       `json:"genres"`
	TypePlayer    []string       `json:"type_player"`
}

// GetGame ดึงรายละเอียดเกมตาม ID
func (s *Store) GetGame(ctx context.Context, id int64) (GameDetail, error) {
	var g GameDetail

	err := s.Pool.QueryRow(ctx, `
		SELECT
			g.id,
			g.title,
			g.cover_url,
			COALESCE((
				SELECT MIN(dl.price)
				FROM game_download_links dl
				WHERE dl.game_id = g.id
			), 0)::float8,
			g.players,
			(
				SELECT dl.platform
				FROM game_download_links dl
				WHERE dl.game_id = g.id
				ORDER BY dl.id
				LIMIT 1
			),
			(
				SELECT ge.name
				FROM game_genres gg
				JOIN genres ge ON ge.id = gg.genre_id
				WHERE gg.game_id = g.id
				ORDER BY gg.position
				LIMIT 1
			),
			COALESCE(vs.vote_average, 0)::float8,
			g.is_featured,
			g.is_new,
			g.is_popular,
			g.description
		FROM games g
		LEFT JOIN game_vote_stats vs ON vs.game_id = g.id
		WHERE g.id = $1
	`, id).Scan(
		&g.ID,
		&g.Title,
		&g.Image,
		&g.Price,
		&g.Players,
		&g.Platform,
		&g.Genre,
		&g.Rating,
		&g.IsFeatured,
		&g.IsNew,
		&g.IsPopular,
		&g.Description,
	)

	if errors.Is(err, pgx.ErrNoRows) {
		return g, ErrNotFound
	}
	if err != nil {
		return g, err
	}

	// กำหนดรูปปก
	if g.Image != nil {
		g.Images.Cover = *g.Image
	}
	g.Images.Gallery = []string{}

	// ดึงรูป Gallery
	imageRows, err := s.Pool.Query(ctx, `
		SELECT image_url
		FROM game_images
		WHERE game_id = $1
		ORDER BY position
	`, id)
	if err != nil {
		return g, err
	}

	for imageRows.Next() {
		var imageURL string
		if err := imageRows.Scan(&imageURL); err != nil {
			imageRows.Close()
			return g, err
		}
		g.Images.Gallery = append(g.Images.Gallery, imageURL)
	}

	err = imageRows.Err()
	imageRows.Close()
	if err != nil {
		return g, err
	}

	// ดึงช่องทางดาวน์โหลดทั้งหมด
	g.DownloadLinks = []DownloadLink{}

	linkRows, err := s.Pool.Query(ctx, `
		SELECT platform, price::float8, url
		FROM game_download_links
		WHERE game_id = $1
		ORDER BY id
	`, id)
	if err != nil {
		return g, err
	}

	for linkRows.Next() {
		var link DownloadLink

		if err := linkRows.Scan(
			&link.Platform,
			&link.Price,
			&link.URL,
		); err != nil {
			linkRows.Close()
			return g, err
		}

		g.DownloadLinks = append(g.DownloadLinks, link)
	}

	err = linkRows.Err()
	linkRows.Close()
	if err != nil {
		return g, err
	}

	// รักษา DownloadURL เดิมไว้เพื่อรองรับ Frontend เก่า
	if len(g.DownloadLinks) > 0 {
		url := g.DownloadLinks[0].URL
		g.DownloadURL = &url
	}

	// ดึงแนวเกมทั้งหมด
	g.Genres = []string{}

	genreRows, err := s.Pool.Query(ctx, `
		SELECT ge.name
		FROM game_genres gg
		JOIN genres ge ON ge.id = gg.genre_id
		WHERE gg.game_id = $1
		ORDER BY gg.position
	`, id)
	if err != nil {
		return g, err
	}

	for genreRows.Next() {
		var name string
		if err := genreRows.Scan(&name); err != nil {
			genreRows.Close()
			return g, err
		}
		g.Genres = append(g.Genres, name)
	}

	err = genreRows.Err()
	genreRows.Close()
	if err != nil {
		return g, err
	}

	// ดึงรูปแบบการเล่นทั้งหมด
	g.TypePlayer = []string{}

	playerRows, err := s.Pool.Query(ctx, `
		SELECT pt.name
		FROM game_player_types gpt
		JOIN player_types pt ON pt.id = gpt.player_type_id
		WHERE gpt.game_id = $1
		ORDER BY gpt.position
	`, id)
	if err != nil {
		return g, err
	}

	for playerRows.Next() {
		var name string
		if err := playerRows.Scan(&name); err != nil {
			playerRows.Close()
			return g, err
		}
		g.TypePlayer = append(g.TypePlayer, name)
	}

	err = playerRows.Err()
	playerRows.Close()
	if err != nil {
		return g, err
	}

	return g, nil
}
