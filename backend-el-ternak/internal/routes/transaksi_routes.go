package routes

import (
	"backend-el-ternak/internal/handlers"
	"backend-el-ternak/internal/middleware"
	"net/http"

	"github.com/gorilla/mux"
)

func TransaksiRoutes(r *mux.Router) {
	transaksi := r.PathPrefix("/transaksi").Subrouter()

	transaksi.Handle("/", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi")(http.HandlerFunc(handlers.GetAllTransaksi)),
	)).Methods("GET")

	transaksi.Handle("/{id}", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi")(http.HandlerFunc(handlers.HandleTransaksiByID)),
	)).Methods("GET", "DELETE")

	transaksi.Handle("/create", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi")(http.HandlerFunc(handlers.CreateTransaksi)),
	)).Methods("POST")	

	transaksi.Handle("/jenis/{jenis}", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi")(http.HandlerFunc(handlers.GetTransaksiGroupByJenis)),
	)).Methods("GET")

	transaksi.Handle("/kategori/{kategori}", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi")(http.HandlerFunc(handlers.GetTransaksiGroupByKategori)),
	)).Methods("GET")
}