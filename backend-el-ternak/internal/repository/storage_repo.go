package repository

import (
	"backend-el-ternak/internal/config"
	"backend-el-ternak/internal/models"
)

func GetCurrentStock() (*models.StorageResponse, error) {
	var res models.StorageResponse

	err := config.DB.Model(&models.Storage{}).
	Select("updated_at, solar_stock, solar_used, sekam_stock, sekam_used").
	First(&res).Error

	if err != nil {
		return nil, err
	}

	type Summary struct {
		Stock int
		Used int
	}

	var pakan Summary
	if err := config.DB.Model(&models.Pakan{}).
	Select("COALESCE(SUM(stock),0) as stock, COALESCE(SUM(used),0) as used").
	Scan(&pakan).Error; err != nil {
		return nil, err
	}

	var ovk Summary
	if err := config.DB.Model(&models.Ovk{}).
	Select("COALESCE(SUM(stock),0) as stock, COALESCE(SUM(used),0) as used").
	Scan(&ovk).Error; err != nil {
		return nil, err
	}

	res.Pakan_stock = pakan.Stock
	res.Pakan_used = pakan.Used
	res.Ovk_stock = ovk.Stock
	res.Ovk_used = ovk.Used

	return &res, nil
}