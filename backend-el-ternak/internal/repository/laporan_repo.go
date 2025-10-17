package repository

import (
	"backend-el-ternak/internal/config"
	"backend-el-ternak/internal/models"
	"errors"
	"fmt"
)


func CreateLaporan(laporan *models.Laporan) error {
	return config.DB.Create(laporan).Error
}

func GetLaporan(kandang_id *uint) ([]models.LaporanSummary, error) {
	var laporans []models.LaporanSummary
	query := config.DB.Table("laporans").
	Select("laporans.id", "users.username AS pencatat", "laporans.kandang_id", "TO_CHAR(laporans.created_at, 'YYYY-MM-DD') AS tanggal", "TO_CHAR(laporans.created_at, 'HH24:MI') AS jam", "laporans.rata_bobot_ayam", "laporans.kematian_ayam", "laporans.pakan_used").
	Joins("LEFT JOIN users ON users.id = laporans.user_id")

	if kandang_id != nil {
		query = query.Where("laporans.kandang_id = ?", kandang_id)
	}

	err := query.Scan(&laporans).Error
	if err != nil {
		return nil , err
	}

	return laporans, nil
}

func GetLaporanByID(laporan_id uint) (*models.LaporanDetail, error) {
	var laporan models.LaporanDetail
	err := config.DB.Table("laporans").
	Select("laporans.id", "users.username AS pencatat", "laporans.kandang_id", "TO_CHAR(laporans.created_at, 'YYYY-MM-DD') AS tanggal", "TO_CHAR(laporans.created_at, 'HH24:MI') AS jam", "laporans.rata_bobot_ayam", "laporans.kematian_ayam", "laporans.pakan_used", "laporans.solar_used", "laporans.sekam_used", "laporans.obat_used").
	Joins("LEFT JOIN users ON users.id = laporans.user_id").
	Where("laporans.id = ?", laporan_id).
	Scan(&laporan).Error

	if err != nil {
		return nil, err
	}

	return &laporan, nil
}

func UpdateLaporanByID(laporan_id uint, newData map[string]interface{}) error {
	result := config.DB.Debug().Model(&models.Laporan{}).Where("id = ?", laporan_id).Updates(newData)

	if result.Error != nil {
		return result.Error
	}

	if result.RowsAffected == 0 {
		return fmt.Errorf("not found")
	}

	return  nil
}

func DeleteLaporanByID(laporan_id uint) error {
	result := config.DB.Model(&models.Laporan{}).
		Where("id = ?", laporan_id).
		Delete(&models.Laporan{})

	if result.Error != nil {
		return result.Error
	}

	if result.RowsAffected == 0 {
		return errors.New("id kandang tidak ditemukan")
	}

	return nil
}