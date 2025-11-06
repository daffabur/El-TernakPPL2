package models

import "gorm.io/gorm"

type Laporan struct {
	gorm.Model
	UserID    uint
	Created_by User `gorm:"foreignKey:UserID"`
	KandangID uint
	Kandang Kandang `gorm:"foreignKey:KandangID"`
	Rata_bobot_ayam float32
	Kematian_ayam int 
	Pakan_used int
	Pakan_tipe string
	Obat_used int
	Obat_tipe string
	Solar_used int
	Sekam_used int
}

type LaporanSummary struct {
	Id uint `json:"id"`
	Pencatat string `json:"pencatat"`
	Tanggal string `json:"tanggal"`
	Jam string `json:"jam"`
	Rata_bobot_ayam float32 `json:"bobot"`
	Kematian_ayam int `json:"mati"`
	Pakan_used int `json:"pakan"`
}

type LaporanDetail struct {
	Id uint `json:"id"`
	Pencatat string `json:"pencatat"`
	Tanggal string `json:"tanggal"`
	Jam string `json:"jam"`
	Rata_bobot_ayam float32 `json:"bobot"`
	Kematian_ayam int `json:"mati"`
	Pakan_used int `json:"pakan"`
	Solar_used int `json:"solar"`
	Sekam_used int`json:"sekam"`
	Obat_used int `json:"obat"`
}