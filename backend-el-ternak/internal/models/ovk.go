package models

import "gorm.io/gorm"

type Ovk struct{
	gorm.Model
	Nama string
	Stock int
	Used int `gorm:"default:0"`
	Storage_id uint `gorm:"default:1"`
}

type OvkList struct {
	Nama string `json:"nama"`
	Stock int `json:"stock"`
	Used int `json:"used"`
}

type OvkSummary struct {
	Stock int `json:"ovk_stock"`
	Used int `json:"ovk_used"`
}