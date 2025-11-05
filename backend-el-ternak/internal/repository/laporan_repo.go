package repository

import (
	"backend-el-ternak/internal/config"
	"backend-el-ternak/internal/models"
	"errors"
	"fmt"
)

func CreateLaporan(laporan *models.Laporan) error {
	tx := config.DB.Begin()
	if err := tx.Create(laporan).Error; err != nil {
		tx.Rollback()
		return err
	}

	//update tabel storage
	var storage models.Storage
	if err := tx.First(&storage, 1).Error; err != nil {
		tx.Rollback()
		return err
	}

	storage.Pakan_used += laporan.Pakan_used
	storage.Sekam_used += laporan.Sekam_used
	storage.Solar_used += laporan.Solar_used
	storage.Obat_used += laporan.Obat_used

	if err := tx.Save(storage).Error; err != nil {
		tx.Rollback()
		return nil
	}

	//update tabel kandang
	var kandang models.Kandang
	err := tx.First(&kandang, laporan.KandangID).Error;
	if err != nil {
		tx.Rollback()
		return err
	}

	kandang.Kematian += laporan.Kematian_ayam
	kandang.Populasi -= laporan.Kematian_ayam
	kandang.Konsumsi_pakan += laporan.Pakan_used
	kandang.Solar += laporan.Solar_used
	kandang.Sekam += laporan.Sekam_used
	kandang.Obat += laporan.Obat_used

	if err := tx.Save(kandang).Error; err != nil {
		tx.Rollback()
		return err
	}

	return tx.Commit().Error
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
	tx := config.DB.Begin()
	
	//ambil laporan lama
	var old_laporan models.Laporan
	if err := tx.First(&old_laporan, "id = ?", laporan_id).Error; err != nil {
		tx.Rollback()
		return err
	}

	//update laporan
	if err := tx.Model(&models.Laporan{}).Where("id = ?", laporan_id).Updates(newData).Error; err != nil {
		tx.Rollback()
		return err
	}

	//ambil data setelah di update
	var new_laporan models.Laporan
	if err := tx.First(&new_laporan, "id = ?", laporan_id).Error; err != nil {
		tx.Rollback()
		return err
	}

	//buat selisih setiap laporan
	diff := models.Laporan {
		Kematian_ayam: new_laporan.Kematian_ayam - old_laporan.Kematian_ayam,
		Pakan_used: new_laporan.Pakan_used - old_laporan.Pakan_used,
		Obat_used: new_laporan.Obat_used - old_laporan.Obat_used,
		Sekam_used: new_laporan.Sekam_used - old_laporan.Sekam_used,
		Solar_used: new_laporan.Solar_used - old_laporan.Solar_used,
	}

	fmt.Print(diff.Kematian_ayam, diff.Pakan_used, diff.Obat_used, diff.Sekam_used, diff.Solar_used)

	//ambil data storage
	var storage models.Storage
	if err := tx.First(&storage, 1).Error; err != nil {
		tx.Rollback()
		return err
	}

	//update data storage
	storage.Pakan_used += diff.Pakan_used
	storage.Obat_used += diff.Obat_used
	storage.Solar_used += diff.Solar_used
	storage.Sekam_used += diff.Sekam_used

	storage.Pakan_stock -= diff.Pakan_used
	storage.Obat_stock -= diff.Obat_used
	storage.Solar_stock -= diff.Solar_used
	storage.Sekam_stock -= diff.Sekam_used

	if err := tx.Save(&storage).Error; err != nil {
		tx.Rollback()
		return err
	}

	//ambil data kandang
	var kandang models.Kandang
	if err := tx.First(&kandang, new_laporan.KandangID).Error; err != nil {
		tx.Rollback()
		return err
	}

	//update data kandang
	kandang.Kematian += diff.Kematian_ayam
	kandang.Populasi -= diff.Kematian_ayam
	kandang.Konsumsi_pakan += diff.Pakan_used
	kandang.Solar += diff.Solar_used
	kandang.Sekam += diff.Sekam_used
	kandang.Obat += diff.Obat_used

	if err := tx.Save(&kandang).Error; err != nil {
		tx.Rollback()
		return err
	}

	return tx.Commit().Error
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