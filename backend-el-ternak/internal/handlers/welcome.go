package handlers

import (
	"backend-el-ternak/utils"
	"net/http"
)

func WelcomeMsg(w http.ResponseWriter, r *http.Request)  {
	utils.RespondSuccess(w, http.StatusOK, "Hi from El-Ternak backend!", nil)
}