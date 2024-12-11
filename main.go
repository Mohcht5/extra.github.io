package main

import (
	"fmt"
	"net/http"
	"os"
	"strings"

	"github.com/joho/godotenv"
)

func main() {
	// تحميل متغيرات البيئة من ملف .env
	err := godotenv.Load()
	if err != nil {
		fmt.Println("Error loading .env file")
	}

	// الحصول على المتغيرات من البيئة
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080" // قيمة افتراضية إذا لم يتم تحديد المنفذ
	}

	user := os.Getenv("USER")
	pass := os.Getenv("PASS")

	// إعداد نقطة النهاية
	http.HandleFunc("/playlist.m3u", func(w http.ResponseWriter, r *http.Request) {
		// استخراج اسم المستخدم وكلمة المرور من الرابط
		reqUser := r.URL.Query().Get("user")
		reqPass := r.URL.Query().Get("pass")

		// تحقق من وجود اسم المستخدم وكلمة المرور
		if reqUser == "" || reqPass == "" {
			http.Error(w, "مفقود اسم المستخدم أو كلمة المرور", http.StatusBadRequest)
			return
		}

		// تحقق من صحة بيانات الدخول
		if reqUser != user || reqPass != pass {
			http.Error(w, "بيانات الدخول غير صحيحة", http.StatusUnauthorized)
			return
		}

		// إذا كانت البيانات صحيحة، قم بإرجاع قائمة M3U
		m3uURL := os.Getenv("M3U_URL")
		if m3uURL == "" {
			http.Error(w, "M3U URL غير محدد", http.StatusInternalServerError)
			return
		}

		// قم بجلب محتويات قائمة M3U من الرابط
		resp, err := http.Get(m3uURL)
		if err != nil {
			http.Error(w, "خطأ أثناء تحميل قائمة M3U", http.StatusInternalServerError)
			return
		}
		defer resp.Body.Close()

		// نسخ محتويات M3U إلى العميل
		w.Header().Set("Content-Type", "application/vnd.apple.mpegurl")
		w.WriteHeader(resp.StatusCode)
		_, _ = w.Write([]byte(strings.TrimSpace(m3uURL)))
	})

	// تشغيل الخادم
	fmt.Println("Server is running on port:", port)
	err = http.ListenAndServe(fmt.Sprintf(":%s", port), nil)
	if err != nil {
		fmt.Printf("HTTP server error: %v\n", err)
	}
}
