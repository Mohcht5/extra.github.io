# استخدم صورة أساسية من Ubuntu أو Debian
FROM ubuntu:latest

# إعداد البيئة
ENV DEBIAN_FRONTEND=noninteractive

# تحديث النظام وتثبيت المتطلبات الأساسية
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y \
    git \
    wget \
    curl \
    bash \
    && apt-get clean

# استنساخ المستودع من GitHub
RUN git clone https://github.com/SlaSerX/FullIPTV /FullIPTV

# الانتقال إلى المجلد المناسب
WORKDIR /FullIPTV

# منح الأذونات للسكربتات
RUN chmod +x FullIPTV-v2.sh

# تعيين المنفذ 80
EXPOSE 80

# تنفيذ السكربت
CMD ["./FullIPTV-v2.sh"]
