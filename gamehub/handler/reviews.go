package handler

import (
	"encoding/json"
	"errors"
	"net/http"
	"strings"
	"unicode/utf8"

	"gamehub/mw"
	"gamehub/store"
)

type reviewReq struct {
	Text string `json:"text"`
}

func (h *Handler) AddReview(w http.ResponseWriter, r *http.Request) {
	memberID, _ := mw.MemberID(r.Context())
	gameID, ok := pathID(r, "id")
	if !ok {
		writeError(w, http.StatusBadRequest, "BAD_ID", "เลขเกมต้องเป็นตัวเลข")
		return
	}
	var req reviewReq
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "BAD_JSON", "อ่านกล่อง JSON ไม่ออก")
		return
	}
	text := strings.TrimSpace(req.Text)
	if utf8.RuneCountInString(text) < 10 || utf8.RuneCountInString(text) > 2000 {
		writeError(w, http.StatusBadRequest, "BAD_TEXT", "รีวิวต้องยาว 10-2000 ตัวอักษร")
		return
	}
	rev, err := h.Store.SaveReview(r.Context(), memberID, gameID, text)
	if errors.Is(err, store.ErrNotFound) {
		writeError(w, http.StatusNotFound, "GAME_NOT_FOUND", "ไม่พบเกมนี้")
		return
	}
	if err != nil {
		internal(w, err)
		return
	}
	writeJSON(w, http.StatusCreated, rev)
}

func (h *Handler) DeleteReview(w http.ResponseWriter, r *http.Request) {
	memberID, _ := mw.MemberID(r.Context())
	reviewID, ok := pathID(r, "id")
	if !ok {
		writeError(w, http.StatusBadRequest, "BAD_ID", "เลขรีวิวต้องเป็นตัวเลข")
		return
	}
	err := h.Store.DeleteReview(r.Context(), reviewID, memberID, mw.Role(r.Context()) == "admin")
	switch {
	case errors.Is(err, store.ErrNotFound):
		writeError(w, http.StatusNotFound, "REVIEW_NOT_FOUND", "ไม่พบรีวิวนี้")
		return
	case errors.Is(err, store.ErrForbidden):
		writeError(w, http.StatusForbidden, "FORBIDDEN", "ลบได้เฉพาะรีวิวของตัวเอง")
		return
	case err != nil:
		internal(w, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

type voteReq struct {
	Score int `json:"score"`
}

func (h *Handler) VoteGame(w http.ResponseWriter, r *http.Request) {
	memberID, _ := mw.MemberID(r.Context())
	gameID, ok := pathID(r, "id")
	if !ok {
		writeError(w, http.StatusBadRequest, "BAD_ID", "เลขเกมต้องเป็นตัวเลข")
		return
	}
	var req voteReq
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "BAD_JSON", "อ่านกล่อง JSON ไม่ออก")
		return
	}
	if req.Score < 1 || req.Score > 10 {
		writeError(w, http.StatusBadRequest, "BAD_SCORE", "คะแนนต้องอยู่ระหว่าง 1-10")
		return
	}
	res, err := h.Store.Vote(r.Context(), memberID, gameID, req.Score)
	if errors.Is(err, store.ErrNotFound) {
		writeError(w, http.StatusNotFound, "GAME_NOT_FOUND", "ไม่พบเกมนี้")
		return
	}
	if err != nil {
		internal(w, err)
		return
	}
	writeJSON(w, http.StatusOK, res)
}