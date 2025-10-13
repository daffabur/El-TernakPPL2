package repository

import (
	"backend-el-ternak/internal/config"
	"backend-el-ternak/internal/models"
	"errors"
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

func GetTransaksiByID(id uint) (*models.TransaksiSummary, error) {
	var transaksi models.TransaksiSummary

	err := config.DB.Model(&models.Transaksi{}).
	Select("id", "tanggal", "nama", "jenis", "kategori", "catatan", "bukti_transaksi", "total").
	Where("id = ?", id).
	First(&transaksi).Error

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