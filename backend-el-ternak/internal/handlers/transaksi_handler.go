package handlers

import (
	services "backend-el-ternak/internal/services/transaksi"
	"backend-el-ternak/utils"
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
)

type CreateTransaksiData struct{
	Nama string
	Jenis string
	Kategori string
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

	err := services.CreateTransaksi(data.Nama, data.Jenis, data.Kategori, data.Nominal, data.Jumlah, data.Catatan, data.Bukti_transaksi, data.Total)

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

	utils.RespondSuccess(w, http.StatusOK, "berhasil mengambil data semua kandang", transaksis)
}

func GetTransaksiByID(w http.ResponseWriter, r *http.Request){
	vars := mux.Vars(r)
	idStr := vars["id"]

	idUint, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		utils.RespondError(w, http.StatusBadRequest, "invalid request")
		return
	}

	id := uint(idUint)

	transaksi, err := services.GetTransaksiByID(id)
	if err != nil {
		utils.RespondError(w, http.StatusInternalServerError, "id tidak ditemukan")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, "berhasil mengambil data transaksi", transaksi)
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