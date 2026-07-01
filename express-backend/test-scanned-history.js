const axios = require('axios');
const jwt = require('jsonwebtoken');

const token = jwt.sign({ id: '5', role: 'canteen_admin', canteen_id: '5' }, 'your_super_secret_key_change_in_production_987654321', { expiresIn: '1h' });

axios.get('http://localhost:3001/api/qr/scanned-history?range=monthly', {
  headers: { Authorization: `Bearer ${token}` }
}).then(res => console.log(res.data)).catch(err => console.error(err.message));
