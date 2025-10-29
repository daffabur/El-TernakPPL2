package initializers

import (
	"log"
	"time"
)

func SynchronizeTime(){
	loc, _ := time.LoadLocation("Asia/Jakarta")
	time.Local = loc
	log.Println("Synchronize time to Asia/Jakarta")
	log.Println("Waktu lokal runtime:", time.Now().Format(time.RFC3339))
}