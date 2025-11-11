package routes

import (
	"backend-el-ternak/internal/handlers"
	"backend-el-ternak/internal/middleware"
	"net/http"

	"github.com/gorilla/mux"
)


func LaporanRoutes(r *mux.Router) {
	laporan := r.PathPrefix("/laporan").Subrouter()

	laporan.Handle("", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi", "pegawai")(http.HandlerFunc(handlers.GetLaporanHandler)),
	)).Methods("GET")

	laporan.Handle("/", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi", "pegawai")(http.HandlerFunc(handlers.GetLaporanHandler)),
	)).Methods("GET")

	laporan.Handle("/create", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi", "pegawai")(http.HandlerFunc(handlers.CreateLaporan)),
	)).Methods("POST")

	// laporan.Handle("/filter", middleware.JwtMiddleware(
	// 	middleware.RoleMiddleware("petinggi")(http.HandlerFunc(handlers.GetLaporanFiltered)),
	// )).Methods("GET")

	laporan.Handle("/{id}", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi", "pegawai")(http.HandlerFunc(handlers.HandleLaporanByID)),
	)).Methods("GET", "DELETE", "PATCH")

	laporan.Handle("/kandang/{id}", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi", "pegawai")(http.HandlerFunc(handlers.GetLaporanHandler)),
	)).Methods("GET")

}