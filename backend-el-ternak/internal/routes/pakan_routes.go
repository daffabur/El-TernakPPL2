package routes

import (
	"backend-el-ternak/internal/handlers"
	"backend-el-ternak/internal/middleware"
	"net/http"

	"github.com/gorilla/mux"
)

func PakanRoutes (r *mux.Router){
	pakan := r.PathPrefix("/pakan").Subrouter()

	pakan.Handle("", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi", "pegawai")(http.HandlerFunc(handlers.GetAllPakan)),
	)).Methods("GET")

	pakan.Handle("/sum", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi", "pegawai")(http.HandlerFunc(handlers.GetSummaryOfPakan)),
	)).Methods("GET")

	pakan.Handle("/detail", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi", "pegawai")(http.HandlerFunc(handlers.GetDetailOfPakan)),
	)).Methods("GET")
}