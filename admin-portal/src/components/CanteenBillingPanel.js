import React, { useState, useEffect } from "react";
import axios from "axios";
import "../styles/billing.css";

export default function CanteenBillingPanel() {
  const token = localStorage.getItem("adminToken");
  const user = JSON.parse(localStorage.getItem("adminUser") || "{}");

  const [couponsScanned, setCouponsScanned] = useState(0);
  const [couponPrice, setCouponPrice] = useState(60); // Default price per coupon
  const [billMonth, setBillMonth] = useState("");
  const [loading, setLoading] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [pastBills, setPastBills] = useState([]);

  const axiosConfig = {
    headers: { Authorization: `Bearer ${token}` }
  };

  // Get current month in YYYY-MM format
  const getCurrentMonthString = () => {
    const d = new Date();
    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, '0');
    return `${year}-${month}`;
  };

  useEffect(() => {
    setBillMonth(getCurrentMonthString());
  }, []);

  const fetchScannedCount = async () => {
    if (!billMonth) return;
    setLoading(true);
    try {
      // Get monthly scan stats
      const res = await axios.get(
        `http://localhost:3001/api/qr/scanned-history?range=monthly`,
        axiosConfig
      );

      if (res.data.success) {
        const found = res.data.data.find(item => item.label === billMonth);
        setCouponsScanned(found ? found.count : 0);
      }
    } catch (err) {
      console.error("Error fetching scanned count:", err);
    } finally {
      setLoading(false);
    }
  };

  const fetchPastBills = async () => {
    try {
      const res = await axios.get("http://localhost:3001/api/billing/canteen-bills", axiosConfig);
      setPastBills(res.data);
    } catch (err) {
      console.error("Error fetching past bills:", err);
    }
  };

  const handleDownloadPDF = async (billId) => {
    try {
      const res = await axios.get(`http://localhost:3001/api/billing/${billId}/pdf`, {
        ...axiosConfig,
        responseType: 'blob'
      });
      const url = window.URL.createObjectURL(new Blob([res.data]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `Bill_${billId}.pdf`);
      document.body.appendChild(link);
      link.click();
    } catch (err) {
      alert("Failed to download PDF");
    }
  };

  const handleDownloadFruitLunchPDF = async () => {
    try {
      const res = await axios.get(`http://localhost:3001/api/billing/fruit-lunch-pdf`, {
        ...axiosConfig,
        responseType: 'blob'
      });
      const url = window.URL.createObjectURL(new Blob([res.data]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `Fruit_Lunch_Orders.pdf`);
      document.body.appendChild(link);
      link.click();
    } catch (err) {
      alert("Failed to download Fruit Lunch PDF");
    }
  };

  const handleEditRevertedBill = (b) => {
    setBillMonth(b.bill_month);
    setCouponPrice(b.coupon_price);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  useEffect(() => {
    if (billMonth && token) {
      fetchScannedCount();
      fetchPastBills();
    }
  }, [billMonth]);

  const handleSubmitBill = async (e) => {
    e.preventDefault();
    if (couponsScanned <= 0) {
      alert("Cannot generate a bill with 0 scanned coupons.");
      return;
    }

    setSubmitting(true);
    try {
      const totalAmount = couponsScanned * couponPrice;
      const res = await axios.post(
        "http://localhost:3001/api/billing/generate-canteen-bill",
        {
          bill_month: billMonth,
          total_coupons_scanned: couponsScanned,
          coupon_price: parseFloat(couponPrice),
          total_amount: totalAmount,
          place_generated: "Canteen Portal"
        },
        axiosConfig
      );

      if (res.data.success) {
        alert("Monthly billing consolidated and submitted successfully to HR! 🎉");
        fetchPastBills();
      }
    } catch (err) {
      alert(err.response?.data?.error || "Failed to submit monthly bill");
    } finally {
      setSubmitting(false);
    }
  };

  const finalAmount = couponsScanned * couponPrice;

  return (
    <div className="billing-panel-container fade-in">
      <div className="billing-header">
        <div>
          <h2>💳 Monthly Canteen Billing System</h2>
          <p className="hr-project-tag">🏪 Canteen: {user.canteen_id} | Administrator Dashboard</p>
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '30px', marginTop: '20px' }}>
        
        {/* BILL GENERATION BOX */}
        <div className="rep-card" style={{ display: 'block', padding: '24px', backgroundColor: '#fff', borderRadius: '16px', boxShadow: '0 4px 20px rgba(0,0,0,0.05)' }}>
          <h3 style={{ marginBottom: '16px', color: '#1a3a8f' }}>Consolidate Monthly Invoice</h3>
          <form onSubmit={handleSubmitBill}>
            <div className="form-group" style={{ marginBottom: '16px' }}>
              <label style={{ display: 'block', fontWeight: '600', marginBottom: '6px' }}>Billing Month</label>
              <input 
                type="month" 
                value={billMonth} 
                onChange={(e) => setBillMonth(e.target.value)} 
                style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px style #ccc' }}
                required 
              />
            </div>

            <div className="billing-quick-stats" style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', marginBottom: '20px' }}>
              <div className="quick-stat-box count-box" style={{ margin: 0, padding: '14px' }}>
                <h5 style={{ margin: 0, fontSize: '12px', color: '#555' }}>Coupons Scanned</h5>
                {loading ? <p style={{ fontSize: '18px' }}>...</p> : <p style={{ fontSize: '24px', margin: '4px 0 0 0' }}>{couponsScanned}</p>}
              </div>
              
              <div className="quick-stat-box amt-box" style={{ margin: 0, padding: '14px', background: '#e6f0ff', border: '1px solid #b3d1ff' }}>
                <h5 style={{ margin: 0, fontSize: '12px', color: '#1a3a8f' }}>Calculated Total</h5>
                <p style={{ fontSize: '24px', margin: '4px 0 0 0', color: '#1a3a8f' }}>₹{finalAmount.toFixed(2)}</p>
              </div>
            </div>

            <div className="form-group" style={{ marginBottom: '20px' }}>
              <label style={{ display: 'block', fontWeight: '600', marginBottom: '6px' }}>Rate per Lunch Coupon (₹)</label>
              <input 
                type="number" 
                value={couponPrice} 
                onChange={(e) => setCouponPrice(Math.max(1, parseFloat(e.target.value) || 0))} 
                style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid #ccc' }}
                min="1"
                required 
              />
            </div>

            <button 
              type="submit" 
              className="btn-action btn-approve" 
              style={{ width: '100%', padding: '12px', fontSize: '15px', borderRadius: '8px', background: '#1a3a8f', color: '#fff', cursor: 'pointer', border: 'none' }}
              disabled={submitting || couponsScanned === 0}
            >
              {submitting ? "Consolidating Bill..." : "🚀 Generate & Submit Bill to HR"}
            </button>
          </form>

          <div style={{ marginTop: '20px', borderTop: '1px solid #eee', paddingTop: '16px' }}>
            <h4 style={{ marginBottom: '10px', color: '#555', fontSize: '14px' }}>Fruit Lunch Report</h4>
            <p style={{ fontSize: '12px', color: '#777', marginBottom: '12px' }}>Download the current month's fruit lunch orders for this canteen.</p>
            <button 
              type="button" 
              className="btn-action" 
              onClick={handleDownloadFruitLunchPDF}
              style={{ width: '100%', padding: '10px', fontSize: '14px', borderRadius: '8px', background: '#0d6efd', color: '#fff', cursor: 'pointer', border: 'none' }}
            >
              📥 Download Fruit Lunch PDF
            </button>
          </div>
        </div>

        {/* BILL SUBMISSION STATUS LIST */}
        <div className="rep-card" style={{ display: 'block', padding: '24px', backgroundColor: '#fff', borderRadius: '16px', boxShadow: '0 4px 20px rgba(0,0,0,0.05)' }}>
          <h3 style={{ marginBottom: '16px', color: '#1a3a8f' }}>Billing Submission Ledger</h3>
          <div style={{ maxHeight: '320px', overflowY: 'auto' }}>
            {pastBills.length === 0 ? (
              <p style={{ color: '#888', textAlign: 'center', marginTop: '40px' }}>No monthly bills submitted by this canteen yet.</p>
            ) : (
              <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '13px' }}>
                <thead>
                  <tr style={{ borderBottom: '2px solid #eee', textAlign: 'left' }}>
                    <th style={{ padding: '8px 4px' }}>Month</th>
                    <th style={{ padding: '8px 4px' }}>Coupons</th>
                    <th style={{ padding: '8px 4px' }}>Rate</th>
                    <th style={{ padding: '8px 4px' }}>Total</th>
                    <th style={{ padding: '8px 4px' }}>Status</th>
                    <th style={{ padding: '8px 4px' }}>Action</th>
                  </tr>
                </thead>
                <tbody>
                  {pastBills.map((b) => (
                    <React.Fragment key={b.id}>
                      <tr style={{ borderBottom: b.comments ? 'none' : '1px solid #eee' }}>
                        <td style={{ padding: '10px 4px' }}>{b.bill_month}</td>
                        <td style={{ padding: '10px 4px' }}>{b.total_coupons_used}</td>
                        <td style={{ padding: '10px 4px' }}>₹{b.coupon_price}</td>
                        <td style={{ padding: '10px 4px' }}>₹{b.total_amount}</td>
                        <td style={{ padding: '10px 4px' }}>
                          <span className={`status-badge bill-${b.status}`} style={{ fontSize: '10px', padding: '2px 6px' }}>
                            {b.status.toUpperCase()}
                          </span>
                        </td>
                        <td style={{ padding: '10px 4px' }}>
                          {b.status === "approved" && (
                            <button 
                              className="btn-action" 
                              style={{background: '#0d6efd', padding: '4px 8px', fontSize: '11px', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer'}}
                              onClick={() => handleDownloadPDF(b.id)}
                            >
                              PDF
                            </button>
                          )}
                        </td>
                      </tr>
                      {b.comments && (
                        <tr style={{ borderBottom: '1px solid #eee', backgroundColor: b.status === 'review' ? '#fffaf0' : '#f8f9fa' }}>
                          <td colSpan="6" style={{ padding: '8px 10px', fontSize: '12px', color: '#555', borderLeft: b.status === 'review' ? '3px solid #ff9800' : '3px solid #ccc' }}>
                            <strong>HR Feedback:</strong> {b.comments}
                            {b.status === 'review' && (
                              <button onClick={() => handleEditRevertedBill(b)} style={{ float: 'right', padding: '4px 10px', background: '#ff9800', color: '#fff', border: 'none', borderRadius: '4px', cursor: 'pointer', fontSize: '11px', fontWeight: 'bold' }}>
                                ✏️ Edit & Resubmit
                              </button>
                            )}
                          </td>
                        </tr>
                      )}
                    </React.Fragment>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </div>

      </div>
    </div>
  );
}
