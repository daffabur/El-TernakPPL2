package handlers

import (
	"backend-el-ternak/internal/services/storage"
	"backend-el-ternak/utils"
	"net/http"
)

func GetCurrentStock(w http.ResponseWriter, r *http.Request) {
	stocks, err := services.GetCurrentStock()
	if err != nil {
		utils.RespondError(w, http.StatusInternalServerError, "gagal mengambil data stock storage")
		return
	}
	utils.RespondSuccess(w, http.StatusOK, "berhasil mengambil data stock storage", stocks)
}