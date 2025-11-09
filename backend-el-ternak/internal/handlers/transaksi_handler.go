package handlers

import (
	"backend-el-ternak/internal/repository"
	"backend-el-ternak/internal/services"
	"backend-el-ternak/utils"
	"context"
	"fmt"
	"log"
	"net/http"
	"path/filepath"
	"strconv"
	"time"

	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/google/uuid"
	"github.com/gorilla/mux"
)

type CreateTransaksiData struct{
	Nama string
	Jenis string
	Kategori string
	Tipe *string
	Tanggal string
	Nominal int
	Jumlah int
	Catatan string
	Bukti_transaksi string
	Total int
}

func CreateTransaksi(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseMultipartForm(5 << 20); err != nil {
		utils.RespondError(w, http.StatusBadRequest, "invalid request: could not parse form")
		return
	}

	file, header, err := r.FormFile("bukti_transaksi")
	var buktiTransaksiURL string = "" 

	if err == nil {
		defer file.Close()

		ext := filepath.Ext(header.Filename)
		fileName := fmt.Sprintf("%s%s", uuid.NewString(), ext)
		contentType := header.Header.Get("Content-Type")
		_, err = s3Client.PutObject(context.TODO(), &s3.PutObjectInput{
			Bucket:      &bucketName,
			Key:         &fileName,
			Body:        file,
			ContentType: &contentType,
		})

		if err != nil {
			log.Printf("Failed to upload to S3: %v", err)
			utils.RespondError(w, http.StatusInternalServerError, "failed to upload file")
			return
		}

		buktiTransaksiURL = fmt.Sprintf("https://%s.s3.%s.amazonaws.com/%s", bucketName, awsRegion, fileName)
	} else if err != http.ErrMissingFile {
		utils.RespondError(w, http.StatusBadRequest, "invalid file upload: "+err.Error())
		return
	}

	nama := r.FormValue("nama")
	jenis := r.FormValue("jenis")
	kategori := r.FormValue("kategori")
	tipe := r.FormValue("tipe")
	tanggalStr := r.FormValue("tanggal")
	nominalStr := r.FormValue("nominal")
	jumlahStr := r.FormValue("jumlah")
	catatan := r.FormValue("catatan")
	totalStr := r.FormValue("total")

	parsedDate, err := time.Parse(time.RFC3339, tanggalStr)
	if err != nil {
		utils.RespondError(w, http.StatusBadRequest, "invalid time format, must be RFC3339: "+tanggalStr)
		return
	}

	nominal, err := strconv.Atoi(nominalStr)
	if err != nil {
		utils.RespondError(w, http.StatusBadRequest, "invalid format for Nominal")
		return
	}

	jumlah, err := strconv.Atoi(jumlahStr)
	if err != nil {
		utils.RespondError(w, http.StatusBadRequest, "invalid format for Jumlah")
		return
	}

	total, err := strconv.Atoi(totalStr)
	if err != nil {
		utils.RespondError(w, http.StatusBadRequest, "invalid format for Total")
		return
	}

	err = services.CreateTransaksi(
		nama,
		jenis,
		kategori,
		&tipe,
		parsedDate,
		nominal,
		jumlah,
		catatan,
		buktiTransaksiURL,
		total,
	)

	if err != nil {
		utils.RespondError(w, http.StatusInternalServerError, "internal server error: "+err.Error())
		return
	}

	responseData := map[string]interface{}{
	"bukti_transaksi_url": buktiTransaksiURL,
	}

	utils.RespondSuccess(w, http.StatusCreated, "berhasil membuat transaksi", responseData)
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

	transaksis, err := services.GetTransaksiFiltered(periode, tanggal)
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