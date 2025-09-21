package main

import (
	"backend-el-ternak/initializers"
	"backend-el-ternak/internal/config"
	"backend-el-ternak/internal/handlers"
	"backend-el-ternak/internal/middleware"
	"backend-el-ternak/internal/services"
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

func init()  {
	initializers.LoadEnvVariables()
	initializers.ConnectDB()
	initializers.SyncDatabase()
}

func main()  {
	services.DB = config.DB

	r := mux.NewRouter()
	api := r.PathPrefix("/api").Subrouter()

	// auth
	auth := api.PathPrefix("/auth").Subrouter()
	auth.HandleFunc("/register", handlers.Register).Methods("POST")
	auth.HandleFunc("/login", handlers.Login).Methods("POST")

	//general
	api.Handle("/profile", middleware.JwtMiddleware(http.HandlerFunc(handlers.Profile))).Methods("GET")

	log.Println("Server running on port: 11222")
	log.Fatal(http.ListenAndServe(":11222", r))
}