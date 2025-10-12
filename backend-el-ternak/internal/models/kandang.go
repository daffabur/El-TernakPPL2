package models

import "gorm.io/gorm"

type Kandang struct{
	gorm.Model
	Nama string `gorm:"not null"`
	Kapasitas int `gorm:"default:0"`
	PenanggungJawab []User `gorm:"foreignKey:KandangID"`
	Populasi int `gorm:"default:0"`
	Kematian int `gorm:"default:0"`
	Konsumsi_pakan int `gorm:"default:0"`
	Solar int `gorm:"default:0"`
	Sekam int `gorm:"default:0"`
	Obat int `gorm:"default:0"`
}

type KandangSummary struct{
	ID int
	Nama string
	Kapasitas int
}