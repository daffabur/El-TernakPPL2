package models

import (
	"time"
	"gorm.io/gorm"
)

type Transaksi struct {
	gorm.Model
	ID uint
	Nama string `gorm:"not null"`
	Jenis string `gorm:"not null"`
	Kategori string `gorm:"not null"`
	Tipe *string `gorm:"default:null"`
	Tanggal time.Time
	Nominal int `gorm:"not null"`
	Jumlah int `gorm:"not null"`
	Catatan string `gorm:"default:'-'"`
	Bukti_transaksi string `gorm:"default:'-'"`
	Total int `gorm:"not null"`
}

type TransaksiSummary struct{
	ID uint
	Tanggal time.Time
	Nama string
	Jenis string
	Kategori string
	Tipe *string
	Catatan string
	Bukti_transaksi string
	Total int
}

type TransaksiForAll struct{
	ID uint
	Tanggal time.Time
	Nama string
	Jenis string
	Kategori string
	Total int
}

type TransaksiTotal struct{
	Total_pengeluaran int
	Total_pemasukan int
	Saldo int
}