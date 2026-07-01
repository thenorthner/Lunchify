import React, { useState, useEffect, useMemo } from 'react';
import api from "../services/api";
import PageHeader from "./PageHeader";
import { CircularProgress } from "@mui/material";
import { 
  Star, 
  CalendarToday,
  ChatBubbleOutline,
  RestaurantMenu,
  ExpandMore,
  TrendingUp
} from '@mui/icons-material';

const foodEmojis = {
  'paneer': '🧀', 'kadhi pakoda': '🍲', 'salad': '🥗', 'dahi': '🥛', 'dal': '🥣',
  'rice': '🍚', 'roti': '🫓', 'sabzi': '🥦', 'chicken': '🍗', 'fish': '🐟',
  'egg': '🥚', 'mutton': '🥩', 'prawn': '🦐', 'soup': '🍜', 'tomato soup': '🍅',
  'sweet corn soup': '🌽', 'dessert': '🍰', 'ice cream': '🍨', 'gulab jamun': '🍮',
  'rasgulla': '⚪', 'jalebi': '🧡', 'kheer': '🥣', 'cake': '🎂', 'fruits': '🍎',
  'apple': '🍎', 'banana': '🍌', 'orange': '🍊', 'mango': '🥭', 'grapes': '🍇',
  'watermelon': '🍉', 'pineapple': '🍍', 'juice': '🧃', 'tea': '🍵', 'coffee': '☕',
  'milk': '🥛', 'lassi': '🥤', 'shake': '🥤', 'soft drink': '🥤', 'water': '💧',
  'rajma': '🫘', 'chole': '🫘', 'bhature': '🫓', 'paratha': '🫓', 'naan': '🫓',
  'poha': '🍚', 'upma': '🍲', 'idli': '⚪', 'dosa': '🥞', 'sambar': '🍲',
  'uttapam': '🥞', 'khichdi': '🍚', 'biryani': '🍛', 'pulao': '🍚', 'burger': '🍔',
  'pizza': '🍕', 'sandwich': '🥪', 'hot dog': '🌭', 'fries': '🍟', 'pasta': '🍝',
  'noodles': '🍜', 'momos': '🥟', 'spring roll': '🥠', 'breakfast': '🍳',
  'omelette': '🍳', 'toast': '🍞', 'cornflakes': '🥣', 'snacks': '🍿', 'samosa': '🥟',
  'kachori': '🥟', 'pakoda': '🍤', 'chips': '🥔', 'popcorn': '🍿', 'sweet': '🍬',
  'chocolate': '🍫', 'barfi': '⬜', 'laddu': '🟠', 'bread': '🍞', 'bun': '🥯',
  'cookie': '🍪', 'donut': '🍩', 'muffin': '🧁', 'potato': '🥔', 'tomato': '🍅',
  'onion': '🧅', 'carrot': '🥕', 'peas': '🟢', 'capsicum': '🫑', 'cauliflower': '🥦',
  'veg': '🥬', 'non veg': '🍖', 'lunch': '🍱', 'dinner': '🍽️', 'meal': '🍛', 'combo': '🍱',
};

const getEmoji = (name) => {
  if (!name) return '🍽️';
  const lowerName = name.toLowerCase();
  for (const [key, value] of Object.entries(foodEmojis)) {
    if (lowerName.includes(key)) {
      return value;
    }
  }
  return '🍽️';
};

const Stars = ({ value }) => {
  const full = Math.floor(value);
  const half = value - full >= 0.5;
  return (
    <span className="star-row" aria-label={`${value} out of 5`} style={{ display: 'flex', alignItems: 'center', gap: '2px' }}>
      {Array.from({ length: 5 }).map((_, i) => {
        const isFilled = i < full || (i === full && half);
        return (
          <Star
            key={i}
            style={{ 
              fontSize: '18px', 
              color: isFilled ? 'var(--rust)' : 'var(--hairline)' 
            }}
          />
        );
      })}
    </span>
  );
};

