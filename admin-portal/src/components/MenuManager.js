import React, { useState, useEffect } from "react";
import "./MenuManager.css";

export default function MenuManager() {
  const today = new Date().toISOString().split("T")[0];

  const [date, setDate] = useState(today);
  const [type, setType] = useState("lunch"); // lunch | fruit | snacks
  const [session, setSession] = useState("Morning"); // Morning | Evening (for snacks)
  const [items, setItems] = useState("");
  const [mode, setMode] = useState("set"); // set | view
  const [loading, setLoading] = useState(false);

  const token = localStorage.getItem("adminToken");

  const fetchMenu = async () => {
    setLoading(true);
    try {
      let url = "";
      if (type === "lunch") {
        url = `http://localhost:3001/api/menu/food?date=${date}`;
      } else if (type === "fruit") {
        url = `http://localhost:3001/api/menu/fruit?date=${date}`;
      } else if (type === "snacks") {
        url = `http://localhost:3001/api/menu/snacks-by-time?date=${date}&session=${session}`;
      }

      const res = await fetch(url, {
        headers: {
          "Authorization": `Bearer ${token}`
        }
      });
      const data = await res.json();

      if (res.ok) {
        if (type === "snacks") {
          const snackList = (data.items || []).map(item => `${item.name} - ${item.price}`).join("\n");
          setItems(snackList);
        } else {
          setItems((data.items || []).join("\n"));
        }
      } else {
        setItems("");
      }
    } catch (err) {
      console.error("❌ Error fetching menu:", err);
      setItems("");
    } finally {
      setLoading(false);
    }
  };

  const saveMenu = async () => {
    if (!items.trim()) {
      alert("Please enter some menu items first.");
      return;
    }

    try {
      let url = "";
      let bodyData = {};

      if (type === "lunch") {
        url = "http://localhost:3001/api/menu/food";
        bodyData = {
          menu_date: date,
          items: items.split("\n").map(i => i.trim()).filter(Boolean)
        };
      } else if (type === "fruit") {
        url = "http://localhost:3001/api/menu/fruit";
        bodyData = {
          menu_date: date,
          fruits: items.split("\n").map(i => i.trim()).filter(Boolean)
        };
      } else if (type === "snacks") {
        url = "http://localhost:3001/api/menu/snacks";
        const parsedItems = items.split("\n").map(line => {
          const parts = line.split("-");
          return {
            name: parts[0]?.trim(),
            price: parseFloat(parts[1]?.trim() || 0)
          };
        }).filter(item => item.name);

        bodyData = {
          menu_date: date,
          session: session,
          items: parsedItems
        };
      }

      const res = await fetch(url, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${token}`
        },
        body: JSON.stringify(bodyData),
      });

      if (res.ok) {
        alert("Menu saved successfully ✅");
      } else {
        const errorData = await res.json();
        alert(`Failed to save menu: ${errorData.message || errorData.error || "Unknown error"}`);
      }
    } catch (err) {
      console.error("❌ Save Menu Error:", err);
      alert("Network error while saving menu");
    }
  };

  useEffect(() => {
    if (mode === "view") fetchMenu();
  }, [mode, date, type, session]);

  return (
    <div className="menu-card">
      <div className="menu-header">
        <h2>🍽️ Menu Management</h2>

        <div className="menu-toggle">
          <button
            className={mode === "set" ? "active" : ""}
            onClick={() => setMode("set")}
          >
            Set Menu
          </button>
          <button
            className={mode === "view" ? "active" : ""}
            onClick={() => setMode("view")}
          >
            View Menu
          </button>
        </div>
      </div>

      <div className="menu-form">
        <label>
          Date
          <input
            type="date"
            value={date}
            onChange={(e) => setDate(e.target.value)}
          />
        </label>

        <label>
          Menu Type
          <select
            value={type}
            onChange={(e) => {
              setType(e.target.value);
              setItems("");
            }}
          >
            <option value="lunch">Lunch</option>
            <option value="fruit">Fruit</option>
            <option value="snacks">Snacks</option>
          </select>
        </label>

        {type === "snacks" && (
          <label>
            Snack Session
            <select
              value={session}
              onChange={(e) => {
                setSession(e.target.value);
                setItems("");
              }}
            >
              <option value="Morning">Morning Snacks</option>
              <option value="Evening">Evening Snacks</option>
            </select>
          </label>
        )}

        <label>
          Menu Items
          {type === "snacks" && (
            <small style={{ display: "block", color: "#666", marginBottom: "5px" }}>Format: Item - Price (one per line)</small>
          )}
          <textarea
            rows="6"
            value={items}
            onChange={(e) => setItems(e.target.value)}
            placeholder={
              type === "snacks"
                ? "Samosa - 20\nTea - 10"
                : type === "fruit"
                ? "Apple\nBanana\nPapaya"
                : "Rice\nDal\nSabzi"
            }
          />
        </label>

        {mode === "set" && (
          <button className="save-btn" onClick={saveMenu}>
            Save Menu
          </button>
        )}

        {mode === "view" && loading && <p>Loading menu...</p>}
      </div>
    </div>
  );
}
