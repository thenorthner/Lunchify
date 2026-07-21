import React, { useEffect, useState } from "react";
import api from "../services/api";
import PageHeader from "./PageHeader";
import { CircularProgress } from "@mui/material";

// Icon imports
import LocationOnIcon from '@mui/icons-material/LocationOn';
import RefreshIcon from '@mui/icons-material/Refresh';
import SyncIcon from '@mui/icons-material/Sync';
import AddIcon from '@mui/icons-material/Add';
import DeleteIcon from '@mui/icons-material/Delete';
import BusinessIcon from '@mui/icons-material/Business';
import AccessTimeIcon from '@mui/icons-material/AccessTime';
import ShowChartIcon from '@mui/icons-material/ShowChart';
import ChevronRightIcon from '@mui/icons-material/ChevronRight';
import QrCodeScannerIcon from '@mui/icons-material/QrCodeScanner';

import CanteenInspector from "./CanteenInspector";
import "../styles/CanteenProjectsPanel.css";

const Row = ({ icon: Icon, label, value, mono, status }) => (
  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '10px' }}>
    <span style={{ display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--ink-muted)' }}>
      <Icon style={{ fontSize: 13 }} />
      <span className="eyebrow" style={{ fontSize: '9.5px', letterSpacing: '0.2em' }}>{label}</span>
    </span>
    <span
      className={mono ? "font-mono-tab" : ""}
      style={{
        color: status ? "var(--emerald)" : "var(--ink)",
        fontWeight: status ? 600 : 500,
        fontSize: '12.5px',
        display: 'flex',
        alignItems: 'center'
      }}
    >
      {status && (
        <span
          style={{ display: 'inline-block', height: '6px', width: '6px', borderRadius: '50%', background: 'var(--emerald)', marginRight: '6px' }}
        />
      )}
      {value}
    </span>
  </div>
);

const ProjectCard = ({ p, index, onDelete, onInspect }) => (
  <div className="atelier" style={{ display: 'flex', flexDirection: 'column', overflow: 'hidden', padding: 0, borderRadius: '12px' }}>
    {/* Navy header */}
    <div
      style={{
        padding: '24px 24px 20px 24px',
        position: 'relative',
        overflow: 'hidden',
        background: 'linear-gradient(140deg, var(--navy) 0%, var(--navy-2) 70%, var(--navy-3) 100%)',
        color: 'var(--on-dark)',
      }}
    >
      <div
        style={{
          position: 'absolute',
          right: '-48px',
          top: '-48px',
          opacity: 0.3,
          width: 180, 
          height: 180, 
          borderRadius: "50%",
          background: "radial-gradient(circle, rgba(84,189,245,.45), transparent 60%)",
        }}
      />
      <div style={{ position: 'relative' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '12px' }}>
          <span
            style={{
              padding: '2px 8px',
              borderRadius: '99px',
              fontSize: '9.5px',
              background: 'rgba(84,189,245,.18)',
              color: 'var(--on-dark-accent)',
              border: '1px solid rgba(84,189,245,.32)',
              letterSpacing: '0.22em',
              fontWeight: 600,
              textTransform: 'uppercase',
            }}
          >
            Project · {(index + 1 < 10 ? '0' : '') + (index + 1)}
          </span>
          {p.project_state && (
            <span className="font-mono-tab" style={{ fontSize: '10px', color: 'var(--on-dark-muted)' }}>
              {p.project_state}
            </span>
          )}
        </div>
        <h3 className="font-display" style={{ fontSize: '22px', fontWeight: 500, lineHeight: 1.12, margin: '0 0 8px 0', color: 'inherit' }}>
          {p.project_name}
        </h3>
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '12px', color: 'var(--on-dark-muted)' }}>
          <LocationOnIcon style={{ fontSize: 13 }} />
          <span>{p.project_location}</span>
        </div>
      </div>
    </div>

    {/* Body */}
    <div style={{ padding: '24px', display: 'flex', flexDirection: 'column', flex: 1, background: '#ffffff' }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div>
          <div className="eyebrow">Project DB ID</div>
          <div className="font-display tnum" style={{ fontSize: '22px', fontWeight: 500, marginTop: '4px' }}>#{p.project_id}</div>
        </div>
        {p.project_id !== 5 && (
          <button
            onClick={() => onDelete(p.project_id, p.project_name)}
            style={{
              display: 'flex', alignItems: 'center', gap: '6px', padding: '6px 12px', borderRadius: '99px', fontSize: '11.5px',
              background: 'var(--spark-soft)',
              color: 'var(--spark)',
              border: '1px solid rgba(226,58,48,.3)',
              cursor: 'pointer',
              fontWeight: 500,
              fontFamily: 'inherit'
            }}
          >
            <DeleteIcon style={{ fontSize: 13 }} />
            Delete
          </button>
        )}
      </div>

      <div className="hairline" style={{ margin: '20px 0' }} />

      {/* Associated canteen */}
      {p.canteen_id ? (
        <div style={{ borderRadius: '12px', padding: '16px', background: 'var(--paper-2)', border: '1px solid var(--hairline)' }}>
          <div className="eyebrow" style={{ color: 'var(--brass)', marginBottom: '8px' }}>Associated Canteen</div>
          <div className="font-display" style={{ fontSize: '15px', lineHeight: 1.375, fontWeight: 500, color: 'var(--ink)' }}>
            {p.canteen_name}
          </div>
          <div style={{ marginTop: '16px' }}>
            <Row icon={QrCodeScannerIcon} label="Module ID" value={`#${p.canteen_id}`} mono />
            <Row icon={LocationOnIcon} label="Location" value={p.canteen_location} />
            <Row icon={AccessTimeIcon} label="Hours" value={`${p.open_time?.substring(0, 5)} - ${p.close_time?.substring(0, 5)}`} mono />
            <Row icon={ShowChartIcon} label="Status" value="ACTIVE" status />
          </div>
        </div>
      ) : (
        <div style={{ background: '#fffbeb', color: '#b45309', padding: '16px', borderRadius: '12px', fontSize: '13px', border: '1px solid #fef3c7' }}>
          No associated canteen found. Please verify configuration.
        </div>
      )}

      <button
        onClick={() => onInspect && onInspect(p)}
        style={{
          marginTop: '20px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', 
          padding: '10px 16px', borderRadius: '10px', fontSize: '13px', 
          color: 'var(--ink)', border: '1px solid var(--hairline)', background: 'transparent',
          cursor: 'pointer', fontWeight: 500, transition: 'all 0.2s', fontFamily: 'inherit',
          width: '100%'
        }}
        onMouseOver={(e) => e.currentTarget.style.background = 'var(--paper-2)'}
        onFocus={(e) => e.currentTarget.style.background = 'var(--paper-2)'}
        onMouseOut={(e) => e.currentTarget.style.background = 'transparent'}
        onBlur={(e) => e.currentTarget.style.background = 'transparent'}
      >
        <span>Inspect module</span>
        <ChevronRightIcon style={{ fontSize: 16 }} />
      </button>
    </div>
  </div>
);

