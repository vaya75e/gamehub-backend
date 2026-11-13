package store

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
)

func (s *Store) UpdateMemberName(ctx context.Context, id int64, name string) error {
	tag, err := s.Pool.Exec(ctx,
		`UPDATE members SET display_name = $2, updated_at = now() WHERE id = $1`, id, name)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (s *Store) PasswordHashByID(ctx context.Context, id int64) (string, error) {
	var hash string
	err := s.Pool.QueryRow(ctx, `SELECT password_hash FROM members WHERE id = $1`, id).Scan(&hash)
	if errors.Is(err, pgx.ErrNoRows) {
		return "", ErrNotFound
	}
	return hash, err
}

func (s *Store) UpdateMemberPassword(ctx context.Context, id int64, hash string) error {
	tag, err := s.Pool.Exec(ctx,
		`UPDATE members SET password_hash = $2, updated_at = now() WHERE id = $1`, id, hash)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}
