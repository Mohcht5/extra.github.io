# استخدم صورة Go الرسمية كأساس
FROM golang:1.20-alpine

# تعيين دليل العمل في الحاوية
WORKDIR /app

# نسخ ملفات المشروع إلى الحاوية
COPY . .

# تثبيت المكتبات المطلوبة
RUN go mod tidy

# بناء التطبيق
RUN go build -o proxy-app .

# تعيين المنفذ الذي سيعمل عليه التطبيق
EXPOSE 8080

# تشغيل التطبيق
CMD ["./proxy-app"]
