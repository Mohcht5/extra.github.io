package main

import (
	"context"
	"fmt"
	"log"
	"m3u-streamer/handlers"
	"m3u-streamer/store"
	"m3u-streamer/updater"
	"m3u-streamer/utils"
	"net/http"
	"os"
	"time"
	"strconv"
	"strings"
)

var (
	userName    = os.Getenv("USER_NAME")
	userPassword = os.Getenv("USER_PASSWORD")
	sessionDurationStr = os.Getenv("SESSION_DURATION")
	sessionExpiry time.Time
)

func main() {
	// Context for graceful shutdown
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	cm := store.NewConcurrencyManager()

	// Initialize updater
	utils.SafeLogln("Starting updater...")
	_, err := updater.Initialize(ctx)
	if err != nil {
		utils.SafeLogFatalf("Error initializing updater: %v", err)
	}

	// Set timezone from environment variable
	if tz := os.Getenv("TZ"); tz != "" {
		var err error
		time.Local, err = time.LoadLocation(tz)
		if err != nil {
			utils.SafeLogf("Error loading location '%s': %v\n", tz, err)
		}
	}

	// Calculate session expiration
	parsedDuration, err := time.ParseDuration(sessionDurationStr)
	if err != nil {
		utils.SafeLogFatalf("Invalid session duration: %v", err)
	}
	sessionExpiry = time.Now().Add(parsedDuration)

	// Set up HTTP handlers
	utils.SafeLogln("Setting up HTTP handlers...")
	http.HandleFunc("/playlist.m3u", func(w http.ResponseWriter, r *http.Request) {
		handlers.M3UHandler(w, r)
	})
	http.HandleFunc("/p/", func(w http.ResponseWriter, r *http.Request) {
		handlers.StreamHandler(w, r, cm)
	})

	// Add login handler
	http.HandleFunc("/login", loginHandler)

	// Start the server
	utils.SafeLogln(fmt.Sprintf("Server is running on port %s...", os.Getenv("PORT")))
	err = http.ListenAndServe(fmt.Sprintf(":%s", os.Getenv("PORT")), nil)
	if err != nil {
		utils.SafeLogFatalf("HTTP server error: %v", err)
	}
}

func loginHandler(w http.ResponseWriter, r *http.Request) {
	// Check if username and password match
	username := r.FormValue("username")
	password := r.FormValue("password")

	// Validate user credentials
	if username != userName || password != userPassword {
		http.Error(w, "Invalid username or password", http.StatusUnauthorized)
		return
	}

	// Check if the session has expired
	if time.Now().After(sessionExpiry) {
		http.Error(w, "Session expired", http.StatusUnauthorized)
		return
	}

	// Return success response
	w.Write([]byte("Login successful"))
}
