import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { 
  Star, 
  CalendarToday,
  ChatBubbleOutline,
  Close,
  RestaurantMenu
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
  return foodEmojis[name.toLowerCase().trim()] || '🍽️';
};

const ItemFeedbackViewer = () => {
  const [feedbacks, setFeedbacks] = useState([]);
  const [loading, setLoading] = useState(false);
  const [date, setDate] = useState(new Date().toISOString().split('T')[0]);
  const [selectedItemRemarks, setSelectedItemRemarks] = useState(null);

  useEffect(() => {
    fetchFeedbacks();
  }, [date]);

  const fetchFeedbacks = async () => {
    setLoading(true);
    try {
      // We assume canteen_id=1 for now, or you can get it from auth context
      const response = await axios.get(`http://localhost:3001/api/item-feedbacks/daily-items?date=${date}&canteen_id=1`);
      setFeedbacks(response.data);
    } catch (error) {
      console.error('Error fetching item feedbacks:', error);
    } finally {
      setLoading(false);
    }
  };

  const renderStars = (rating) => {
    const stars = [];
    for (let i = 1; i <= 5; i++) {
      stars.push(
        <Star 
          key={i} 
          style={{ 
            color: i <= Math.round(rating) ? '#FFB800' : '#CDD5E0',
            fontSize: '20px',
            marginRight: '2px'
          }} 
        />
      );
    }
    return stars;
  };

  return (
    <div style={{ backgroundColor: '#F0F4FF', minHeight: '100%', padding: '24px', borderRadius: '12px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <div>
          <h2 style={{ color: '#1A3A8F', fontWeight: '800', margin: '0 0 4px 0' }}>Daily Menu Ratings</h2>
          <p style={{ color: '#5B6F9A', margin: 0, fontSize: '14px' }}>See aggregated feedback for each food item</p>
        </div>
        
        <div style={{ display: 'flex', alignItems: 'center', backgroundColor: '#fff', padding: '8px 16px', borderRadius: '12px', boxShadow: '0 4px 12px rgba(43,86,214,0.05)' }}>
          <CalendarToday style={{ color: '#2B56D6', fontSize: '18px', marginRight: '8px' }} />
          <input 
            type="date" 
            value={date}
            onChange={(e) => setDate(e.target.value)}
            style={{ border: 'none', outline: 'none', color: '#1A3A8F', fontWeight: 'bold', fontFamily: 'inherit' }}
          />
        </div>
      </div>

      {loading ? (
        <div style={{ display: 'flex', justifyContent: 'center', padding: '40px' }}>
          <div className="spinner"></div>
        </div>
      ) : feedbacks.length === 0 ? (
        <div style={{ backgroundColor: '#fff', padding: '40px', borderRadius: '16px', textAlign: 'center', boxShadow: '0 4px 16px rgba(43,86,214,0.05)' }}>
          <RestaurantMenu style={{ fontSize: '48px', color: '#CDD5E0', marginBottom: '16px' }} />
          <h3 style={{ color: '#1A3A8F', margin: '0 0 8px 0' }}>No Feedback Yet</h3>
          <p style={{ color: '#5B6F9A', margin: 0 }}>There are no item ratings available for this date.</p>
        </div>
      ) : (
        <div style={{ display: 'grid', gap: '16px', gridTemplateColumns: 'repeat(auto-fill, minmax(340px, 1fr))' }}>
          {feedbacks.map((item, index) => (
            <div key={index} style={{ 
              backgroundColor: '#fff', 
              borderRadius: '16px', 
              padding: '20px',
              boxShadow: '0 4px 16px rgba(43,86,214,0.07)',
              display: 'flex',
              flexDirection: 'column'
            }}>
              <div style={{ display: 'flex', alignItems: 'center', marginBottom: '16px' }}>
                <div style={{ 
                  width: '48px', height: '48px', 
                  backgroundColor: '#E8EFFF', 
                  borderRadius: '12px',
                  display: 'flex', justifyContent: 'center', alignItems: 'center',
                  fontSize: '24px', marginRight: '16px'
                }}>
                  {getEmoji(item.item_name)}
                </div>
                <div style={{ flex: 1 }}>
                  <h3 style={{ color: '#1A3A8F', margin: '0 0 4px 0', fontSize: '18px', fontWeight: '700' }}>{item.item_name}</h3>
                  <div style={{ display: 'flex', alignItems: 'center' }}>
                    <div style={{ display: 'flex', alignItems: 'center', marginRight: '8px' }}>
                      {renderStars(item.average_rating)}
                    </div>
                    <span style={{ color: '#1A3A8F', fontWeight: 'bold', fontSize: '14px' }}>{item.average_rating.toFixed(1)}</span>
                    <span style={{ color: '#5B6F9A', fontSize: '12px', marginLeft: '6px' }}>({item.total_reviews} reviews)</span>
                  </div>
                </div>
              </div>
              
              <div style={{ marginTop: 'auto', paddingTop: '12px', borderTop: '1px solid #F0F4FF' }}>
                <button 
                  onClick={() => setSelectedItemRemarks(item)}
                  style={{
                    width: '100%',
                    padding: '10px',
                    backgroundColor: item.remarks && item.remarks.length > 0 ? '#F5F8FF' : '#f9f9f9',
                    color: item.remarks && item.remarks.length > 0 ? '#2B56D6' : '#a0a0a0',
                    border: 'none',
                    borderRadius: '8px',
                    fontWeight: 'bold',
                    cursor: item.remarks && item.remarks.length > 0 ? 'pointer' : 'not-allowed',
                    display: 'flex',
                    justifyContent: 'center',
                    alignItems: 'center',
                    transition: 'all 0.2s'
                  }}
                  disabled={!item.remarks || item.remarks.length === 0}
                >
                  <ChatBubbleOutline style={{ fontSize: '18px', marginRight: '8px' }} />
                  {item.remarks && item.remarks.length > 0 
                    ? `View ${item.remarks.length} Remarks` 
                    : 'No Remarks'}
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Remarks Modal */}
      {selectedItemRemarks && (
        <div style={{
          position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
          backgroundColor: 'rgba(0,0,0,0.5)',
          display: 'flex', justifyContent: 'center', alignItems: 'center',
          zIndex: 1000,
          padding: '20px'
        }}>
          <div style={{
            backgroundColor: '#fff',
            borderRadius: '20px',
            width: '100%',
            maxWidth: '500px',
            maxHeight: '80vh',
            display: 'flex',
            flexDirection: 'column',
            boxShadow: '0 10px 40px rgba(0,0,0,0.2)'
          }}>
            <div style={{ 
              padding: '20px 24px', 
              borderBottom: '1px solid #F0F4FF',
              display: 'flex', justifyContent: 'space-between', alignItems: 'center'
            }}>
              <div style={{ display: 'flex', alignItems: 'center' }}>
                <span style={{ fontSize: '24px', marginRight: '12px' }}>{getEmoji(selectedItemRemarks.item_name)}</span>
                <h3 style={{ color: '#1A3A8F', margin: 0, fontSize: '18px' }}>{selectedItemRemarks.item_name} Remarks</h3>
              </div>
              <button 
                onClick={() => setSelectedItemRemarks(null)}
                style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#5B6F9A', padding: '4px' }}
              >
                <Close />
              </button>
            </div>
            
            <div style={{ padding: '24px', overflowY: 'auto', flex: 1 }}>
              {selectedItemRemarks.remarks.map((remark, idx) => (
                <div key={idx} style={{ 
                  backgroundColor: '#F5F8FF', 
                  padding: '16px', 
                  borderRadius: '12px',
                  marginBottom: '12px',
                  borderLeft: '4px solid #2B56D6'
                }}>
                  <p style={{ color: '#1A3A8F', margin: 0, fontSize: '14px', lineHeight: '1.5' }}>"{remark}"</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default ItemFeedbackViewer;
