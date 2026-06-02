import React, { useState, useEffect } from "react";
import axios from "axios";
import "../styles/OrdersManager.css";

export default function OrdersManager() {
  const token = localStorage.getItem("adminToken");
  const user = JSON.parse(localStorage.getItem("adminUser") || "{}");

  const [activeSubTab, setActiveSubTab] = useState("food"); // 'food', 'fruit', 'snacks'
  const [loading, setLoading] = useState(false);
  const [orders, setOrders] = useState([]);
  const [pendingOnly, setPendingOnly] = useState(true);

  const axiosConfig = {
    headers: { Authorization: `Bearer ${token}` }
  };

  const fetchOrders = async () => {
    setLoading(true);
    setOrders([]); // Clear orders so stale data is not shown!
    try {
      let endpoint = "";
      if (activeSubTab === "food") {
        endpoint = pendingOnly 
          ? "http://localhost:3001/api/food-lunch/requests" 
          : "http://localhost:3001/api/food-lunch/details";
      } else if (activeSubTab === "fruit") {
        endpoint = pendingOnly 
          ? "http://localhost:3001/api/fruit-lunch/requests" 
          : "http://localhost:3001/api/fruit-lunch/details";
      } else if (activeSubTab === "snacks") {
        endpoint = "http://localhost:3001/api/snacks";
      }

      const res = await axios.get(endpoint, axiosConfig);
      setOrders(res.data);
    } catch (err) {
      console.error("Error fetching orders:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchOrders();
  }, [activeSubTab, pendingOnly]);

  const handleUpdateStatus = async (orderId, newStatus) => {
    try {
      let url = "";
      if (activeSubTab === "food") {
        url = `http://localhost:3001/api/food-lunch/${orderId}/status`;
      } else if (activeSubTab === "fruit") {
        url = `http://localhost:3001/api/fruit-lunch/${orderId}/status`;
      }

      const res = await axios.patch(url, { status: newStatus }, axiosConfig);
      if (res.data.success) {
        alert(`Order successfully marked as ${newStatus}!` + 
          (newStatus === "rejected" || newStatus === "cancelled" ? " Coupon balance has been refunded." : "")
        );
        fetchOrders();
      }
    } catch (err) {
      alert(err.response?.data?.error || "Failed to update order status");
    }
  };

  const handleMarkDelivered = async (orderId) => {
    try {
      let url = "";
      if (activeSubTab === "food") {
        url = `http://localhost:3001/api/food-lunch/${orderId}/mark-delivered`;
      } else if (activeSubTab === "fruit") {
        url = `http://localhost:3001/api/fruit-lunch/${orderId}/mark-delivered`;
      }

      const res = await axios.post(url, {}, axiosConfig);
      if (res.data.success) {
        alert("Order successfully marked as DELIVERED!");
        fetchOrders();
      }
    } catch (err) {
      alert(err.response?.data?.error || "Failed to mark order as delivered");
    }
  };

  const handleUpdateSnackOrder = async (orderId, status) => {
    try {
      const res = await axios.put(
        `http://localhost:3001/api/snacks/snack-orders/${orderId}`,
        { status },
        axiosConfig
      );
      if (res.data.success) {
        alert(`Snack order successfully marked as ${status.toUpperCase()}!`);
        fetchOrders();
      }
    } catch (err) {
      alert(err.response?.data?.error || "Failed to update snack order");
    }
  };

  const parseSnackItems = (itemsStr) => {
    try {
      const parsed = typeof itemsStr === 'string' ? JSON.parse(itemsStr) : itemsStr;
      if (Array.isArray(parsed)) {
        return parsed.map(item => `${item.name} (x${item.quantity || 1})`).join(", ");
      }
      return String(itemsStr);
    } catch (e) {
      return String(itemsStr);
    }
  };

  const formatTime = (timeStr) => {
    if (!timeStr) return "N/A";
    return timeStr.substring(0, 5); // display HH:MM
  };

  return (
    <div className="orders-manager-container fade-in">
      <div className="orders-header">
        <h2>📦 Canteen Orders Manager</h2>
        <p className="canteen-badge">🏪 Canteen ID: {user.canteen_id}</p>
      </div>

      {/* SUB-TABS */}
      <div className="orders-tabs">
        <button 
          className={`orders-tab-btn ${activeSubTab === "food" ? "active" : ""}`}
          onClick={() => { setActiveSubTab("food"); setPendingOnly(true); }}
        >
          🍛 Food Lunch Orders
        </button>
        <button 
          className={`orders-tab-btn ${activeSubTab === "fruit" ? "active" : ""}`}
          onClick={() => { setActiveSubTab("fruit"); setPendingOnly(true); }}
        >
          🍎 Fruit Lunch Orders
        </button>
        <button 
          className={`orders-tab-btn ${activeSubTab === "snacks" ? "active" : ""}`}
          onClick={() => setActiveSubTab("snacks")}
        >
          ☕ Morning/Evening Snacks
        </button>
      </div>

      {/* FILTER CONTROLS */}
      <div className="filter-controls">
        <label className="toggle-container">
          <input 
            type="checkbox" 
            checked={pendingOnly}
            onChange={(e) => setPendingOnly(e.target.checked)}
          />
          <span className="toggle-slider"></span>
          <span className="toggle-label">{pendingOnly ? "Showing Pending Orders Only" : "Showing All Orders"}</span>
        </label>
        <button className="refresh-btn" onClick={fetchOrders}>🔄 Refresh List</button>
      </div>

      {activeSubTab === "snacks" && (
        <div className="filter-controls" style={{marginTop: "-10px", marginBottom: "20px", borderTop: "none", paddingTop: "0"}}>
          <span className="info-txt">ℹ️ Snacks orders operate on a Pay-at-Counter model. Mark them Paid & Delivered when processed.</span>
        </div>
      )}

      {/* ORDERS LIST */}
      {loading ? (
        <div className="loading-state">
          <div className="spinner"></div>
          <p>Fetching orders, please wait...</p>
        </div>
      ) : orders.filter(o => !pendingOnly || o.status === 'pending').length === 0 ? (
        <div className="empty-state">
          <p>📭 No orders found matching this filter.</p>
        </div>
      ) : (
        <div className="orders-table-wrapper">
          <table className="orders-table">
            <thead>
              {activeSubTab === "snacks" ? (
                <tr>
                  <th>Order ID</th>
                  <th>Employee ID</th>
                  <th>Employee Name</th>
                  <th>Snack Items</th>
                  <th>Session</th>
                  <th>Total Cost</th>
                  <th>Date</th>
                  <th>Status</th>
                  <th>Actions</th>
                </tr>
              ) : (
                <tr>
                  <th>Order ID</th>
                  <th>Employee ID</th>
                  <th>Employee Name</th>
                  <th>Date</th>
                  <th>Status</th>
                  <th>Actions</th>
                </tr>
              )}
            </thead>
            <tbody>
              {orders.filter(o => !pendingOnly || o.status === 'pending').map((order) => {
                if (activeSubTab === "snacks") {
                  return (
                    <tr key={order.id}>
                      <td>#{order.id}</td>
                      <td><strong>{order.employee_id}</strong></td>
                      <td>{order.employee_name || order.name}</td>
                      <td className="snack-items-col">{parseSnackItems(order.items)}</td>
                      <td><span style={{ textTransform: "capitalize" }}>{order.session || "Morning"}</span></td>
                      <td><span className="amount-badge">₹{order.total || 0}</span></td>
                      <td>{new Date(order.created_at || order.date).toLocaleDateString()}</td>
                      <td>
                        <span className={`status-badge status-${order.status || 'pending'}`}>
                          {(order.status || 'pending').toUpperCase()}
                        </span>
                      </td>
                      <td>
                        <div className="action-buttons">
                          {order.status === "pending" && (
                            <>
                              <button 
                                className="btn-action btn-accept"
                                onClick={() => handleUpdateSnackOrder(order.id, "accepted")}
                              >
                                Accept
                              </button>
                              <button 
                                className="btn-action btn-reject"
                                onClick={() => handleUpdateSnackOrder(order.id, "rejected")}
                              >
                                Reject
                              </button>
                            </>
                          )}
                          {order.status === "accepted" && (
                            <button 
                              className="btn-action btn-deliver"
                              onClick={() => handleUpdateSnackOrder(order.id, "delivered")}
                            >
                              Complete & Pay (Cash)
                            </button>
                          )}
                          {order.status !== "cancelled" && order.status !== "rejected" && order.status !== "delivered" && (
                            <button 
                              className="btn-action btn-cancel"
                              onClick={() => handleUpdateSnackOrder(order.id, "cancelled")}
                            >
                              Cancel
                            </button>
                          )}
                        </div>
                      </td>
                    </tr>
                  );
                } else {
                  return (
                    <tr key={order.id}>
                      <td>#{order.id}</td>
                      <td><strong>{order.employee_id}</strong></td>
                      <td>{order.employee_name || order.name}</td>
                      <td>{new Date(order.date).toLocaleDateString()}</td>
                      <td>
                        <span className={`status-badge status-${order.status}`}>
                          {order.status.toUpperCase()}
                        </span>
                      </td>
                      <td>
                        <div className="action-buttons">
                          {order.status === "pending" && (
                            <>
                              <button 
                                className="btn-action btn-accept"
                                onClick={() => handleUpdateStatus(order.id, "accepted")}
                              >
                                Accept
                              </button>
                              <button 
                                className="btn-action btn-reject"
                                onClick={() => handleUpdateStatus(order.id, "rejected")}
                              >
                                Reject
                              </button>
                            </>
                          )}
                          {order.status === "accepted" && (
                            <button 
                              className="btn-action btn-deliver"
                              onClick={() => handleMarkDelivered(order.id)}
                            >
                              Mark Delivered
                            </button>
                          )}
                          {order.status !== "cancelled" && order.status !== "rejected" && order.status !== "delivered" && (
                            <button 
                              className="btn-action btn-cancel"
                              onClick={() => handleUpdateStatus(order.id, "cancelled")}
                            >
                              Cancel Order
                            </button>
                          )}
                        </div>
                      </td>
                    </tr>
                  );
                }
              })}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
