package repository

import (
	"backend-el-ternak/internal/config"
	"backend-el-ternak/internal/models"
	"fmt"
)

func CreateKandang(kandang *models.Kandang) error {
	return config.DB.Create(kandang).Error
}

func GetKandangByID(id uint) (*models.KandangSummary, error){
	var kandang models.KandangSummary

	err := config.DB.Model(&models.Kandang{}).
	Select("id", "nama", "jumlahAyam").
	Where("id = ?", id).
	First(&kandang).Error

	if err != nil {
		return nil, err
	}
	
	return &kandang, nil
}

func GetAllKandang() ([]models.KandangSummary, error){
	var kandang []models.KandangSummary
	err := config.DB.Model(&models.Kandang{}).
	Select("id", "nama", "jumlah_ayam").
	Find(&kandang).Error

	if err != nil {
		return nil, err
	}

	fmt.Println(kandang)
	return kandang, nil
}