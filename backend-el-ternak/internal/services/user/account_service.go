package services

import (
	"backend-el-ternak/internal/models"
	"backend-el-ternak/internal/repository"
	"errors"
)

func GetUserProfile(id int) (*models.UserSummary, error)  {
	user, err := repository.GetUserById(id)
	if err != nil {
		return nil, errors.New("user not found")
	}

	return user, nil
}

 // next work
func GetDashboard(username string) {

}