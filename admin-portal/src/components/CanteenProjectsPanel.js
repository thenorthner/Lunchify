import React, { useEffect, useState } from "react";
import axios from "axios";
import "../styles/CanteenProjectsPanel.css";

export default function CanteenProjectsPanel() {
  const token = localStorage.getItem("adminToken");
  const user = JSON.parse(localStorage.getItem("adminUser") || "{}");

  const [mappings, setMappings] = useState([]);
  const [loading, setLoading] = useState(false);
  const [creating, setCreating] = useState(false);
  const [showModal, setShowModal] = useState(false);
  const [formData, setFormData] = useState({ project_name: "", state: "", canteen_name: "", location: "", open_time: "07:00:00", close_time: "22:00:00" });

  const axiosConfig = {
    headers: { Authorization: `Bearer ${token}` }
  };

  const fetchMappings = async () => {
    setLoading(true);
    try {
      const res = await axios.get("http://localhost:3001/api/transfer/projects-canteens", axiosConfig);
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
      await axios.post("http://localhost:3001/api/transfer/create-module", formData, axiosConfig);
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
      const res = await axios.delete(`http://localhost:3001/api/transfer/projects/${projectId}`, axiosConfig);
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

  return (
    <div className="canteen-projects-container fade-in">
      <div className="cp-header">
        <div>
          <h2>🏢 Project & Canteen Management</h2>
          <p className="cp-subheader">IT Admin view of isolated projects and associated food modules.</p>
        </div>
        <div style={{ display: 'flex', gap: '10px' }}>
          <button className="cp-refresh-btn" onClick={() => setShowModal(true)} style={{ background: '#28a745' }}>➕ New Project & Canteen</button>
          <button className="cp-refresh-btn" onClick={fetchMappings}>🔄 Sync Mappings</button>
        </div>
      </div>

      {showModal && (
        <div className="modal-overlay" style={{ position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 1000 }}>
          <div className="modal-content" style={{ background: 'white', padding: '20px', borderRadius: '8px', width: '400px' }}>
            <h3>Create New Module</h3>
            <form onSubmit={handleCreateModule}>
              <label style={{ display: 'block', margin: '10px 0' }}>
                Project Name *:
                <input type="text" required value={formData.project_name} onChange={e => setFormData({...formData, project_name: e.target.value})} style={{ width: '100%' }} placeholder="e.g. Bikaner Project" />
              </label>
              <label style={{ display: 'block', margin: '10px 0' }}>
                Canteen Name *:
                <input type="text" required value={formData.canteen_name} onChange={e => setFormData({...formData, canteen_name: e.target.value})} style={{ width: '100%' }} placeholder="e.g. Bikaner Executive Canteen" />
              </label>
              <label style={{ display: 'block', margin: '10px 0' }}>
                Location (City/Area) *:
                <input type="text" required value={formData.location} onChange={e => setFormData({...formData, location: e.target.value})} style={{ width: '100%' }} placeholder="e.g. Bikaner" />
              </label>
              <label style={{ display: 'block', margin: '10px 0' }}>
                State *:
                <input type="text" required value={formData.state} onChange={e => setFormData({...formData, state: e.target.value})} style={{ width: '100%' }} placeholder="e.g. Rajasthan" />
              </label>
              <div style={{ display: 'flex', gap: '10px', marginTop: '20px' }}>
                <button type="submit" disabled={creating} className="save-btn" style={{ flex: 1, padding: '10px', background: '#007bff', color: 'white', border: 'none', borderRadius: '4px' }}>{creating ? 'Saving...' : 'Create'}</button>
                <button type="button" onClick={() => setShowModal(false)} style={{ flex: 1, padding: '10px', background: '#dc3545', color: 'white', border: 'none', borderRadius: '4px' }}>Cancel</button>
              </div>
            </form>
          </div>
        </div>
      )}

      <div className="rule-info-box">
        💡 <strong>System Architecture Rule:</strong> "1 Project = 1 Canteen". Each project location is strictly mapped to one food module canteen. Employees are isolated to their own project's menu and orders.
      </div>

      {loading ? (
        <div className="cp-loading">
          <div className="spinner"></div>
          <p>Synchronizing project schemas...</p>
        </div>
      ) : (
        <div className="projects-grid">
          {mappings.map((item) => (
            <div className="project-node-card" key={item.project_id}>
              {/* Card Header with gradient */}
              <div className="card-top-gradient">
                <h3>{item.project_name}</h3>
                <span className="location-pin">📍 {item.project_location}, {item.project_state}</span>
              </div>

              {/* Card Body */}
              <div className="card-body-details">
                <div className="detail-row">
                  <span className="detail-label">Project Database ID</span>
                  <span className="detail-val font-code">#{item.project_id}</span>
                </div>
                
                {item.project_id !== 5 && (
                  <div style={{ marginTop: '10px', textAlign: 'right' }}>
                    <button 
                      onClick={() => handleDeleteProject(item.project_id, item.project_name)}
                      style={{
                        background: '#dc3545',
                        color: 'white',
                        border: 'none',
                        padding: '6px 12px',
                        borderRadius: '4px',
                        cursor: 'pointer',
                        fontSize: '0.85rem'
                      }}
                    >
                      🗑️ Delete Entire Project
                    </button>
                  </div>
                )}

                <hr className="divider" />

                {item.canteen_id ? (
                  <div className="associated-canteen-info">
                    <div className="canteen-title-row">
                      <span className="canteen-tag">ASSOCIATED CANTEEN</span>
                      <h4>{item.canteen_name}</h4>
                    </div>

                    <div className="canteen-meta-details">
                      <div className="detail-row">
                        <span className="detail-label">Canteen Module ID</span>
                        <span className="detail-val font-code">#{item.canteen_id}</span>
                      </div>
                      <div className="detail-row">
                        <span className="detail-label">Physical Location</span>
                        <span className="detail-val">{item.canteen_location}</span>
                      </div>
                      <div className="detail-row">
                        <span className="detail-label">Operating Hours</span>
                        <span className="detail-val hours-tag">🕒 {item.open_time?.substring(0, 5)} - {item.close_time?.substring(0, 5)}</span>
                      </div>
                      <div className="detail-row">
                        <span className="detail-label">Operational Status</span>
                        <span className="detail-val status-active">🟢 Active & Running</span>
                      </div>
                    </div>
                  </div>
                ) : (
                  <div className="no-canteen-warning">
                    ⚠️ No associated canteen found for this project! Please verify configuration.
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