const RatingCard = ({ r, expanded, onToggle }) => {
  const isAcclaimed = r.average_rating >= 4.5;
  const isSolid = r.average_rating >= 3.5;
  
  return (
    <div className="atelier lift" style={{ padding: '24px' }} data-testid={`rating-${r.item_name}`}>
      <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: '16px' }}>
        <div style={{ display: 'flex', alignItems: 'flex-start', gap: '16px' }}>
          <div
            style={{
              width: 56, height: 56,
              background: "var(--emerald-soft)",
              color: "var(--emerald)",
              border: "1px solid var(--hairline)",
              display: 'grid',
              placeItems: 'center',
              borderRadius: '12px',
              flexShrink: 0,
              fontSize: '24px'
            }}
          >
            {getEmoji(r.item_name)}
          </div>
          <div>
            <div className="eyebrow" style={{ marginBottom: '4px' }}>Food Item</div>
            <h3 className="font-display" style={{ fontSize: 24, fontWeight: 500, letterSpacing: "-0.02em", margin: 0, color: 'var(--ink)' }}>{r.item_name}</h3>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginTop: '8px' }}>
              <Stars value={r.average_rating} />
              <span className="font-display tnum" style={{ fontSize: 18, fontWeight: 500, color: 'var(--ink)' }}>{r.average_rating.toFixed(1)}</span>
              <span style={{ fontSize: '12px', color: "var(--ink-muted)" }}>
                ({r.total_reviews} review{r.total_reviews === 1 ? "" : "s"})
              </span>
            </div>
          </div>
        </div>
        <div
          style={{
            padding: '4px 12px',
            borderRadius: '9999px',
            fontSize: '10.5px',
            background: isAcclaimed ? "var(--emerald-soft)" : isSolid ? "#e4f1fb" : "var(--amber-soft)",
            color:      isAcclaimed ? "var(--emerald)"      : isSolid ? "#0e6cb0" : "#6a4a0e",
            border: "1px solid var(--hairline)",
            letterSpacing: "0.18em",
            fontWeight: 600,
            textTransform: "uppercase",
          }}
        >
          {isAcclaimed ? "Acclaimed" : isSolid ? "Solid" : "Mixed"}
        </div>
      </div>

      <div className="hairline" style={{ margin: '20px 0' }} />

      <button
        onClick={onToggle}
        style={{ 
          display: 'flex', alignItems: 'center', justifyContent: 'space-between', 
          width: '100%', fontSize: '13px', color: "var(--ink)", 
          background: 'none', border: 'none', cursor: 'pointer', padding: 0 
        }}
      >
        <span style={{ display: 'flex', alignItems: 'center', gap: '8px', color: "var(--emerald)" }}>
          <ChatBubbleOutline style={{ fontSize: '16px' }} />
          View {(r.remarks || []).length} remark{(r.remarks || []).length === 1 ? "" : "s"}
        </span>
        <ExpandMore
          style={{ 
            fontSize: '18px',
            transform: expanded ? "rotate(180deg)" : "rotate(0)", 
            transition: "transform .2s ease", 
            color: "var(--ink-muted)" 
          }}
        />
      </button>

      {expanded && (
        <div style={{ marginTop: '16px', display: 'flex', flexDirection: 'column', gap: '12px' }}>
          {(r.remarks || []).map((rm, i) => (
            <div
              key={i}
              style={{ 
                padding: '16px', 
                borderRadius: '10px', 
                background: "var(--paper-2)", 
                border: "1px solid var(--hairline)" 
              }}
            >
              <div className="eyebrow" style={{ marginBottom: '4px', color: "var(--brass)" }}>Anonymous</div>
              <div style={{ fontSize: '14px', color: "var(--ink-2)" }}>&ldquo;{rm}&rdquo;</div>
            </div>
          ))}
          {(!r.remarks || r.remarks.length === 0) && (
            <div style={{ padding: '16px', textAlign: 'center', color: 'var(--ink-muted)', fontSize: '13px', background: "var(--paper-2)", borderRadius: '10px', border: "1px solid var(--hairline)" }}>
              No remarks
            </div>
          )}
        </div>
      )}
    </div>
  );
};

