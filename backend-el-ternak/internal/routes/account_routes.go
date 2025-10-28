package routes

import (
	"backend-el-ternak/internal/handlers"
	"backend-el-ternak/internal/middleware"
	"net/http"

	"github.com/gorilla/mux"
)

func AccountRoutes(r *mux.Router)  {
	account := r.PathPrefix("/account").Subrouter()
	
	// {/me} -> get currently login users data
	account.Handle("/me", middleware.JwtMiddleware(
		http.HandlerFunc(handlers.Profile),
	)).Methods("GET")

	// {/dashboard} -> get all data from kandang, only allowed for petinggi
	account.Handle("/dashboard",middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi")(http.HandlerFunc(handlers.Dashboard)),
		)).Methods("GET")
}
