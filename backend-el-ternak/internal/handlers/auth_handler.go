package handlers

import (
	"backend-el-ternak/internal/services/user"
	"backend-el-ternak/pkg"
	"backend-el-ternak/utils"
	"encoding/json"
	"errors"
	"net/http"
)

type AuthRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type UserContext struct {
	Username string
	Role string
}

func Register(w http.ResponseWriter, r *http.Request) {
	var req AuthRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		utils.RespondError(w, http.StatusBadRequest, "invalid request")
		return
	}

	err := services.RegisterUser(req.Username, req.Password)
	if err != nil {
		if errors.Is(err, services.ErrUserExists){
			utils.RespondError(w, http.StatusConflict, "username telah terdaftar")
			return
		}
		utils.RespondError(w, http.StatusInternalServerError, "register user gagal")
		return
	}

	utils.RespondSuccess(w, http.StatusCreated, "register user berhasil", nil)
}

func Login(w http.ResponseWriter, r *http.Request){
	var req AuthRequest

	// bad request
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		utils.RespondError(w, http.StatusBadRequest, "invalid request")
		return
	}

	// wrong credentials
	user, err := services.LoginUser(req.Username, req.Password)
	if err != nil {
		utils.RespondError(w, http.StatusUnauthorized, "invalid credentials")
		return
	}

	if !user.IsActive {
		utils.RespondError(w, http.StatusForbidden, "account status is inactive")
		return
	}

	// generate JWT token
	token, err := pkg.GenerateJWT(int(user.ID), user.Username, user.Role)
	if err != nil {
		utils.RespondError(w, http.StatusInternalServerError, "gagal membuat token")
		return
	}

	data := map[string]string{
		"token": token,
		"role": user.Role,
	}

	utils.RespondSuccess(w, http.StatusOK, "Login Berhasil", data)
}