package repository

import (
	"backend-el-ternak/internal/config"
	"backend-el-ternak/internal/models"
)

func GetAllOvk() ([]models.OvkList, error) {
	var ovks []models.OvkList
	err := config.DB.Model(&models.Ovk{}).
	Select("nama", "stock", "used").
	Find(&ovks).Error;
	if err != nil {
		return nil, err
	}

	return ovks, nil
}

func GetSummaryOfOvk() (*models.OvkSummary, error) {
	var res models.OvkSummary
	err := config.DB.Model(&models.Ovk{}).
	Select("SUM(stock) AS stock, SUM(used) AS used").
	Scan(&res).Error

	if err != nil {
		return nil, err
	}

	return &res, nil
}

func GetDetailOfOvk(nama string) (*models.OvkList, error) {
	var res models.OvkList
	err := config.DB.Model(&models.Ovk{}).
	Select("nama", "stock", "used").
	Where("nama = ?", nama).
	First(&res).Error

	if err != nil {
		return nil, err
	}

	return &res, nil 
}