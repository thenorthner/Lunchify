import React, { useState, useEffect, useCallback, useMemo } from "react";
import api from "../services/api";
import PageHeader from "./PageHeader";
import SearchIcon from '@mui/icons-material/Search';
import ClearIcon from '@mui/icons-material/Clear';
import CalendarTodayIcon from '@mui/icons-material/CalendarToday';
import QrCodeScannerIcon from '@mui/icons-material/QrCodeScanner';
import RefreshIcon from '@mui/icons-material/Refresh';
import SyncIcon from '@mui/icons-material/Sync';
import { CircularProgress } from "@mui/material";
import "../styles/ScanHistoryPanel.css";

const KindBadge = ({ kind }) => {
  const cfg = {
    FOOD:  { bg: "var(--emerald-soft)", fg: "var(--emerald)", ring: "rgba(30,77,214,.25)" },
    FRUIT: { bg: "#e4f1fb",             fg: "#0e6cb0",        ring: "rgba(45,164,232,.32)" },
    SNACK: { bg: "var(--spark-soft)",   fg: "var(--spark)",   ring: "rgba(226,58,48,.28)" },
    LUNCH: { bg: "var(--emerald-soft)", fg: "var(--emerald)", ring: "rgba(30,77,214,.25)" },
    SHARING: { bg: "#e4f1fb", fg: "#0e6cb0", ring: "rgba(45,164,232,.32)" },
  }[(kind || "").toUpperCase()] || { bg: "var(--bone)", fg: "var(--ink)", ring: "var(--hairline-strong)" };
  
  return (
    <span
      style={{
        display: "inline-flex",
        alignItems: "center",
        padding: "4px 10px",
        borderRadius: "8px",
        fontSize: "10px",
        background: cfg.bg,
        color: cfg.fg,
        border: `1px solid ${cfg.ring}`,
        fontWeight: 600,
        textTransform: "uppercase",
      }}
    >
      {(kind || "").toUpperCase()}
    </span>
  );
};

