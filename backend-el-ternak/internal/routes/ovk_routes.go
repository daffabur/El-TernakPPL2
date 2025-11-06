package routes

import (
	"backend-el-ternak/internal/handlers"
	"backend-el-ternak/internal/middleware"
	"net/http"

	"github.com/gorilla/mux"
)

func OvkRoutes (r *mux.Router){
	ovk := r.PathPrefix("/ovk").Subrouter()
	
	ovk.Handle("", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi", "pegawai")(http.HandlerFunc(handlers.GetAllObat)),
	)).Methods("GET")

	ovk.Handle("/sum", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi", "pegawai")(http.HandlerFunc(handlers.GetSummaryOfOvk)),
	)).Methods("GET")

	ovk.Handle("/detail", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi", "pegawai")(http.HandlerFunc(handlers.GetDetailOfOvk)),
	)).Methods("GET")
}