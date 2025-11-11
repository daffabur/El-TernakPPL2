package models

import "gorm.io/gorm"

type User struct {
	gorm.Model
	Username string `gorm:"unique;not null"`
	Password string `gorm:"not null"`
	Role string `gorm:"default:pegawai"`
	IsActive bool `gorm:"column:is_active"`
	IsPJ bool `gorm:"column:is_pj"`
	KandangID *uint `gorm:"default:null"`
	Kandang *Kandang
}

type UserSummary struct {
	Id uint `json:"id"`
	Username string `json:"username"`
	Role string `json:"role"`
	IsActive bool `json:"is_active"`
	IsPj bool `json:"is_pj"`
	KandangID int `json:"kandang_id"`
	NamaKandang string`json:"nama_kandang"`
}