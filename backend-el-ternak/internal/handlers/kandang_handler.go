package handlers

import (
	"backend-el-ternak/internal/repository"
	services "backend-el-ternak/internal/services/kandang"
	"backend-el-ternak/utils"
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
)

type CreateKandangData struct {
	Nama string
	Kapasitas int
	IdPenanggungJawab []uint
}

func CreateKandang(w http.ResponseWriter, r *http.Request) {
	var data CreateKandangData
	if err := json.NewDecoder(r.Body).Decode(&data); err != nil {
		utils.RespondError(w, http.StatusBadRequest, "invalid request")
		return
	}

	fmt.Println(data.Kapasitas)

	err := services.CreateKandang(data.Nama, data.Kapasitas, data.IdPenanggungJawab)
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

func HandleKandangByID(w http.ResponseWriter, r *http.Request) {
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
		kandang, err := repository.GetKandangByID(uint(id))
		if err != nil {
			if err.Error() == "id kandang tidak ditemukan" {
				utils.RespondError(w, http.StatusNotFound, err.Error())
				return
			}
			utils.RespondError(w, http.StatusInternalServerError, "gagal mengambil data kandang")
			return
		}

		utils.RespondSuccess(w, http.StatusOK, "berhasil mengambil data kandang", kandang)

	case http.MethodDelete:
		err := repository.DeleteKandangByID(uint(id))
		if err != nil {
			if err.Error() == "id kandang tidak ditemukan" {
				utils.RespondError(w, http.StatusNotFound, err.Error())
				return
			}
			utils.RespondError(w, http.StatusInternalServerError, "gagal menghapus data kandang")
			return
		}

		utils.RespondSuccess(w, http.StatusOK, "berhasil menghapus data kandang", nil)
	
	case http.MethodPatch:
		var input map[string]interface{}
		if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
			utils.RespondError(w, http.StatusBadRequest, "invalid JSON body")
			return
		}
		fmt.Println(input)
		// return

		err := repository.UpdateKandangByID(id, input)
		if err != nil {
			if err.Error() == "not found" {
				utils.RespondError(w, http.StatusNotFound, "id kandang tidak ditemukan")
				return
			}
			utils.RespondError(w, http.StatusBadRequest, "gagal mengupdate data kandang")
			return
		}

		utils.RespondSuccess(w, http.StatusOK, "berhasil update data kandang", nil)

	default:
		utils.RespondError(w, http.StatusMethodNotAllowed, "method tidak diizinkan")
	}
}