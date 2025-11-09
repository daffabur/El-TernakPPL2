package handlers

import (
	"backend-el-ternak/internal/services"
	"backend-el-ternak/utils"
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
)

type CreateLaporanData struct {
	Created_by uint `json:"created_by"`
	KandangID uint `json:"kandang_id"`
	Ratabobot float32 `json:"rata_bobot_ayam"`
	Kematian int `json:"kematian_ayam"`
	Pakan int `json:"pakan_used"`
	Pakan_tipe string `json:"pakan_tipe"`
	Solar int `json:"solar_used"`
	Sekam int `json:"sekam_used"`
	Obat int `json:"obat_used"`
	Obat_tipe string `json:"obat_tipe"`
}

func CreateLaporan(w http.ResponseWriter, r *http.Request) {
	var data CreateLaporanData
	if err := json.NewDecoder(r.Body).Decode(&data); err != nil {
		utils.RespondError(w, http.StatusBadRequest,"invalid request")
		return
	}

	err := services.CreateLaporan(data.Created_by, data.KandangID, float32(data.Ratabobot), data.Kematian, data.Pakan, data.Solar, data.Sekam, data.Obat, data.Pakan_tipe, data.Obat_tipe)
	if err != nil {
		utils.RespondError(w, http.StatusBadRequest, "internal server error")
		return
	}

	utils.RespondSuccess(w, http.StatusCreated, "berhasil membuat laporan", nil)
}

func GetLaporanHandler(w http.ResponseWriter, r *http.Request) {
	kandang_idStr := r.URL.Query().Get("kandang")

	if kandang_idStr != "" {
		idUint, err := strconv.ParseUint(kandang_idStr, 10, 64)
		if err != nil {
			utils.RespondError(w, http.StatusBadRequest, "invalid request")
			return
		}

		id := uint(idUint)
		laporans, err := services.GetLaporanPerKandang(id)
		if err != nil {
			utils.RespondError(w, http.StatusInternalServerError, "gagal mengambil data laporan")
			return
		}

		utils.RespondSuccess(w, http.StatusOK, "berhasil mengambil data laporan", laporans)
		return
	}

	laporans, err := services.GetAllLaporan()
	if err != nil {
		utils.RespondError(w, http.StatusInternalServerError, "gagal mengambil data laporan")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, "berhasil mengambil data laporan", laporans)
}

func HandleLaporanByID(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]

	idUint, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		utils.RespondError(w, http.StatusBadRequest, "gagal menghapus laporan")
		return
	}

	id := uint(idUint)

	switch r.Method {
	case http.MethodGet:
		laporan, err := services.GetLaporanByID(id)
		if err != nil {
			utils.RespondError(w, http.StatusInternalServerError, "gagal mengambil data laporan")
			return
		}

		utils.RespondSuccess(w, http.StatusOK, "berhasil mengambil data laporan", laporan)
	case http.MethodDelete:
		err = services.DeleteLaporanByID(id)
		if err != nil {
			utils.RespondError(w, http.StatusInternalServerError, "gagal menghapus laporan")
			return
		}

		utils.RespondSuccess(w, http.StatusOK, "berhasil menghapus laporan", nil)
	case http.MethodPatch:
		var input map[string]interface{}
		if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
			utils.RespondError(w, http.StatusBadRequest, "invalid JSON body")
			return
		}

		err := services.UpdateLaporanByID(id, input)
		if err != nil {
			if err.Error() == "not found" {
				utils.RespondError(w, http.StatusNotFound, "id laporan tidak ditemukan")
				return
			}
			utils.RespondError(w, http.StatusBadRequest, "gagal mengupdate data laporan")
			return
		}

		utils.RespondSuccess(w, http.StatusOK, "berhasil update data laporan", nil)
	default:
		utils.RespondError(w, http.StatusMethodNotAllowed, "method tidak diizinkan")
	}
}

func GetLaporanFiltered(w http.ResponseWriter, r *http.Request) {
	periode := r.URL.Query().Get("periode")
	tanggal := r.URL.Query().Get("tanggal")

	validPeriode := map[string]bool{
		"hari_ini" : true,
		"minggu_ini" : true,
		"bulan_ini" : true,
		"per_hari" : true,
	}

	if !validPeriode[periode]{
		utils.RespondError(w, http.StatusBadRequest, "periode tidak valid")
		return
	}

	laporans, err := services.GetLaporanFiltered(periode, tanggal)
	if err != nil {
		utils.RespondError(w, http.StatusInternalServerError, "gagal mengambil data laporan")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, "berhasil mengambil data laporan", laporans)
}