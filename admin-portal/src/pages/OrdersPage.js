import React, { useEffect, useState } from "react";
import "./Common.css";

export default function OrdersPage() {
  const [orders, setOrders] = useState([]);

  useEffect(() => {
    loadOrders();
  }, []);

  const loadOrders = async () => {
    const res = await fetch("http://localhost:3001/api/orders");
    const data = await res.json();
    setOrders(data);
  };

  return (
    <div className="page-container fade-in">
      <h2>Orders</h2>

      <table className="styled-table">
        <thead>
          <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Date</th>
          </tr>
        </thead>
        <tbody>
          {orders.map((o, i) => (
            <tr key={i}>
              <td>{o.employee_name}</td>
              <td>{o.type}</td>
              <td>{o.created_at}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
