const axios = require('axios');
async function test() {
  try {
    const loginRes = await axios.post('http://localhost:3001/api/auth/login', {
      employeeId: 'IT001',
      password: 'Admin@123'
    }, {
      headers: { 'x-requested-with': 'XMLHttpRequest' }
    });
    console.log('Login successful');
    const token = loginRes.data.token;
    const couponRes = await axios.get('http://localhost:3001/api/coupons/IT001', {
      headers: { Authorization: 'Bearer ' + token }
    });
    console.log('Coupon Status:', couponRes.data);
  } catch (err) {
    console.log('Error:', err.response?.data || err.message);
  }
}
test();
