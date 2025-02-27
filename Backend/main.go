package main

import (
    "database/sql" // Add this import
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
    r.HandleFunc("/api/sessions", authMiddleware(getAllSessionsHandler)).Methods("GET")

    log.Println("Server starting on :3000")
    log.Fatal(http.ListenAndServe(":3000", r))
}

func getAllSessionsHandler(w http.ResponseWriter, r *http.Request) {
    db, err := sql.Open("sqlite3", "./calculator.db")
    if err != nil {
        log.Println("Database connection error:", err)
        http.Error(w, "Database error", http.StatusInternalServerError)
        return
    }
    defer db.Close()

    rows, err := db.Query("SELECT session_id, add_count, subtract_count, multiply_count, divide_count, last_updated FROM sessions")
    if err != nil {
        log.Println("Query execution error:", err)
        http.Error(w, "Query error", http.StatusInternalServerError)
        return
    }
    defer rows.Close()

    sessions := make([]Session, 0)
    for rows.Next() {
        var s Session
        err := rows.Scan(&s.SessionID, &s.AddCount, &s.SubtractCount, &s.MultiplyCount, &s.DivideCount, &s.LastUpdated)
        if err != nil {
            log.Println("Scan error:", err)
            http.Error(w, "Scan error", http.StatusInternalServerError)
            return
        }
        sessions = append(sessions, s)
    }

    if err = rows.Err(); err != nil {
        log.Println("Rows error:", err)
        http.Error(w, "Rows error", http.StatusInternalServerError)
        return
    }

    w.Header().Set("Content-Type", "application/json")
    if err := json.NewEncoder(w).Encode(sessions); err != nil {
        log.Println("JSON encoding error:", err)
        http.Error(w, "Encoding error", http.StatusInternalServerError)
        return
    }
}