export default function CanteenProjectsPanel({ user = {} }) {
  const [mappings, setMappings] = useState([]);
  const [loading, setLoading] = useState(false);
  const [creating, setCreating] = useState(false);
  const [showModal, setShowModal] = useState(false);
  const [formData, setFormData] = useState({ project_name: "", state: "", canteen_name: "", location: "", open_time: "07:00:00", close_time: "22:00:00" });
  const [q, setQ] = useState("");
  const [inspecting, setInspecting] = useState(null); // holds the project object being inspected

  const fetchMappings = async () => {
    setLoading(true);
    try {
      const res = await api.get("/transfer/projects-canteens");
      setMappings(res.data);
    } catch (err) {
      console.error("Error fetching project-canteen mappings:", err);
    } finally {
      setLoading(false);
    }
  };

  const handleCreateModule = async (e) => {
    e.preventDefault();
    setCreating(true);
    try {
      await api.post("/transfer/create-module", formData);
      alert("Project and Canteen Module created successfully!");
      setShowModal(false);
      setFormData({ project_name: "", state: "", canteen_name: "", location: "", open_time: "07:00:00", close_time: "22:00:00" });
      fetchMappings();
    } catch (err) {
      console.error(err);
      alert(err.response?.data?.error || "Error creating module");
    } finally {
      setCreating(false);
    }
  };

  const handleDeleteProject = async (projectId, projectName) => {
    if (projectId === 5) {
      alert("Cannot delete the default Corporate Headquarters (CHQ) Canteen.");
      return;
    }
    
    const userInput = window.prompt(
      `SECURITY CHECK:\nTo prevent accidental deletion, please type the exact project name to confirm.\n\nProject Name: "${projectName}"\n\nAll associated employees will be mapped to CHQ (Corporate Headquarters) by default.`
    );
    
    if (userInput !== projectName) {
      if (userInput !== null) {
        alert("Project name did not match. Deletion cancelled.");
      }
      return;
    }

    try {
      const res = await api.delete(`/transfer/projects/${projectId}`);
      alert(res.data.message || "Project and Canteen deleted successfully. Users moved to CHQ.");
      fetchMappings();
    } catch (err) {
      console.error(err);
      alert(err.response?.data?.message || err.response?.data?.error || "Error deleting project");
    }
  };

  useEffect(() => {
    fetchMappings();
  }, []);

  const list = mappings.filter((p) =>
    !q || p.project_name.toLowerCase().includes(q.toLowerCase()) || (p.project_location || "").toLowerCase().includes(q.toLowerCase())
  );

  if (inspecting) {
    return (
      <CanteenInspector
        canteenId={inspecting.canteen_id}
        canteenName={inspecting.canteen_name}
        projectName={inspecting.project_name}
        projectLocation={inspecting.project_location || inspecting.canteen_location}
        openTime={inspecting.open_time}
        closeTime={inspecting.close_time}
        onBack={() => setInspecting(null)}
      />
    );
  }

  return (
    <div className="projects-manager-container fade-in" style={{ fontFamily: '"Geist", "Inter", "Lexend", -apple-system, system-ui, sans-serif' }}>
      <PageHeader
        eyebrow="Chapter VI · Estate"
        title="Projects across"
        italicTail="the network"
        description="IT Admin's view of isolated projects and their associated food modules. The architecture rule is firm: one project, one canteen."
        right={
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <button 
              onClick={fetchMappings} 
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
              {loading ? <CircularProgress size={16} style={{ color: 'inherit' }} /> : <SyncIcon style={{ fontSize: 16, color: '#475569' }} />}
              Sync Mappings
            </button>
            <button className="btn-ink" onClick={() => setShowModal(true)} style={{ fontSize: '13px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <AddIcon style={{ fontSize: 14 }} />
              New Project & Canteen
            </button>
          </div>
        }
      />

      {/* Architecture rule */}
      <div
        className="atelier"
        style={{
          padding: '20px',
          marginBottom: '32px',
          display: 'flex',
          alignItems: 'flex-start',
          gap: '16px',
          background: "linear-gradient(180deg, rgba(224,236,253,.85), rgba(241,246,252,.6))",
          borderColor: 'rgba(30,77,214,.22)',
          borderWidth: '1px',
          borderStyle: 'solid',
        }}
      >
        <div
          style={{
            display: 'grid',
            placeItems: 'center',
            borderRadius: '50%',
            flexShrink: 0,
            width: 36, 
            height: 36,
            background: "var(--emerald)",
            color: "#fff",
          }}
        >
          <BusinessIcon style={{ fontSize: 16 }} />
        </div>
        <div style={{ flex: 1 }}>
          <div className="eyebrow" style={{ color: "var(--emerald)", marginBottom: '4px' }}>System Architecture Rule</div>
          <div className="font-display" style={{ fontSize: '18px', fontWeight: 500, letterSpacing: "-0.015em", color: 'var(--ink)' }}>
            <span style={{ fontStyle: "italic", color: "var(--emerald)" }}>One project</span> · one canteen · isolated menus & orders.
          </div>
          <p style={{ fontSize: '12.5px', marginTop: '4px', color: "var(--ink-muted)", marginBottom: 0 }}>
            Each project location is strictly mapped to a single food module. Employees only see their own project's menu and ordering surface.
          </p>
        </div>
      </div>

      {/* Search */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '24px' }}>
        <input
          className="input-atelier"
          placeholder="Search project or location..."
          value={q}
          onChange={(e) => setQ(e.target.value)}
          style={{ maxWidth: '400px', width: '100%' }}
        />
        <span className="eyebrow">{list.length} project{list.length === 1 ? "" : "s"}</span>
      </div>

      {loading && mappings.length === 0 ? (
        <div className="loading-box">
          <CircularProgress size={24} style={{ color: "var(--ink)", marginBottom: 12 }} />
          <div>Synchronizing project schemas...</div>
        </div>
      ) : (
        <div className="projects-grid">
          {list.map((p, index) => <ProjectCard key={p.project_id} p={p} index={index} onDelete={handleDeleteProject} onInspect={(proj) => setInspecting(proj)} />)}
        </div>
      )}

      {showModal && (
        <div className="atelier-modal-overlay">
          <div className="atelier-modal">
            <h3 className="font-display" style={{ fontSize: 20, marginBottom: "24px" }}>Create New Module</h3>
            <form onSubmit={handleCreateModule}>
              <div className="form-group">
                <label className="eyebrow" htmlFor="projectName">Project Name *</label>
                <input id="projectName" type="text" required value={formData.project_name} onChange={e => setFormData({...formData, project_name: e.target.value})} className="input-atelier" placeholder="e.g. Bikaner Project" />
              </div>
              <div className="form-group">
                <label className="eyebrow" htmlFor="canteenName">Canteen Name *</label>
                <input id="canteenName" type="text" required value={formData.canteen_name} onChange={e => setFormData({...formData, canteen_name: e.target.value})} className="input-atelier" placeholder="e.g. Bikaner Executive Canteen" />
              </div>
              <div className="form-group">
                <label className="eyebrow" htmlFor="location">Location (City/Area) *</label>
                <input id="location" type="text" required value={formData.location} onChange={e => setFormData({...formData, location: e.target.value})} className="input-atelier" placeholder="e.g. Bikaner" />
              </div>
              <div className="form-group">
                <label className="eyebrow" htmlFor="state">State *</label>
                <input id="state" type="text" required value={formData.state} onChange={e => setFormData({...formData, state: e.target.value})} className="input-atelier" placeholder="e.g. Rajasthan" />
              </div>
              <div style={{ display: 'flex', gap: '12px', marginTop: '24px' }}>
                <button type="submit" disabled={creating} className="btn-ink" style={{ flex: 1 }}>{creating ? 'Saving...' : 'Create'}</button>
                <button type="button" onClick={() => setShowModal(false)} className="btn-ghost" style={{ flex: 1 }}>Cancel</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
