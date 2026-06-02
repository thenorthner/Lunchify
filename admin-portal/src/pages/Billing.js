import React, { useState } from "react";
import Navbar from "../components/Navbar";

export default function Billing() {
  const [date, setDate] = useState("");
  const [bill, setBill] = useState(null);
  const [loading, setLoading] = useState(false);

  const fetchBill = async () => {
    if (!date) {
      alert("Please select a date");
      return;
    }

    setLoading(true);

    try {
      const res = await fetch(
        `http://localhost:3001/api/billing?date=${date}`,
        {
          headers: {
            Authorization: `Bearer ${localStorage.getItem("adminToken")}`,
          },
        }
      );

      const data = await res.json();
      if (!res.ok) {
        alert(data.message || "Error fetching bill");
        return;
      }

      setBill(data);
    } catch (err) {
      alert("Server not reachable");
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
      <Navbar />
      <div style={{ padding: 30 }}>
        <h2>Billing</h2>

        <div style={{ marginBottom: 20 }}>
          <input
            type="date"
            value={date}
            onChange={(e) => setDate(e.target.value)}
            style={{ padding: 8 }}
          />
          <button onClick={fetchBill} style={btn}>
            Generate Bill
          </button>
        </div>

        {loading && <p>Loading...</p>}

        {bill && (
          <div style={card}>
            <h3>Bill for {bill.date}</h3>

            <table style={table}>
              <thead>
                <tr>
                  <th>Category</th>
                  <th>Orders</th>
                  <th>Amount (₹)</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>Food</td>
                  <td>{bill.food.count || 0}</td>
                  <td>{bill.food.total || 0}</td>
                </tr>
                <tr>
                  <td>Fruit</td>
                  <td>{bill.fruit.count || 0}</td>
                  <td>{bill.fruit.total || 0}</td>
                </tr>
                <tr>
                  <td>Snacks</td>
                  <td>{bill.snacks.count || 0}</td>
                  <td>{bill.snacks.total || 0}</td>
                </tr>
              </tbody>
            </table>

            <h3 style={{ marginTop: 20 }}>
              Grand Total: ₹{bill.grandTotal}
            </h3>
          </div>
        )}
      </div>
    </>
  );
}

const btn = {
  marginLeft: 10,
  padding: "8px 14px",
  background: "#0056a6",
  color: "white",
  border: "none",
  cursor: "pointer",
};

const card = {
  background: "#fff",
  padding: 20,
  borderRadius: 10,
  boxShadow: "0 4px 12px rgba(0,0,0,0.1)",
  width: "500px",
};

const table = {
  width: "100%",
  borderCollapse: "collapse",
};
