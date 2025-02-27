package main

import (
    "database/sql"
    "encoding/json"
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
    r.HandleFunc("/api/sessions", authMiddleware(getAllSessionsHandler)).Methods("GET") // New endpoint

    log.Println("Server starting on :3000")
    log.Fatal(http.ListenAndServe(":3000", r))
}

func getAllSessionsHandler(w http.ResponseWriter, r *http.Request) {
    db, err := sql.Open("sqlite3", "./calculator.db")
    if err != nil {
        http.Error(w, "Database error", http.StatusInternalServerError)
        return
    }
    defer db.Close()

    rows, err := db.Query("SELECT session_id, add_count, subtract_count, multiply_count, divide_count, last_updated FROM sessions")
    if err != nil {
        http.Error(w, "Query error", http.StatusInternalServerError)
        return
    }
    defer rows.Close()

    var sessions []Session
    for rows.Next() {
        var s Session
        err := rows.Scan(&s.SessionID, &s.AddCount, &s.SubtractCount, &s.MultiplyCount, &s.DivideCount, &s.LastUpdated)
        if err != nil {
            http.Error(w, "Scan error", http.StatusInternalServerError)
            return
        }
        sessions = append(sessions, s)
    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(sessions)
}