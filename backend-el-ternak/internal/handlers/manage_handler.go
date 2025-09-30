package handlers

import (
	"backend-el-ternak/internal/repository"
	"backend-el-ternak/internal/services/user"
	"backend-el-ternak/utils"
	"encoding/json"
	"errors"
	"fmt"
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

func CreateUser(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Username string `json:"username"`
		Password string `json:"password"`
		Role string `json:"role"`
		IsActive bool `json:"isActive"`
		KandangID *uint `json:"kandangID"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		utils.RespondError(w, http.StatusBadRequest, "invalid request")
		return
	}

	//handler role
	newRole := strings.ToLower(req.Role)
	if newRole != "petinggi" && newRole != "pegawai" {
		utils.RespondError(w, http.StatusBadRequest, "invalid role")
		return
	}

	fmt.Println(req)

	err := services.CreateUser(req.Username, req.Password, newRole, req.IsActive ,req.KandangID)
	if err != nil {
		if errors.Is(err, services.ErrUserExists) {
			utils.RespondError(w, http.StatusConflict, "username telah terdaftar")
			return
		}
		fmt.Println(err)
		utils.RespondError(w, http.StatusInternalServerError, "gagal menambahkan user")
		return
	}

	utils.RespondSuccess(w, http.StatusCreated, "berhasil menambahkan user", nil)
}

func EditPegawai(w http.ResponseWriter, r *http.Request)  {
	var req struct {
		Username string `json:"username"`
		Role string `json:"role"`
		IsActive bool `json:"isActive"`
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
		"username" : req.Username,
		"role" : newRole,
		"is_active": req.IsActive,
	}

	fmt.Println(newData)

	err := services.UpdateUserByUsername(req.Username, newData)
	if err != nil {
		if err.Error() == "not found" {
			utils.RespondError(w, http.StatusNotFound, "user tidak ditemukan")
			return
		}
		fmt.Println(err)
		utils.RespondError(w, http.StatusInternalServerError, "failed change user data")
		return
	}

	utils.RespondSuccess(w, http.StatusOK, "berhasil update data user", nil)
}

func DeletePegawai(w http.ResponseWriter, r *http.Request)  {
	var req struct {
		Username string `json:"username"`
	}
	
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		utils.RespondError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	
	err := services.DeleteUserById(req.Username)
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