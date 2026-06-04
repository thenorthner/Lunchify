import React, { useEffect, useState } from "react";
import axios from "axios";
import "../styles/TransferPanel.css";

export default function TransferPanel() {
  const token = localStorage.getItem("adminToken");
  const user = JSON.parse(localStorage.getItem("adminUser") || "{}");

  const [history, setHistory] = useState([]);
  const [loading, setLoading] = useState(false);

  // Form State
  const [employeeId, setEmployeeId] = useState("");
  const [toProjectId, setToProjectId] = useState("2"); // default to Rampur (since 1 is Shimla HQ)
  const [transferring, setTransferring] = useState(false);

  const axiosConfig = {
    headers: { Authorization: `Bearer ${token}` }
  };

  const fetchHistory = async () => {
    setLoading(true);
    try {
      const res = await axios.get("http://localhost:3001/api/transfer/history", axiosConfig);
      setHistory(res.data);
    } catch (err) {
      console.error("Error fetching transfer history:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchHistory();
  }, []);

  const handleTransfer = async (e) => {
    e.preventDefault();
    if (!employeeId.trim()) return alert("Please enter a valid Employee ID");

    const targetProjectName = 
      toProjectId === "1" ? "Shimla HQ" : 
      toProjectId === "2" ? "Rampur Project" : 
      toProjectId === "3" ? "Nathpa Jhakri Project" : "Selected Project";

    const confirmTransfer = window.confirm(
      `Are you sure you want to transfer Employee ${employeeId.toUpperCase()} to ${targetProjectName}? This will automatically align their canteen association and preserve their coupon balance.`
    );
    if (!confirmTransfer) return;

    setTransferring(true);
    try {
      const res = await axios.post(
        "http://localhost:3001/api/transfer/request",
        {
          employee_id: employeeId.trim().toUpperCase(),
          to_project_id: parseInt(toProjectId, 10)
        },
        axiosConfig
      );

      if (res.data.success) {
        alert(res.data.message);
        setEmployeeId("");
        fetchHistory();
      }
    } catch (err) {
      alert(err.response?.data?.error || "Failed to perform transfer request");
    } finally {
      setTransferring(false);
    }
  };

  return (
    <div className="transfer-panel-container fade-in">
      <div className="transfer-header">
        <div>
          <h2>🔄 Employee Project Transfers</h2>
          <p className="hr-project-tag">💼 Associated Project ID: {user.project_id}</p>
        </div>
      </div>

      <div className="transfer-grid">
        {/* TRANSFER FORM */}
        <div className="transfer-form-card">
          <h3>📦 Relocate Employee</h3>
          <p className="form-info">
            Transfer an employee to another project location. The system automatically preserves their remaining coupon balances (16 - used) and realigns their active canteen association.
          </p>

          <form onSubmit={handleTransfer}>
            <div className="form-group">
              <label>Employee ID</label>
              <input 
                type="text" 
                placeholder="e.g. EMP101" 
                value={employeeId} 
                onChange={(e) => setEmployeeId(e.target.value)} 
                required
              />
            </div>

            <div className="form-group">
              <label>Target Project Location</label>
              <select 
                value={toProjectId} 
                onChange={(e) => setToProjectId(e.target.value)}
                required
              >
                <option value="1">Shimla HQ (Himachal Pradesh)</option>
                <option value="2">Rampur Project (Himachal Pradesh)</option>
                <option value="3">Nathpa Jhakri Project (Himachal Pradesh)</option>
              </select>
            </div>

            <button type="submit" className="btn-transfer" disabled={transferring}>
              {transferring ? "Processing Relocation..." : "Execute Project Transfer"}
            </button>
          </form>
        </div>

        {/* LOGS SUMMARY STATS */}
        <div className="transfer-stats-box">
          <div className="t-stat">
            <h4>Transfers Audited</h4>
            <p className="stat-number">{history.length}</p>
          </div>
          <div className="t-info-alert">
            <h5>💡 Transfer Rules</h5>
            <ul>
              <li>1 Project = 1 Canteen mapping is strictly enforced.</li>
              <li>Coupons automatically deduct properly from old project balances.</li>
              <li>Transfer logs are fully immutable and archived for audit compliance.</li>
            </ul>
          </div>
        </div>
      </div>

      {/* HISTORY TABLE */}
      <div className="transfer-history-section">
        <h3>📄 Project Relocation Archives</h3>

        {loading ? (
          <div className="transfer-loading">
            <div className="spinner"></div>
            <p>Fetching transfer archives...</p>
          </div>
        ) : history.length === 0 ? (
          <div className="transfer-empty">
            <p>📭 No employee transfers logged for your project.</p>
          </div>
        ) : (
          <div className="transfer-table-wrapper">
            <table className="transfer-table">
              <thead>
                <tr>
                  <th>Log ID</th>
                  <th>Employee ID</th>
                  <th>Employee Name</th>
                  <th>From Project</th>
                  <th>To Project</th>
                  <th>Coupons Transferred</th>
                  <th>Initiated By (Admin)</th>
                  <th>Date & Time</th>
                </tr>
              </thead>
              <tbody>
                {history.map((log) => (
                  <tr key={log.id}>
                    <td>#{log.id}</td>
                    <td>{log.employee_id}</td>
                    <td>{log.employee_name}</td>
                    <td><span className="proj-badge proj-from">{log.from_project}</span></td>
                    <td><span className="proj-badge proj-to">{log.to_project}</span></td>
                    <td><span className="coupons-tag">{log.coupons_transferred} coupons</span></td>
                    <td className="admin-txt">{log.admin_name}</td>
                    <td>{new Date(log.transferred_at).toLocaleString()}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
