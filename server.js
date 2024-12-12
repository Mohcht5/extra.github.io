const express = require('express');
const request = require('request');
const app = express();

// استرداد قائمة القنوات من متغير البيئة
const streams = JSON.parse(process.env.STREAMS || "{}");

// إعداد البروكسي
app.get('/stream/:id', (req, res) => {
  const streamUrl = streams[req.params.id];
  if (!streamUrl) {
    return res.status(404).send("Stream not found");
  }

  // تمرير الطلب إلى الرابط الأصلي
  request(streamUrl).pipe(res);
});

// تشغيل الخادم
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Proxy server running on port ${PORT}`);
});
