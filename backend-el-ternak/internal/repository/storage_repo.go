package repository

import (
	"backend-el-ternak/internal/config"
	"backend-el-ternak/internal/models"
)

func GetCurrentStock() (*models.StorageResponse, error) {
	var storage *models.StorageResponse

	err := config.DB.Model(&models.Storage{}).
	Find(&storage).Error

	if err != nil {
		return nil, err
	}

	return storage, nil
}