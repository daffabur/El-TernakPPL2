package services

import (
	"backend-el-ternak/internal/models"
	"backend-el-ternak/internal/repository"
	"time"
)

func CreateTransaksi(nama, jenis, kategori string, tipe *string, tanggal time.Time, nominal int, jumlah int, catatan string, linkbukti string, total int) error {
	newTransaksi := models.Transaksi{
		Nama: nama,
		Jenis: jenis,
		Kategori: kategori,
		Tipe: tipe,
		Tanggal: tanggal,
		Nominal: nominal,
		Jumlah: jumlah,
		Catatan: catatan,
		Bukti_transaksi: linkbukti,
		Total: total,
	}

	var kategoriPtr *string

	if newTransaksi.Jenis == "pengeluaran" && (newTransaksi.Kategori == "pakan" || newTransaksi.Kategori == "ovk" || newTransaksi.Kategori == "sekam" || newTransaksi.Kategori == "solar") {
		kategoriPtr = &newTransaksi.Kategori
	}

	err := repository.CreateTransaksi(&newTransaksi, kategoriPtr)
	if err != nil {
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

func GetTransaksiSummary() (*models.TransaksiTotal, error) {
	summary, err := repository.GetTransaksiSummary()
	if err != nil {
		return nil, err
	}

	return summary, nil
}

func GetTransaksiFiltered(periode, tanggal string) ([]models.TransaksiForAll, error) {
	transaksis, err :=repository.GetTransaksiFiltered(periode, tanggal)
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

func DeleteTransaksiByID(id uint) error {
	err := repository.DeleteTransaksiByID(id)
	if err != nil {
		return err
	}
	return nil
}