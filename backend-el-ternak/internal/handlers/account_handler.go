package handlers

import (
	"backend-el-ternak/internal/middleware"
	"backend-el-ternak/internal/services"
	"backend-el-ternak/utils"
	"net/http"
)

type UserProfile struct {
	ID int
	Username string
	Role string
}

func Profile(w http.ResponseWriter, r *http.Request){
	userCtx, ok := r.Context().Value("user").(middleware.UserContext)
	if !ok {
		utils.RespondError(w, http.StatusUnauthorized, "invalid context")
		return
	}

	user, err := services.GetUserProfile(userCtx.ID)
	if err != nil {
		utils.RespondError(w, http.StatusNotFound, "user not found")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, "Berhasil mendapatkan profile anda", user)
}

//dummy dashboard
func Dashboard(w http.ResponseWriter, r *http.Request) {
	userCtx, ok := r.Context().Value("user").(middleware.UserContext)
	if !ok {
		utils.RespondError(w, http.StatusUnauthorized, "invalid context")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, "Welcome you have access to dashboard, "+userCtx.Username, nil)
}