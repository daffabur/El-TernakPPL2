package models

import "gorm.io/gorm"

type Pakan struct{
	gorm.Model
	Nama string
	Stock int
	Used int `gorm:"default:0"`
	Storage_id uint `gorm:"default:1"`
}

type PakanList struct {
	Nama string `json:"nama"`
	Stock int `json:"stock"`
	Used int `json:"used"`
}

type PakanSummary struct {
	Stock int `json:"pakan_stock"`
	Used int `json:"pakan_used"`
}