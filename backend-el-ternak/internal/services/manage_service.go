package services

import (
	"backend-el-ternak/internal/models"
	"backend-el-ternak/internal/repository"
	"errors"
)

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

func UpdateUserById(id uint, newData map[string]interface{}) error {
	err := repository.UpdateUser(id, newData)
	if err != nil {
		return err
	}

	return nil
}

func DeleteUserById(id uint) error {
	err := repository.DeleteById(id)
	if err != nil {
		return err
	}

	return nil
}