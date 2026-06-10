package main

import (
	"bytes"
	"database/sql"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"path/filepath"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	_ "github.com/mattn/go-sqlite3"
)

func init() {
	// Keep test output quiet and deterministic.
	gin.SetMode(gin.TestMode)
}

// newTestDB returns a schema-initialized database backed by a throwaway file
// that the test framework cleans up automatically.
func newTestDB(t *testing.T) *sql.DB {
	t.Helper()
	path := filepath.Join(t.TempDir(), "test.db")
	db, err := sql.Open("sqlite3", path)
	if err != nil {
		t.Fatalf("opening test db: %v", err)
	}
	t.Cleanup(func() { db.Close() })

	if err := createSchema(db); err != nil {
		t.Fatalf("creating schema: %v", err)
	}
	return db
}

// addAuth attaches valid Basic auth credentials to a request.
func addAuth(req *http.Request) *http.Request {
	req.SetBasicAuth(defaultUsername, defaultPassword)
	return req
}

func sampleSession() Session {
	return Session{
		SessionID:     "550e8400-e29b-41d4-a716-446655440000",
		AddCount:      3,
		SubtractCount: 1,
		MultiplyCount: 2,
		DivideCount:   0,
		LastUpdated:   time.Date(2025, 2, 26, 10, 0, 0, 0, time.UTC),
	}
}

// MARK: - Persistence

func TestSaveSessionPersistsRow(t *testing.T) {
	db := newTestDB(t)
	want := sampleSession()

	if err := saveSession(db, want); err != nil {
		t.Fatalf("saveSession returned error: %v", err)
	}

	sessions, err := fetchSessions(db)
	if err != nil {
		t.Fatalf("fetchSessions returned error: %v", err)
	}
	if len(sessions) != 1 {
		t.Fatalf("expected 1 session, got %d", len(sessions))
	}

	got := sessions[0]
	if got.SessionID != want.SessionID {
		t.Errorf("SessionID = %q, want %q", got.SessionID, want.SessionID)
	}
	if got.AddCount != want.AddCount || got.SubtractCount != want.SubtractCount ||
		got.MultiplyCount != want.MultiplyCount || got.DivideCount != want.DivideCount {
		t.Errorf("counts = %+v, want add=%d sub=%d mul=%d div=%d",
			got, want.AddCount, want.SubtractCount, want.MultiplyCount, want.DivideCount)
	}
}

func TestSaveSessionUpsertsOnSameID(t *testing.T) {
	db := newTestDB(t)
	session := sampleSession()

	if err := saveSession(db, session); err != nil {
		t.Fatalf("first save: %v", err)
	}
	// Same id, updated counts — should replace, not duplicate.
	session.AddCount = 99
	if err := saveSession(db, session); err != nil {
		t.Fatalf("second save: %v", err)
	}

	sessions, err := fetchSessions(db)
	if err != nil {
		t.Fatalf("fetchSessions: %v", err)
	}
	if len(sessions) != 1 {
		t.Fatalf("expected upsert to keep 1 row, got %d", len(sessions))
	}
	if sessions[0].AddCount != 99 {
		t.Errorf("AddCount = %d, want 99 (updated value)", sessions[0].AddCount)
	}
}

func TestFetchSessionsEmptyReturnsEmptySlice(t *testing.T) {
	db := newTestDB(t)

	sessions, err := fetchSessions(db)
	if err != nil {
		t.Fatalf("fetchSessions: %v", err)
	}
	if sessions == nil {
		t.Fatal("expected non-nil empty slice, got nil")
	}
	if len(sessions) != 0 {
		t.Errorf("expected 0 sessions, got %d", len(sessions))
	}
}

// MARK: - Handlers

func TestSaveSessionHandlerSuccess(t *testing.T) {
	db := newTestDB(t)
	router := setupRouter(db)

	body, _ := json.Marshal(sampleSession())
	req := addAuth(httptest.NewRequest(http.MethodPost, "/api/session", bytes.NewReader(body)))
	req.Header.Set("Content-Type", "application/json")
	rec := httptest.NewRecorder()

	router.ServeHTTP(rec, req)

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d (body: %s)", rec.Code, http.StatusOK, rec.Body.String())
	}

	// The handler should have persisted the row.
	sessions, err := fetchSessions(db)
	if err != nil {
		t.Fatalf("fetchSessions: %v", err)
	}
	if len(sessions) != 1 {
		t.Fatalf("expected handler to persist 1 session, got %d", len(sessions))
	}
}

func TestSaveSessionHandlerRejectsInvalidJSON(t *testing.T) {
	db := newTestDB(t)
	router := setupRouter(db)

	req := addAuth(httptest.NewRequest(http.MethodPost, "/api/session", bytes.NewReader([]byte("{not valid json"))))
	req.Header.Set("Content-Type", "application/json")
	rec := httptest.NewRecorder()

	router.ServeHTTP(rec, req)

	if rec.Code != http.StatusBadRequest {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusBadRequest)
	}
}

func TestGetSessionsHandlerReturnsStoredSessions(t *testing.T) {
	db := newTestDB(t)
	if err := saveSession(db, sampleSession()); err != nil {
		t.Fatalf("seeding session: %v", err)
	}
	router := setupRouter(db)

	req := addAuth(httptest.NewRequest(http.MethodGet, "/api/sessions", nil))
	rec := httptest.NewRecorder()

	router.ServeHTTP(rec, req)

	if rec.Code != http.StatusOK {
		t.Fatalf("status = %d, want %d", rec.Code, http.StatusOK)
	}

	var sessions []Session
	if err := json.Unmarshal(rec.Body.Bytes(), &sessions); err != nil {
		t.Fatalf("decoding response: %v (body: %s)", err, rec.Body.String())
	}
	if len(sessions) != 1 {
		t.Fatalf("expected 1 session in response, got %d", len(sessions))
	}
	if sessions[0].SessionID != sampleSession().SessionID {
		t.Errorf("SessionID = %q, want %q", sessions[0].SessionID, sampleSession().SessionID)
	}
}

// MARK: - Auth

func TestRoutesRejectMissingCredentials(t *testing.T) {
	router := setupRouter(newTestDB(t))

	body, _ := json.Marshal(sampleSession())
	req := httptest.NewRequest(http.MethodPost, "/api/session", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	rec := httptest.NewRecorder()

	router.ServeHTTP(rec, req)

	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("status = %d, want %d for request without credentials", rec.Code, http.StatusUnauthorized)
	}
}

func TestRoutesRejectInvalidCredentials(t *testing.T) {
	router := setupRouter(newTestDB(t))

	req := httptest.NewRequest(http.MethodGet, "/api/sessions", nil)
	req.SetBasicAuth("admin", "wrong-password")
	rec := httptest.NewRecorder()

	router.ServeHTTP(rec, req)

	if rec.Code != http.StatusUnauthorized {
		t.Fatalf("status = %d, want %d for request with bad credentials", rec.Code, http.StatusUnauthorized)
	}
}
