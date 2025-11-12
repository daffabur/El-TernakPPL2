package models

import (
	"time"

	"gorm.io/gorm"
)

type Storage struct {
	gorm.Model
	Solar_stock int
	Sekam_stock int
	Solar_used  int
	Sekam_used  int

	Ovks []Ovk `gorm:"foreignKey:Storage_id"`
	Pakans []Pakan `gorm:"foreignKey:Storage_id"`
}

type StorageResponse struct {
	Updated_at time.Time `json:"updated_at"`
	Pakan_stock int `json:"pakan_stock"`
	Solar_stock int `json:"solar_stock"`
	Sekam_stock int `json:"sekam_stock"`
	Ovk_stock  int `json:"ovk_stock"`
	Pakan_used  int `json:"pakan_used"`
	Solar_used  int `json:"solar_used"`
	Sekam_used  int `json:"sekam_used"`
	Ovk_used   int `json:"ovk_used"`
}

type MonthlyReport struct {
	Januari int `json:"januari"`
	Februari int `json:"februari"`
	Maret int `json:"maret"`
	April int `json:"april"`
	Mei int `json:"mei"`
	Juni int `json:"juni"`
	Juli int `json:"juli"`
	Agustus int `json:"agustus"`
	September int `json:"september"`
	Oktober int `json:"oktober"`
	November int `json:"november"`
	Desember int `json:"desember"`
}

type StorageReport struct {
	Tahun string `json:"tahun"`
	Pakan MonthlyReport `json:"pakan"`
	Solar MonthlyReport `json:"solar"`
	Sekam MonthlyReport `json:"sekam"`
	OVK MonthlyReport `json:"ovk"`
}