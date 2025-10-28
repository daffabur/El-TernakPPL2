package routes

import (
	"backend-el-ternak/internal/handlers"
	"backend-el-ternak/internal/middleware"
	"net/http"

	"github.com/gorilla/mux"
)

func StorageRoutes(r *mux.Router){
	storage := r.PathPrefix("/storage").Subrouter()

	storage.Handle("/", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi")(http.HandlerFunc(handlers.GetCurrentStock)),
	)).Methods("GET")
}