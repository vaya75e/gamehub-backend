package handler

import (
	"encoding/json"
	"errors"
	"net/http"
	"unicode/utf8"

	"gamehub/mw"
	"gamehub/store"
)

func (h *Handler) ListWishlist(w http.ResponseWriter, r *http.Request) {
	id, _ := mw.MemberID(r.Context())
	items, err := h.Store.ListWishlist(r.Context(), id)
	if err != nil {
		internal(w, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"items": items})
}

type wishlistReq struct {
	GameID int64   `json:"gameId"`
	Note   *string `json:"note"`
}

func (h *Handler) AddWishlist(w http.ResponseWriter, r *http.Request) {
	id, _ := mw.MemberID(r.Context())
	var req wishlistReq
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "BAD_JSON", "อ่านกล่อง JSON ไม่ออก")
		return
	}
	if req.GameID <= 0 {
		writeError(w, http.StatusBadRequest, "BAD_ID", "เลขเกมต้องเป็นตัวเลข")
		return
	}
	req.Note = trimPtr(req.Note)
	if req.Note != nil && utf8.RuneCountInString(*req.Note) > 200 {
		writeError(w, http.StatusBadRequest, "BAD_NOTE", "โน้ตยาวไม่เกิน 200 ตัวอักษร")
		return
	}
	err := h.Store.AddWishlist(r.Context(), id, req.GameID, req.Note)
	if errors.Is(err, store.ErrNotFound) {
		writeError(w, http.StatusNotFound, "GAME_NOT_FOUND", "ไม่พบเกมนี้")
		return
	}
	if err != nil {
		internal(w, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// RemoveWishlist: DELETE /api/wishlist/{id} โดย id คือเลขเกม
func (h *Handler) RemoveWishlist(w http.ResponseWriter, r *http.Request) {
	memberID, _ := mw.MemberID(r.Context())
	gameID, ok := pathID(r, "id")
	if !ok {
		writeError(w, http.StatusBadRequest, "BAD_ID", "เลขเกมต้องเป็นตัวเลข")
		return
	}
	err := h.Store.RemoveWishlist(r.Context(), memberID, gameID)
	if errors.Is(err, store.ErrNotFound) {
		writeError(w, http.StatusNotFound, "NOT_IN_WISHLIST", "เกมนี้ไม่ได้อยู่ในรายการโปรด")
		return
	}
	if err != nil {
		internal(w, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}
