package services

import (
	"backend-el-ternak/internal/models"
	"backend-el-ternak/internal/repository"
	"errors"
	"fmt"
	"log"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

func CreateUser(username, password, role string, isActive bool, kandangID *uint) error {
	if kandangID != nil {
		fmt.Println("kandang ada IDnya:", kandangID)	
	} else {
		fmt.Println("kandang kosong kan bang")
	}

	var user models.User
	err := DB.Where("username = ?", username).First(&user).Error
	
	if err == nil {
		return ErrUserExists
	}

	if err != gorm.ErrRecordNotFound {
		return err
	}
	
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)

	if err!=nil {
		log.Fatalf("failed hashed password, error: %v", err)
	}

	newUser := &models.User{
		Username: username,
		Password: string(hashedPassword),
		Role: role,
		IsActive: isActive,
		KandangID: kandangID,
	}

	fmt.Println("ini dari service:", newUser)

	return repository.CreateUser(newUser)
}

func GetAllProfileData() ([]models.UserSummary, error) {
	users, err := repository.GetAllUser()
	if err != nil {
		return nil, errors.New("failed to fetch users data")
	}

	return users, nil
}

func GetUserByRole(role string) ([]models.UserSummary, error) {
	users, err := repository.GetUserByRole(role)
	if err != nil {
		return nil, errors.New("failed to fetch user data")
	}

	return users, nil
}

func UpdateUserByUsername(username string, newData map[string]interface{}) error {
	err := repository.UpdateUserByUsername(username, newData)
	if err != nil {
		return err
	}

	return nil
}

func DeleteUserByUsername(username string) error {
	err := repository.DeleteByUsername(username)
	if err != nil {
		return err
	}

	return nil
}