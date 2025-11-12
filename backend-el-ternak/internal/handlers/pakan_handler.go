package handlers

import (
	"backend-el-ternak/internal/services"
	"backend-el-ternak/utils"
	"net/http"
)

func GetAllPakan(w http.ResponseWriter, r *http.Request){
	pakans, err := services.GetAllPakan()
	if err != nil {
		utils.RespondError(w, http.StatusNotFound, "gagal mengambil data pakan")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, "berhasil mengambil data pakan", pakans)
}

func GetSummaryOfPakan(w http.ResponseWriter, r *http.Request) {
	res, err := services.GetSummaryOfPakan()
	if err != nil {
		utils.RespondError(w, http.StatusInternalServerError, "gagal mengambil data")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, "berhasil mengambil data Pakan", res)
}

func GetDetailOfPakan(w http.ResponseWriter, r *http.Request) {
	nama := r.URL.Query().Get("nama")

	res, err := services.GetDetailOfPakan(nama)
	if err != nil {
		utils.RespondError(w, http.StatusInternalServerError, "gagal mengambil data Pakan")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, "berhasil mengambil data Pakan", res)
}