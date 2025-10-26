package routes

import (
	"backend-el-ternak/internal/handlers"
	"backend-el-ternak/internal/middleware"
	"net/http"

	"github.com/gorilla/mux"
)

func UploadRoutes(r *mux.Router) {
	upload := r.PathPrefix("/upload").Subrouter()
	
	upload.Handle("", middleware.JwtMiddleware(
		middleware.RoleMiddleware("pegawai", "petinggi")(http.HandlerFunc(handlers.UploadImageHandler)),
	)).Methods("POST")
}