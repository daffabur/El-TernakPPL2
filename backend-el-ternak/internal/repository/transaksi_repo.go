package repository

import (
	"backend-el-ternak/internal/config"
	"backend-el-ternak/internal/models"
	"errors"
	"fmt"
	"time"
)

func CreateTransaksi(transaksi *models.Transaksi) error {
	return config.DB.Create(transaksi).Error
}

func GetAllTransaksi() ([]models.TransaksiForAll, error) {
	var transaksi []models.TransaksiForAll
	err := config.DB.Model(&models.Transaksi{}).
	Select("id", "nama", "tanggal", "jenis", "kategori", "total").
	Find(&transaksi).Error

	if err != nil {
		return  nil, err
	}

	return transaksi, nil
}

func GetTransaksiSummary() (*models.TransaksiTotal, error) {
	var result models.TransaksiTotal

	err := config.DB.Model(&models.Transaksi{}).
	Select("COALESCE(SUM(total), 0)").
	Where("jenis = ?", "pemasukan").
	Scan(&result.Total_pemasukan).Error

	if err != nil {
		return nil, err
	}

	errr := config.DB.Model(&models.Transaksi{}).
	Select("COALESCE(SUM(total), 0)").
	Where("jenis = ?", "pengeluaran").
	Scan(&result.Total_pengeluaran).Error

	if errr != nil {
		return nil, errr
	}

	result.Saldo = result.Total_pemasukan - result.Total_pengeluaran
	return &result, nil
}

func GetTransaksiFiltered(periode string) ([]models.TransaksiForAll, error) {
	var transaksis []models.TransaksiForAll
	var startDate, endDate time.Time
	now := time.Now()

	switch periode{
	case "hari_ini":
		fmt.Println("ini dari case hari_ini")
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
	}
	err := config.DB.Model(&models.Transaksi{}).
	Select("id", "tanggal", "nama", "jenis", "kategori", "total").
	Where("tanggal BETWEEN ? AND ?", startDate, endDate).
	Order("tanggal DESC").
	Find(&transaksis).Error

	return transaksis, err
}

func GetTransaksiByID(id uint) (*models.TransaksiSummary, error) {
	var transaksi models.TransaksiSummary

	err := config.DB.Model(&models.Transaksi{}).
	Select("id", "tanggal", "nama", "jenis", "kategori", "catatan", "bukti_transaksi", "total").
	Where("id = ?", id).
	First(&transaksi).Error

	fmt.Println(&transaksi)

	if err !=  nil {
		return nil, err
	}

	return &transaksi, nil
}

func GetTransaksiGroupByJenis(jenis string) ([]models.TransaksiForAll, error) {
	var transaksi []models.TransaksiForAll

	err := config.DB.Model(&models.Transaksi{}).
	Select("id", "nama", "tanggal", "jenis", "kategori", "total").
	Where("jenis = ?", jenis).
	Find(&transaksi).Error

	if err != nil {
		return nil, err
	}

	return transaksi, nil
}

func GetTransaksiGroupByKategori(kategori string) ([]models.TransaksiForAll, error) {
	var transaksi []models.TransaksiForAll

	err := config.DB.Model(&models.Transaksi{}).
	Select("id", "nama", "tanggal", "jenis","kategori", "total").
	Where("kategori = ?", kategori).
	Find(&transaksi).Error

	if err != nil {
		return nil, err
	}

	return transaksi, nil
}

func DeleteTransaksiByID(id uint) error {
	result := config.DB.Model(&models.Transaksi{}).
		Where("id = ?", id).
		Delete(&models.Transaksi{})

	if result.Error != nil {
		return result.Error
	}

	if result.RowsAffected == 0 {
		return errors.New("id transaksi tidak ditemukan")
	}

	return nil
}