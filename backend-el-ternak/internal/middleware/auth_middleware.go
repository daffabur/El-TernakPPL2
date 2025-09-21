package middleware

import (
	"net/http"
	"os"
	"strings"

	"github.com/golang-jwt/jwt/v5"
)

func JwtMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")
		if authHeader == "" {
			http.Error(w, "missing token", http.StatusUnauthorized)
			return 
		}

		tokenString := strings.TrimPrefix(authHeader, "Bearer ")
		secret := []byte(os.Getenv("JWT_SECRET"))

		_, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			return secret,nil
		})

		if err != nil {
			http.Error(w, "invalid token", http.StatusUnauthorized)
			return 
		}

		next.ServeHTTP(w, r)
	})
}