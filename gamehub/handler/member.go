package handler

import (
	"encoding/json"
	"errors"
	"net/http"
	"strings"
	"unicode/utf8"

	"gamehub/auth"
	"gamehub/mw"
	"gamehub/store"
)

type updateMeReq struct {
	DisplayName string `json:"displayName"`
}

// UpdateMe แก้ชื่อที่แสดง (Profile)
func (h *Handler) UpdateMe(w http.ResponseWriter, r *http.Request) {
	id, _ := mw.MemberID(r.Context())
	var req updateMeReq
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "BAD_JSON", "อ่านกล่อง JSON ไม่ออก")
		return
	}
	name := strings.TrimSpace(req.DisplayName)
	if name == "" || utf8.RuneCountInString(name) > 50 {
		writeError(w, http.StatusBadRequest, "BAD_NAME", "ต้องมีชื่อที่แสดง และยาวไม่เกิน 50 ตัวอักษร")
		return
	}
	if err := h.Store.UpdateMemberName(r.Context(), id, name); err != nil {
		if errors.Is(err, store.ErrNotFound) {
			writeError(w, http.StatusUnauthorized, "MEMBER_GONE", "ไม่พบบัญชีนี้แล้ว กรุณาเข้าสู่ระบบใหม่")
			return
		}
		internal(w, err)
		return
	}
	m, err := h.Store.MemberByID(r.Context(), id)
	if err != nil {
		internal(w, err)
		return
	}
	writeJSON(w, http.StatusOK, m)
}

type changePasswordReq struct {
	CurrentPassword string `json:"currentPassword"`
	NewPassword     string `json:"newPassword"`
}

// ChangePassword เปลี่ยนรหัสผ่าน ต้องยืนยันรหัสเดิมก่อน
func (h *Handler) ChangePassword(w http.ResponseWriter, r *http.Request) {
	id, _ := mw.MemberID(r.Context())
	var req changePasswordReq
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "BAD_JSON", "อ่านกล่อง JSON ไม่ออก")
		return
	}
	if utf8.RuneCountInString(req.NewPassword) < 8 || len(req.NewPassword) > 72 {
		writeError(w, http.StatusBadRequest, "BAD_PASSWORD", "รหัสผ่านใหม่ต้องยาว 8 ตัวอักษรขึ้นไป และไม่เกิน 72 ไบต์")
		return
	}
	hash, err := h.Store.PasswordHashByID(r.Context(), id)
	if errors.Is(err, store.ErrNotFound) {
		writeError(w, http.StatusUnauthorized, "MEMBER_GONE", "ไม่พบบัญชีนี้แล้ว กรุณาเข้าสู่ระบบใหม่")
		return
	}
	if err != nil {
		internal(w, err)
		return
	}
	if !auth.CheckPassword(hash, req.CurrentPassword) {
		writeError(w, http.StatusBadRequest, "BAD_CURRENT_PASSWORD", "รหัสผ่านปัจจุบันไม่ถูกต้อง")
		return
	}
	newHash, err := auth.HashPassword(req.NewPassword)
	if err != nil {
		internal(w, err)
		return
	}
	if err := h.Store.UpdateMemberPassword(r.Context(), id, newHash); err != nil {
		internal(w, err)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}
