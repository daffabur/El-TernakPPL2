package handlers

import (
	"backend-el-ternak/internal/repository"
	services "backend-el-ternak/internal/services/transaksi"
	"backend-el-ternak/utils"
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/gorilla/mux"
)

type CreateTransaksiData struct{
	Nama string
	Jenis string
	Kategori string
	Tanggal string
	Nominal int
	Jumlah int
	Catatan string
	Bukti_transaksi string
	Total int
}

func CreateTransaksi(w http.ResponseWriter, r *http.Request) {
	var data CreateTransaksiData
	if err := json.NewDecoder(r.Body).Decode(&data); err != nil {
		utils.RespondError(w, http.StatusBadRequest, "invalid request")
		return
	}

	parsedDate, err := time.Parse(time.RFC3339, data.Tanggal)
	fmt.Println(parsedDate)

	if err != nil {
		utils.RespondError(w, http.StatusBadRequest, "invalid time format")
		return
	}

	err = services.CreateTransaksi(data.Nama, data.Jenis, data.Kategori, parsedDate, data.Nominal, data.Jumlah, data.Catatan, data.Bukti_transaksi, data.Total)

	if err != nil {
		utils.RespondError(w, http.StatusInternalServerError, "internal server error")
		return
	}

	utils.RespondSuccess(w, http.StatusCreated, "berhasil membuat transaksi", nil)
}

func GetAllTransaksi(w http.ResponseWriter, r *http.Request){
	transaksis, err := services.GetAllTransaksi()
	if err != nil {
		utils.RespondError(w, http.StatusInternalServerError, "gagal mengambil data semua transaksi")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, "berhasil mengambil data semua transaksi", transaksis)
}

func HandleTransaksiByID(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]

	idUint, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		utils.RespondError(w, http.StatusBadRequest, "invalid request")
		return
	}

	id := uint(idUint)

	switch r.Method {
	case http.MethodGet:
		transaksi, err := repository.GetTransaksiByID(uint(id))
		if err != nil {
			if err.Error() == "id transaksi tidak ditemukan" {
				utils.RespondError(w, http.StatusNotFound, err.Error())
				return
			}
			utils.RespondError(w, http.StatusInternalServerError, "gagal mengambil data transaksi")
			return
		}

		utils.RespondSuccess(w, http.StatusOK, "berhasil mengambil data transaksi", transaksi)

	case http.MethodDelete:
		err := repository.DeleteTransaksiByID(uint(id))
		if err != nil {
			if err.Error() == "id transaksi tidak ditemukan" {
				utils.RespondError(w, http.StatusNotFound, err.Error())
				return
			}
			utils.RespondError(w, http.StatusInternalServerError, "gagal menghapus data transaksi")
			return
		}

		utils.RespondSuccess(w, http.StatusOK, "berhasil menghapus data transaksi", nil)

	default:
		utils.RespondError(w, http.StatusMethodNotAllowed, "method tidak diizinkan")
	}
}

func GetTransaksiSummary(w http.ResponseWriter, r *http.Request) {
	fmt.Println("sampe ke sini kok di handler summary")
	summary, err := services.GetTransaksiSummary()
	if err != nil {
		utils.RespondError(w, http.StatusInternalServerError, "gagal mengambil data summary transaksi")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, "berhasil mengambil data summary transaksi", summary)
}

func GetTransaksiFiltered(w http.ResponseWriter, r *http.Request) {
	periode := r.URL.Query().Get("periode")

	validPeriode := map[string]bool{
		"hari_ini" : true,
		"minggu_ini" : true,
		"bulan_ini" : true,
	}

	if !validPeriode[periode]{
		utils.RespondError(w, http.StatusBadRequest, "periode tidak valid")
		return
	}

	transaksis, err := services.GetTransaksiFiltered(periode)
	if err != nil {
		utils.RespondError(w, http.StatusInternalServerError, "gagal mengambil data transaksi")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, "berhasil mengambil data transaksi", transaksis)
}

func GetTransaksiGroupByJenis(w http.ResponseWriter, r *http.Request){
	vars := mux.Vars(r)
	jenis := vars["jenis"]

	validJenis := map[string]bool{
		"pengeluaran" : true,
		"pemasukan" : true,
	}

	if !validJenis[jenis]{
		utils.RespondError(w, http.StatusBadRequest, "jenis tidak valid")
		return
	}

	transaksis, err := services.GetTransaksiGroupByJenis(jenis)
	if err != nil {
		utils.RespondError(w, http.StatusBadRequest, "gagal mengambil data transaksi")
		return 
	}

	utils.RespondSuccess(w, http.StatusOK, "berhasil mengambil data transaksi", transaksis)
}

func GetTransaksiGroupByKategori(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	kategori := vars["kategori"]

	validKategori := map[string]bool{
		"solar" : true,
		"gaji" : true,
		"pakan" : true,
		"panen" : true,
	}

	if !validKategori[kategori]{
		utils.RespondError(w, http.StatusBadRequest, "kategori tidak valid")
		return
	}

	transaksis, err := services.GetTransaksiGroupByKategori(kategori)
	fmt.Println(err)
	if err != nil {
		utils.RespondError(w, http.StatusBadRequest, "gagal mengambil data transaksi")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, "berhasil mengambil data transaksi", transaksis)
}