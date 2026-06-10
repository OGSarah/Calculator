package main

import (
	"os"

	"github.com/gin-gonic/gin"
)

// Development fallbacks used when the corresponding environment variables are
// unset. In a real deployment these would never be checked in — credentials
// would come solely from the environment or a secrets store.
const (
	defaultUsername = "admin"
	defaultPassword = "calculator123"
)

// basicAuth guards routes with HTTP Basic auth. Credentials are read from the
// CALC_USERNAME / CALC_PASSWORD environment variables, falling back to the
// development defaults above. gin.BasicAuth handles header parsing, a
// constant-time credential comparison, and the 401 / WWW-Authenticate response.
func basicAuth() gin.HandlerFunc {
	return gin.BasicAuth(gin.Accounts{
		authUsername(): authPassword(),
	})
}

func authUsername() string {
	return envOrDefault("CALC_USERNAME", defaultUsername)
}

func authPassword() string {
	return envOrDefault("CALC_PASSWORD", defaultPassword)
}

func envOrDefault(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}
