# استخدام صورة Ubuntu
FROM ubuntu:20.04

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
