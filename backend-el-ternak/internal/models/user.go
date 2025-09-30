package models

import "gorm.io/gorm"

type User struct {
	gorm.Model
	Username string `gorm:"unique;not null"`
	Password string `gorm:"not null"`
	Role string `gorm:"default:pegawai"`
	IsActive bool `gorm:"column:is_active"`
	KandangID *uint `gorm:"default:null"`
	Kandang *Kandang
}

type UserSummary struct {
	Username string `json:"username"`
	Role string `json:"role"`
	IsActive bool `json:"is_active"`
}