# استخدام صورة Ubuntu
FROM ubuntu:20.04

# تعيين متغير البيئة لتجنب التفاعل أثناء تثبيت tzdata
ENV DEBIAN_FRONTEND=noninteractive

# تحديث النظام وتثبيت المتطلبات
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    software-properties-common \
    wget \
    tzdata \
    && apt-get clean

# تعيين المنطقة الزمنية إلى US
RUN ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# تنزيل ملف xui.tar.gz من الرابط
RUN wget -O /app/xui.tar.gz https://www.top4top.me/download/7GjKKDp3vUReZpp/EBnkmWkl6mR0y/xui.tar.gz

# نسخ السكربت إلى الحاوية
COPY script.py /app/script.py

# تعيين مسار العمل
WORKDIR /app

# تثبيت مكتبات Python المطلوبة (مثال: Flask)
RUN pip3 install --no-cache-dir flask

# كشف المنفذ 80
EXPOSE 80

# تشغيل السكربت
CMD ["python3", "script.py"]
