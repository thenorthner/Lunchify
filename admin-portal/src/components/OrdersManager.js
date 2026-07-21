import React, { useState, useEffect, useMemo } from "react";
import api from "../services/api";
import PageHeader from "./PageHeader";
import { CircularProgress } from "@mui/material";
import BuildingIcon from '@mui/icons-material/Domain';
import RefreshIcon from '@mui/icons-material/Refresh';
import SyncIcon from '@mui/icons-material/Sync';
import LocalMallOutlinedIcon from '@mui/icons-material/LocalMallOutlined';
import SpaIcon from '@mui/icons-material/Spa';
import LocalCafeOutlinedIcon from '@mui/icons-material/LocalCafeOutlined';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import CancelIcon from '@mui/icons-material/Cancel';
import PendingIcon from '@mui/icons-material/HourglassEmpty';
import DeliveryDiningIcon from '@mui/icons-material/DeliveryDining';
import "../styles/OrdersManager.css";

const SUBTABS = [
  { k: "food",   label: "Food Lunch",       icon: LocalMallOutlinedIcon },
  { k: "fruit",  label: "Fruit Lunch",      icon: SpaIcon },
  { k: "snacks", label: "Morning · Evening", icon: LocalCafeOutlinedIcon },
];

const StatusChip = ({ status }) => {
  const cfg = {
    accepted:  { cls: "chip-emerald", dot: "var(--emerald)", icon: CheckCircleIcon },
    pending:   { cls: "chip-amber",   dot: "#b07a16", icon: PendingIcon },
    delivered: { cls: "chip-emerald", dot: "var(--emerald)", icon: DeliveryDiningIcon },
    cancelled: { cls: "chip-rust",    dot: "var(--rust)", icon: CancelIcon },
    rejected:  { cls: "chip-rust",    dot: "var(--rust)", icon: CancelIcon },
  }[status.toLowerCase()] || { cls: "", dot: "var(--ink)", icon: PendingIcon };
  
  return (
    <span className={`chip ${cfg.cls}`}>
      <span className="inline-block" style={{ height: "6px", width: "6px", borderRadius: "50%", background: cfg.dot, display: 'inline-block' }} />
      {status.toUpperCase()}
    </span>
  );
};

