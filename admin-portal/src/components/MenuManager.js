import React, { useState, useEffect } from "react";
import PageHeader from "./PageHeader";
import CalendarMonthIcon from "@mui/icons-material/CalendarMonth";
import CalendarTodayIcon from "@mui/icons-material/CalendarToday";
import AddIcon from "@mui/icons-material/Add";
import CloseIcon from "@mui/icons-material/Close";
import RestaurantIcon from "@mui/icons-material/Restaurant";
import AppleIcon from "@mui/icons-material/Apple";
import LocalCafeIcon from "@mui/icons-material/LocalCafe";
import DarkModeIcon from "@mui/icons-material/DarkMode";
import SaveIcon from "@mui/icons-material/Save";
import { CircularProgress } from "@mui/material";
import "./MenuManager.css";
import api from "../services/api";

const Section = ({ icon: Icon, no, title, kicker, children }) => (
  <div className="atelier brass-corner" style={{ padding: "28px" }} data-testid={`section-${title?.toString().toLowerCase().replace(/\s+/g, "-")}`}>
    <div style={{ display: "flex", alignItems: "flex-start", gap: "20px" }}>
      <div
        style={{
          display: "grid",
          placeItems: "center",
          flexShrink: 0,
          width: 44,
          height: 44,
          borderRadius: 12,
          background: "var(--emerald-soft)",
          color: "var(--emerald)",
          border: "1px solid rgba(31,90,71,.18)",
        }}
      >
        <Icon style={{ fontSize: 18 }} />
      </div>
      <div style={{ flex: 1 }}>
        <div style={{ display: "flex", alignItems: "baseline", gap: "12px" }}>
          <span className="font-display" style={{ fontStyle: "italic", fontSize: "14px", color: "var(--brass)" }}>{no}</span>
          <h3 className="font-display" style={{ fontSize: "24px", fontWeight: 500, letterSpacing: "-0.02em", margin: 0 }}>{title}</h3>
        </div>
        {kicker && <div className="eyebrow" style={{ marginTop: "4px" }}>{kicker}</div>}
      </div>
    </div>
    <div style={{ marginTop: "24px" }}>{children}</div>
  </div>
);

const Tag = ({ children, onRemove }) => (
  <span
    style={{
      display: "inline-flex",
      alignItems: "center",
      gap: "8px",
      padding: "6px 6px 6px 14px",
      borderRadius: "9999px",
      background: "var(--paper)",
      border: "1px solid var(--hairline-strong)",
      color: "var(--ink)",
      fontSize: 13,
    }}
  >
    {children}
    <button
      onClick={onRemove}
      style={{
        display: "grid",
        placeItems: "center",
        borderRadius: "9999px",
        width: 18,
        height: 18,
        background: "var(--bone)",
        color: "var(--ink-muted)",
        border: "none",
        cursor: "pointer",
        padding: 0
      }}
      data-testid={`remove-${children}`}
    >
      <CloseIcon style={{ fontSize: 11 }} />
    </button>
  </span>
);

