# استخدم صورة Node.js الأساسية
FROM node:18-alpine

# إعداد مجلد العمل داخل الحاوية
WORKDIR /app

# نسخ ملفات المشروع إلى الحاوية (إذا لم يكن هناك ملف package-lock.json)
COPY package.json ./

# تثبيت الحزم المطلوبة
RUN npm install

# نسخ باقي الملفات إذا كانت موجودة
COPY . .

# تحديد المنفذ الذي سيعمل عليه التطبيق
EXPOSE 3000

# تشغيل التطبيق
CMD ["npm", "start"]
