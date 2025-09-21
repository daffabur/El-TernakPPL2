package initializers

import (
	"backend-el-ternak/internal/config"

	"gorm.io/gorm"
)

var DB *gorm.DB

func ConnectDB(){
	config.ConnectDB()
}