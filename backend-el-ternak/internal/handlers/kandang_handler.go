package handlers

import (
	services "backend-el-ternak/internal/services/kandang"
	"backend-el-ternak/utils"
	"encoding/json"
	"fmt"
	"net/http"
)

type CreateKandangData struct {
	Nama string
	JumlahAyam int
	IdPenanggungJawab []uint
}

func CreateKandang(w http.ResponseWriter, r *http.Request) {
	var data CreateKandangData
	if err := json.NewDecoder(r.Body).Decode(&data); err != nil {
		utils.RespondError(w, http.StatusBadRequest, "invalid request")
		return
	}

	fmt.Println(data.JumlahAyam)

	err := services.CreateKandang(data.Nama, data.JumlahAyam, data.IdPenanggungJawab)
	if err != nil {
		utils.RespondError(w, http.StatusInternalServerError, "internal server error")
		return
	}

	utils.RespondSuccess(w, http.StatusCreated, "berhasil membuat kandang", nil)
}

func GetAllKandang(w http.ResponseWriter, r *http.Request)  {
	kandangs, err := services.GetAllKandangData()
	if err != nil {
		utils.RespondError(w, http.StatusInternalServerError, "gagal mengambil data semua kandang")
		return
	}
	
	utils.RespondSuccess(w, http.StatusOK, "Berhasil mengambil data semua kandang", kandangs)
}

//future work
func GetKandangByID(w http.ResponseWriter, r *http.Response) {

}