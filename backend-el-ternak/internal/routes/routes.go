package routes

import (
	"backend-el-ternak/internal/handlers"
	"backend-el-ternak/internal/middleware"

	"github.com/gorilla/mux"
)

func RegisteredRoutes(r *mux.Router)  {
	api := r.PathPrefix("/api").Subrouter()
	api.HandleFunc("/", handlers.WelcomeMsg).Methods("GET")

	AuthRoutes(api)
	AccountRoutes(api)
	ManageRoutes(api)
	KandangRoutes(api)
	TransaksiRoutes(api)
	LaporanRoutes(api)
	UploadRoutes(api)
	StorageRoutes(api)
	OvkRoutes(api)
	PakanRoutes(api)
	
	api.Use(middleware.EnableCORS)
}