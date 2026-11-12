package store

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
)

var ErrForbidden = errors.New("forbidden")

// SaveReview สมาชิก 1 คนรีวิวเกม 1 เรื่องได้ 1 ครั้ง เขียนซ้ำ = แก้ข้อความเดิม
func (s *Store) SaveReview(ctx context.Context, memberID, gameID int64, text string) (Review, error) {
	var id int64
	err := s.Pool.QueryRow(ctx,
		`INSERT INTO reviews (member_id, game_id, text) VALUES ($1, $2, $3)
         ON CONFLICT (member_id, game_id) DO UPDATE SET text = EXCLUDED.text, updated_at = now()
         RETURNING id`, memberID, gameID, text).Scan(&id)
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) && pgErr.Code == "23503" {
		return Review{}, ErrNotFound
	}
	if err != nil {
		return Review{}, err
	}
	var r Review
	err = s.Pool.QueryRow(ctx,
		`SELECT r.id, r.member_id, r.game_id, r.text, r.created_at, r.updated_at,
                m.display_name, v.score
         FROM reviews r
         JOIN members m ON m.id = r.member_id
         LEFT JOIN votes v ON v.member_id = r.member_id AND v.game_id = r.game_id
         WHERE r.id = $1`, id).
		Scan(&r.ID, &r.MemberID, &r.GameID, &r.Text, &r.CreatedAt, &r.UpdatedAt,
			&r.Member.DisplayName, &r.Score)
	r.Member.ID = r.MemberID
	return r, err
}

// DeleteReview เจ้าของรีวิวลบได้ และ admin ลบของใครก็ได้
func (s *Store) DeleteReview(ctx context.Context, reviewID, memberID int64, isAdmin bool) error {
	var owner int64
	err := s.Pool.QueryRow(ctx, `SELECT member_id FROM reviews WHERE id = $1`, reviewID).Scan(&owner)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	if err != nil {
		return err
	}
	if owner != memberID && !isAdmin {
		return ErrForbidden
	}
	_, err = s.Pool.Exec(ctx, `DELETE FROM reviews WHERE id = $1`, reviewID)
	return err
}