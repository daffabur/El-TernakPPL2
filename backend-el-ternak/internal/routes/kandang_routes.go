package routes

import (
	"backend-el-ternak/internal/handlers"
	"backend-el-ternak/internal/middleware"
	"net/http"

	"github.com/gorilla/mux"
)

func KandangRoutes(r *mux.Router)  {
	kandang := r.PathPrefix("/kandang").Subrouter()

	kandang.Handle("/", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi")(http.HandlerFunc(handlers.GetAllKandang)),
	)).Methods("GET")

	kandang.Handle("/create", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi")(http.HandlerFunc(handlers.CreateKandang)),
	)).Methods("POST")

	kandang.Handle("/{id}",middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi", "pegawai")(http.HandlerFunc(handlers.HandleKandangByID)),
	)).Methods("GET", "DELETE", "PATCH", "PUT")
}