# استخدام صورة أساسية من Ubuntu
FROM ubuntu:20.04

# تحديث الحزم وتثبيت الأدوات المطلوبة
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    bash \
    git \
    && rm -rf /var/lib/apt/lists/*

# تعيين مجلد العمل
WORKDIR /app

# تنزيل السكربت
RUN wget https://raw.githubusercontent.com/spawk/FIPTV-V2/master/fulliptv.sh

# جعل السكربت قابلًا للتنفيذ
RUN chmod +x fulliptv.sh

# تعيين المنفذ 8080
EXPOSE 8080

# تشغيل السكربت
CMD ["./fulliptv.sh"]
