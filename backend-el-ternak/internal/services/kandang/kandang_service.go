package services

import (
	"backend-el-ternak/internal/config"
	"backend-el-ternak/internal/models"
	"backend-el-ternak/internal/repository"
)

func CreateKandang(nama string, kapasitas int) error {
	var penanggungJawab []models.User

	if err := config.DB.Find(&penanggungJawab).Error; err != nil {
		return err
	}

	newKandang := models.Kandang{
		Nama: nama,
		Kapasitas: kapasitas,
		Penanggung_jawab: penanggungJawab,
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

func GetKandangByID(id uint) (*models.KandangDetail, error) {
	kandang, err := repository.GetKandangByID(id)
	if err != nil {
		return nil, err
	}

	return kandang, nil
}

func UpdateKandangByID(id uint, newData map[string]interface{}) error {
	err := repository.UpdateKandangByID(id, newData)
	if err != nil {
		return err
	}

	return nil
}

func DeleteKandangByID(id uint) error {
	err := repository.DeleteKandangByID(id)
	if err != nil {
		return err
	}
	return nil
}