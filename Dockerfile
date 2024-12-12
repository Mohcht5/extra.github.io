# تحديد الصورة الأساسية
FROM node:18-alpine

# إعداد مجلد العمل داخل الحاوية
WORKDIR /app

# نسخ ملفات المشروع إلى الحاوية
COPY package.json package-lock.json ./
COPY server.js ./

# تثبيت الحزم المطلوبة
RUN npm install

# تحديد المنفذ الذي سيعمل عليه التطبيق
EXPOSE 3000

# تحديد الأمر الافتراضي لتشغيل التطبيق
CMD ["npm", "start"]
