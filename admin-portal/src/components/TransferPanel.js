import React, { useEffect, useState } from "react";
import api from "../services/api";
import { CircularProgress } from "@mui/material";
import PageHeader from "../components/PageHeader";
import "../styles/TransferPanel.css";

// Icons
import PeopleIcon from '@mui/icons-material/People';
import ArrowForwardIcon from '@mui/icons-material/ArrowForward';
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';
import SecurityIcon from '@mui/icons-material/Security';
import ReceiptLongIcon from '@mui/icons-material/ReceiptLong';
import LocationOnIcon from '@mui/icons-material/LocationOn';
import SendIcon from '@mui/icons-material/Send';
import WarningAmberIcon from '@mui/icons-material/WarningAmber';
import HistoryIcon from '@mui/icons-material/History';
import MenuBookIcon from '@mui/icons-material/MenuBook';

export default function TransferPanel({ user = {} }) {
  const [history, setHistory] = useState([]);
  const [projects, setProjects] = useState([]);
  const [loading, setLoading] = useState(false);

  // Form State
  const [employeeId, setEmployeeId] = useState("");
  const [toProjectId, setToProjectId] = useState("2"); // default to Rampur (since 1 is Shimla HQ)
  const [transferring, setTransferring] = useState(false);

  const fetchHistoryAndProjects = async () => {
    setLoading(true);
    try {
      const [historyRes, projectsRes] = await Promise.all([
        api.get("/transfer/history"),
        api.get("/transfer/projects")
      ]);
      setHistory(historyRes.data);
      setProjects(projectsRes.data);
      if (projectsRes.data.length > 0) {
        setToProjectId(projectsRes.data[0].id.toString());
      }
    } catch (err) {
      console.error("Error fetching data:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchHistoryAndProjects();
  }, []);

  const handleTransfer = async (e) => {
    e.preventDefault();
    if (!employeeId.trim()) return alert("Please enter a valid Employee ID");

    const selectedProject = projects.find(p => p.id.toString() === toProjectId);
    const targetProjectName = selectedProject ? selectedProject.name : "Selected Project";

    const confirmTransfer = window.confirm(
      `Are you sure you want to transfer Employee ${employeeId.toUpperCase()} to ${targetProjectName}? This will automatically align their canteen association and preserve their coupon balance.`
    );
    if (!confirmTransfer) return;

    setTransferring(true);
    try {
      const res = await api.post("/transfer/request",
        {
          employee_id: employeeId.trim().toUpperCase(),
          to_project_id: parseInt(toProjectId, 10)
        }
      );

      if (res.data.success) {
        alert(res.data.message);
        setEmployeeId("");
        fetchHistoryAndProjects();
      }
    } catch (err) {
      alert(err.response?.data?.error || "Failed to perform transfer request");
    } finally {
      setTransferring(false);
    }
  };

  const activeTargetProject = projects.find(p => p.id.toString() === toProjectId);

  return (
    <>
      <PageHeader
        eyebrow="Chapter XI · Mobility"
        title="Employee project"
        italicTail="transfers"
        description={`Relocate an employee to another project location. The system preserves their remaining coupon balance and realigns their active canteen association. Associated Project · ${user.project_id || '05'}.`}
        right={
          <div className="chip" data-testid="audit-badge">
            <MenuBookIcon style={{ fontSize: 13 }} />
            <span className="eyebrow">Audit Trail</span>
            <span className="font-mono-tab" style={{ fontSize: '12px' }}>{history.length}</span>
          </div>
        }
      />

      <div style={{ display: 'grid', gridTemplateColumns: '1.05fr 1fr', gap: '24px', marginBottom: '40px' }} className="transfer-grid">
        {/* Relocate form */}
        <div className="atelier brass-corner" style={{ padding: '28px' }} data-testid="relocate-form">
          <div style={{ display: 'flex', alignItems: 'flex-start', gap: '16px', marginBottom: '24px' }}>
            <div
              style={{
                display: 'grid', placeItems: 'center', borderRadius: '12px', flexShrink: 0,
                width: 48, height: 48,
                background: "linear-gradient(140deg, #54bdf5, #1e4dd6)",
                color: "#fff",
                boxShadow: "0 10px 24px -12px rgba(30,77,214,.5)",
              }}
            >
              <PeopleIcon style={{ fontSize: 20 }} />
            </div>
            <div>
              <div className="eyebrow" style={{ color: "var(--brass)", marginBottom: '4px' }}>Mobility</div>
              <h3 className="font-display" style={{ fontSize: 26, fontWeight: 500, letterSpacing: "-0.02em", margin: 0 }}>
                Relocate an employee
              </h3>
              <p style={{ fontSize: '13px', marginTop: '4px', color: "var(--ink-muted)", margin: '4px 0 0 0' }}>
                Provide the employee's ID and choose their new project. Coupon ledger reconciles automatically.
              </p>
            </div>
          </div>

          <form onSubmit={handleTransfer} style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            <div data-testid="empid-field">
              <label htmlFor="employeeIdInput" className="eyebrow" style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px' }}>
                <PeopleIcon style={{ fontSize: 12, color: "var(--ink-muted)" }} />
                Employee ID
              </label>
              <input
                id="employeeIdInput"
                value={employeeId}
                onChange={(e) => setEmployeeId(e.target.value)}
                className="input-atelier font-mono-tab"
                placeholder="e.g. EMP101"
                data-testid="transfer-empid"
                required
                style={{ width: '100%', boxSizing: 'border-box' }}
              />
            </div>

            <div data-testid="target-field">
              <label htmlFor="toProjectIdSelect" className="eyebrow" style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px' }}>
                <LocationOnIcon style={{ fontSize: 12, color: "var(--ink-muted)" }} />
                Target Project Location
              </label>
              <div style={{ position: 'relative' }}>
                <select
                  id="toProjectIdSelect"
                  value={toProjectId}
                  onChange={(e) => setToProjectId(e.target.value)}
                  className="input-atelier"
                  data-testid="transfer-target"
                  required
                  style={{ width: '100%', boxSizing: 'border-box', paddingRight: '40px', appearance: 'none' }}
                >
                  {projects.map(proj => (
                    <option key={proj.id} value={proj.id}>
                      {proj.name} ({proj.location})
                    </option>
                  ))}
                </select>
                <ExpandMoreIcon
                  style={{
                    position: 'absolute', right: '12px', top: '50%', transform: 'translateY(-50%)',
                    pointerEvents: 'none', color: "var(--ink-muted)", fontSize: 14
                  }}
                />
              </div>
            </div>

            {/* Visual journey preview */}
            <div
              style={{
                padding: '16px', borderRadius: '12px', display: 'flex', alignItems: 'center',
                gap: '12px', flexWrap: 'wrap', background: "var(--paper-2)", border: "1px solid var(--hairline)"
              }}
              data-testid="journey-preview"
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '12.5px', color: "var(--ink-muted)" }}>
                <span className="eyebrow">From</span>
                <span className="font-mono-tab" style={{ color: "var(--ink)" }}>
                  {employeeId.trim() || "—"}'s current project
                </span>
              </div>
              <ArrowForwardIcon style={{ fontSize: 14, color: "var(--brass)" }} />
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '12.5px' }}>
                <span className="eyebrow">To</span>
                <span style={{ color: "var(--emerald)", fontWeight: 500 }}>
                  {activeTargetProject ? activeTargetProject.name : 'Select Project'}
                </span>
              </div>
            </div>

            <button
              type="submit"
              className="btn-brass"
              data-testid="execute-transfer"
              disabled={!employeeId.trim() || transferring}
              style={{ width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', marginTop: '4px' }}
            >
              <SendIcon style={{ fontSize: 15 }} />
              {transferring ? "Processing Relocation..." : "Execute Project Transfer"}
            </button>
          </form>
        </div>

        {/* Side: audit stat + rules */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
          {/* Audit counter */}
          <div
            style={{
              padding: '24px',
              background: "linear-gradient(135deg, var(--navy-2), var(--navy))",
              color: "var(--on-dark)",
              border: "1px solid rgba(84,189,245,.22)",
              borderRadius: '14px',
            }}
            data-testid="audit-card"
          >
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <div className="eyebrow" style={{ color: "var(--on-dark-accent)" }}>Transfers audited</div>
              <div
                style={{
                  display: 'grid', placeItems: 'center', borderRadius: '10px',
                  width: 36, height: 36, background: "rgba(84,189,245,.15)", color: "var(--on-dark-accent)"
                }}
              >
                <ReceiptLongIcon style={{ fontSize: 16 }} />
              </div>
            </div>
            <div className="font-display" style={{ fontSize: 60, fontWeight: 400, lineHeight: 1, letterSpacing: "-0.04em", fontVariantNumeric: 'tabular-nums', marginTop: '20px' }}>
              {history.length}
            </div>
            <div style={{ fontSize: '12px', marginTop: '8px', color: "var(--on-dark-muted)" }}>
              all journalled · immutable · signed
            </div>
          </div>

          {/* Rules */}
          <div
            className="atelier"
            style={{
              padding: '24px',
              background: "linear-gradient(180deg, rgba(251,234,203,.55), rgba(251,247,238,.45))",
              borderColor: "rgba(176,122,22,.32)",
            }}
            data-testid="rules-card"
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '12px' }}>
              <div
                style={{
                  display: 'grid', placeItems: 'center', borderRadius: '10px',
                  width: 36, height: 36, background: "rgba(176,122,22,.18)", color: "#8a6018"
                }}
              >
                <WarningAmberIcon style={{ fontSize: 16 }} />
              </div>
              <div>
                <div className="eyebrow" style={{ color: "#8a6018" }}>Transfer Rules</div>
                <div className="font-display" style={{ fontSize: '20px', marginTop: '2px', fontWeight: 500, color: 'var(--ink)' }}>The four canons</div>
              </div>
            </div>
            <ul style={{ margin: 0, padding: 0, listStyle: 'none', display: 'flex', flexDirection: 'column', gap: '10px', fontSize: '13px', color: "var(--ink-2)" }}>
              {[
                <React.Fragment key="1"><b>1 Project = 1 Canteen</b> mapping is strictly enforced.</React.Fragment>,
                "Coupons automatically deduct/preserve from the prior project balance.",
                "Each transfer log is immutable and archived for audit compliance.",
                "Reversal requires a counter-entry; nothing is mutated retroactively.",
              ].map((line, i) => (
                <li key={i} style={{ display: 'flex', alignItems: 'flex-start', gap: '8px' }}>
                  <span
                    style={{
                      marginTop: '8px', display: 'inline-block',
                      width: 4, height: 4, borderRadius: 4, background: "#8a6018", flexShrink: 0
                    }}
                  />
                  <span>{line}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>

      {/* Archive */}
      <div className="atelier" style={{ overflow: 'hidden' }} data-testid="archive">
        <div style={{ padding: '20px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', borderBottom: "1px solid var(--hairline)" }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div
              style={{
                display: 'grid', placeItems: 'center', borderRadius: '10px',
                width: 36, height: 36, background: "var(--emerald-soft)", color: "var(--emerald)"
              }}
            >
              <HistoryIcon style={{ fontSize: 16 }} />
            </div>
            <div>
              <div className="eyebrow">Project Relocation Archives</div>
              <div className="font-display" style={{ fontSize: '20px', marginTop: '2px', fontWeight: 500, color: 'var(--ink)' }}>
                Every move, signed and shelved
              </div>
            </div>
          </div>
          <span className="chip">
            <SecurityIcon style={{ fontSize: 12 }} />
            Immutable
          </span>
        </div>

        {loading ? (
          <div style={{ padding: '40px 0', textAlign: 'center' }}>
            <CircularProgress size={24} style={{ color: "var(--ink)", marginBottom: 12 }} />
            <p style={{ fontSize: 13, color: 'var(--ink-muted)' }}>Fetching transfer archives...</p>
          </div>
        ) : history.length === 0 ? (
          <div style={{ padding: '40px 0', textAlign: 'center', color: 'var(--ink-muted)', fontSize: 13 }}>
            <p>No employee transfers logged for your project.</p>
          </div>
        ) : (
          <table className="atelier-table">
            <thead>
              <tr>
                <th style={{ textAlign: 'left', padding: '12px 16px' }}>Log</th>
                <th style={{ textAlign: 'left', padding: '12px 16px' }}>Employee</th>
                <th style={{ textAlign: 'left', padding: '12px 16px' }}>Name</th>
                <th style={{ textAlign: 'left', padding: '12px 16px' }}>From</th>
                <th style={{ padding: '12px 16px' }}></th>
                <th style={{ textAlign: 'left', padding: '12px 16px' }}>To</th>
                <th style={{ textAlign: 'left', padding: '12px 16px' }}>Coupons</th>
                <th style={{ textAlign: 'left', padding: '12px 16px' }}>Initiated by</th>
                <th style={{ textAlign: 'left', padding: '12px 16px' }}>Date &amp; Time</th>
              </tr>
            </thead>
            <tbody>
              {history.map((t) => (
                <tr key={t.id} data-testid={`log-${t.id}`}>
                  <td style={{ padding: '16px' }}>
                    <span className="font-display" style={{ color: "var(--brass)", fontSize: 14, fontStyle: 'italic' }}>№</span>
                    <span className="font-mono-tab" style={{ marginLeft: '6px' }}>{String(t.id).padStart(4, "0")}</span>
                  </td>
                  <td className="font-mono-tab" style={{ padding: '16px' }}>{t.employee_id}</td>
                  <td style={{ padding: '16px' }}>
                    <span style={{ fontSize: '14px', fontWeight: 500 }}>{t.employee_name}</span>
                  </td>
                  <td style={{ padding: '16px' }}>
                    <span
                      style={{
                        padding: '4px 10px',
                        borderRadius: '9999px',
                        fontSize: '11px',
                        background: "var(--rust-soft)",
                        color: "var(--rust)",
                        border: "1px solid rgba(214,51,39,.25)",
                        letterSpacing: "0.02em",
                      }}
                    >
                      {t.from_project}
                    </span>
                  </td>
                  <td style={{ width: 24, padding: "16px 4px" }}>
                    <ArrowForwardIcon style={{ fontSize: 14, color: "var(--brass)" }} />
                  </td>
                  <td style={{ padding: '16px' }}>
                    <span
                      style={{
                        padding: '4px 10px',
                        borderRadius: '9999px',
                        fontSize: '11px',
                        background: "var(--emerald-soft)",
                        color: "var(--emerald)",
                        border: "1px solid rgba(30,77,214,.25)",
                        letterSpacing: "0.02em",
                      }}
                    >
                      {t.to_project}
                    </span>
                  </td>
                  <td style={{ padding: '16px' }}>
                    <span className="chip" style={{ padding: "4px 10px", fontSize: 12, background: 'var(--sky-soft, #e0f2fe)', color: 'var(--sky, #0284c7)', border: '1px solid rgba(2,132,199,.2)' }}>
                      {t.coupons_transferred} coupons
                    </span>
                  </td>
                  <td style={{ fontSize: '13px', color: "var(--ink-2)", padding: '16px' }}>{t.admin_name}</td>
                  <td className="font-mono-tab" style={{ fontSize: '12px', color: "var(--ink-muted)", padding: '16px' }}>
                    {new Date(t.transferred_at).toLocaleString()}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </>
  );
}