export default function OrdersManager({ user = {} }) {
  const [activeSubTab, setActiveSubTab] = useState("food");
  const [loading, setLoading] = useState(false);
  const [orders, setOrders] = useState([]);

  const fetchOrders = async () => {
    setLoading(true);
    setOrders([]);
    try {
      let endpoint = "";
      if (activeSubTab === "food") {
        endpoint = "/food-lunch/details";
      } else if (activeSubTab === "fruit") {
        endpoint = "/fruit-lunch/details";
      } else if (activeSubTab === "snacks") {
        endpoint = "/snacks";
      }

      const res = await api.get(endpoint);
      setOrders(res.data);
    } catch (err) {
      console.error("Error fetching orders:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchOrders();
  }, [activeSubTab]);

  const handleUpdateStatus = async (orderId, newStatus) => {
    try {
      let url = "";
      if (activeSubTab === "food") {
        url = `/food-lunch/${orderId}/status`;
      } else if (activeSubTab === "fruit") {
        url = `/fruit-lunch/${orderId}/status`;
      }

      const res = await api.patch(url, { status: newStatus });
      if (res.data.success) {
        alert(`Order successfully marked as ${newStatus}!`);
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
        url = `/food-lunch/${orderId}/mark-delivered`;
      } else if (activeSubTab === "fruit") {
        url = `/fruit-lunch/${orderId}/mark-delivered`;
      }

      const res = await api.post(url, {});
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
      const res = await api.put(`/snacks/snack-orders/${orderId}`, { status });
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
        return parsed.map(item => `${item.name || item.snack || 'Unknown'} (x${item.quantity || 1})`).join(", ");
      }
      return String(itemsStr);
    } catch (e) {
      return String(itemsStr);
    }
  };

  const formatTime = (timeStr) => {
    if (!timeStr) return "N/A";
    return timeStr.substring(0, 5);
  };

  const counts = useMemo(() => {
    return {
      pending: orders.filter((o) => (o.status || "").toLowerCase() === "pending").length,
      accepted: orders.filter((o) => (o.status || "").toLowerCase() === "accepted").length,
      delivered: orders.filter((o) => (o.status || "").toLowerCase() === "delivered").length,
    };
  }, [orders]);

  return (
    <>
        <PageHeader
          eyebrow="Chapter IV · Service"
          title="Canteen orders,"
          italicTail="orchestrated"
          description="Each ticket is a promise. Accept, deliver, and document — with the calm precision of a well-run dining room."
          right={
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', padding: '8px 16px', background: '#fff', border: '1px solid #cbd5e1', borderRadius: '9999px', fontSize: '11px' }}>
              <BuildingIcon style={{ fontSize: 16, color: '#475569' }} />
              <span style={{ fontWeight: 600, letterSpacing: '0.05em', color: '#64748b', textTransform: 'uppercase' }}>Canteen</span>
              <span style={{ fontWeight: 600, color: '#0f172a' }}>{user.canteen_id == 5 ? 'Corporate Headquarters · CHQ' : user.canteen_id || 'Unknown'}</span>
            </div>
          }
        />

        {/* Sub-tabs */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '4px', padding: '4px', width: 'fit-content', marginBottom: '32px', background: '#fff', border: '1px solid #cbd5e1', borderRadius: '12px' }}>
          {SUBTABS.map((s) => {
            const Icon = s.icon;
            const isActive = activeSubTab === s.k;
            return (
              <button
                key={s.k}
                onClick={() => setActiveSubTab(s.k)}
                style={{
                  display: 'flex', alignItems: 'center', gap: '8px',
                  padding: '8px 16px',
                  borderRadius: '8px',
                  fontSize: '14px', fontWeight: 600,
                  fontFamily: 'inherit', transition: 'all 0.2s ease',
                  cursor: 'pointer', border: 'none',
                  background: isActive ? '#0f172a' : 'transparent',
                  color: isActive ? '#fff' : '#475569',
                }}
              >
                <Icon style={{ fontSize: 18 }} />
                {s.label}
              </button>
            )
          })}
        </div>


        {/* Table */}
        <div className="atelier" style={{ overflow: 'hidden' }}>
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "20px", borderBottom: "1px solid var(--hairline)" }}>
            <div>
              <div className="eyebrow">Today&#39;s docket</div>
              <div className="font-display" style={{ fontSize: "20px", fontWeight: 500, marginTop: "2px" }}>
                {orders.length} tickets in queue
              </div>
            </div>
            <button 
              onClick={fetchOrders} 
              disabled={loading} 
              style={{ 
                display: 'flex', alignItems: 'center', gap: '6px', 
                fontSize: '13px', fontWeight: 500, color: '#0f172a',
                background: '#fff', border: '1px solid #cbd5e1', borderRadius: '9999px',
                padding: '6px 16px', cursor: 'pointer', transition: 'all 0.2s ease'
              }}
              onMouseOver={(e) => e.currentTarget.style.background = '#f8fafc'}
              onFocus={(e) => e.currentTarget.style.background = '#f8fafc'}
              onMouseOut={(e) => e.currentTarget.style.background = '#fff'}
              onBlur={(e) => e.currentTarget.style.background = '#fff'}
            >
              {loading ? <CircularProgress size={16} style={{ color: "inherit" }} /> : <SyncIcon style={{ fontSize: 16, color: '#475569' }} />}
              Refresh
            </button>
          </div>

          {loading ? (
            <div style={{ padding: '60px 0', textAlign: 'center', color: 'var(--ink-muted)' }}>Loading orders...</div>
          ) : orders.length === 0 ? (
            <div style={{ padding: '60px 0', textAlign: 'center', color: 'var(--ink-muted)' }}>No {activeSubTab} orders found for today.</div>
          ) : (
            <table className="atelier-table">
              <thead>
                <tr>
                  <th>Order</th>
                  <th>Employee</th>
                  <th>Details</th>
                  <th>Status</th>
                  <th style={{ textAlign: 'right' }}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {orders.map((o) => {
                  const isSnack = activeSubTab === "snacks";
                  const status = o.status ? o.status.toUpperCase() : 'PENDING';
                  return (
                    <tr key={o.id}>
                      <td>
                        <span className="font-display italic" style={{ color: "var(--brass)", fontSize: 14 }}>№</span>
                        <span className="font-mono-tab" style={{ marginLeft: "6px" }}>{String(o.id).padStart(4, "0")}</span>
                      </td>
                      <td>
                        <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
                          <div
                            className="font-display"
                            style={{
                              width: 32, height: 32, borderRadius: "50%",
                              background: "var(--paper-2)", border: "1px solid var(--hairline)",
                              display: "grid", placeItems: "center",
                              color: "var(--ink)", fontSize: 13, fontWeight: 500
                            }}
                          >
                            {o.employee_name ? o.employee_name.split(" ").map(p => p[0]).slice(0, 2).join("").toUpperCase() : "?"}
                          </div>
                          <div>
                            <div style={{ fontSize: "14px" }}>{o.employee_name || "Unknown"}</div>
                            <div className="font-mono-tab" style={{ fontSize: "12px", color: "var(--ink-muted)", marginTop: "2px" }}>{o.employee_id}</div>
                          </div>
                        </div>
                      </td>
                      <td>
                        {isSnack ? (
                          <div style={{ fontSize: "13px" }}>
                            <div>{parseSnackItems(o.snack_items || o.items)}</div>
                            <div style={{ fontWeight: 500, marginTop: "4px" }}>₹{o.total_price || o.total}</div>
                          </div>
                        ) : (
                          <div className="font-mono-tab" style={{ fontSize: "13px", color: 'var(--ink-muted)' }}>
                            {formatTime(o.lunch_time)}
                          </div>
                        )}
                      </td>
                      <td>
                        <StatusChip status={status} />
                      </td>
                      <td style={{ textAlign: 'right' }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', justifyContent: 'flex-end' }}>
                          {status === "ACCEPTED" && !isSnack && (
                            <button
                              onClick={() => handleMarkDelivered(o.id)}
                              style={{ display: 'flex', alignItems: 'center', gap: '6px', padding: '6px 14px', borderRadius: '99px', fontSize: '12px', fontWeight: 500, border: '1px solid var(--emerald-2)', background: 'var(--emerald)', color: '#ffffff', cursor: 'pointer', fontFamily: 'inherit' }}
                            >
                              <CheckCircleIcon style={{ fontSize: 12 }} /> Mark Delivered
                            </button>
                          )}
                          {status === "ACCEPTED" && isSnack && (
                            <button
                              onClick={() => handleUpdateSnackOrder(o.id, "delivered")}
                              style={{ display: 'flex', alignItems: 'center', gap: '6px', padding: '6px 14px', borderRadius: '99px', fontSize: '12px', fontWeight: 500, border: '1px solid var(--emerald-2)', background: 'var(--emerald)', color: '#ffffff', cursor: 'pointer', fontFamily: 'inherit' }}
                            >
                              <CheckCircleIcon style={{ fontSize: 12 }} /> Mark Delivered
                            </button>
                          )}
                          {status === "PENDING" && !isSnack && (
                            <button
                              onClick={() => handleUpdateStatus(o.id, "accepted")}
                              style={{ display: 'flex', alignItems: 'center', gap: '6px', padding: '6px 14px', borderRadius: '99px', fontSize: '12px', fontWeight: 500, border: '1px solid var(--emerald-2)', background: 'var(--emerald)', color: '#ffffff', cursor: 'pointer', fontFamily: 'inherit' }}
                            >
                              <CheckCircleIcon style={{ fontSize: 12 }} /> Accept
                            </button>
                          )}
                          {status === "PENDING" && isSnack && (
                            <button
                              onClick={() => handleUpdateSnackOrder(o.id, "accepted")}
                              style={{ display: 'flex', alignItems: 'center', gap: '6px', padding: '6px 14px', borderRadius: '99px', fontSize: '12px', fontWeight: 500, border: '1px solid var(--emerald-2)', background: 'var(--emerald)', color: '#ffffff', cursor: 'pointer', fontFamily: 'inherit' }}
                            >
                              <CheckCircleIcon style={{ fontSize: 12 }} /> Accept
                            </button>
                          )}
                          {(status === "PENDING" || status === "ACCEPTED") && !isSnack && (
                            <button
                              onClick={() => handleUpdateStatus(o.id, "cancelled")}
                              style={{ display: 'flex', alignItems: 'center', gap: '6px', padding: '6px 14px', borderRadius: '99px', fontSize: '12px', fontWeight: 500, border: '1px solid var(--hairline-strong)', background: 'transparent', color: 'var(--ink)', cursor: 'pointer', fontFamily: 'inherit' }}
                            >
                              <CancelIcon style={{ fontSize: 12 }} /> Cancel
                            </button>
                          )}
                          {(status === "PENDING" || status === "ACCEPTED") && isSnack && (
                            <button
                              onClick={() => handleUpdateSnackOrder(o.id, "rejected")}
                              style={{ display: 'flex', alignItems: 'center', gap: '6px', padding: '6px 14px', borderRadius: '99px', fontSize: '12px', fontWeight: 500, border: '1px solid var(--hairline-strong)', background: 'transparent', color: 'var(--ink)', cursor: 'pointer', fontFamily: 'inherit' }}
                            >
                              <CancelIcon style={{ fontSize: 12 }} /> Reject
                            </button>
                          )}
                          {status === "DELIVERED" && (
                            <span className="font-display italic" style={{ fontSize: '12px', color: 'var(--ink-muted)' }}>
                              served
                            </span>
                          )}
                          {(status === "CANCELLED" || status === "REJECTED") && (
                            <span className="font-display italic" style={{ fontSize: '12px', color: 'var(--rust)' }}>
                              voided
                            </span>
                          )}
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          )}
        </div>
    </>
  );
}

