package utils

import (
	"encoding/json"
	"net/http"
)

type JSONResponse struct {
	Success bool `json:"success"`
	Message string `json:"message,omitempty"`
	Data interface{} `json:"data,omitempty"`
	Error string `json:"error,omitempty"`
}

func RespondJSON(w http.ResponseWriter, status int, payload JSONResponse){
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(payload)
}

func RespondSuccess(w http.ResponseWriter, status int, message string, data interface{}){
	RespondJSON(w, status, JSONResponse{
		Success: true,
		Message: message,
		Data: data,
	})
}

func RespondError(w http.ResponseWriter, status int, errorMsg string){
	RespondJSON(w, status, JSONResponse{
		Success: false,
		Error: errorMsg,
	})
}