package routes

import (
	"backend-el-ternak/internal/handlers"

	"github.com/gorilla/mux"
)

func AuthRoutes(r *mux.Router) {
	auth := r.PathPrefix("/auth").Subrouter()
	auth.HandleFunc("/register", handlers.Register).Methods("POST")
	auth.HandleFunc("/login", handlers.Login).Methods("POST")
}