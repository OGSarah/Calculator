package main

import (
    "log"
    "net/http"

    "github.com/gorilla/mux"
    _ "github.com/mattn/go-sqlite3"
)

func main() {
    err := initDB()
    if err != nil {
        log.Fatal("Error initializing database:", err)
    }

    r := mux.NewRouter()
    r.HandleFunc("/api/session", authMiddleware(logSessionHandler)).Methods("POST")

    log.Println("Server starting on :3000")
    log.Fatal(http.ListenAndServe(":3000", r))
}