export default function ScanHistoryPanel() {
  const [loading, setLoading] = useState(false);
  const [logs, setLogs] = useState([]);
  
  const [employeeId, setEmployeeId] = useState("");
  const [date, setDate] = useState("");
  const [month, setMonth] = useState("");

  const fetchScanLogs = useCallback(async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams();
      if (employeeId) params.append("employee_id", employeeId.trim());
      if (date) params.append("date", date);
      if (month) params.append("month", month);
      
      const res = await api.get(`/qr/scan-logs?${params.toString()}`, {
        credentials: "include"
      });
      setLogs(res.data || []);
    } catch (err) {
      console.error("Error fetching scan logs:", err);
    } finally {
      setLoading(false);
    }
  }, [employeeId, date, month]);

  useEffect(() => {
    fetchScanLogs();
  }, [fetchScanLogs]);

  const clearFilters = () => {
    setEmployeeId("");
    setDate("");
    setMonth("");
  };

  return (
    <>
        <PageHeader
          eyebrow="Chapter V · Archive"
          title="Scan history,"
          italicTail="every keystroke witnessed"
          description="A chronological dossier of every QR coupon honoured at this counter. Filter, search, and verify against the source records."
          right={
            <button 
              onClick={fetchScanLogs} 
              disabled={loading}
              style={{ 
                display: 'flex', alignItems: 'center', gap: '6px', 
                fontSize: '13px', fontWeight: 500, color: '#0f172a',
                background: '#fff', border: '1px solid #cbd5e1', borderRadius: '9999px',
                padding: '6px 16px', cursor: 'pointer', transition: 'all 0.2s ease',
                fontFamily: 'inherit'
              }}
              onMouseOver={(e) => e.currentTarget.style.background = '#f8fafc'}
              onFocus={(e) => e.currentTarget.style.background = '#f8fafc'}
              onMouseOut={(e) => e.currentTarget.style.background = '#fff'}
              onBlur={(e) => e.currentTarget.style.background = '#fff'}
            >
              {loading ? <CircularProgress size={16} style={{ color: "inherit" }} /> : <SyncIcon style={{ fontSize: 16, color: '#475569' }} />}
              Refresh
            </button>
          }
        />

        <div
          className="atelier-dark history-filter-bar"
          style={{ padding: '20px', marginBottom: '32px', display: 'grid', gridTemplateColumns: '1fr 200px 200px auto', gap: '12px', alignItems: 'center' }}
        >
          <div style={{ position: 'relative' }}>
            <SearchIcon style={{ position: "absolute", left: 16, top: "50%", transform: "translateY(-50%)", color: "var(--on-dark-muted)", fontSize: 18 }} />
            <input
              placeholder="Search by Employee ID..."
              value={employeeId}
              onChange={(e) => setEmployeeId(e.target.value)}
              style={{
                width: '100%',
                padding: '12px 16px 12px 44px',
                borderRadius: '10px',
                outline: 'none',
                fontSize: '14px',
                fontFamily: 'inherit',
                background: "rgba(84,189,245,.06)",
                border: "1px solid rgba(84,189,245,.22)",
                color: "var(--on-dark)",
                boxSizing: 'border-box'
              }}
            />
          </div>
          <div style={{ position: 'relative' }}>
            <CalendarTodayIcon style={{ position: "absolute", left: 14, top: "50%", transform: "translateY(-50%)", color: "var(--on-dark-muted)", fontSize: 16, zIndex: 10 }} />
            <input
              type="date"
              value={date}
              onChange={(e) => setDate(e.target.value)}
              className="font-mono-tab"
              style={{
                width: '100%',
                padding: '12px 12px 12px 38px',
                borderRadius: '10px',
                outline: 'none',
                fontSize: '13px',
                background: "rgba(84,189,245,.06)",
                border: "1px solid rgba(84,189,245,.22)",
                color: "var(--on-dark)",
                colorScheme: "dark",
                boxSizing: 'border-box'
              }}
            />
          </div>
          <select
            value={month}
            onChange={(e) => setMonth(e.target.value)}
            style={{
              width: '100%',
              padding: '12px 32px 12px 16px',
              borderRadius: '10px',
              outline: 'none',
              fontSize: '13px',
              fontFamily: 'inherit',
              background: "rgba(84,189,245,.06)",
              border: "1px solid rgba(84,189,245,.22)",
              color: "var(--on-dark)",
              appearance: 'none',
              boxSizing: 'border-box'
            }}
          >
            <option value="">Select Month</option>
            <option value="1">January</option>
            <option value="2">February</option>
            <option value="3">March</option>
            <option value="4">April</option>
            <option value="5">May</option>
            <option value="6">June</option>
            <option value="7">July</option>
            <option value="8">August</option>
            <option value="9">September</option>
            <option value="10">October</option>
            <option value="11">November</option>
            <option value="12">December</option>
          </select>
          <button
            onClick={clearFilters}
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '8px',
              padding: '12px 16px',
              borderRadius: '10px',
              fontSize: '13px',
              fontFamily: 'inherit',
              cursor: 'pointer',
              background: "rgba(84,189,245,.14)",
              color: "var(--on-dark-accent)",
              border: "1px solid rgba(84,189,245,.32)"
            }}
          >
            <ClearIcon style={{ fontSize: 16 }} />
            Clear
          </button>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
          {logs.map((log) => {
            const dateObj = new Date(log.scanned_at || log.created_at);
            const formattedDate = dateObj.toLocaleDateString();
            const formattedTime = dateObj.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
            
            return (
              <div
                key={log.id}
                className="atelier lift"
                style={{
                  padding: '20px',
                  display: 'grid',
                  gridTemplateColumns: 'auto 1fr auto auto',
                  alignItems: 'center',
                  gap: '20px',
                  background: '#ffffff',
                  borderRadius: '16px',
                  border: '1px solid var(--hairline)',
                }}
              >
                <div
                  style={{
                    display: 'grid',
                    placeItems: 'center',
                    borderRadius: '12px',
                    width: 48,
                    height: 48,
                    background: "var(--emerald-soft)",
                    border: "1px solid rgba(31,90,71,.18)",
                    color: "var(--emerald)",
                  }}
                >
                  <QrCodeScannerIcon style={{ fontSize: 20 }} />
                </div>
                <div>
                  <div className="font-display" style={{ fontSize: "19px", fontWeight: 500, color: 'var(--ink)' }}>{log.employee_name || "Unknown Employee"}</div>
                  <div style={{ fontSize: "12px", display: 'flex', alignItems: 'center', gap: '8px', marginTop: '2px', color: "var(--ink-muted)" }}>
                    <span className="eyebrow">Employee</span>
                    <span className="font-mono-tab">ID · {log.employee_id}</span>
                  </div>
                </div>
                <KindBadge kind={log.type || "lunch"} />
                <div style={{ textAlign: 'right' }}>
                  <div className="font-mono-tab" style={{ fontSize: "13px", color: "var(--ink)" }}>{formattedDate}</div>
                  <div className="font-mono-tab" style={{ fontSize: "11px", color: "var(--ink-muted)", marginTop: '2px' }}>{formattedTime}</div>
                </div>
              </div>
            );
          })}
          
          {!loading && logs.length === 0 && (
            <div className="atelier" style={{ padding: '48px', textAlign: 'center', background: '#ffffff', borderRadius: '16px', border: '1px solid var(--hairline)' }}>
              <div className="eyebrow" style={{ marginBottom: '8px' }}>Nothing in the archive</div>
              <div className="font-display" style={{ fontSize: '22px', fontWeight: 500, color: 'var(--ink)' }}>No scans match those filters.</div>
            </div>
          )}
          
          {loading && (
            <div className="atelier" style={{ padding: '48px', textAlign: 'center', background: '#ffffff', borderRadius: '16px', border: '1px solid var(--hairline)' }}>
              <CircularProgress size={24} style={{ color: 'var(--ink-muted)', marginBottom: '12px' }} />
              <div className="eyebrow">Fetching archive...</div>
            </div>
          )}
        </div>
    </>
  );
}
