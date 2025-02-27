package main

import (
    "database/sql"
    "encoding/json"
    "net/http"
)

func logSessionHandler(w http.ResponseWriter, r *http.Request) {
    db, err := sql.Open("sqlite3", "./calculator.db")
    if err != nil {
        http.Error(w, "Database error", http.StatusInternalServerError)
        return
    }
    defer db.Close()

    var session Session
    if err := json.NewDecoder(r.Body).Decode(&session); err != nil {
        http.Error(w, "Invalid request body", http.StatusBadRequest)
        return
    }

    if err := saveSession(db, session); err != nil {
        http.Error(w, "Failed to save session", http.StatusInternalServerError)
        return
    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(map[string]string{
        "message": "Session data saved successfully",
    })
}