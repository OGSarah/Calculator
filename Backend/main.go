package main

import (
    "database/sql"
    "encoding/json"
    "log"
    "net/http"
    "time"

    "github.com/gin-gonic/gin"
    _ "github.com/mattn/go-sqlite3"
)

// Session struct matches frontend JSON
type Session struct {
    SessionID     string    `json:"sessionId"`
    AddCount      int       `json:"addCount"`
    SubtractCount int       `json:"subtractCount"`
    MultiplyCount int       `json:"multiplyCount"`
    DivideCount   int       `json:"divideCount"`
    LastUpdated   time.Time `json:"lastUpdated,omitempty"`
}

func initDB() error {
    db, err := sql.Open("sqlite3", "./calculator.db")
    if err != nil {
        log.Println("Error opening database:", err)
        return err
    }
    defer db.Close()

    log.Println("Creating sessions table...")
    _, err = db.Exec(`
        CREATE TABLE IF NOT EXISTS sessions (
            session_id TEXT PRIMARY KEY,
            add_count INTEGER DEFAULT 0,
            subtract_count INTEGER DEFAULT 0,
            multiply_count INTEGER DEFAULT 0,
            divide_count INTEGER DEFAULT 0,
            last_updated DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    `)
    if err != nil {
        log.Println("Error creating table:", err)
        return err
    }
    log.Println("Database initialized successfully")
    return nil
}

func saveSession(db *sql.DB, session Session) error {
    stmt, err := db.Prepare(`
        INSERT OR REPLACE INTO sessions (
            session_id, add_count, subtract_count, 
            multiply_count, divide_count, last_updated
        ) VALUES (?, ?, ?, ?, ?, ?)
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
        session.LastUpdated,
    )
    return err
}

func main() {
    if err := initDB(); err != nil {
        log.Fatal(err)
    }

    db, err := sql.Open("sqlite3", "./calculator.db")
    if err != nil {
        log.Fatal("Error opening database in main:", err)
    }
    defer db.Close()

    router := gin.Default()

    // POST /api/session handler for saving session data
    router.POST("/api/session", func(c *gin.Context) {
        var session Session
        if err := c.ShouldBindJSON(&session); err != nil {
            log.Println("Error binding JSON:", err)
            c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
            return
        }
        log.Println("Received session:", session)
        if err := saveSession(db, session); err != nil {
            log.Println("Error saving session:", err)
            c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save session"})
            return
        }
        log.Println("Session saved successfully")
        c.JSON(http.StatusOK, gin.H{"message": "Session saved"})
    })

    // GET /api/sessions handler for fetching all sessions
    router.GET("/api/sessions", func(c *gin.Context) {
        rows, err := db.Query("SELECT session_id, add_count, subtract_count, multiply_count, divide_count, last_updated FROM sessions")
        if err != nil {
            log.Println("Query execution error:", err)
            c.JSON(http.StatusInternalServerError, gin.H{"error": "Query error"})
            return
        }
        defer rows.Close()

        sessions := make([]Session, 0)
        for rows.Next() {
            var s Session
            err := rows.Scan(&s.SessionID, &s.AddCount, &s.SubtractCount, &s.MultiplyCount, &s.DivideCount, &s.LastUpdated)
            if err != nil {
                log.Println("Scan error:", err)
                c.JSON(http.StatusInternalServerError, gin.H{"error": "Scan error"})
                return
            }
            sessions = append(sessions, s)
        }

        if err = rows.Err(); err != nil {
            log.Println("Rows error:", err)
            c.JSON(http.StatusInternalServerError, gin.H{"error": "Rows error"})
            return
        }

        c.JSON(http.StatusOK, sessions)
    })

    // Start server
    log.Println("Starting server on :3000")
    if err := router.Run(":3000"); err != nil {
        log.Fatal("Error starting server:", err)
    }
}