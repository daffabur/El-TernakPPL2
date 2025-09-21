package initializers

import (
	"backend-el-ternak/internal/config"
	"backend-el-ternak/internal/models"
)

func SyncDatabase()  {
	config.DB.AutoMigrate(&models.User{})
}