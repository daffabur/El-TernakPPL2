package repository

import (
	"backend-el-ternak/internal/config"
	"backend-el-ternak/internal/models"
	"errors"
	"fmt"
	"time"
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
	storage.Sekam_used += laporan.Sekam_used
	storage.Solar_used += laporan.Solar_used
	storage.Sekam_stock -= laporan.Sekam_used
	storage.Solar_stock -= laporan.Solar_used

	//update tabel ovk
	var ovk models.Ovk
	if err := tx.Where("nama = ?", laporan.Obat_tipe).First(&ovk).Error; err != nil {
		tx.Rollback()
		return err
	}
	ovk.Used += laporan.Obat_used
	ovk.Stock -= laporan.Obat_used

	//update tabel pakan
	var pakan models.Pakan
	if err := tx.Where("nama = ?", laporan.Pakan_tipe).First(&pakan).Error; err != nil {
		tx.Rollback()
		return err
	}
	pakan.Used += laporan.Pakan_used
	pakan.Stock -= laporan.Pakan_used

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

	if err := tx.Save(storage).Error; err != nil {
		tx.Rollback()
		return nil
	}

	if err := tx.Save(ovk).Error; err != nil {
		tx.Rollback()
		return err
	}

	if err := tx.Save(pakan).Error; err != nil {
		tx.Rollback()
		return err
	}

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

func GetLaporanFiltered(kandang_id uint, periode, tanggal string) ([]models.LaporanSummary, error) {
	var laporans []models.LaporanSummary
	var startDate, endDate time.Time
	now := time.Now()

	switch periode{
	case "hari_ini":
		startDate = time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())
		endDate = startDate.Add(24 * time.Hour)
	case "minggu_ini":
		offset := int(now.Weekday())
		if offset == 0 {
			offset = 7
		}
		startDate = now.AddDate(0, 0, -offset+1)
		endDate = startDate.AddDate(0 , 0, 7)
	case "bulan_ini":
		startDate = time.Date(now.Year(), now.Month(),1 , 0, 0, 0, 0, now.Location())
		endDate = startDate.AddDate(0, 1, 0).Add(-time.Nanosecond)
	case "per_hari":
		parsedDate, err := time.Parse("2006-01-02", tanggal)
		if err != nil {
			return nil, fmt.Errorf("format tanggal tidak valid, gunakan YYYY-MM-DD")
		}

		startDate = time.Date(parsedDate.Year(), parsedDate.Month(), parsedDate.Day(), 0, 0, 0, 0, parsedDate.Location())
		endDate = startDate.Add(24 * time.Hour)
	}
	
	query := config.DB.Table("laporans").
	Select("laporans.id", "users.username AS pencatat", "laporans.kandang_id", "TO_CHAR(laporans.created_at, 'YYYY-MM-DD') AS tanggal", "TO_CHAR(laporans.created_at, 'HH24:MI') AS jam", "laporans.rata_bobot_ayam", "laporans.kematian_ayam", "laporans.pakan_used").
	Joins("LEFT JOIN users ON users.id = laporans.user_id").
	Where("laporans.kandang_id = ?", kandang_id).
	Where("laporans.created_at BETWEEN ? AND ?", startDate, endDate).
	Order("tanggal DESC")

	err := query.Scan(&laporans).Error
	if err != nil {
		return nil , err
	}

	return laporans, nil
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

	//ambil data ovk
	var ovk models.Ovk
	if err := tx.Where("nama = ?", new_laporan.Obat_tipe).First(&ovk).Error; err != nil {
		tx.Rollback()
		return err
	}
	//update data ovk
	ovk.Used += diff.Obat_used
	ovk.Stock -= diff.Obat_used

	//ambil data pakan
	var pakan models.Pakan
	if err := tx.Where("nama = ?", new_laporan.Pakan_tipe).First(&pakan).Error; err != nil {
		tx.Rollback()
		return err
	}
	//update data pakan
	pakan.Used += diff.Pakan_used
	pakan.Stock -= diff.Pakan_used

	//ambil data storage
	var storage models.Storage
	if err := tx.First(&storage, 1).Error; err != nil {
		tx.Rollback()
		return err
	}
	//update data storage
	storage.Solar_used += diff.Solar_used
	storage.Sekam_used += diff.Sekam_used
	storage.Solar_stock -= diff.Solar_used
	storage.Sekam_stock -= diff.Sekam_used

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

	if err := tx.Save(&ovk).Error; err != nil {
		tx.Rollback()
		return err
	}
	
	if err := tx.Save(&pakan).Error; err != nil {
		tx.Rollback()
		return err
	}
	
	if err := tx.Save(&storage).Error; err != nil {
		tx.Rollback()
		return err
	}
	
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