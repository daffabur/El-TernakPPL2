package services

import (
	"backend-el-ternak/internal/config"
	"backend-el-ternak/internal/models"
	"backend-el-ternak/internal/repository"
	"time"
)

func CreateTransaksi(nama, jenis, kategori string, nominal int, jumlah int, catatan string, linkbukti string, total int) error {
	newTransaksi := models.Transaksi{
		Nama: nama,
		Jenis: jenis,
		Kategori: kategori,
		Tanggal: time.Now(),
		Nominal: nominal,
		Jumlah: jumlah,
		Catatan: catatan,
		Bukti_transaksi: linkbukti,
		Total: total,
	}

	if err := config.DB.Create(&newTransaksi).Error; err != nil {
		return err
	}

	return nil
}

func GetAllTransaksi() ([]models.TransaksiForAll, error) {
	transaksis, err := repository.GetAllTransaksi()
	if err != nil {
		return nil, err
	}
	
	return transaksis, nil
}

func GetTransaksiByID(id uint) (*models.TransaksiSummary, error) {
	transaksi, err := repository.GetTransaksiByID(id)
	if err != nil {
		return nil, err
	}

	return transaksi, nil
}

func GetTransaksiGroupByJenis(jenis string) ([]models.TransaksiForAll, error) {
	transaksis, err := repository.GetTransaksiGroupByJenis(jenis)
	if err != nil {
		return nil, err
	}

	return transaksis, nil
}

func GetTransaksiGroupByKategori(kategori string) ([]models.TransaksiForAll, error) {
	transaksis, err := repository.GetTransaksiGroupByKategori(kategori)
	if err != nil {
		return nil, err
	}

	return transaksis, nil
}