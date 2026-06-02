import React, { useEffect, useState } from "react";
import axios from "axios";
import "../styles/FeedbackViewer.css";

export default function FeedbackViewer() {
  const token = localStorage.getItem("adminToken");
  const user = JSON.parse(localStorage.getItem("adminUser") || "{}");

  const [feedbacks, setFeedbacks] = useState([]);
  const [loading, setLoading] = useState(false);
  const [searchTerm, setSearchTerm] = useState("");

  const axiosConfig = {
    headers: { Authorization: `Bearer ${token}` }
  };

  const fetchFeedbacks = async () => {
    setLoading(true);
    try {
      const res = await axios.get("http://localhost:3001/api/feedbacks", axiosConfig);
      setFeedbacks(res.data);
    } catch (err) {
      console.error("Error fetching feedbacks:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchFeedbacks();
  }, []);

  const renderStars = (rating) => {
    const stars = [];
    for (let i = 1; i <= 5; i++) {
      stars.push(
        <span key={i} className={i <= rating ? "star gold-star" : "star grey-star"}>
          ★
        </span>
      );
    }
    return <div className="stars-wrapper">{stars}</div>;
  };

  const filteredFeedbacks = feedbacks.filter(f => 
    f.subject.toLowerCase().includes(searchTerm.toLowerCase()) ||
    f.message.toLowerCase().includes(searchTerm.toLowerCase()) ||
    f.employee_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    f.employee_id.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="feedback-viewer-container fade-in">
      <div className="fb-header">
        <div>
          <h2>💬 System Problems & Feedbacks</h2>
          <p className="fb-subheader">IT Admin Centralized Portal to audit system tickets and employee reports.</p>
        </div>
        <button className="fb-refresh-btn" onClick={fetchFeedbacks}>🔄 Refresh Tickets</button>
      </div>

      {/* FILTER SEARCH BAR */}
      <div className="search-filter-bar">
        <input 
          type="text" 
          placeholder="🔍 Search tickets by Employee ID, Name, Subject, or Message content..." 
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="search-input"
        />
        <div className="ticket-count-badge">
          🎟️ Active Tickets: <strong>{filteredFeedbacks.length}</strong>
        </div>
      </div>

      {loading ? (
        <div className="fb-loading">
          <div className="spinner"></div>
          <p>Downloading support logs...</p>
        </div>
      ) : filteredFeedbacks.length === 0 ? (
        <div className="fb-empty">
          <p>📭 No active feedback reports found matching the search criteria.</p>
        </div>
      ) : (
        <div className="tickets-grid">
          {filteredFeedbacks.map((ticket) => (
            <div className="ticket-card" key={ticket.id}>
              {/* Card Top Information */}
              <div className="ticket-top-row">
                <span className="canteen-assoc-tag">🏪 {ticket.canteen_name} ({ticket.project_name})</span>
                <span className="ticket-date-txt">{new Date(ticket.created_at).toLocaleString()}</span>
              </div>

              {/* Subject & Message */}
              <div className="ticket-body">
                <h3 className="ticket-subject">{ticket.subject}</h3>
                <p className="ticket-message">{ticket.message}</p>
              </div>

              {/* Rating stars if rating exists */}
              <div className="rating-row">
                <span className="rating-label">Employee Satisfaction Rating:</span>
                {renderStars(ticket.rating)}
              </div>

              {/* Card Footer Details */}
              <div className="ticket-footer">
                <div className="employee-info-block">
                  <div className="emp-avatar">{ticket.employee_name.charAt(0).toUpperCase()}</div>
                  <div className="emp-meta-txt">
                    <strong>{ticket.employee_name}</strong>
                    <span>ID: {ticket.employee_id} | {ticket.employee_department || "General"}</span>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
