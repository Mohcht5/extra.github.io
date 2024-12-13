# استخدم صورة Nginx الرسمية
FROM nginx:latest

# نسخ إعدادات Nginx المخصصة
COPY nginx.conf /etc/nginx/nginx.conf

# فتح المنفذ 80
EXPOSE 80
