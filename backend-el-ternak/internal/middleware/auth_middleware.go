package middleware

import (
	"backend-el-ternak/utils"
	"context"
	"fmt"
	"net/http"
	"os"
	"strings"

	"github.com/golang-jwt/jwt/v5"
)

type UserContext struct {
	ID int
	Username string
	Role string
}

func JwtMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")
		if authHeader == "" {
			utils.RespondError(w, http.StatusUnauthorized, "missing token")
			return 
		}

		tokenString := strings.TrimPrefix(authHeader, "Bearer ")
		secret := []byte(os.Getenv("JWT_SECRET"))

		claims := jwt.MapClaims{}
		token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
			return secret,nil
		})

		if err != nil || !token.Valid {
			utils.RespondError(w, http.StatusUnauthorized, "invalid token")
			return 
		}
		
		ctx := context.WithValue(r.Context(), "user", UserContext{
			ID: int(claims["id"].(float64)),
			Username: claims["username"].(string),
			Role: claims["role"].(string),
		})

		userCtx := ctx.Value("user").(UserContext)
		fmt.Printf("ID = %d, Username = %s, Role = %s\n", userCtx.ID, userCtx.Username, userCtx.Role)
		
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

func RoleMiddleware(allowedRoles ...string) func(http.Handler) http.Handler{
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			userCtx, ok := r.Context().Value("user").(UserContext)
			if !ok {
				utils.RespondError(w, http.StatusForbidden, "role anda tidak diizinkan")
				return
			}

			allowed := false
			for _,role := range allowedRoles{
				if userCtx.Role == role {
					allowed = true
					break
				}
			}

			if !allowed {
				utils.RespondError(w, http.StatusForbidden, "role anda tidak diizinkan")
				return
			}
			
			next.ServeHTTP(w, r)
		})
	}
}