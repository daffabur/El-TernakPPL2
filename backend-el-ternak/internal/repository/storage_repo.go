package repository

import (
	"backend-el-ternak/internal/config"
	"backend-el-ternak/internal/models"
	"fmt"
	"time"
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

func CheckPakanStock() (bool, error) {
	pakan_per_1000_ayam_per_hari := 85

	var pakan int
	if err := config.DB.Model(&models.Pakan{}).
	Select("COALESCE(SUM(stock),0)").
	Scan(&pakan).Error; err != nil {
		return false, err
	}
	fmt.Println("total pakan = ", pakan)

	var populasi int
	if err := config.DB.Model(&models.Kandang{}).
	Select("COALESCE(SUM(populasi),0)").
	Scan(&populasi).Error; err != nil {
		return false, err
	}
	fmt.Println("total populasi = ", populasi)

	now := time.Now()
	firstOfNextMonth := time.Date(now.Year(), now.Month()+1, 1, 0, 0, 0, 0, now.Location())

	day_left := int(firstOfNextMonth.Sub(now).Hours() / 24)

	fmt.Println("Hari tersisa hingga akhir bulan:", day_left)

	threshold_stock_min := ((populasi / 1000) * pakan_per_1000_ayam_per_hari) * day_left

	fmt.Println("threshold min = ", threshold_stock_min)

	if pakan < threshold_stock_min {
		return true, nil
	}

	return false, nil
}