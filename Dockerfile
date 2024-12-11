# استخدام صورة Go الرسمية
FROM golang:1.20 AS builder

# تعيين مجلد العمل داخل الحاوية
WORKDIR /app

# نسخ ملفات go.mod و go.sum فقط أولاً
COPY go.mod go.sum ./

# تثبيت المكتبات المطلوبة
RUN go mod tidy

# نسخ باقي الملفات
COPY . .

# بناء التطبيق باستخدام Go
RUN go build -o proxy-app main.go

# الصورة النهائية
FROM alpine:latest

# تثبيت الأدوات الأساسية لتشغيل التطبيق
RUN apk --no-cache add ca-certificates

# نسخ التطبيق من مرحلة البناء
COPY --from=builder /app/proxy-app /usr/local/bin/proxy-app

# تشغيل التطبيق عند بدء الحاوية
ENTRYPOINT ["/usr/local/bin/proxy-app"]

# الاستماع على المنفذ 8080
EXPOSE 8080
