package main

import (
	"fmt"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"strings"
	"github.com/gorilla/mux"
	"github.com/sirupsen/logrus"
	"strconv"
)

// دالة لقراءة القنوات من رابط m3u
func getChannelsFromM3U(url string) ([]string, error) {
	// تحميل محتوى ملف m3u من الرابط
	resp, err := http.Get(url)
	if err != nil {
		logrus.Error("Error fetching m3u file: ", err)
		return nil, err
	}
	defer resp.Body.Close()

	// قراءة القنوات من محتوى الملف
	var channels []string
	buf := make([]byte, 1024)
	for {
		n, err := resp.Body.Read(buf)
		if n > 0 {
			// إضافة القنوات إلى القائمة
			lines := strings.Split(string(buf[:n]), "\n")
			for _, line := range lines {
				// البحث عن روابط m3u (تبدأ بـ http)
				if strings.HasPrefix(line, "http") {
					channels = append(channels, line)
				}
			}
		}
		if err != nil {
			break
		}
	}

	if len(channels) == 0 {
		return nil, fmt.Errorf("No channels found in m3u file")
	}
	return channels, nil
}

// دالة للبث عبر البروكسي
func streamHandler(w http.ResponseWriter, r *http.Request) {
	// قراءة رقم القناة من معلمة الاستعلام
	channelID := r.URL.Query().Get("channel")
	if channelID == "" {
		http.Error(w, "Channel parameter is missing", http.StatusBadRequest)
		return
	}

	// الحصول على رابط m3u من المتغير البيئي
	m3uURL := os.Getenv("M3U_URL")
	if m3uURL == "" {
		http.Error(w, "M3U URL not set", http.StatusInternalServerError)
		return
	}

	// تحميل قائمة القنوات من الرابط
	channels, err := getChannelsFromM3U(m3uURL)
	if err != nil {
		http.Error(w, "Error loading channels from m3u", http.StatusInternalServerError)
		return
	}

	// التحقق من صحة القناة المطلوبة
	var channelIndex int
	channelIndex, err = strconv.Atoi(channelID)
	if err != nil || channelIndex < 1 || channelIndex > len(channels) {
		http.Error(w, "Invalid channel ID", http.StatusBadRequest)
		return
	}

	// الحصول على رابط القناة
	channelURL := channels[channelIndex-1]

	// تحويل رابط القناة إلى URL صالح
	proxyURL, err := url.Parse(channelURL)
	if err != nil {
		http.Error(w, "Error parsing channel URL", http.StatusBadRequest)
		return
	}

	// إعداد البروكسي
	proxy := httputil.NewSingleHostReverseProxy(proxyURL)

	// توجيه الطلب إلى البروكسي
	proxy.ServeHTTP(w, r)
}

// دالة لعرض صفحة القنوات
func channelsHandler(w http.ResponseWriter, r *http.Request) {
	// الحصول على رابط m3u من المتغير البيئي
	m3uURL := os.Getenv("M3U_URL")
	if m3uURL == "" {
		http.Error(w, "M3U URL not set", http.StatusInternalServerError)
		return
	}

	// تحميل قائمة القنوات
	channels, err := getChannelsFromM3U(m3uURL)
	if err != nil {
		http.Error(w, "Error loading channels from m3u", http.StatusInternalServerError)
		return
	}

	// عرض قائمة القنوات
	w.Header().Set("Content-Type", "text/html")
	w.Write([]byte("<h1>قائمة القنوات</h1>"))
	for i, channel := range channels {
		channelNumber := i + 1
		channelName := fmt.Sprintf("قناة %d", channelNumber)
		channelURL := fmt.Sprintf("http://localhost:8080/stream?channel=%d", channelNumber)
		w.Write([]byte(fmt.Sprintf("<p><a href='%s'>%s</a></p>", channelURL, channelName)))
	}
}

// إعداد الراوتر والمسارات
func setupRouter() *mux.Router {
	r := mux.NewRouter()
	r.HandleFunc("/stream", streamHandler).Methods("GET")
	r.HandleFunc("/channels", channelsHandler).Methods("GET")
	return r
}

func main() {
	// إعداد الراوتر
	r := setupRouter()

	// بدء السيرفر
	fmt.Println("Starting server on http://localhost:8080")
	http.ListenAndServe(":8080", r)
}
