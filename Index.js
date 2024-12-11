const http = require('http');
const https = require('https');
const url = require('url');

const server = http.createServer((req, res) => {
    const parsedUrl = url.parse(req.url, true);
    const targetUrl = decodedUrl.parsedUrl.query.url; // استخدم الرابط الأصلي من query

    if (targetUrl) {
        const parsedTarget = url.parse(targetUrl);
        const proxy = parsedTarget.protocol === 'https:' ? https : http;

        proxy.get(targetUrl, (proxyRes) => {
            res.writeHead(proxyRes.statusCode, proxyRes.headers);
            proxyRes.pipe(res, { end: true });
        }).on('error', (err) => {
            res.statusCode = 500;
            res.end('Proxy Error: ' + err.message);
        });
    } else {
        res.statusCode = 400;
        res.end('No URL Provided');
    }
});

server.listen(3000, () => {
    console.log('Proxy server is running...');
});
