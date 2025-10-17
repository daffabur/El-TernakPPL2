package initializers

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

func LoadEnvVariables() {
	if os.Getenv("GO_ENV") != "production" {
		err := godotenv.Load()
		if err != nil {
			log.Fatal("Error: Gagal memuat file .env di mode development")
		}
		log.Println("File .env berhasil dimuat (mode development)")
	} else {
		log.Println("Berjalan dalam mode produksi (menggunakan variabel dari environment)")
	}
}