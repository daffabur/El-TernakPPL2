package services

import (
	"backend-el-ternak/internal/models"
	"backend-el-ternak/internal/repository"
)

func CreateLaporan(createdBy, kandangId uint, rata_bobot_ayam float32, kematian, pakan, solar, sekam, obat int, pakan_tipe, obat_tipe string) error {
	newData := models.Laporan{
		UserID: createdBy,
		KandangID: kandangId,
		Rata_bobot_ayam: rata_bobot_ayam,
		Kematian_ayam: kematian,
		Pakan_used: pakan,
		Pakan_tipe: pakan_tipe,
		Solar_used: solar,
		Sekam_used: sekam,
		Obat_used: obat,
		Obat_tipe: obat_tipe,
	}
	err := repository.CreateLaporan(&newData)
	if err != nil {
		return err
	}
	
	return nil
}

func GetAllLaporan() ([]models.LaporanSummary, error) {
	laporans, err := repository.GetLaporan(nil)
	if err != nil {
		return nil, err
	}
	
	return laporans, nil
}

func GetLaporanPerKandang(kandang_id uint) ([]models.LaporanSummary, error) {
	laporans, err := repository.GetLaporan(&kandang_id)
	if err != nil {
		return nil, err
	}

	return laporans, nil
}

func GetLaporanByID(laporan_id uint) (*models.LaporanDetail, error) {
	laporan, err := repository.GetLaporanByID(laporan_id)
	if err != nil {
		return nil, err
	}

	return laporan, nil
}

func GetLaporanFiltered(kandang_id uint, periode, tanggal string) ([]models.LaporanSummary, error) {
	laporans, err :=repository.GetLaporanFiltered(kandang_id, periode, tanggal)
	if err != nil {
		return nil, err
	}

	return laporans, nil
}

func UpdateLaporanByID(laporan_id uint, newData map[string]interface{}) error {
	err := repository.UpdateLaporanByID(laporan_id, newData)
	if err != nil {
		return err
	}
	
	return nil
}

func DeleteLaporanByID(laporan_id uint) error {
	err := repository.DeleteLaporanByID(laporan_id)
	if err != nil {
		return err
	}

	return nil
}