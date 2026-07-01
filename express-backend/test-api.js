const http = require('http');

http.get('http://127.0.0.1:3001/api/auth/check-id/30609', (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    console.log('Status Code:', res.statusCode);
    console.log('Response:', data);
  });
}).on('error', (err) => {
  console.log('Error: ', err.message);
});
