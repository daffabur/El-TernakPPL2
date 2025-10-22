package models

import "gorm.io/gorm"

type Kandang struct{
	gorm.Model
	Nama string `gorm:"not null"`
	Kapasitas int `gorm:"default:0"`
	Penanggung_jawab []User `gorm:"foreignKey:KandangID"`
	Populasi int `gorm:"default:0"`
	Kematian int `gorm:"default:0"`
	Konsumsi_pakan int `gorm:"default:0"`
	Solar int `gorm:"default:0"`
	Sekam int `gorm:"default:0"`
	Obat int `gorm:"default:0"`
	Status string `gorm:"default:'active'"`
	Laporans []Laporan `gorm:"foreignKey:KandangID"`
}

type KandangSummary struct{
	ID int
	Nama string
	Kapasitas int
	Populasi int
}

type KandangDetail struct{
	ID int `json:"id"`
	Nama string `json:"nama"`
	Kapasitas int `json:"kapasitas"`
	Populasi int `json:"populasi"`
	Kematian int `json:"kematian"`
	Konsumsi_pakan int `json:"pakan"`
	Solar int `json:"solar"`
	Sekam int `json:"sekam"`
	Obat int `json:"obat"`
	Status string `json:"status"`
	Penanggung_jawab []UserSummary `json:"penanggung_jawab"`
}
