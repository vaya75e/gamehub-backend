package handler

import (
	"encoding/json"
	"errors"
	"log"
	"net/http"
	"strconv"

	"moviehub/auth"
	"moviehub/store"
)

type Handler struct {
	Store   *store.Store
	Tickets *auth.Issuer
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(v)
}

func writeError(w http.ResponseWriter, status int, code, message string) {
	writeJSON(w, status, map[string]any{
		"error": map[string]string{"code": code, "message": message},
	})
}

func internal(w http.ResponseWriter, err error) {
	log.Printf("internal error: %v", err)
	writeError(w, http.StatusInternalServerError, "INTERNAL", "ระบบขัดข้อง ลองใหม่อีกครั้ง")
}

func pathID(r *http.Request, name string) (int64, bool) {
	id, err := strconv.ParseInt(r.PathValue(name), 10, 64)
	return id, err == nil && id > 0
}

// SearchGames รับ ?q= &genre= &players= &sort=
func (h *Handler) SearchGames(w http.ResponseWriter, r *http.Request) {
	qs := r.URL.Query()
	items, err := h.Store.SearchGames(r.Context(),
		qs.Get("q"), qs.Get("genre"), qs.Get("players"), qs.Get("sort"))
	if err != nil {
		internal(w, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"items": items})
}

func (h *Handler) GetGame(w http.ResponseWriter, r *http.Request) {
	id, ok := pathID(r, "id")
	if !ok {
		writeError(w, http.StatusBadRequest, "BAD_ID", "เลขเกมต้องเป็นตัวเลข")
		return
	}
	g, err := h.Store.GetGame(r.Context(), id)
	switch {
	case errors.Is(err, store.ErrNotFound):
		writeError(w, http.StatusNotFound, "GAME_NOT_FOUND", "ไม่พบเกมนี้")
		return
	case err != nil:
		internal(w, err)
		return
	}
	writeJSON(w, http.StatusOK, g)
}

func (h *Handler) ListReviews(w http.ResponseWriter, r *http.Request) {
	gameID, ok := pathID(r, "id")
	if !ok {
		writeError(w, http.StatusBadRequest, "BAD_ID", "เลขเกมต้องเป็นตัวเลข")
		return
	}
	items, err := h.Store.ListReviews(r.Context(), gameID)
	if err != nil {
		internal(w, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"items": items})
}