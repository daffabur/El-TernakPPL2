package repository

import (
	"backend-el-ternak/internal/config"
	"backend-el-ternak/internal/models"
)

func CreateUser(user *models.User) error {
	return config.DB.Create(user).Error
}

func GetUserByUsername(username string) (*models.User, error) {
	var user models.User
	err := config.DB.Where("username = ?", username).First(&user).Error

	if err != nil {
		return nil, err
	}

	return &user, nil
}