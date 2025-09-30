package main

import (
	"backend-el-ternak/initializers"
	"backend-el-ternak/internal/config"
	"backend-el-ternak/internal/routes"
	"backend-el-ternak/internal/services/user"
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
	r.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		http.Redirect(w, r, "/api/", http.StatusTemporaryRedirect)
	})
	
	routes.RegisteredRoutes(r)

	log.Println("Server running on port: 11222")
	log.Fatal(http.ListenAndServe(":11222", r))
}