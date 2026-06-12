import React, { useState, useEffect } from "react";
import { Tabs, Tab, Chip, IconButton, Button, CircularProgress } from "@mui/material";
import AddIcon from "@mui/icons-material/Add";
import RestaurantIcon from "@mui/icons-material/Restaurant";
import LocalCafeIcon from "@mui/icons-material/LocalCafe";
import FastfoodIcon from "@mui/icons-material/Fastfood";
import CalendarMonthIcon from "@mui/icons-material/CalendarMonth";
import "./MenuManager.css";

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

  const token = localStorage.getItem("adminToken");

  // Fetch logic
  const fetchMenu = async () => {
    setLoading(true);
    setFoodItems([]);
    setFruitItems([]);
    setMorningSnacks([]);
    
    try {
      let foodUrl = `http://localhost:3001/api/menu/food?date=${date}`;
      let fruitUrl = `http://localhost:3001/api/menu/fruit?date=${date}`;
      let snacksUrl = `http://localhost:3001/api/menu/snacks?date=${date}&session=Morning`;

      if (tabIndex === 1) {
        // If weekly, we can fetch via the same endpoint but passing a date that lands on that day
        // Or we might need to rely on the backend falling back to weekly template.
        // The backend GET endpoints /food, /fruit, /snacks fallback to weekly if no specific date is set.
        // Wait, for Weekly Template viewing, we should fetch specifically weekly template. 
        // We can just construct a date that is guaranteed to match that dayOfWeek but maybe not have specific overrides.
        // Let's just fetch the specific date, backend handles weekly fallback if empty.
      }

      const headers = { "Authorization": `Bearer ${token}` };

      const [resFood, resFruit, resSnacks] = await Promise.all([
        fetch(foodUrl, { headers }),
        fetch(fruitUrl, { headers }),
        fetch(snacksUrl, { headers })
      ]);

      if (resFood.ok) {
        const data = await resFood.json();
        setFoodItems(data.items || []);
      }
      if (resFruit.ok) {
        const data = await resFruit.json();
        setFruitItems(data.items || []);
      }
      if (resSnacks.ok) {
        const data = await resSnacks.json();
        setMorningSnacks(data.items || []);
      }
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

  // Save All
  const saveAllMenus = async () => {
    setSaving(true);
    try {
      const headers = {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${token}`
      };

      let foodUrl = "http://localhost:3001/api/menu/food";
      let fruitUrl = "http://localhost:3001/api/menu/fruit";
      let snacksUrl = "http://localhost:3001/api/menu/snacks";

      let foodBody = { menu_date: date, items: foodItems };
      let fruitBody = { menu_date: date, fruits: fruitItems };
      let snacksBody = { menu_date: date, session: "Morning", items: morningSnacks };

      if (tabIndex === 1) {
        foodUrl = "http://localhost:3001/api/menu/weekly/food";
        fruitUrl = "http://localhost:3001/api/menu/weekly/fruit";
        snacksUrl = "http://localhost:3001/api/menu/weekly/snacks";

        foodBody = { day_of_week: dayOfWeek, items: foodItems };
        fruitBody = { day_of_week: dayOfWeek, fruits: fruitItems };
        snacksBody = { day_of_week: dayOfWeek, session: "Morning", items: morningSnacks };
      }

      await Promise.all([
        fetch(foodUrl, { method: "POST", headers, body: JSON.stringify(foodBody) }),
        fetch(fruitUrl, { method: "POST", headers, body: JSON.stringify(fruitBody) }),
        fetch(snacksUrl, { method: "POST", headers, body: JSON.stringify(snacksBody) })
      ]);

      alert("All Menus Saved Successfully ✅");
    } catch (err) {
      console.error("❌ Save Menu Error:", err);
      alert("Network error while saving menus");
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="menu-manager-container">
      {/* Banner */}
      <div className="menu-header-banner">
        <img src="/logo192.png" alt="Header Background" onError={(e) => e.target.style.display='none'} />
        <div style={{ position: 'absolute', top: 20, left: 24, display: 'flex', alignItems: 'center' }}>
          <IconButton size="small" style={{ backgroundColor: 'white', marginRight: 12 }}>
            <RestaurantIcon style={{ color: '#1A2E6E', fontSize: 18 }} />
          </IconButton>
          <h2 style={{ margin: 0, color: '#1A2E6E', fontSize: 24, fontWeight: 800 }}>Setup Menu</h2>
        </div>
      </div>

      {/* Tabs */}
      <div className="menu-tabs-container">
        <Tabs 
          value={tabIndex} 
          onChange={(e, v) => setTabIndex(v)} 
          centered
          sx={{
            '& .MuiTab-root': { fontWeight: 700, textTransform: 'none', fontSize: 16, color: '#8A96A8' },
            '& .Mui-selected': { color: '#1A3A8F !important' },
            '& .MuiTabs-indicator': { backgroundColor: '#1A3A8F', height: 3 }
          }}
        >
          <Tab label="Specific Date" />
          <Tab label="Weekly Template" />
        </Tabs>
      </div>

      {/* Date / Day Override */}
      <div className="date-override-container">
        <span>{tabIndex === 0 ? "Date Override:" : "Select Day:"}</span>
        <div style={{ display: 'flex', alignItems: 'center', color: '#1A3A8F', fontWeight: 600 }}>
          <CalendarMonthIcon fontSize="small" style={{ marginRight: 6 }} />
          {tabIndex === 0 ? (
            <input 
              type="date" 
              value={date} 
              onChange={(e) => setDate(e.target.value)} 
              style={{ border: 'none', background: 'transparent', outline: 'none', color: '#1A3A8F', fontWeight: 600, fontFamily: 'inherit' }}
            />
          ) : (
            <select 
              value={dayOfWeek} 
              onChange={(e) => setDayOfWeek(parseInt(e.target.value))}
              style={{ border: 'none', background: 'transparent', outline: 'none', color: '#1A3A8F', fontWeight: 600, fontFamily: 'inherit', fontSize: '14px' }}
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
      </div>

      {loading ? (
        <div style={{ display: 'flex', justifyContent: 'center', padding: 40 }}>
          <CircularProgress style={{ color: '#1A3A8F' }} />
        </div>
      ) : (
        <>
          {/* Food Menu Card */}
          <div className="menu-section-card">
            <div className="menu-section-header">
              <RestaurantIcon />
              <h3>Food Menu</h3>
            </div>
            <div className="menu-section-content">
              <div className="chips-container">
                {foodItems.map((item, idx) => (
                  <Chip 
                    key={idx} 
                    label={item} 
                    onDelete={() => handleRemoveFood(idx)} 
                    variant="outlined"
                    style={{ backgroundColor: '#F8FAFC', borderColor: '#E2E8F0', color: '#1A2E6E', fontWeight: 600 }}
                  />
                ))}
              </div>
              <div className="input-container">
                <input 
                  type="text" 
                  placeholder="Enter food item..." 
                  value={newFood}
                  onChange={(e) => setNewFood(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && handleAddFood()}
                />
                <IconButton className="add-btn" onClick={handleAddFood}>
                  <AddIcon fontSize="small" />
                </IconButton>
              </div>
            </div>
          </div>

          {/* Fruit Menu Card */}
          <div className="menu-section-card">
            <div className="menu-section-header">
              <LocalCafeIcon />
              <h3>Fruit Menu</h3>
            </div>
            <div className="menu-section-content">
              <div className="chips-container">
                {fruitItems.map((item, idx) => (
                  <Chip 
                    key={idx} 
                    label={item} 
                    onDelete={() => handleRemoveFruit(idx)} 
                    variant="outlined"
                    style={{ backgroundColor: '#F8FAFC', borderColor: '#E2E8F0', color: '#1A2E6E', fontWeight: 600 }}
                  />
                ))}
              </div>
              <div className="input-container">
                <input 
                  type="text" 
                  placeholder="Enter fruit name..." 
                  value={newFruit}
                  onChange={(e) => setNewFruit(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && handleAddFruit()}
                />
                <IconButton className="add-btn" onClick={handleAddFruit}>
                  <AddIcon fontSize="small" />
                </IconButton>
              </div>
            </div>
          </div>

          {/* Snacks Menu Card */}
          <div className="menu-section-card">
            <div className="menu-section-header">
              <FastfoodIcon />
              <h3>Snacks Menu (Morning)</h3>
            </div>
            <div className="menu-section-content">
              <div className="chips-container">
                {morningSnacks.map((item, idx) => (
                  <Chip 
                    key={idx} 
                    label={`${item.name} - ₹${item.price}`} 
                    onDelete={() => handleRemoveSnack(idx)} 
                    variant="outlined"
                    style={{ backgroundColor: '#F8FAFC', borderColor: '#E2E8F0', color: '#1A2E6E', fontWeight: 600 }}
                  />
                ))}
              </div>
              <div className="snacks-input-row">
                <div className="input-container" style={{ flex: 2 }}>
                  <input 
                    type="text" 
                    placeholder="Snack name..." 
                    value={newSnackName}
                    onChange={(e) => setNewSnackName(e.target.value)}
                  />
                </div>
                <div className="input-container" style={{ flex: 1 }}>
                  <input 
                    type="number" 
                    placeholder="Price (₹)" 
                    value={newSnackPrice}
                    onChange={(e) => setNewSnackPrice(e.target.value)}
                    onKeyDown={(e) => e.key === 'Enter' && handleAddSnack()}
                  />
                </div>
                <IconButton className="add-btn" onClick={handleAddSnack} style={{ minWidth: 32 }}>
                  <AddIcon fontSize="small" />
                </IconButton>
              </div>
            </div>
          </div>

          <Button 
            variant="contained" 
            className="save-all-btn"
            onClick={saveAllMenus}
            disabled={saving}
          >
            {saving ? <CircularProgress size={24} style={{ color: 'white' }} /> : "Save All Menus"}
          </Button>
        </>
      )}
    </div>
  );
}
