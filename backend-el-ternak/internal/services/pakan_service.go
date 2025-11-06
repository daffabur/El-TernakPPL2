package services

import (
	"backend-el-ternak/internal/models"
	"backend-el-ternak/internal/repository"
)

func GetAllPakan() ([]models.PakanList, error){
	pakans, err := repository.GetAllPakan()
	if err != nil {
		return nil, err
	}

	return pakans, nil
}


func GetSummaryOfPakan() (*models.PakanSummary, error) {
	res, err := repository.GetSummaryOfPakan()
	if err != nil {
		return nil, err
	}

	return res, nil
}

func GetDetailOfPakan(nama string) (*models.PakanList, error) {
	pakan, err := repository.GetDetailOfPakan(nama)
	if err != nil {
		return nil, err
	}

	return pakan, nil
}