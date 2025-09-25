package handlers

import (
	"backend-el-ternak/internal/repository"
	"backend-el-ternak/internal/services"
	"backend-el-ternak/utils"
	"encoding/json"
	"net/http"
	"strings"
)

func GetAllProfileData(w http.ResponseWriter, r *http.Request)  {
	users, err := services.GetAllProfileData()
	if err != nil {
		utils.RespondError(w, http.StatusInternalServerError, "failed to fetch")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, "berhasil mendapatkan data users", users)
}

func GetPegawaiData(w http.ResponseWriter, r *http.Request)  {
	users, err := repository.GetUserByRole("pegawai")
	if err != nil {
		utils.RespondError(w, http.StatusInternalServerError, "failed to fetch")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, "berhasil mendapatkan data pegawai", users)
}

func GetPetinggiData(w http.ResponseWriter, r *http.Request)  {
	users, err := repository.GetUserByRole("petinggi")
	if err != nil {
		utils.RespondError(w, http.StatusInternalServerError, "failed to fetch")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, "berhasil mendapatkan data petinggi", users)
}

func EditPegawai(w http.ResponseWriter, r *http.Request)  {
	var req struct {
		ID uint `json:"id"`
		Role string `json:"role"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		utils.RespondError(w, http.StatusInternalServerError, "failed update data")
		return
	}

	newRole := strings.ToLower(req.Role)
	if newRole != "pegawai" && newRole != "petinggi" {
		utils.RespondError(w, http.StatusBadRequest, "invalid role")
		return
	}

	newData := map[string]interface{}{
		"id" : req.ID,
		"role" : newRole,
	}

	err := services.UpdateUserById(req.ID, newData)
	if err != nil {
		if err.Error() == "not found" {
			utils.RespondError(w, http.StatusNotFound, "user tidak ditemukan")
			return
		}
		utils.RespondError(w, http.StatusInternalServerError, "failed change user data")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, "berhasil update data user", nil)
}

func DeletePegawai(w http.ResponseWriter, r *http.Request)  {
	var req struct {
		ID uint `json:"id"`
	}
	
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		utils.RespondError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	
	err := services.DeleteUserById(req.ID)
	if err != nil {
		if err.Error() == "not found" {
			utils.RespondError(w, http.StatusNotFound, "user tidak ditemukan")
			return
		}
		utils.RespondError(w, http.StatusInternalServerError, "failed to delete user")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, "berhasil menghapus data", nil)
}