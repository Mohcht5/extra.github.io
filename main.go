package main

import (
	"fmt"
	"github.com/elazarl/goproxy"
	"net/http"
	"io"
)

func main() {
	// إنشاء خادم بروكسي
	proxy := goproxy.NewProxyHttpServer()
	proxy.Verbose = true

	// تعيين عنوان URL للمصدر الذي تريد إعادة بثه
	sourceURL := "https://stream1.freetv.fun/0--bein-sports-2-2.m3u8"

	// إعداد خادم HTTP لإعادة بث المحتوى
	http.HandleFunc("/bein-sports", func(w http.ResponseWriter, r *http.Request) {
		// إرسال الطلب إلى عنوان URL المصدر
		resp, err := http.Get(sourceURL)
		if err != nil {
			http.Error(w, fmt.Sprintf("Error: %s", err.Error()), http.StatusInternalServerError)
			return
		}
		defer resp.Body.Close()

		// نسخ المحتوى من المصدر إلى العميل
		w.Header().Set("Content-Type", "application/vnd.apple.mpegurl")
		io.Copy(w, resp.Body)
	})

	// بدء الخادم على المنفذ 8080
	http.ListenAndServe(":8080", nil)
}
