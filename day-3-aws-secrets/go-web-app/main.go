package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	// Read the environment variable injected by the EC2 server
	secret := os.Getenv("APP_SECRET")
	if secret == "" {
		secret = "No secret found! Running locally?"
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Secure App Running! Secret Value: %s\n", secret)
	})

	fmt.Println("Server starting on port 8080...", secret)
	log.Fatal(http.ListenAndServe(":8080", nil))
}