const ItemFeedbackViewer = ({ user }) => {
  const [feedbacks, setFeedbacks] = useState([]);
  const [loading, setLoading] = useState(false);
  const [date, setDate] = useState(new Date().toISOString().split('T')[0]);
  const [open, setOpen] = useState(null);
  
  const [canteens, setCanteens] = useState([]);
  const [selectedCanteenId, setSelectedCanteenId] = useState(user?.canteen_id || 1);

  const isAdmin = user?.role === 'it_admin' || user?.role === 'hr_admin';

  useEffect(() => {
    if (isAdmin) {
      const fetchCanteens = async () => {
        try {
          const res = await api.get("/transfer/projects-canteens");
          const uniqueCanteens = [];
          res.data.forEach(row => {
            if (row.canteen_id && !uniqueCanteens.find(x => x.id === row.canteen_id)) {
              uniqueCanteens.push({
                id: row.canteen_id,
                name: row.canteen_name,
                project_id: row.project_id
              });
            }
          });
          setCanteens(uniqueCanteens);
          if (uniqueCanteens.length > 0 && (!selectedCanteenId || selectedCanteenId === 1)) {
            setSelectedCanteenId(uniqueCanteens[0].id);
          }
        } catch (err) {
          console.error("Error fetching canteens:", err);
        }
      };
      fetchCanteens();
    } else if (user?.canteen_id) {
        setSelectedCanteenId(user.canteen_id);
    }
  }, [isAdmin, user]);

  useEffect(() => {
    fetchFeedbacks();
  }, [date, selectedCanteenId]);

  const fetchFeedbacks = async () => {
    setLoading(true);
    try {
      const response = await api.get(`/item-feedbacks/daily-items?date=${date}&canteen_id=${selectedCanteenId || 1}`);
      setFeedbacks(response.data);
    } catch (error) {
      console.error('Error fetching item feedbacks:', error);
    } finally {
      setLoading(false);
    }
  };

  const avg = useMemo(() => {
    if (feedbacks.length === 0) return 0;
    return feedbacks.reduce((a, b) => a + b.average_rating, 0) / feedbacks.length;
  }, [feedbacks]);

  const totalReviews = useMemo(() => {
    return feedbacks.reduce((a, b) => a + b.total_reviews, 0);
  }, [feedbacks]);

  const topItem = useMemo(() => {
    if (feedbacks.length === 0) return null;
    return feedbacks.reduce((prev, current) => (prev.average_rating > current.average_rating) ? prev : current);
  }, [feedbacks]);

  return (
    <div style={{ width: '100%', fontFamily: '"Geist", "Inter", "Lexend", -apple-system, system-ui, sans-serif' }} className="fade-in">
      <PageHeader
        eyebrow="Chapter VIII · Resonance"
        title="Voice of the room,"
        italicTail="daily menu ratings"
        description="Aggregated feedback for each item on the day's menu — sentiment captured, course-corrected, repeated tomorrow."
      />

      {/* Filter strip */}
      <div className="atelier" style={{ padding: '16px', marginBottom: '32px', display: 'flex', flexWrap: 'wrap', alignItems: 'center', gap: '16px', justifyContent: 'space-between' }}>
        <div style={{ display: 'flex', flexWrap: 'wrap', alignItems: 'center', gap: '12px' }}>
          {isAdmin && canteens.length > 0 && (
            <div style={{ position: 'relative' }}>
              <select
                value={selectedCanteenId}
                onChange={(e) => setSelectedCanteenId(e.target.value)}
                className="input-atelier"
                style={{ paddingRight: '40px', appearance: 'none', minWidth: '300px' }}
              >
                {canteens.map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
              </select>
              <ExpandMore style={{ position: 'absolute', right: '12px', top: '50%', transform: 'translateY(-50%)', pointerEvents: 'none', color: "var(--ink-muted)", fontSize: '18px' }} />
            </div>
          )}
          <div style={{ position: 'relative' }}>
            <CalendarToday style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', zIndex: 10, color: "var(--ink-muted)", fontSize: '16px' }} />
            <input
              type="date"
              value={date}
              onChange={(e) => setDate(e.target.value)}
              className="input-atelier font-mono-tab"
              style={{ paddingLeft: '36px' }}
            />
          </div>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '24px' }}>
          <div style={{ textAlign: 'right' }}>
            <div className="eyebrow">Day average</div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginTop: '4px' }}>
              <Stars value={avg} />
              <span className="font-display tnum" style={{ fontSize: '20px', fontWeight: 500, color: 'var(--ink)' }}>{avg.toFixed(2)}</span>
            </div>
          </div>
          <div style={{ textAlign: 'right' }}>
            <div className="eyebrow">Total reviews</div>
            <div className="font-display tnum" style={{ fontSize: '20px', fontWeight: 500, marginTop: '4px', color: 'var(--ink)' }}>{totalReviews}</div>
          </div>
        </div>
      </div>

      {/* Highlight strip */}
      {topItem && (
        <div
          className="atelier-dark"
          style={{ padding: '20px', marginBottom: '32px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: '12px' }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
            <div
              style={{ display: 'grid', placeItems: 'center', borderRadius: '12px', width: 40, height: 40, background: "rgba(84,189,245,.15)", color: "var(--on-dark-accent)" }}
            >
              <TrendingUp style={{ fontSize: '18px' }} />
            </div>
            <div>
              <div className="eyebrow" style={{ color: "var(--on-dark-accent)" }}>Top of the day</div>
              <div className="font-display" style={{ fontSize: '20px', marginTop: '2px', fontWeight: 500, color: "var(--paper)" }}>
                <span style={{ fontStyle: "italic", color: "var(--on-dark-accent)" }}>{topItem.item_name}</span> — highest rated item.
              </div>
            </div>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Stars value={topItem.average_rating} />
            <span className="font-display tnum" style={{ fontSize: '18px', fontWeight: 500, color: 'var(--paper)' }}>{topItem.average_rating.toFixed(1)}</span>
          </div>
        </div>
      )}

      {loading ? (
        <div className="loading-box" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '60px 20px' }}>
          <CircularProgress size={24} style={{ color: "var(--ink)", marginBottom: 12 }} />
          <div>Loading feedback data...</div>
        </div>
      ) : feedbacks.length === 0 ? (
        <div className="empty-box" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '60px 20px' }}>
          <RestaurantMenu style={{ fontSize: 32, color: 'var(--ink-muted)', marginBottom: 16 }} />
          <div style={{ color: 'var(--ink)' }}>No Feedback Yet</div>
          <div style={{ color: 'var(--ink-muted)', fontSize: 13, marginTop: 4 }}>There are no item ratings available for this date.</div>
        </div>
      ) : (
        <div style={{ display: 'grid', gap: '20px', gridTemplateColumns: 'repeat(auto-fill, minmax(400px, 1fr))' }}>
          {feedbacks.map((r, i) => (
            <RatingCard
              key={r.item_name || i}
              r={r}
              expanded={open === r.item_name}
              onToggle={() => setOpen(open === r.item_name ? null : r.item_name)}
            />
          ))}
        </div>
      )}
    </div>
  );
};

export default ItemFeedbackViewer;
