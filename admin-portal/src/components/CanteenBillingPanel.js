import React, { useState, useEffect, useMemo } from "react";
import api from "../services/api";
import PageHeader from "./PageHeader";
import { CircularProgress } from "@mui/material";
import DescriptionOutlinedIcon from '@mui/icons-material/DescriptionOutlined';
import CalendarTodayIcon from '@mui/icons-material/CalendarToday';
import GetAppIcon from '@mui/icons-material/GetApp';
import AutoAwesomeIcon from '@mui/icons-material/AutoAwesome';
import ReceiptLongIcon from '@mui/icons-material/ReceiptLong';
import "../styles/billing.css";

export default function CanteenBillingPanel({ user = {} }) {
  const [couponsScanned, setCouponsScanned] = useState(0);
  const [couponPrice, setCouponPrice] = useState(60);
  const [billMonth, setBillMonth] = useState("");
  const [loading, setLoading] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [pastBills, setPastBills] = useState([]);

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
      const queryCanteen = user?.canteen_id ? `&canteen_id=${user.canteen_id}` : '';
      const res = await api.get(`/qr/scanned-history?range=monthly${queryCanteen}`);

      if (res.data.success) {
        const found = res.data.data.find(item => item.label === billMonth);
        setCouponsScanned(found ? parseInt(found.count, 10) : 0);
      }
    } catch (err) {
      console.error("Error fetching scanned count:", err);
    } finally {
      setLoading(false);
    }
  };

  const fetchPastBills = async () => {
    try {
      const queryCanteen = user?.canteen_id ? `?canteen_id=${user.canteen_id}` : '';
      const res = await api.get(`/billing/canteen-bills${queryCanteen}`);
      setPastBills(res.data);
    } catch (err) {
      console.error("Error fetching past bills:", err);
    }
  };

  const handleDownloadPDF = async (billId) => {
    try {
      const res = await api.get(`/billing/${billId}/pdf`, { responseType: 'blob' });
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
      const res = await api.get(`/billing/fruit-lunch-pdf`, { responseType: 'blob' });
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

  useEffect(() => {
    if (billMonth) {
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
      const res = await api.post("/billing/generate-canteen-bill", {
        bill_month: billMonth,
        total_coupons_scanned: couponsScanned,
        coupon_price: parseFloat(couponPrice),
        total_amount: totalAmount,
        place_generated: "Canteen Portal",
        canteen_id: user.canteen_id || 5
      });

      if (res.data.success) {
        alert("Monthly billing consolidated and submitted successfully to HR!");
        fetchPastBills();
      }
    } catch (err) {
      alert(err.response?.data?.error || "Failed to submit monthly bill");
    } finally {
      setSubmitting(false);
    }
  };

  const total = useMemo(() => couponsScanned * couponPrice, [couponsScanned, couponPrice]);

  const selectedMonthName = useMemo(() => {
    if (!billMonth) return "Current Month";
    const d = new Date(billMonth + "-01");
    return d.toLocaleString("en-US", { month: "long" });
  }, [billMonth]);

  const ytdSettled = useMemo(() => {
    return pastBills
      .filter(b => b.status === "approved")
      .reduce((sum, b) => sum + parseFloat(b.total_amount), 0);
  }, [pastBills]);

  return (
    <div className="billing-container fade-in" style={{ fontFamily: '"Geist", "Inter", "Lexend", -apple-system, system-ui, sans-serif' }}>
      <PageHeader
        eyebrow="Chapter III · Treasury"
        title="Monthly canteen"
        italicTail="invoicing & reconciliation"
        description={`Canteen ${user.canteen_id || '5'} · Administrator Desk. Consolidate coupon counts, set the per-lunch rate, and submit the invoice to Human Resources.`}
        right={
          <div className="chip chip-emerald">
            <AutoAwesomeIcon style={{ fontSize: 13, marginRight: 4 }} />
            <span>FY 2026 · Q2</span>
          </div>
        }
      />

      <div style={{ display: 'grid', gridTemplateColumns: '1.05fr 1fr', gap: '24px', alignItems: 'start', paddingBottom: '40px' }}>
        
        {/* Invoice Composer */}
        <div style={{ padding: '32px', background: '#ffffff', borderRadius: '16px', border: '1px solid #cbd5e1', boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.02)', position: 'relative' }}>
          {/* Top-left corner cut */}
          <div style={{ position: 'absolute', top: '-1px', left: '-1px', width: '24px', height: '24px', borderTop: '2px solid #38bdf8', borderLeft: '2px solid #38bdf8', borderTopLeftRadius: '16px' }} />
          {/* Bottom-right corner cut */}
          <div style={{ position: 'absolute', bottom: '-1px', right: '-1px', width: '24px', height: '24px', borderBottom: '2px solid #38bdf8', borderRight: '2px solid #38bdf8', borderBottomRightRadius: '16px' }} />
          <div className="eyebrow" style={{ marginBottom: '8px' }}>Consolidate · Monthly Invoice</div>
          <h2 className="font-display" style={{ fontSize: '34px', lineHeight: 1.1, fontWeight: 400, margin: 0, color: 'var(--navy)' }}>
            Compose the <span style={{ fontStyle: "italic", color: "#1e4dd6" }}>{selectedMonthName}</span> invoice
          </h2>

          <div style={{ marginTop: '28px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
            <div>
              <label className="eyebrow" htmlFor="billMonth" style={{ color: '#64748b', letterSpacing: '0.15em' }}>Billing Month</label>
              <div style={{ marginTop: '12px', position: 'relative' }}>
                <CalendarTodayIcon style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)', fontSize: 16, color: '#94a3b8' }} />
                <input
                  id="billMonth"
                  type="month"
                  value={billMonth}
                  onChange={(e) => setBillMonth(e.target.value)}
                  className="input-atelier"
                  style={{ width: '100%', boxSizing: 'border-box', paddingLeft: '44px', height: '52px', fontSize: '15px', color: 'var(--navy)' }}
                />
              </div>
            </div>
            <div>
              <label className="eyebrow" htmlFor="couponPrice" style={{ color: '#64748b', letterSpacing: '0.15em' }}>Rate per Lunch Coupon (₹)</label>
              <div style={{ marginTop: '12px', position: 'relative' }}>
                <span className="font-mono-tab" style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)', fontSize: '16px', color: 'var(--navy)' }}>₹</span>
                <input
                  id="couponPrice"
                  type="number"
                  value={couponPrice}
                  onChange={(e) => setCouponPrice(Number(e.target.value) || 0)}
                  className="input-atelier"
                  style={{ width: '100%', boxSizing: 'border-box', paddingLeft: '40px', height: '52px', fontSize: '15px', color: 'var(--navy)' }}
                />
              </div>
            </div>
          </div>

          <div style={{ marginTop: '24px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
            {/* Coupons Scanned */}
            <div
              style={{
                padding: '24px',
                borderRadius: '16px',
                background: '#eaf4ff',
                border: '1px solid rgba(30, 77, 214, 0.15)',
                position: 'relative',
                overflow: 'hidden'
              }}
            >
              <div className="eyebrow" style={{ color: "#1e4dd6" }}>Coupons Scanned</div>
              <div className="font-display tnum" style={{ fontSize: '64px', fontWeight: 400, lineHeight: 1, letterSpacing: "-0.04em", marginTop: '12px', color: "#0a1733" }}>
                {loading ? <CircularProgress size={28} style={{ color: '#1e4dd6', margin: '18px 0' }} /> : couponsScanned}
              </div>
              <div style={{ fontSize: '13px', marginTop: '12px', color: "#1e4dd6" }}>verified entries</div>
            </div>

            {/* Calculated Total */}
            <div
              style={{
                padding: '24px',
                borderRadius: '16px',
                background: '#0a1733',
                color: '#ffffff',
                position: 'relative',
                overflow: 'hidden',
                boxShadow: '0 8px 24px -8px rgba(10, 23, 51, 0.4)'
              }}
            >
              <div className="eyebrow" style={{ color: "#54bdf5" }}>Calculated Total</div>
              <div className="font-display tnum" style={{ fontSize: '64px', fontWeight: 400, lineHeight: 1, letterSpacing: "-0.04em", marginTop: '12px', color: '#ffffff' }}>
                <span style={{ color: "#54bdf5", fontSize: '40px', marginRight: '6px', verticalAlign: 'baseline' }}>₹</span>
                {total.toLocaleString("en-IN")}
              </div>
              <div style={{ fontSize: '13px', marginTop: '16px', color: "#8a9bbe" }}>{couponsScanned} × ₹{couponPrice}</div>
            </div>
          </div>

          <button
            onClick={handleSubmitBill}
            disabled={submitting || couponsScanned <= 0}
            style={{
              width: '100%',
              marginTop: '32px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '10px',
              padding: '18px',
              borderRadius: '999px',
              background: '#0a1733',
              color: '#ffffff',
              fontSize: '16px',
              fontWeight: 600,
              cursor: (submitting || couponsScanned <= 0) ? 'not-allowed' : 'pointer',
              opacity: (submitting || couponsScanned <= 0) ? 0.6 : 1,
              border: 'none',
              boxShadow: '0 8px 24px -12px rgba(10, 23, 51, 0.6)',
              transition: 'all 0.2s',
              fontFamily: 'inherit'
            }}
          >
            <ReceiptLongIcon style={{ fontSize: 20 }} />
            {submitting ? "Submitting..." : "Generate & Submit Bill to HR"}
          </button>

          <div className="hairline" style={{ margin: '36px 0' }} />

          <div style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
            <div style={{ display: 'grid', placeItems: 'center', flexShrink: 0, width: '44px', height: '44px', borderRadius: '12px', background: '#f4f7fb', border: '1px solid #c7d2e3', color: '#3b82f6' }}>
              <DescriptionOutlinedIcon style={{ fontSize: 20 }} />
            </div>
            <div style={{ flex: 1 }}>
              <div className="font-display" style={{ fontSize: '18px', fontWeight: 600, color: 'var(--navy)' }}>Fruit Lunch Report</div>
              <p style={{ fontSize: '13.5px', marginTop: '4px', color: 'var(--ink-muted)', lineHeight: 1.5, margin: 0 }}>
                Download the current month's fruit lunch orders for this canteen — a parallel ledger for fruit-only consumers.
              </p>
            </div>
            <button
              onClick={handleDownloadFruitLunchPDF}
              style={{
                display: 'flex', alignItems: 'center', gap: '8px',
                background: 'linear-gradient(135deg, #2da4e8, #1e4dd6)',
                color: '#fff',
                padding: '12px 28px',
                borderRadius: '99px',
                fontSize: '15px',
                fontWeight: 600,
                border: 'none',
                cursor: 'pointer',
                boxShadow: '0 4px 12px rgba(30,77,214,.3)',
                transition: 'transform 0.2s',
                fontFamily: 'inherit'
              }}
            >
              <GetAppIcon style={{ fontSize: 18 }} />
              PDF
            </button>
          </div>
        </div>

        {/* Ledger */}
        <div style={{ padding: '32px', background: '#ffffff', borderRadius: '16px', border: '1px solid #cbd5e1', boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.02)' }}>
          <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', marginBottom: '24px' }}>
            <div>
              <div className="eyebrow">Submission Ledger</div>
              <h3 className="font-display" style={{ fontSize: '26px', fontWeight: 500, marginTop: '4px', margin: 0 }}>Recent invoices</h3>
            </div>
            <span className="chip">All time</span>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            {pastBills.length === 0 ? (
              <div style={{ textAlign: 'center', padding: '40px 0', color: 'var(--ink-muted)', fontSize: '13px' }}>No billing records found.</div>
            ) : (
              pastBills.map((b, i) => {
                const isApproved = b.status === "approved";
                return (
                  <div
                    key={i}
                    style={{
                      padding: '24px',
                      borderRadius: '16px',
                      display: 'grid',
                      gridTemplateColumns: '1fr auto auto',
                      alignItems: 'center',
                      gap: '20px',
                      background: '#ffffff',
                      border: '1px solid #cbd5e1',
                      boxShadow: '0 1px 3px rgba(0,0,0,0.02)',
                      transition: 'transform 0.2s, box-shadow 0.2s',
                      cursor: 'pointer'
                    }}
                    onMouseEnter={(e) => { e.currentTarget.style.transform = 'translateY(-2px)'; e.currentTarget.style.boxShadow = '0 6px 12px rgba(0,0,0,0.05)'; }}
                    onMouseLeave={(e) => { e.currentTarget.style.transform = 'translateY(0)'; e.currentTarget.style.boxShadow = '0 1px 3px rgba(0,0,0,0.02)'; }}
                  >
                    <div>
                      <div className="font-mono-tab" style={{ fontSize: '12px', color: 'var(--ink-muted)' }}>{b.bill_month}</div>
                      <div className="font-display" style={{ fontSize: '22px', fontWeight: 500, marginTop: '2px' }}>
                        ₹<span className="tnum">{parseFloat(b.total_amount).toLocaleString("en-IN")}</span>
                      </div>
                      <div style={{ fontSize: '12px', color: 'var(--ink-muted)' }}>
                        {b.total_coupons_used} coupons × ₹{b.coupon_price}
                      </div>
                    </div>
                    
                    <span 
                      style={isApproved ? {
                        display: 'inline-flex', alignItems: 'center', gap: '6px',
                        background: '#eff6ff',
                        border: '1px solid #bfdbfe',
                        color: '#2563eb',
                        padding: '4px 12px',
                        borderRadius: '99px',
                        fontSize: '11px',
                        fontWeight: 600,
                        letterSpacing: '0.05em'
                      } : {
                        display: 'inline-flex', alignItems: 'center', gap: '6px',
                        background: '#fef3c7',
                        border: '1px solid #fde68a',
                        color: '#b45309',
                        padding: '4px 12px',
                        borderRadius: '99px',
                        fontSize: '11px',
                        fontWeight: 600,
                        letterSpacing: '0.05em'
                      }}
                    >
                      <span
                        style={{
                          display: 'inline-block',
                          height: '6px',
                          width: '6px',
                          borderRadius: '50%',
                          background: isApproved ? "#2563eb" : "#b45309",
                        }}
                      />
                      {b.status.toUpperCase()}
                    </span>
                    
                    <button
                      onClick={() => handleDownloadPDF(b.id)}
                      style={{ 
                        display: 'flex', alignItems: 'center', gap: '6px', fontSize: '12px',
                        background: 'linear-gradient(135deg, #2da4e8, #1e4dd6)',
                        color: '#fff',
                        padding: '6px 16px',
                        borderRadius: '99px',
                        fontWeight: 600,
                        border: 'none',
                        cursor: 'pointer',
                        boxShadow: '0 4px 12px rgba(30,77,214,.3)',
                        transition: 'transform 0.2s',
                        fontFamily: 'inherit'
                      }}
                    >
                      <GetAppIcon style={{ fontSize: 14 }} />
                      PDF
                    </button>
                  </div>
                );
              })
            )}
          </div>

          <div className="hairline" style={{ margin: '24px 0' }} />
          
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', fontSize: '12px', color: 'var(--ink-muted)' }}>
            <span className="eyebrow">YTD Settled</span>
            <span className="font-mono-tab">
              ₹{ytdSettled.toLocaleString("en-IN")}
            </span>
          </div>
        </div>

      </div>
    </div>
  );
}
