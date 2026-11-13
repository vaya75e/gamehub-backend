package store

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5/pgconn"
)

type VoteResult struct {
	Score       int     `json:"score"`
	VoteCount   int64   `json:"voteCount"`
	VoteAverage float64 `json:"voteAverage"`
}

// Vote โหวตใหม่ = แก้คะแนนเดิม (upsert) แล้วคืนคะแนนเฉลี่ยล่าสุดของเกม
func (s *Store) Vote(ctx context.Context, memberID, gameID int64, score int) (VoteResult, error) {
	_, err := s.Pool.Exec(ctx,
		`INSERT INTO votes (member_id, game_id, score) VALUES ($1, $2, $3)
         ON CONFLICT (member_id, game_id) DO UPDATE SET score = EXCLUDED.score, updated_at = now()`,
		memberID, gameID, score)
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) && pgErr.Code == "23503" {
		return VoteResult{}, ErrNotFound
	}
	if err != nil {
		return VoteResult{}, err
	}
	res := VoteResult{Score: score}
	err = s.Pool.QueryRow(ctx,
		`SELECT vote_count, vote_average::float8 FROM game_vote_stats WHERE game_id = $1`, gameID).
		Scan(&res.VoteCount, &res.VoteAverage)
	return res, err
}
