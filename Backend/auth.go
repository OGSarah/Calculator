package main

import (
    "encoding/base64"
    "net/http"
    "strings"
)

const (
    username = "admin"
    password = "calculator123"
)

func authMiddleware(next http.HandlerFunc) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        authHeader := r.Header.Get("Authorization")
        if authHeader == "" {
            http.Error(w, "Authorization header required", http.StatusUnauthorized)
            return
        }

        authParts := strings.SplitN(authHeader, " ", 2)
        if len(authParts) != 2 || authParts[0] != "Basic" {
            http.Error(w, "Invalid authorization header", http.StatusUnauthorized)
            return
        }

        decoded, err := base64.StdEncoding.DecodeString(authParts[1])
        if err != nil {
            http.Error(w, "Invalid base64 encoding", http.StatusUnauthorized)
            return
        }

        credentials := strings.SplitN(string(decoded), ":", 2)
        if len(credentials) != 2 || credentials[0] != username || credentials[1] != password {
            http.Error(w, "Invalid credentials", http.StatusUnauthorized)
            return
        }

        next(w, r)
    }
}