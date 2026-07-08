import React, { useEffect, useState, useMemo } from "react";
import api from "../services/api";
import PageHeader from "./PageHeader";
import { CircularProgress } from "@mui/material";
import SearchIcon from '@mui/icons-material/Search';
import RefreshIcon from '@mui/icons-material/Refresh';
import SyncIcon from '@mui/icons-material/Sync';
import ChatBubbleOutlineIcon from '@mui/icons-material/ChatBubbleOutline';
import BoltIcon from '@mui/icons-material/Bolt';
import ReportProblemIcon from '@mui/icons-material/ReportProblem';
import InfoOutlinedIcon from '@mui/icons-material/InfoOutlined';
import DeleteOutlineIcon from '@mui/icons-material/DeleteOutline';
import "../styles/FeedbackViewer.css";

const PRIORITY = {
  HIGH:   { cls: "chip-spark",   icon: BoltIcon,           dot: "var(--spark)" },
  MEDIUM: { cls: "chip-amber",   icon: ReportProblemIcon,  dot: "#b07a16" },
  LOW:    { cls: "chip-sky",     icon: InfoOutlinedIcon,   dot: "#2da4e8" },
};

const Initials = (name) => {
  if (!name) return "U";
  return name.substring(0, 2).toUpperCase();
};

const TicketCard = ({ t, onDelete }) => {
  const p = PRIORITY[t.priority?.toUpperCase()] || PRIORITY.LOW;
  const Icon = p.icon;

  const handleRespond = async () => {
    const response = window.prompt(`Respond to ${t.employee_name}'s ticket:\nSubject: ${t.subject}`);
    if (!response) return;

    try {
      const res = await api.post(`/feedbacks/${t.id}/respond`, { message: response });
      if (res.data?.success) {
        alert(`Response sent! A push notification has been sent to ${t.employee_name}'s mobile device.`);
      } else {
        alert("Failed to send response.");
      }
    } catch (err) {
      console.error("Error sending response:", err);
      alert("Error sending response. Make sure the backend supports this.");
    }
  };
  
  const handleDelete = async () => {
    if (window.confirm("Are you sure you want to delete this ticket?")) {
      try {
        const res = await api.delete(`/feedbacks/${t.id}`);
        if (res.data?.success) {
          onDelete(t.id);
        } else {
          alert("Failed to delete ticket.");
        }
      } catch (err) {
        console.error("Error deleting ticket:", err);
        alert("Error deleting ticket.");
      }
    }
  };

  return (
    <div className="atelier lift" style={{ padding: '24px', marginBottom: '16px' }}>
      {/* Top row */}
      <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: '16px', flexWrap: 'wrap', marginBottom: '16px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <span
            style={{
              padding: '4px 12px',
              borderRadius: '9999px',
              fontSize: '10px',
              background: 'var(--emerald-soft)',
              color: 'var(--emerald)',
              border: '1px solid rgba(30,77,214,.22)',
              letterSpacing: '0.18em',
              fontWeight: 600,
              textTransform: 'uppercase',
            }}
          >
            {t.canteen_name} {t.project_name ? `(${t.project_name})` : ''}
          </span>

        </div>
        <div className="font-mono-tab" style={{ fontSize: '11.5px', color: 'var(--ink-muted)' }}>
          {new Date(t.created_at).toLocaleString()}
        </div>
      </div>

      <h3 className="font-display" style={{ fontSize: 24, fontWeight: 500, letterSpacing: '-0.02em', margin: 0 }}>
        {t.subject}
      </h3>
      <p style={{ fontSize: '14px', marginTop: '8px', lineHeight: 1.6, color: 'var(--ink-2)', marginBottom: 0 }}>
        {t.message}
      </p>

      <div className="hairline" style={{ margin: '20px 0' }} />

      {/* Submitter */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <div
            className="font-display"
            style={{
              display: 'grid',
              placeItems: 'center',
              borderRadius: '50%',
              fontSize: '13px',
              width: 36, height: 36,
              background: 'linear-gradient(140deg, #54bdf5, #1e4dd6)',
              color: '#fff',
              fontWeight: 500,
            }}
          >
            {Initials(t.employee_name)}
          </div>
          <div>
            <div style={{ fontSize: '14px', fontWeight: 500 }}>{t.employee_name || 'Unknown User'}</div>
            <div style={{ fontSize: '11px', color: 'var(--ink-muted)', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <span className="font-mono-tab">ID · {t.employee_id}</span>
              <span style={{ width: 12, height: 1, background: 'var(--hairline-strong)' }} />
              <span className="eyebrow" style={{ fontSize: 9.5 }}>{t.employee_department || "General"}</span>
            </div>
          </div>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <button
            className="btn-ghost"
            style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '12px' }}
            onClick={handleRespond}
          >
            <ChatBubbleOutlineIcon style={{ fontSize: 14 }} />
            Respond
          </button>
          <button
            className="btn-ghost"
            style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '12px', color: '#ef4444' }}
            onClick={handleDelete}
            title="Delete Ticket"
          >
            <DeleteOutlineIcon style={{ fontSize: 16 }} />
          </button>
        </div>
      </div>
    </div>
  );
};

