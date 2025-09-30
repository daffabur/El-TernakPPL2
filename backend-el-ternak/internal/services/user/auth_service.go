package services

import (
	"backend-el-ternak/internal/models"
	"backend-el-ternak/internal/repository"
	"errors"
	"log"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

var DB *gorm.DB

func RegisterUser(username, password string) error {
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
	}

	return repository.CreateUser(newUser)
}

func LoginUser(username, password string) (*models.User, error){
	user, err := repository.GetUserByUsername(username)
	if err != nil {
		return nil, errors.New("user not found")
	}

	if err:= bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(password)); err != nil {
		return nil, errors.New("invalid password")
	}

	return user, nil
}