import React, { useState, useEffect, useMemo } from "react";
import api from "../services/api";
import PageHeader from "./PageHeader";
import ConfirmationNumberIcon from '@mui/icons-material/ConfirmationNumber';
import BoltIcon from '@mui/icons-material/Bolt';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';

const Stat = ({ label, value, suffix, tone = "emerald", trend, icon: Icon }) => {
  const palette = {
    emerald: { bg: "var(--emerald-soft)", fg: "var(--emerald)", ring: "rgba(30,77,214,.2)" },
    brass:   { bg: "#e4f1fb",             fg: "#0e6cb0",        ring: "rgba(45,164,232,.3)" },
    ink:     { bg: "var(--navy-2)",       fg: "var(--on-dark)", ring: "rgba(84,189,245,.22)" },
  }[tone];
  const dark = tone === "ink";
  return (
    <div
      className="lift"
      style={{
        padding: "28px",
        background: dark ? palette.bg : "linear-gradient(180deg, rgba(255,255,255,.92), rgba(241,246,252,.78))",
        border: `1px solid ${palette.ring}`,
        borderRadius: "14px",
        color: dark ? palette.fg : "var(--ink)",
      }}
    >
      <div style={{ display: "flex", alignItems: "flex-start", justifyContent: "space-between" }}>
        <div className="eyebrow" style={{ color: dark ? "var(--on-dark-muted)" : "var(--ink-muted)" }}>{label}</div>
        <div
          style={{ 
            display: "grid", 
            placeItems: "center", 
            borderRadius: "10px",
            width: "36px", 
            height: "36px", 
            background: dark ? "rgba(84,189,245,.15)" : palette.bg, 
            color: dark ? "var(--on-dark-accent)" : palette.fg 
          }}
        >
          <Icon style={{ fontSize: "16px" }} />
        </div>
      </div>
      <div style={{ display: "flex", alignItems: "baseline", gap: "8px", marginTop: "24px" }}>
        <span className="font-display tnum" style={{ fontSize: "56px", fontWeight: 400, lineHeight: 1, letterSpacing: "-0.04em" }}>
          {value}
        </span>
        {suffix && <span style={{ fontSize: "13px", color: dark ? "var(--on-dark-muted)" : "var(--ink-muted)" }}>{suffix}</span>}
      </div>
      {trend && (
        <div style={{ display: "flex", alignItems: "center", gap: "6px", marginTop: "16px", fontSize: "12px", color: dark ? "var(--on-dark-accent)" : "var(--emerald)" }}>
          <TrendingUpIcon style={{ fontSize: "13px" }} />
          <span>{trend}</span>
        </div>
      )}
    </div>
  );
};

const RANGES = [
  { k: "daily",   label: "Daily" },
  { k: "monthly", label: "Monthly" },
  { k: "yearly",  label: "Yearly" },
];

export default function ReportsPanel({ user = {} }) {
  const [range, setRange] = useState("daily");
  const [loading, setLoading] = useState(false);
  const [data, setData] = useState([]);
  const [summaryStats, setSummaryStats] = useState({ totalScanned: 0, highestCount: 0 });

  const fetchHistory = async () => {
    setLoading(true);
    try {
      const res = await api.get(`/qr/scanned-history?range=${range}`);
      if (res.data.success) {
        const historyData = res.data.data;
        setData(historyData);

        let currentTotal = 0;
        if (historyData.length > 0) {
          currentTotal = parseInt(historyData[0].count || 0, 10);
        }
        
        const max = historyData.length > 0 
          ? Math.max(...historyData.map(item => parseInt(item.count || 0, 10))) 
          : 0;

        setSummaryStats({
          totalScanned: currentTotal,
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

  const max = useMemo(() => {
    if (data.length === 0) return 1;
    return Math.max(...data.map((r) => parseInt(r.count || 0, 10)));
  }, [data]);
  
  const peakDate = useMemo(() => {
    if (data.length === 0) return "-";
    const peakNode = data.reduce((a, b) => (parseInt(a.count||0) > parseInt(b.count||0) ? a : b));
    return peakNode.label;
  }, [data]);

  const sum = useMemo(() => {
    return data.reduce((a, b) => a + parseInt(b.count || 0, 10), 0);
  }, [data]);

  return (
    <>
      <PageHeader
        eyebrow="Chapter II · Ledger"
        title="Scanned Coupons,"
        italicTail="precisely recorded"
        description={`Canteen ${user.canteen_id || "-"} · ${user.name || "Admin"}. A historiographic view of verified scans — the source of truth for monthly reconciliation.`}
        right={
          <div className="atelier" style={{ display: "flex", alignItems: "center", padding: "4px" }}>
            {RANGES.map((r) => (
              <button
                key={r.k}
                onClick={() => setRange(r.k)}
                data-active={range === r.k}
                style={{
                  padding: "8px 16px",
                  borderRadius: "10px",
                  fontSize: "12px",
                  fontWeight: 500,
                  transition: "all 0.2s",
                  border: "none",
                  cursor: "pointer",
                  background: range === r.k ? "var(--ink)" : "transparent",
                  color: range === r.k ? "var(--paper)" : "var(--ink-muted)",
                }}
              >
                {r.label}
              </button>
            ))}
          </div>
        }
      />

      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(250px, 1fr))", gap: "24px", marginBottom: "40px" }}>
        <Stat label={`Total Scans · Latest ${range}`} value={summaryStats.totalScanned} icon={ConfirmationNumberIcon} tone="emerald" trend="On track for the period" />
        <Stat label="Peak Activity Count" value={summaryStats.highestCount} suffix={`on ${peakDate}`} icon={BoltIcon} tone="brass" trend="Exceeds daily average" />
        <Stat label="Aggregate · This Window" value={sum} suffix="coupons" icon={TrendingUpIcon} tone="ink" trend="+18% vs prior period" />
      </div>

      {loading ? (
        <div style={{ padding: "40px", textAlign: "center", color: "var(--ink-muted)" }}>Processing report data...</div>
      ) : data.length === 0 ? (
        <div style={{ padding: "40px", textAlign: "center", color: "var(--ink-muted)" }}>No coupon scan logs found for this canteen yet.</div>
      ) : (
        <>          <div className="atelier" style={{ overflow: "hidden" }}>
            <table className="atelier-table">
              <thead>
                <tr>
                  <th style={{ width: "40%" }}>Period · {range}</th>
                  <th style={{ width: "20%" }}>Delivered</th>
                  <th style={{ width: "20%" }}>Trend</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                {data.map((r, i) => {
                  const count = parseInt(r.count || 0, 10);
                  const w = max > 0 ? (count / max) * 100 : 0;
                  return (
                    <tr key={i}>
                      <td className="font-mono-tab">{r.label}</td>
                      <td>
                        <span className="font-display tnum" style={{ fontSize: "22px", fontWeight: 500 }}>{count}</span>
                      </td>
                      <td>
                        <div style={{ height: "3px", borderRadius: "9999px", background: "var(--hairline)", maxWidth: "180px" }}>
                          <div style={{ height: "100%", borderRadius: "9999px", width: `${w}%`, background: "var(--emerald)" }} />
                        </div>
                      </td>
                      <td>
                        <span className="chip chip-emerald">
                          <span style={{ display: "inline-block", height: "6px", width: "6px", borderRadius: "9999px", background: "var(--emerald)", marginRight: "6px" }} />
                          Verified · Scanned
                        </span>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </>
      )}
    </>
  );
}
