package services

import (
	"backend-el-ternak/internal/models"
	"backend-el-ternak/internal/repository"
)

func GetAllObat() ([]models.OvkList, error) {
	obats, err := repository.GetAllOvk()
	if err != nil {
		return nil, err
	}

	return obats, nil
}

func GetSummaryOfOvk() (*models.OvkSummary, error) {
	res, err := repository.GetSummaryOfOvk()
	if err != nil {
		return nil, err
	}

	return res, nil
}

func GetDetailOfOvk(nama string) (*models.OvkList, error) {
	ovk, err := repository.GetDetailOfOvk(nama)
	if err != nil {
		return nil, err
	}

	return ovk, nil
}