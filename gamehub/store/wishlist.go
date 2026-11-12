package store

import (
	"context"
	"errors"
	"time"

	"github.com/jackc/pgx/v5/pgconn"
)

type WishlistItem struct {
	Game
	Note    *string   `json:"note"`
	AddedAt time.Time `json:"addedAt"`
}

func (s *Store) ListWishlist(ctx context.Context, memberID int64) ([]WishlistItem, error) {
	rows, err := s.Pool.Query(ctx,
		`SELECT g.id, g.title, g.image_url, g.price::float8, g.players, g.platform,
                (SELECT coalesce(ge.name_th, ge.name_en) FROM game_genres gg
                   JOIN genres ge ON ge.id = gg.genre_id
                  WHERE gg.game_id = g.id AND gg.position = 0),
                coalesce(vs.vote_average, 0)::float8,
                w.note, w.added_at
         FROM wishlist_items w
         JOIN games g ON g.id = w.game_id
         LEFT JOIN game_vote_stats vs ON vs.game_id = g.id
         WHERE w.member_id = $1
         ORDER BY w.added_at DESC`, memberID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []WishlistItem{}
	for rows.Next() {
		var it WishlistItem
		if err := rows.Scan(&it.ID, &it.Title, &it.Image, &it.Price, &it.Players,
			&it.Platform, &it.Genre, &it.Rating, &it.Note, &it.AddedAt); err != nil {
			return nil, err
		}
		out = append(out, it)
	}
	return out, rows.Err()
}

// AddWishlist เพิ่มเกม ถ้ามีอยู่แล้วแค่อัปเดตโน้ต ไม่มีเกมนี้ตอบ ErrNotFound
func (s *Store) AddWishlist(ctx context.Context, memberID, gameID int64, note *string) error {
	_, err := s.Pool.Exec(ctx,
		`INSERT INTO wishlist_items (member_id, game_id, note) VALUES ($1, $2, $3)
         ON CONFLICT (member_id, game_id) DO UPDATE SET note = EXCLUDED.note`,
		memberID, gameID, note)
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) && pgErr.Code == "23503" {
		return ErrNotFound
	}
	return err
}

func (s *Store) RemoveWishlist(ctx context.Context, memberID, gameID int64) error {
	tag, err := s.Pool.Exec(ctx,
		`DELETE FROM wishlist_items WHERE member_id = $1 AND game_id = $2`, memberID, gameID)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}