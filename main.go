package main

import (
	"log"
	"net/http"
	"net/url"
	"os"
)

func main() {
	// قراءة عنوان المصدر من المتغير البيئي SOURCE_URL
	target := os.Getenv("SOURCE_URL")
	if target == "" {
		log.Fatal("SOURCE_URL environment variable is required")
		os.Exit(1)
	}

	// تحليل عنوان المصدر إلى URL
	parsedURL, err := url.Parse(target)
	if err != nil {
		log.Fatal("Error parsing the target URL: ", err)
		os.Exit(1)
	}

	// إنشاء بروكسي HTTP
	proxy := http.NewServeMux()
	proxy.Handle("/", http.StripPrefix("/", http.ProxyURL(parsedURL)))

	// بدء الخادم للاستماع على المنفذ 8080
	log.Println("Starting proxy server on :8080...")
	err = http.ListenAndServe(":8080", proxy)
	if err != nil {
		log.Fatal("Error starting the proxy server: ", err)
	}
}
