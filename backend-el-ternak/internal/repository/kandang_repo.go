package repository

import (
	"backend-el-ternak/internal/config"
	"backend-el-ternak/internal/models"
	"errors"
)

func CreateKandang(kandang *models.Kandang) error {
	return config.DB.Create(kandang).Error
}

func GetAllKandang() ([]models.KandangSummary, error){
	var kandangs []models.KandangSummary
	err := config.DB.Model(&models.Kandang{}).
	Select("id", "nama", "populasi").
	Find(&kandangs).Error

	if err != nil {
		return nil, err
	}

	return kandangs, nil
}

func GetKandangByID(id uint) (*models.KandangDetail, error){
	var kandang models.KandangDetail

	err := config.DB.Model(&models.Kandang{}).
	Select("kandangs.id", "kandangs.nama", "kandangs.kapasitas", "kandangs.populasi", "kandangs.kematian", "kandangs.konsumsi_pakan", "kandangs.solar", "kandangs.sekam", "kandangs.obat", "kandangs.status", "users.username as penanggung_jawab").
	Joins("LEFT JOIN users on kandangs.id = users.kandang_id").
	Where("kandangs.id = ?", id).
	First(&kandang).Error

	if err != nil {
		return nil, err
	}
	
	return &kandang, nil
}

func DeleteKandangByID(id uint) error {
	result := config.DB.Model(&models.Kandang{}).
		Where("id = ?", id).
		Delete(&models.Kandang{})

	if result.Error != nil {
		return result.Error
	}

	if result.RowsAffected == 0 {
		return errors.New("id kandang tidak ditemukan")
	}

	return nil
}