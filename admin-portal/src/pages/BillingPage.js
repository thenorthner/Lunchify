import React, { useState } from "react";
import "./Common.css";

export default function BillingPage() {
  const [from, setFrom] = useState("");
  const [to, setTo] = useState("");
  const [bill, setBill] = useState(null);
  const [error, setError] = useState("");

  const generateBill = async () => {
    if (!from || !to) {
      setError("Please select both dates");
      return;
    }

    setError("");

    try {
      const res = await fetch(
        `http://localhost:3001/api/billing/range?from=${from}&to=${to}`
      );

      const data = await res.json();

      if (!res.ok) {
        throw new Error(data.message || "Billing failed");
      }

      setBill(data);
    } catch (err) {
      console.error(err);
      setError("Unable to generate bill");
    }
  };

  return (
    <div className="page-container fade-in">
      <h2>Billing</h2>

      <div className="billing-controls">
        <input type="date" onChange={(e) => setFrom(e.target.value)} />
        <input type="date" onChange={(e) => setTo(e.target.value)} />
        <button onClick={generateBill}>Generate Bill</button>
      </div>

      {error && <p style={{ color: "red" }}>{error}</p>}

      {bill && (
        <div className="billing-card">
          <p>
            Total Coupons Used: <strong>{bill.totalCoupons}</strong>
          </p>
          <p>
            Total Amount: <strong>₹ {bill.amount}</strong>
          </p>
        </div>
      )}
    </div>
  );
}