export default function MenuManager() {
  const today = new Date().toISOString().split("T")[0];

  const [tabIndex, setTabIndex] = useState(0); // 0 = Specific Date, 1 = Weekly Template
  const [date, setDate] = useState(today);
  const [dayOfWeek, setDayOfWeek] = useState(new Date().getDay() || 7);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);

  const [foodItems, setFoodItems] = useState([]);
  const [newFood, setNewFood] = useState("");

  const [fruitItems, setFruitItems] = useState([]);
  const [newFruit, setNewFruit] = useState("");

  const [morningSnacks, setMorningSnacks] = useState([]);
  const [newSnackName, setNewSnackName] = useState("");
  const [newSnackPrice, setNewSnackPrice] = useState("");

  const [eveningSnacks, setEveningSnacks] = useState([]);
  const [newEveningSnackName, setNewEveningSnackName] = useState("");
  const [newEveningSnackPrice, setNewEveningSnackPrice] = useState("");

  // Fetch logic
  const fetchMenu = async () => {
    setLoading(true);
    setFoodItems([]);
    setFruitItems([]);
    setMorningSnacks([]);
    setEveningSnacks([]);

    try {
      let foodUrl = `/menu/food?date=${date}`;
      let fruitUrl = `/menu/fruit?date=${date}`;
      let snacksUrl = `/menu/snacks?date=${date}&session=Morning`;
      let eveningSnacksUrl = `/menu/snacks?date=${date}&session=Evening`;

      const [resFood, resFruit, resSnacks, resEveningSnacks] = await Promise.all([
        api.get(foodUrl),
        api.get(fruitUrl),
        api.get(snacksUrl),
        api.get(eveningSnacksUrl)
      ]);

      if (resFood.data) setFoodItems(resFood.data.items || []);
      if (resFruit.data) setFruitItems(resFruit.data.items || []);
      if (resSnacks.data) setMorningSnacks(resSnacks.data.items || []);
      if (resEveningSnacks.data) setEveningSnacks(resEveningSnacks.data.items || []);
    } catch (err) {
      console.error("❌ Error fetching menu:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchMenu();
  }, [date, tabIndex, dayOfWeek]);

  // Add Item Logic
  const handleAddFood = () => {
    if (newFood.trim()) {
      setFoodItems([...foodItems, newFood.trim()]);
      setNewFood("");
    }
  };

  const handleAddFruit = () => {
    if (newFruit.trim()) {
      setFruitItems([...fruitItems, newFruit.trim()]);
      setNewFruit("");
    }
  };

  const handleAddSnack = () => {
    if (newSnackName.trim() && newSnackPrice.trim()) {
      setMorningSnacks([...morningSnacks, { name: newSnackName.trim(), price: parseFloat(newSnackPrice) }]);
      setNewSnackName("");
      setNewSnackPrice("");
    }
  };

  const handleAddEveningSnack = () => {
    if (newEveningSnackName.trim() && newEveningSnackPrice.trim()) {
      setEveningSnacks([...eveningSnacks, { name: newEveningSnackName.trim(), price: parseFloat(newEveningSnackPrice) }]);
      setNewEveningSnackName("");
      setNewEveningSnackPrice("");
    }
  };

  // Remove Item Logic
  const handleRemoveFood = (idx) => {
    setFoodItems(foodItems.filter((_, i) => i !== idx));
  };
  const handleRemoveFruit = (idx) => {
    setFruitItems(fruitItems.filter((_, i) => i !== idx));
  };
  const handleRemoveSnack = (idx) => {
    setMorningSnacks(morningSnacks.filter((_, i) => i !== idx));
  };
  const handleRemoveEveningSnack = (idx) => {
    setEveningSnacks(eveningSnacks.filter((_, i) => i !== idx));
  };

  // Save All
  const saveAllMenus = async () => {
    setSaving(true);
    try {
      let foodUrl = "/menu/food";
      let fruitUrl = "/menu/fruit";
      let snacksUrl = "/menu/snacks";
      let eveningSnacksUrl = "/menu/snacks";

      let foodBody = { menu_date: date, items: foodItems };
      let fruitBody = { menu_date: date, fruits: fruitItems };
      let snacksBody = { menu_date: date, session: "Morning", items: morningSnacks };
      let eveningSnacksBody = { menu_date: date, session: "Evening", items: eveningSnacks };

      if (tabIndex === 1) {
        foodUrl = "/menu/weekly/food";
        fruitUrl = "/menu/weekly/fruit";
        snacksUrl = "/menu/weekly/snacks";
        eveningSnacksUrl = "/menu/weekly/snacks";

        foodBody = { day_of_week: dayOfWeek, items: foodItems };
        fruitBody = { day_of_week: dayOfWeek, fruits: fruitItems };
        snacksBody = { day_of_week: dayOfWeek, session: "Morning", items: morningSnacks };
        eveningSnacksBody = { day_of_week: dayOfWeek, session: "Evening", items: eveningSnacks };
      }

      await Promise.all([
        api.post(foodUrl, foodBody),
        api.post(fruitUrl, fruitBody),
        api.post(snacksUrl, snacksBody),
        api.post(eveningSnacksUrl, eveningSnacksBody)
      ]);

      alert("All Menus Saved Successfully");
    } catch (err) {
      console.error("❌ Save Menu Error:", err);
      alert("Network error while saving menus");
    } finally {
      setSaving(false);
    }
  };

  return (
    <div style={{ paddingBottom: "40px" }}>
      <PageHeader
        eyebrow="Chapter I · Curation"
        title="Compose the day's"
        italicTail="culinary programme"
        description="Set the canteen's offerings with the deliberation of a maître d'. Items here flow directly to coupon generation and downstream billing."
        right={
          <div className="chip" style={{ display: "flex", alignItems: "center", gap: "8px" }} data-testid="date-chip">
            <CalendarMonthIcon style={{ fontSize: 14 }} />
            <span className="eyebrow">Service Date</span>
            <span className="font-mono-tab" style={{ fontSize: "12px" }}>
              {tabIndex === 0 ? date : ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"][dayOfWeek - 1]}
            </span>
          </div>
        }
      />

      {/* Mode toggle */}
      <div className="atelier" style={{ display: "flex", alignItems: "center", gap: "4px", padding: "4px", width: "fit-content", marginBottom: "32px" }} data-testid="mode-toggle">
        {[
          { k: 0, label: "Specific Date", icon: CalendarMonthIcon },
          { k: 1, label: "Weekly Template", icon: CalendarTodayIcon },
        ].map((m) => (
          <button
            key={m.k}
            onClick={() => setTabIndex(m.k)}
            data-active={tabIndex === m.k}
            data-testid={`mode-\${m.k}`}
            style={{
              display: "flex",
              alignItems: "center",
              gap: "8px",
              padding: "10px 20px",
              borderRadius: "10px",
              fontSize: "13px",
              fontWeight: 500,
              transition: "all 0.2s",
              background: tabIndex === m.k ? "var(--ink)" : "transparent",
              color: tabIndex === m.k ? "var(--paper)" : "var(--ink-muted)",
              border: "none",
              cursor: "pointer"
            }}
          >
            <m.icon style={{ fontSize: 14 }} />
            {m.label}
          </button>
        ))}
      </div>

      {/* Date override */}
      <div className="atelier" style={{ padding: "24px", marginBottom: "32px", display: "flex", alignItems: "center", justifyContent: "space-between" }} data-testid="date-override">
        <div>
          <div className="eyebrow" style={{ marginBottom: "4px" }}>
            {tabIndex === 0 ? "Date Override" : "Select Day"}
          </div>
          <div className="font-display" style={{ fontSize: "20px", fontWeight: 500 }}>
            {tabIndex === 0 ? "Specific Service Date" : "Recurring Weekly Setup"}
          </div>
        </div>
        {tabIndex === 0 ? (
          <input
            type="date"
            value={date}
            onChange={(e) => setDate(e.target.value)}
            className="input-atelier font-mono-tab"
            style={{ maxWidth: "200px" }}
            data-testid="date-input"
          />
        ) : (
          <select
            value={dayOfWeek}
            onChange={(e) => setDayOfWeek(parseInt(e.target.value))}
            className="input-atelier"
            style={{ maxWidth: "200px" }}
          >
            <option value={1}>Monday</option>
            <option value={2}>Tuesday</option>
            <option value={3}>Wednesday</option>
            <option value={4}>Thursday</option>
            <option value={5}>Friday</option>
            <option value={6}>Saturday</option>
            <option value={7}>Sunday</option>
          </select>
        )}
      </div>

      {loading ? (
        <div style={{ display: "flex", justifyContent: "center", padding: "40px" }}>
          <CircularProgress style={{ color: "var(--ink)" }} />
        </div>
      ) : (
        <div className="menu-grid">
          <Section icon={RestaurantIcon} no="i." title="Food Menu" kicker="Lunch · Mains">
            <div style={{ display: "flex", flexWrap: "wrap", gap: "8px", marginBottom: "16px" }}>
              {foodItems.map((f, i) => (
                <Tag key={i} onRemove={() => handleRemoveFood(i)}>{f}</Tag>
              ))}
              {foodItems.length === 0 && <span style={{ fontSize: "13px", color: "var(--ink-faint)" }}>No items yet.</span>}
            </div>
            <div style={{ display: "flex", gap: "8px" }}>
              <input
                className="input-atelier"
                placeholder="Enter food item…"
                value={newFood}
                onChange={(e) => setNewFood(e.target.value)}
                onKeyDown={(e) => e.key === "Enter" && handleAddFood()}
                data-testid="food-input"
              />
              <button onClick={handleAddFood} className="btn-ink" style={{ padding: "0 20px" }} data-testid="add-food"><AddIcon style={{ fontSize: 16 }} /></button>
            </div>
          </Section>

          <Section icon={AppleIcon} no="ii." title="Fruit Menu" kicker="Seasonal · Fresh">
            <div style={{ display: "flex", flexWrap: "wrap", gap: "8px", marginBottom: "16px" }}>
              {fruitItems.map((f, i) => (
                <Tag key={i} onRemove={() => handleRemoveFruit(i)}>{f}</Tag>
              ))}
              {fruitItems.length === 0 && <span style={{ fontSize: "13px", color: "var(--ink-faint)" }}>No items yet.</span>}
            </div>
            <div style={{ display: "flex", gap: "8px" }}>
              <input
                className="input-atelier"
                placeholder="Enter fruit name…"
                value={newFruit}
                onChange={(e) => setNewFruit(e.target.value)}
                onKeyDown={(e) => e.key === "Enter" && handleAddFruit()}
                data-testid="fruit-input"
              />
              <button onClick={handleAddFruit} className="btn-ink" style={{ padding: "0 20px" }} data-testid="add-fruit"><AddIcon style={{ fontSize: 16 }} /></button>
            </div>
          </Section>

          <Section icon={LocalCafeIcon} no="iii." title="Morning Snacks" kicker="à la carte · Priced">
            <div style={{ display: "flex", flexDirection: "column", gap: "8px", marginBottom: "16px" }}>
              {morningSnacks.map((s, i) => (
                <div key={i} style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "10px 16px", borderRadius: "10px", background: "var(--paper)", border: "1px solid var(--hairline)" }}>
                  <span style={{ fontSize: "14px" }}>{s.name}</span>
                  <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
                    <span className="font-mono-tab" style={{ fontSize: "13px", color: "var(--emerald)" }}>₹{s.price.toFixed(2)}</span>
                    <button onClick={() => handleRemoveSnack(i)} style={{ color: "var(--ink-faint)", background: "transparent", border: "none", cursor: "pointer", padding: 0 }} data-testid={`remove-morning-\${i}`}>
                      <CloseIcon style={{ fontSize: 14 }} />
                    </button>
                  </div>
                </div>
              ))}
            </div>
            <div style={{ display: "grid", gridTemplateColumns: "1fr 120px auto", gap: "8px" }}>
              <input className="input-atelier" placeholder="Snack name…" value={newSnackName} onChange={(e) => setNewSnackName(e.target.value)} data-testid="morning-name" />
              <input className="input-atelier font-mono-tab" type="number" placeholder="₹ Price" value={newSnackPrice} onChange={(e) => setNewSnackPrice(e.target.value)} data-testid="morning-price" />
              <button onClick={handleAddSnack} className="btn-ink" style={{ padding: "0 16px" }} data-testid="add-morning"><AddIcon style={{ fontSize: 16 }} /></button>
            </div>
          </Section>

          <Section icon={DarkModeIcon} no="iv." title="Evening Snacks" kicker="à la carte · Priced">
            <div style={{ display: "flex", flexDirection: "column", gap: "8px", marginBottom: "16px" }}>
              {eveningSnacks.map((s, i) => (
                <div key={i} style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "10px 16px", borderRadius: "10px", background: "var(--paper)", border: "1px solid var(--hairline)" }}>
                  <span style={{ fontSize: "14px" }}>{s.name}</span>
                  <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
                    <span className="font-mono-tab" style={{ fontSize: "13px", color: "var(--emerald)" }}>₹{s.price.toFixed(2)}</span>
                    <button onClick={() => handleRemoveEveningSnack(i)} style={{ color: "var(--ink-faint)", background: "transparent", border: "none", cursor: "pointer", padding: 0 }} data-testid={`remove-evening-\${i}`}>
                      <CloseIcon style={{ fontSize: 14 }} />
                    </button>
                  </div>
                </div>
              ))}
            </div>
            <div style={{ display: "grid", gridTemplateColumns: "1fr 120px auto", gap: "8px" }}>
              <input className="input-atelier" placeholder="Snack name…" value={newEveningSnackName} onChange={(e) => setNewEveningSnackName(e.target.value)} data-testid="evening-name" />
              <input className="input-atelier font-mono-tab" type="number" placeholder="₹ Price" value={newEveningSnackPrice} onChange={(e) => setNewEveningSnackPrice(e.target.value)} data-testid="evening-price" />
              <button onClick={handleAddEveningSnack} className="btn-ink" style={{ padding: "0 16px" }} data-testid="add-evening"><AddIcon style={{ fontSize: 16 }} /></button>
            </div>
          </Section>
        </div>
      )}

      {!loading && (
        <div className="atelier" style={{ marginTop: "40px", padding: "24px", display: "flex", alignItems: "center", justifyContent: "space-between", flexWrap: "wrap", gap: "16px" }} data-testid="save-bar">
          <div>
            <div className="eyebrow">Ready for service</div>
            <div className="font-display" style={{ fontSize: "20px", marginTop: "4px", fontWeight: 500 }}>
              {foodItems.length + fruitItems.length + morningSnacks.length + eveningSnacks.length} items composed across 4 chapters
            </div>
          </div>
          <button onClick={saveAllMenus} disabled={saving} className="btn-brass" style={{ display: "flex", alignItems: "center", gap: "8px", border: "none", cursor: saving ? "not-allowed" : "pointer" }} data-testid="save-all">
            {saving ? <CircularProgress size={16} style={{ color: "var(--ink)" }} /> : <SaveIcon style={{ fontSize: 16 }} />}
            {saving ? "Committing..." : "Commit Menu"}
          </button>
        </div>
      )}
    </div>
  );
}

