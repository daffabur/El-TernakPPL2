package repository

import (
	"backend-el-ternak/internal/config"
	"backend-el-ternak/internal/models"
	"errors"
	"fmt"

	"gorm.io/gorm"
)

func CreateKandang(kandang *models.Kandang, pj_id uint) error {
	tx := config.DB.Begin()
	if err := tx.Create(kandang).Error; err != nil {
		tx.Rollback()
		return err
	}

	if err := tx.Model(&models.User{}).
	Where("id = ?", pj_id).
	Updates(map[string]interface{}{
		"kandang_id" : kandang.ID,
		"is_pj":  true,
	}).Error; err != nil {
		tx.Rollback()
		return err
	}

	if err := tx.Commit().Error; err != nil {
		tx.Rollback()
		return err
	}

	return nil
}

func GetAllKandang() ([]models.KandangSummary, error){
	var kandangs []models.KandangSummary
	err := config.DB.Model(&models.Kandang{}).
	Select("id", "nama", "kapasitas", "populasi").
	Find(&kandangs).Error

	if err != nil {
		return nil, err
	}

	return kandangs, nil
}

// func GetKandangByID(id uint) (*models.KandangDetail, error){
// 	var kandang models.KandangDetail

// 	err := config.DB.Model(&models.Kandang{}).
// 	Select("kandangs.id", "kandangs.nama", "kandangs.kapasitas", "kandangs.populasi", "kandangs.kematian", "kandangs.konsumsi_pakan", "kandangs.solar", "kandangs.sekam", "kandangs.obat", "kandangs.status", "users.username as penanggung_jawab").
// 	Joins("LEFT JOIN users on kandangs.id = users.kandang_id").
// 	Where("kandangs.id = ?", id).
// 	First(&kandang).Error

// 	if err != nil {
// 		return nil, err
// 	}
	
// 	return &kandang, nil
// }

func GetKandangByID(id uint) (*models.KandangDetail, error) {
	var kandang models.Kandang

	err := config.DB.Preload("Penanggung_jawab", func (db *gorm.DB) *gorm.DB  {
		return db.Select("id", "username", "is_pj", "kandang_id", "role")
	}).
	Where("id = ?", id).
	First(&kandang).Error

	if err != nil {
		return nil, err
	}

	var detail models.KandangDetail
	detail.ID = int(kandang.ID)
	detail.Nama = kandang.Nama
	detail.Kapasitas = kandang.Kapasitas
	detail.Populasi = kandang.Populasi
	detail.Kematian = kandang.Kematian
	detail.Konsumsi_pakan = kandang.Konsumsi_pakan
	detail.Solar = kandang.Solar
	detail.Sekam = kandang.Sekam
	detail.Obat = kandang.Obat
	detail.Status = kandang.Status

	for _, user := range kandang.Penanggung_jawab {
		detail.Penanggung_jawab = append(detail.Penanggung_jawab, models.UserSummary{
			Id:       user.ID,
			Username: user.Username,
			IsPj:     user.IsPJ,
			Role: user.Role,
		})
	}

	return &detail, nil
}

func UpdateKandangByID(id uint, newData map[string]interface{}) error {
	tx := config.DB.Begin()

	pjID, hasPj := newData["id_pj_kandang"]
	delete(newData, "id_pj_kandang")

	result := tx.Model(&models.Kandang{}).Where("id = ?", id).Updates(newData)
	if result.Error != nil {
		tx.Rollback()
		return result.Error
	}
	if result.RowsAffected == 0 {
		tx.Rollback()
		return fmt.Errorf("kandang not found")
	}

	if hasPj {
		if err := tx.Model(&models.User{}).
			Where("kandang_id = ?", id).
			Update("kandang_id", nil).Error; err != nil {
			tx.Rollback()
			return err
		}

		if err := tx.Model(&models.User{}).
			Where("id = ?", pjID).
			Update("kandang_id", id).Error; err != nil {
			tx.Rollback()
			return err
		}
	}

	return tx.Commit().Error
}

func DeleteKandangByID(id uint) error {
	result := config.DB.Model(&models.Kandang{}).
		Where("id = ?", id).
		Delete(&models.Kandang{})

	if result.Error != nil {
		return result.Error
	}

	if result.RowsAffected == 0 {
		return errors.New("id kandang tidak ditemukan")
	}

	return nil
}