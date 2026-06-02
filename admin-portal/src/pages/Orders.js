import { useEffect, useState } from 'react';
import api from '../services/api';

export default function Orders() {
  const [orders, setOrders] = useState([]);

  useEffect(() => {
    api.get('/orders').then(res => setOrders(res.data));
  }, []);

  return (
    <div>
      <h2>Orders</h2>
      {orders.map(o => (
        <div key={o.id}>
          {o.employee_id} – ₹{o.total_amount}
        </div>
      ))}
    </div>
  );
}
