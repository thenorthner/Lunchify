import React, { useState, useEffect } from "react";
import axios from "axios";
import QrCodeScannerIcon from '@mui/icons-material/QrCodeScanner';
import "../styles/ScanHistoryPanel.css";

export default function ScanHistoryPanel() {
  const token = localStorage.getItem("adminToken");
  const [loading, setLoading] = useState(false);
  const [logs, setLogs] = useState([]);

  const fetchScanLogs = async () => {
    setLoading(true);
    try {
      const res = await axios.get("http://localhost:3001/api/qr/scan-logs", {
        headers: { Authorization: `Bearer ${token}` }
      });
      setLogs(res.data || []);
    } catch (err) {
      console.error("Error fetching scan logs:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchScanLogs();
  }, []);

  const formatDate = (dateStr) => {
    const d = new Date(dateStr);
    return `${d.toLocaleDateString()} ${d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}`;
  };

  return (
    <div className="scan-history-container fade-in">
      <div className="scan-history-header">
        <h2>🧾 Current Month Scan History</h2>
        <button className="refresh-btn" onClick={fetchScanLogs}>🔄 Refresh</button>
      </div>

      {loading ? (
        <div className="loading-state">
          <div className="spinner"></div>
          <p>Fetching scan logs...</p>
        </div>
      ) : logs.length === 0 ? (
        <div className="empty-state">
          <p>📭 No scans recorded this month.</p>
        </div>
      ) : (
        <div className="scan-history-list">
          {logs.map((log) => (
            <div className="scan-log-card" key={log.id}>
              <div className="scan-log-icon">
                <QrCodeScannerIcon fontSize="large" style={{ color: "#2563EB" }} />
              </div>
              <div className="scan-log-details">
                <h4>{log.employee_name || "Unknown Employee"}</h4>
                <span className="emp-id">ID: {log.employee_id}</span>
              </div>
              <div className="scan-log-meta">
                <div className={`scan-type-badge type-${(log.type || "lunch").toLowerCase()}`}>
                  {(log.type || "lunch").toUpperCase()}
                </div>
                <span className="scan-date">{formatDate(log.created_at)}</span>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
