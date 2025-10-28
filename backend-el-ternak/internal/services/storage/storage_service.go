package services

import (
	"backend-el-ternak/internal/models"
	"backend-el-ternak/internal/repository"
)

func GetCurrentStock() (*models.StorageResponse, error) {
	stocks, err := repository.GetCurrentStock()
	if err != nil {
		return nil, err
	}

	return stocks, nil
}