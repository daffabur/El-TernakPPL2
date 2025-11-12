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

	storage.Handle("/checkPakan", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi")(http.HandlerFunc(handlers.CheckPakanStock)),
	)).Methods("GET")

	storage.Handle("/report", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi")(http.HandlerFunc(handlers.GetYearlyReport)),
	)).Methods("GET")
}