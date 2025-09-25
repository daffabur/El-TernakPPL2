package pkg

import (
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

func GenerateJWT(id int, username, role string)(string, error) {
	secret := []byte(os.Getenv("JWT_SECRET"))

	// payload of jwt
	claims := jwt.MapClaims{
		"exp" : time.Now().Add(time.Hour * 1).Unix(),
		"role" : role,
		"username" : username,
		"id" : id,
	}
	
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(secret)
}