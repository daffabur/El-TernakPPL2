package models

import (
	"time"

	"gorm.io/gorm"
)

type Storage struct {
	gorm.Model
	Pakan_stock int
	Solar_stock int
	Sekam_stock int
	Obat_stock  int
	Pakan_used  int
	Solar_used  int
	Sekam_used  int
	Obat_used   int

	Ovks []Ovk `gorm:"foreignKey:Storage_id"`
	Pakans []Pakan `gorm:"foreignKey:Storage_id"`
}

type StorageResponse struct {
	Updated_at time.Time `json:"updated_at"`
	Pakan_stock int `json:"pakan_stock"`
	Solar_stock int `json:"solar_stock"`
	Sekam_stock int `json:"sekam_stock"`
	Obat_stock  int `json:"obat_stock"`
	Pakan_used  int `json:"pakan_used"`
	Solar_used  int `json:"solar_used"`
	Sekam_used  int `json:"sekam_used"`
	Obat_used   int `json:"obat_used"`
}
