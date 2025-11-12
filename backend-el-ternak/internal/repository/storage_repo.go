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

func GetYearlyReport(tahun string) (*models.StorageReport, error) {
	type Result struct {
		Bulan      int
		PakanUsed  int
		SolarUsed  int
		SekamUsed  int
		ObatUsed   int
	}

	var results []Result

	query := `
		SELECT 
			EXTRACT(MONTH FROM created_at)::INT AS bulan,
			COALESCE(SUM(pakan_used), 0) AS pakan_used,
			COALESCE(SUM(solar_used), 0) AS solar_used,
			COALESCE(SUM(sekam_used), 0) AS sekam_used,
			COALESCE(SUM(obat_used), 0) AS obat_used
		FROM laporans
		WHERE EXTRACT(YEAR FROM created_at) = ?
		GROUP BY bulan
		ORDER BY bulan ASC
	`

	if err := config.DB.Raw(query, tahun).Scan(&results).Error; err != nil {
		return nil, err
	}

	report := &models.StorageReport{Tahun: tahun}

	for _, r := range results {
		switch r.Bulan {
		case 1:
			report.Pakan.Januari = r.PakanUsed
			report.Solar.Januari = r.SolarUsed
			report.Sekam.Januari = r.SekamUsed
			report.OVK.Januari = r.ObatUsed
		case 2:
			report.Pakan.Februari = r.PakanUsed
			report.Solar.Februari = r.SolarUsed
			report.Sekam.Februari = r.SekamUsed
			report.OVK.Februari = r.ObatUsed
		case 3:
			report.Pakan.Maret = r.PakanUsed
			report.Solar.Maret = r.SolarUsed
			report.Sekam.Maret = r.SekamUsed
			report.OVK.Maret = r.ObatUsed
		case 4:
			report.Pakan.April = r.PakanUsed
			report.Solar.April = r.SolarUsed
			report.Sekam.April = r.SekamUsed
			report.OVK.April = r.ObatUsed
		case 5:
			report.Pakan.Mei = r.PakanUsed
			report.Solar.Mei = r.SolarUsed
			report.Sekam.Mei = r.SekamUsed
			report.OVK.Mei = r.ObatUsed
		case 6:
			report.Pakan.Juni = r.PakanUsed
			report.Solar.Juni = r.SolarUsed
			report.Sekam.Juni = r.SekamUsed
			report.OVK.Juni = r.ObatUsed
		case 7:
			report.Pakan.Juli = r.PakanUsed
			report.Solar.Juli = r.SolarUsed
			report.Sekam.Juli = r.SekamUsed
			report.OVK.Juli = r.ObatUsed
		case 8:
			report.Pakan.Agustus = r.PakanUsed
			report.Solar.Agustus = r.SolarUsed
			report.Sekam.Agustus = r.SekamUsed
			report.OVK.Agustus = r.ObatUsed
		case 9:
			report.Pakan.September = r.PakanUsed
			report.Solar.September = r.SolarUsed
			report.Sekam.September = r.SekamUsed
			report.OVK.September = r.ObatUsed
		case 10:
			report.Pakan.Oktober = r.PakanUsed
			report.Solar.Oktober = r.SolarUsed
			report.Sekam.Oktober = r.SekamUsed
			report.OVK.Oktober = r.ObatUsed
		case 11:
			report.Pakan.November = r.PakanUsed
			report.Solar.November = r.SolarUsed
			report.Sekam.November = r.SekamUsed
			report.OVK.November = r.ObatUsed
		case 12:
			report.Pakan.Desember = r.PakanUsed
			report.Solar.Desember = r.SolarUsed
			report.Sekam.Desember = r.SekamUsed
			report.OVK.Desember = r.ObatUsed
		default:
			fmt.Println("Unknown month:", r.Bulan)
		}
	}

	return report, nil
}