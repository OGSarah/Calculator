package main

import (
    "database/sql"
)

type Session struct {
    SessionID     string `json:"sessionId"`
    AddCount      int    `json:"operations.+"`
    SubtractCount int    `json:"operations.−"`
    MultiplyCount int    `json:"operations.×"`
    DivideCount   int    `json:"operations.÷"`
}

func initDB() error {
    db, err := sql.Open("sqlite3", "./calculator.db")
    if err != nil {
        return err
    }
    defer db.Close()

    _, err = db.Exec(`
        CREATE TABLE IF NOT EXISTS sessions (
            session_id TEXT PRIMARY KEY,
            add_count INTEGER DEFAULT 0,
            subtract_count INTEGER DEFAULT 0,
            multiply_count INTEGER DEFAULT 0,
            divide_count INTEGER DEFAULT 0
        )
    `)
    return err
}

func saveSession(db *sql.DB, session Session) error {
    stmt, err := db.Prepare(`
        INSERT OR REPLACE INTO sessions (
            session_id, add_count, subtract_count, 
            multiply_count, divide_count
        ) VALUES (?, ?, ?, ?, ?)
    `)
    if err != nil {
        return err
    }
    defer stmt.Close()

    _, err = stmt.Exec(
        session.SessionID,
        session.AddCount,
        session.SubtractCount,
        session.MultiplyCount,
        session.DivideCount,
    )
    return err
}