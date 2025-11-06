package handlers

import (
	"backend-el-ternak/internal/services"
	"backend-el-ternak/utils"
	"net/http"
)

func GetAllObat(w http.ResponseWriter, r *http.Request) {
	obats, err := services.GetAllObat()
	if err != nil {
		utils.RespondError(w, http.StatusInternalServerError, "gagal mengambil data obat")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, "berhasil mengambil data obat", obats)
}

func GetSummaryOfOvk(w http.ResponseWriter, r *http.Request) {
	res, err := services.GetSummaryOfOvk()
	if err != nil {
		utils.RespondError(w, http.StatusInternalServerError, "gagal mengambil data")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, "berhasil mengambil data OVK", res)
}

func GetDetailOfOvk(w http.ResponseWriter, r *http.Request) {
	nama := r.URL.Query().Get("nama")

	res, err := services.GetDetailOfOvk(nama)
	if err != nil {
		utils.RespondError(w, http.StatusInternalServerError, "gagal mengambil data OVK")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, "berhasil mengambil data OVK", res)
}