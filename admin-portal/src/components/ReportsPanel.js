import React, { useState, useEffect } from "react";
import axios from "axios";
import ConfirmationNumberIcon from '@mui/icons-material/ConfirmationNumber';
import BoltIcon from '@mui/icons-material/Bolt';
import "../styles/ReportsPanel.css";

export default function ReportsPanel() {
  const token = localStorage.getItem("adminToken");
  const user = JSON.parse(localStorage.getItem("adminUser") || "{}");

  const [range, setRange] = useState("daily"); // 'daily', 'monthly', 'yearly'
  const [loading, setLoading] = useState(false);
  const [data, setData] = useState([]);
  const [summaryStats, setSummaryStats] = useState({ totalScanned: 0, highestCount: 0 });

  const axiosConfig = {
    headers: { Authorization: `Bearer ${token}` }
  };

  const fetchHistory = async () => {
    setLoading(true);
    try {
      const res = await axios.get(
        `http://localhost:3001/api/qr/scanned-history?range=${range}`,
        axiosConfig
      );

      if (res.data.success) {
        const historyData = res.data.data;
        setData(historyData);

        // Calculate simple summaries
        const total = historyData.reduce((sum, item) => sum + parseInt(item.count || 0, 10), 0);
        const max = historyData.length > 0 
          ? Math.max(...historyData.map(item => parseInt(item.count || 0, 10))) 
          : 0;

        setSummaryStats({
          totalScanned: total,
          highestCount: max
        });
      }
    } catch (err) {
      console.error("Error fetching scanned history:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchHistory();
  }, [range]);

  const getRangeLabel = () => {
    if (range === "daily") return "Date (Daily)";
    if (range === "monthly") return "Month (Monthly)";
    if (range === "yearly") return "Year (Yearly)";
    return "";
  };

  return (
    <div className="reports-container fade-in">
      <div className="reports-header-section">
        <div>
          <h2>📈 Scanned Coupons History</h2>
          <p className="canteen-info-tag">🏪 Canteen: {user.canteen_id} | Admin: {user.name}</p>
        </div>

        <div className="reports-range-selector">
          <button 
            className={`range-btn ${range === "daily" ? "active" : ""}`}
            onClick={() => setRange("daily")}
          >
            📆 Daily
          </button>
          <button 
            className={`range-btn ${range === "monthly" ? "active" : ""}`}
            onClick={() => setRange("monthly")}
          >
            📅 Monthly
          </button>
          <button 
            className={`range-btn ${range === "yearly" ? "active" : ""}`}
            onClick={() => setRange("yearly")}
          >
            🏛️ Yearly
          </button>
        </div>
      </div>

      {/* AGGREGATED CARDS SUMMARY */}
      <div className="reports-summary-cards">
        <div className="rep-card rep-total">
          <div className="rep-icon"><ConfirmationNumberIcon fontSize="large" style={{ color: '#3730a3' }} /></div>
          <div className="rep-meta">
            <h3>Total Scanned Coupons</h3>
            <p>{summaryStats.totalScanned}</p>
          </div>
        </div>

        <div className="rep-card rep-peak">
          <div className="rep-icon"><BoltIcon fontSize="large" style={{ color: '#b45309' }} /></div>
          <div className="rep-meta">
            <h3>Peak Activity Count</h3>
            <p>{summaryStats.highestCount}</p>
          </div>
        </div>
      </div>

      {/* SCANNED STATS LIST */}
      {loading ? (
        <div className="reports-loading">
          <div className="spinner"></div>
          <p>Processing report data...</p>
        </div>
      ) : data.length === 0 ? (
        <div className="reports-empty">
          <p>📭 No coupon scan logs found for this canteen yet.</p>
        </div>
      ) : (
        <div className="reports-table-wrapper">
          <div className="privacy-badge">🔒 Privacy Protected: Zero employee identification parameters are exposed in scan history reports.</div>
          
          <table className="reports-table">
            <thead>
              <tr>
                <th>{getRangeLabel()}</th>
                <th style={{ textAlign: 'center' }}>Delivered Quantity Count</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              {data.map((item, idx) => (
                <tr key={idx}>
                  <td>{item.label}</td>
                  <td style={{ textAlign: 'center' }}>
                    <span className="stats-qty-badge">{item.count}</span>
                  </td>
                  <td>
                    <span className="stats-success-badge">✅ Verified Scanned</span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
