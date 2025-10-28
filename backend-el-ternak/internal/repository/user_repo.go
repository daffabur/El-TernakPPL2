package repository

import (
	"backend-el-ternak/internal/config"
	"backend-el-ternak/internal/models"
	"fmt"
)

func CreateUser(user *models.User) error {
	fmt.Println("dari repo:", user)
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

func GetUserById(id int) (*models.UserSummary, error) {
	var user models.UserSummary
	err := config.DB.Model(&models.User{}).
	Select("id", "username", "role", "is_active", "is_pj", "kandang_id").
	Where("id = ?", id).
	First(&user).Error

	if err != nil {
		return nil, err
	}

	return &user, nil
}

func GetAllUser() ([]models.UserSummary, error) {
	var users []models.UserSummary
	err := config.DB.Model(&models.User{}).
	Select("username", "role", "is_active").
	Find(&users).Error
	
	if err != nil {
		return nil, err
	}

	return users, nil
}

func GetUserByRole(role string) ([]models.UserSummary, error) {
	var users []models.UserSummary
	err := config.DB.Model(&models.User{}).Where("role = ?", role).Find(&users).Error
	if err != nil {
		return nil, err
	}

	return users, nil
}

func UpdateUserByUsername(username string, newData map[string]interface{}) error {
	result := config.DB.Debug().Model(&models.User{}).Where("username = ?", username).Updates(newData)

	if result.Error != nil {
		return result.Error
	}

	if result.RowsAffected == 0 {
		return fmt.Errorf("not found")
	}

	return nil
}

func DeleteByUsername(username string) error  {
	result := config.DB.Where("username = ?", username).Delete(&models.User{})
	if result.Error != nil {
		return result.Error
	}

	if result.RowsAffected == 0 {
		return fmt.Errorf("not found")
	}

	return nil
}