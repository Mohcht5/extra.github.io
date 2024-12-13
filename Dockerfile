# استخدم صورة أساسية من Ubuntu
FROM ubuntu:20.04

# تعيين البيئة لتجنب الأسئلة التفاعلية
ENV DEBIAN_FRONTEND=noninteractive

# تحديث النظام وتثبيت الحزم المطلوبة
RUN apt-get update && \
    apt-get install -y \
    wget \
    curl \
    gnupg \
    lsb-release \
    sudo \
    unzip \
    tar \
    git \
    && apt-get clean

# تحميل السكربت من GitHub
RUN wget https://raw.githubusercontent.com/iptvpanel/Xtream-Codes-1.60.0/master/installer.sh -O /installer.sh

# إعطاء صلاحيات التنفيذ للسكربت
RUN chmod +x /installer.sh

# تشغيل السكربت عند بدء الحاوية
CMD ["/installer.sh"]
