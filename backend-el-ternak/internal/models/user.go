package models

import "gorm.io/gorm"

type User struct {
	gorm.Model
	Username string `gorm:"unique;not null"`
	Password string `gorm:"not null"`
	Role string `gorm:"default:pegawai"`
}

type UserSummary struct {
	ID int `json:"id"`
	Username string `json:"username"`
	Role string `json:"role"`
}