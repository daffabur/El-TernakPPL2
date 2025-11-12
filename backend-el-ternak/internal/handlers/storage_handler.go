package handlers

import (
	"backend-el-ternak/internal/services"
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

func CheckPakanStock(w http.ResponseWriter, r * http.Request) {
	status, err := services.CheckPakanStock()
	if err != nil {
		utils.RespondError(w, http.StatusInternalServerError, "gagal check pakan stock")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, "berhasil check stock storage", status)
}

func GetYearlyReport(w http.ResponseWriter, r *http.Request) {
	tahun := r.URL.Query().Get("tahun")
	reports, err := services.GetYearlyReport(tahun)

	if err != nil {
		utils.RespondError(w, http.StatusInternalServerError, "gagal mengambil data tahunan")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, "berhasil mengambil data tahunan", reports)
}