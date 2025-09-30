package models

import "gorm.io/gorm"

type Kandang struct{
	gorm.Model
	Nama string `gorm:"not null"`
	JumlahAyam int `gorm:"default:0"`
	PenanggungJawab []User `gorm:"foreignKey:KandangID"`
}

type KandangSummary struct{
	ID int
	Nama string
	JumlahAyam int
}