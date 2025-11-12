package repository

import (
	"backend-el-ternak/internal/config"
	"backend-el-ternak/internal/models"
)

func GetAllPakan() ([]models.PakanList, error){
	var pakans []models.PakanList
	err := config.DB.Model(&models.Pakan{}).
	Select("nama", "stock", "used").
	Find(&pakans).Error

	if err != nil {
		return nil, err
	}

	return pakans, nil
}

func GetSummaryOfPakan() (*models.PakanSummary, error) {
	var res models.PakanSummary
	err := config.DB.Model(&models.Pakan{}).
	Select("SUM(stock) AS stock, SUM(used) AS used").
	Scan(&res).Error

	if err != nil {
		return nil, err
	}

	return &res, nil
}

func GetDetailOfPakan(nama string) (*models.PakanList, error) {
	var res models.PakanList
	err := config.DB.Model(&models.Pakan{}).
	Select("nama", "stock", "used").
	Where("nama = ?", nama).
	First(&res).Error

	if err != nil {
		return nil, err
	}

	return &res, nil 
}