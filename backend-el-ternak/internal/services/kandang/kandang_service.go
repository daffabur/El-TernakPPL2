package services

import (
	"backend-el-ternak/internal/config"
	"backend-el-ternak/internal/models"
	"backend-el-ternak/internal/repository"
)

func CreateKandang(nama string, kapasitas int, idPenanggungJawab []uint) error {
	var penanggungJawab []models.User

	if err := config.DB.Find(&penanggungJawab, idPenanggungJawab).Error; err != nil {
		return err
	}

	newKandang := models.Kandang{
		Nama: nama,
		Kapasitas: kapasitas,
		PenanggungJawab: penanggungJawab,
	}

	if err := config.DB.Create(&newKandang).Error; err != nil {
		return err
	}

	return nil
}

func GetAllKandangData() ([]models.KandangSummary, error) {
	kandangs, err  := repository.GetAllKandang()
	if err != nil {
		return nil, err
	}

	return kandangs, nil
}

func GetKandangByID(id uint) (*models.KandangSummary, error) {
	kandang, err := repository.GetKandangByID(id)
	if err != nil {
		return nil, err
	}

	return kandang, nil
}