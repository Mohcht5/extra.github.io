# استخدم صورة Debian 11 كـ صورة أساسية
FROM debian:11

# تحديث الحزم وتثبيت المتطلبات الأساسية
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y curl sudo apache2 php php-cli php-mysqli php-curl php-json php-gd php-zip php-mbstring unzip wget gnupg2 && \
    apt-get clean

# تثبيت MySQL (أو MariaDB إذا كان الخيار المفضل)
RUN apt-get install -y mariadb-server

# تحميل وتثبيت FOS-Streaming
RUN curl -s https://raw.githubusercontent.com/theraw/FOS-Streaming-v69/master/install/debian11 | bash

# تعيين دليل العمل
WORKDIR /home/fos-streaming/fos

# فتح المنفذ 7777 للاستماع على واجهة FOS-Streaming
EXPOSE 7777

# تعيين البيئة الأساسية مثل كلمة مرور MySQL
ENV MYSQL_ROOT_PASSWORD=rootpassword

# نسخ ملف الإعدادات (إذا كان لديك ملف مخصص)
#COPY settings.php /home/fos-streaming/fos/www/settings.php

# إنشاء قاعدة البيانات (اختياري إذا كنت بحاجة إلى ذلك)
RUN mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS fos_streaming;"

# إعداد Cron Job لتشغيل السكربت بشكل دوري
RUN echo "*/2 * * * * /etc/alternatives/php /home/fos-streaming/fos/www/cron.php" >> /etc/crontab

# بدء Apache و MySQL بشكل متوازي
CMD service apache2 start && service mysql start && tail -f /dev/null
