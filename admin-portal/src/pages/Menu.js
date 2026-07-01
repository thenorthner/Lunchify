import { useEffect, useState } from 'react';
import api from '../services/api';

export default function Menu({ type }) {
  const [items, setItems] = useState([]);
  const [name, setName] = useState('');
  const [price, setPrice] = useState('');

  useEffect(() => {
    api.get(`/menu/${type}`).then(res => setItems(res.data));
  }, [type]);

  const addItem = async () => {
    await api.post(`/menu/${type}`, { name, price });
    window.location.reload();
  };

  return (
    <div>
      <h2>{type.toUpperCase()} MENU</h2>
      {items.map(i => (
        <div key={i.id}>{i.name} – ₹{i.price}</div>
      ))}
      <label htmlFor="menu-itemName" className="sr-only">Item Name</label>
      <input id="menu-itemName" placeholder="Item" onChange={e => setName(e.target.value)} />
      
      <label htmlFor="menu-itemPrice" className="sr-only">Price</label>
      <input id="menu-itemPrice" placeholder="Price" onChange={e => setPrice(e.target.value)} />
      <button onClick={addItem}>Add</button>
    </div>
  );
}
