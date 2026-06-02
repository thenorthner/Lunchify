import React, { useState } from "react";
import "./Common.css";

export default function MenuPage() {
  const [type, setType] = useState("food");
  const [items, setItems] = useState("");
  const date = new Date().toISOString().split("T")[0];

  const saveMenu = async () => {
    await fetch("http://localhost:3001/api/menu/update", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        date,
        lunchType: type,
        items,
      }),
    });

    alert("Menu saved for today");
    setItems("");
  };

  return (
    <div className="page-container fade-in">
      <h2>Update Today’s Menu</h2>

      <select value={type} onChange={(e) => setType(e.target.value)}>
        <option value="food">Food</option>
        <option value="fruit">Fruit</option>
        <option value="snacks">Snacks</option>
      </select>

      <textarea
        rows="6"
        placeholder="Enter items (one per line)"
        value={items}
        onChange={(e) => setItems(e.target.value)}
      />

      <button onClick={saveMenu}>Save Menu</button>
    </div>
  );
}
