# استخدام صورة Ubuntu
FROM ubuntu:20.04

# تحديث النظام وتثبيت المتطلبات
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    wget \
    && apt-get clean

# نسخ السكربت إلى الحاوية
COPY script.py /app/script.py

# تعيين مسار العمل
WORKDIR /app

# تحميل الملف xui.tar.gz من الرابط
RUN wget -O /app/xui.tar.gz https://www.top4top.me/download/7GjKKDp3vUReZpp/EBnkmWkl6mR0y/xui.tar.gz

# تثبيت المكتبات المطلوبة لتشغيل XtremeUI
RUN pip3 install --no-cache-dir \
    Flask \
    Flask-SocketIO \
    requests \
    gunicorn

# تشغيل السكربت
CMD ["python3", "script.py"]

# كشف المنفذ 80
EXPOSE 80