export default function FeedbackViewer({ user = {} }) {
  const [feedbacks, setFeedbacks] = useState([]);
  const [loading, setLoading] = useState(false);
  const [searchTerm, setSearchTerm] = useState("");

  const fetchFeedbacks = async () => {
    setLoading(true);
    try {
      const res = await api.get("/feedbacks");
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

  const filteredFeedbacks = useMemo(() => {
    return feedbacks.filter((f) => {
      const text = `${f.subject || ''} ${f.message || ''} ${f.employee_name || ''} ${f.employee_id || ''} ${f.canteen_name || ''}`.toLowerCase();
      return !searchTerm || text.includes(searchTerm.toLowerCase());
    });
  }, [feedbacks, searchTerm]);

  const counts = {
    high: feedbacks.filter((t) => (t.priority || "").toUpperCase() === "HIGH").length,
    medium: feedbacks.filter((t) => (t.priority || "").toUpperCase() === "MEDIUM").length,
    low: feedbacks.filter((t) => !(t.priority || "").toUpperCase().match(/^(HIGH|MEDIUM)$/)).length,
  };

  return (
    <div style={{ paddingBottom: '40px' }} className="fade-in">
      <PageHeader
        eyebrow="Chapter VII · Voices"
        title="System problems,"
        italicTail="attended to"
        description="A centralised portal where IT Admin audits system tickets and employee reports — each voice heard, every issue traced."
        right={
          <button 
            onClick={fetchFeedbacks} 
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



      {/* Search */}
      <div className="atelier-dark" style={{ padding: '16px', marginBottom: '24px', display: 'flex', alignItems: 'center', gap: '12px' }}>
        <div style={{ position: 'relative', flex: 1, display: 'flex', alignItems: 'center' }}>
          <SearchIcon style={{ position: 'absolute', left: '16px', color: 'var(--on-dark-muted)', fontSize: 18 }} />
          <input
            placeholder="Search tickets by Employee ID, Name, Subject or Message…"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            style={{
              width: '100%',
              padding: '12px 16px 12px 44px',
              borderRadius: '10px',
              outline: 'none',
              fontSize: '14px',
              background: 'rgba(84,189,245,.06)',
              border: '1px solid rgba(84,189,245,.22)',
              color: 'var(--on-dark)',
              boxSizing: 'border-box'
            }}
          />
        </div>
        <span className="eyebrow" style={{ color: 'var(--on-dark-accent)' }}>
          {filteredFeedbacks.length} ticket{filteredFeedbacks.length === 1 ? "" : "s"}
        </span>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
        {loading ? (
          <div style={{ padding: '48px', textAlign: 'center', background: 'var(--paper)', borderRadius: '8px', border: '1px solid var(--hairline)' }}>
            <CircularProgress size={24} style={{ color: "var(--ink)", marginBottom: 12 }} />
            <div style={{ color: 'var(--ink-2)' }}>Downloading support logs...</div>
          </div>
        ) : filteredFeedbacks.length === 0 ? (
          <div className="atelier" style={{ padding: '48px', textAlign: 'center' }}>
            <div className="eyebrow" style={{ marginBottom: '8px' }}>All quiet</div>
            <div className="font-display" style={{ fontSize: '22px', fontWeight: 500 }}>No tickets match those filters.</div>
          </div>
        ) : (
          filteredFeedbacks.map((ticket, index) => (
            <TicketCard 
              key={ticket.id || index} 
              t={ticket} 
              onDelete={(id) => setFeedbacks(prev => prev.filter(f => f.id !== id))}
            />
          ))
        )}
      </div>
    </div>
  );
}
