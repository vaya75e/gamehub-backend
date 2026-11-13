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

// ทุก handler ในไฟล์นี้ถูกครอบด้วย RequireLogin + RequireRole("admin") ใน main.go แล้ว

func (h *Handler) AdminStats(w http.ResponseWriter, r *http.Request) {
	st, err := h.Store.Stats(r.Context())
	if err != nil {
		internal(w, err)
		return
	}
	writeJSON(w, http.StatusOK, st)
}

func (h *Handler) AdminMembers(w http.ResponseWriter, r *http.Request) {
	items, err := h.Store.ListMembers(r.Context())
	if err != nil {
		internal(w, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"items": items})
}

type roleReq struct {
	Role string `json:"role"`
}

func (h *Handler) AdminSetRole(w http.ResponseWriter, r *http.Request) {
	id, ok := pathID(r, "id")
	if !ok {
		writeError(w, http.StatusBadRequest, "BAD_ID", "เลขสมาชิกต้องเป็นตัวเลข")
		return
	}
	var req roleReq
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "BAD_JSON", "อ่านกล่อง JSON ไม่ออก")
		return
	}
	if req.Role != "member" && req.Role != "admin" {
		writeError(w, http.StatusBadRequest, "BAD_ROLE", "role ต้องเป็น member หรือ admin")
		return
	}
	if me, _ := mw.MemberID(r.Context()); me == id {
		writeError(w, http.StatusBadRequest, "SELF_ROLE", "เปลี่ยนบทบาทของตัวเองไม่ได้ ให้ admin คนอื่นทำแทน")
		return
	}
	m, err := h.Store.UpdateMemberRole(r.Context(), id, req.Role)
	if errors.Is(err, store.ErrNotFound) {
		writeError(w, http.StatusNotFound, "MEMBER_NOT_FOUND", "ไม่พบสมาชิกคนนี้")
		return
	}
	if err != nil {
		internal(w, err)
		return
	}
	writeJSON(w, http.StatusOK, m)
}

func (h *Handler) Genres(w http.ResponseWriter, r *http.Request) {
	items, err := h.Store.ListGenres(r.Context())
	if err != nil {
		internal(w, err)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"items": items})
}

// ---------- เกม ----------

func trimPtr(p *string) *string {
	if p == nil {
		return nil
	}
	s := strings.TrimSpace(*p)
	if s == "" {
		return nil
	}
	return &s
}

// validateGame ตรวจฝั่ง server ซ้ำอีกชั้น เพราะ curl ไม่ผ่านฟอร์ม
func validateGame(in *store.GameInput) (code, message string) {
	in.Title = strings.TrimSpace(in.Title)
	in.ImageURL = trimPtr(in.ImageURL)
	in.Description = trimPtr(in.Description)
	in.Players = trimPtr(in.Players)
	in.DownloadURL = trimPtr(in.DownloadURL)
	in.Platform = trimPtr(in.Platform)

	if in.Title == "" || utf8.RuneCountInString(in.Title) > 255 {
		return "BAD_TITLE", "ต้องมีชื่อเกม และยาวไม่เกิน 255 ตัวอักษร"
	}
	if in.Price < 0 {
		return "BAD_PRICE", "ราคาต้องไม่ติดลบ (0 = ฟรี)"
	}
	if in.ImageURL != nil && !strings.HasPrefix(*in.ImageURL, "http") {
		return "BAD_IMAGE", "รูปเกมต้องเป็น URL เต็ม (https://...)"
	}
	if in.DownloadURL != nil && !strings.HasPrefix(*in.DownloadURL, "http") {
		return "BAD_DOWNLOAD", "ช่องทางดาวน์โหลดต้องเป็น URL เต็ม (https://...)"
	}
	return "", ""
}

func (h *Handler) AdminGetGame(w http.ResponseWriter, r *http.Request) {
	id, ok := pathID(r, "id")
	if !ok {
		writeError(w, http.StatusBadRequest, "BAD_ID", "เลขเกมต้องเป็นตัวเลข")
		return
	}
	g, err := h.Store.AdminGetGame(r.Context(), id)
	if errors.Is(err, store.ErrNotFound) {
		writeError(w, http.StatusNotFound, "GAME_NOT_FOUND", "ไม่พบเกมนี้")
		return
	}
	if err != nil {
		internal(w, err)
		return
	}
	writeJSON(w, http.StatusOK, g)
}

func (h *Handler) AdminCreateGame(w http.ResponseWriter, r *http.Request) {
	var in store.GameInput
	if err := json.NewDecoder(r.Body).Decode(&in); err != nil {
		writeError(w, http.StatusBadRequest, "BAD_JSON", "อ่านกล่อง JSON ไม่ออก")
		return
	}
	if code, msg := validateGame(&in); code != "" {
		writeError(w, http.StatusBadRequest, code, msg)
		return
	}
	g, err := h.Store.CreateGame(r.Context(), in)
	switch {
	case errors.Is(err, store.ErrBadGenre):
		writeError(w, http.StatusBadRequest, "BAD_GENRE", "ไม่มีแนวเกมรหัสนี้")
		return
	case err != nil:
		internal(w, err)
		return
	}
	writeJSON(w, http.StatusCreated, g)
}

func (h *Handler) AdminUpdateGame(w http.ResponseWriter, r *http.Request) {
	id, ok := pathID(r, "id")
	if !ok {
		writeError(w, http.StatusBadRequest, "BAD_ID", "เลขเกมต้องเป็นตัวเลข")
		return
	}
	var in store.GameInput
	if err := json.NewDecoder(r.Body).Decode(&in); err != nil {
		writeError(w, http.StatusBadRequest, "BAD_JSON", "อ่านกล่อง JSON ไม่ออก")
		return
	}
	if code, msg := validateGame(&in); code != "" {
		writeError(w, http.StatusBadRequest, code, msg)
		return
	}
	g, err := h.Store.UpdateGame(r.Context(), id, in)
	switch {
	case errors.Is(err, store.ErrNotFound):
		writeError(w, http.StatusNotFound, "GAME_NOT_FOUND", "ไม่พบเกมนี้")
		return
	case errors.Is(err, store.ErrBadGenre):
		writeError(w, http.StatusBadRequest, "BAD_GENRE", "ไม่มีแนวเกมรหัสนี้")
		return
	case err != nil:
		internal(w, err)
		return
	}
	writeJSON(w, http.StatusOK, g)
}

func (h *Handler) AdminDeleteGame(w http.ResponseWriter, r *http.Request) {
	id, ok := pathID(r, "id")
	if !ok {
		writeError(w, http.StatusBadRequest, "BAD_ID", "เลขเกมต้องเป็นตัวเลข")
		return
	}
	err := h.Store.DeleteGame(r.Context(), id)
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
