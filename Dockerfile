# استخدام صورة Ubuntu
FROM ubuntu:20.04

# تحديث النظام وتثبيت المتطلبات
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    software-properties-common \
    wget \
    && apt-get clean

# نسخ السكربت إلى الحاوية
COPY script.py /app/script.py

# تعيين مسار العمل
WORKDIR /app

# تثبيت المكتبات المطلوبة (إن وجدت)
RUN pip3 install --no-cache-dir some-python-library

# كشف المنفذ 80
EXPOSE 80

# تشغيل السكربت
CMD ["python3", "script.py"]
