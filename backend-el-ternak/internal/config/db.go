package config

import (
	"backend-el-ternak/internal/models"
	"fmt"
	"log"
	"os"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func ConnectDB() {
	var err error
	dsn := fmt.Sprintf(
		"host=%s user=%s password=%s dbname=%s port=%s sslmode=require",
		os.Getenv("DB_HOST"),
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASS"),
		os.Getenv("DB_NAME"),
		os.Getenv("DB_PORT"),
	)

	DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("Gagal tersambung ke Database: ", err)
	}

	log.Println("Berhasil terhubung ke database")

	err = DB.AutoMigrate(
		&models.Laporan{},
		&models.Transaksi{},
		&models.User{},
		&models.Kandang{},
		&models.Storage{},
	)

	if err != nil {
		log.Fatal("Gagal migrasi database", err)
	}

	log.Println("Berhasil migrasi database")
}