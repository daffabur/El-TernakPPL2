package services

import (
	"backend-el-ternak/internal/models"
	"backend-el-ternak/internal/repository"
)

func CreateKandang(nama string, kapasitas int, id_pj uint) error {
	newKandang := models.Kandang{
		Nama: nama,
		Kapasitas: kapasitas,
		Populasi: kapasitas,
	}

	err := repository.CreateKandang(&newKandang, id_pj)
	
	if err != nil {
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