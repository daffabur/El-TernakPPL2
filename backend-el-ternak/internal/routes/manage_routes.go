package routes

import (
	"backend-el-ternak/internal/handlers"
	"backend-el-ternak/internal/middleware"
	"net/http"

	"github.com/gorilla/mux"
)

func ManageRoutes(r *mux.Router)  {
	manage := r.PathPrefix("/manage").Subrouter()

	// {/} -> get all user data
	manage.Handle("/", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi")(http.HandlerFunc(handlers.GetAllProfileData)),
	)).Methods("GET")

	// {/pegawai} -> get all pegawai-only data
	manage.Handle("/pegawai", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi")(http.HandlerFunc(handlers.GetPegawaiData)),
	)).Methods("GET")

	// {/petinggi} -> get all petinggi-only data
	manage.Handle("/petinggi", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi")(http.HandlerFunc(handlers.GetPetinggiData)),
	)).Methods("GET")

	// {/create} -> actionable only for petinggi
	manage.Handle("/create", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi")(http.HandlerFunc(handlers.CreateUser)),
	)).Methods("POST")

	// {/edit} -> actionable only for petinggi
	manage.Handle("/edit", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi")(http.HandlerFunc(handlers.EditPegawai)),
	)).Methods("PUT")

	// {/delete} -> actionable only for petinggi
	manage.Handle("/delete", middleware.JwtMiddleware(
		middleware.RoleMiddleware("petinggi")(http.HandlerFunc(handlers.DeletePegawai)),
	)).Methods("DELETE")
}