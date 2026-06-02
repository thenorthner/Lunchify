import React, { useState, useEffect } from "react";
import axios from "axios";
import "./MenuManager.css"; // Reuse card and form classes for consistency, with custom overrides
import "../styles/Tabs.css";

export default function AdminAccountsPanel() {
  const token = localStorage.getItem("adminToken");
  
  const [employeeId, setEmployeeId] = useState("");
  const [adminUserId, setAdminUserId] = useState("");
  const [name, setName] = useState("");
  const [department, setDepartment] = useState("");
  const [phone, setPhone] = useState("");
  const [password, setPassword] = useState("");
  const [role, setRole] = useState("employee");
  const [selectedProject, setSelectedProject] = useState("");
  
  const [projects, setProjects] = useState([]);
  const [loading, setLoading] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [message, setMessage] = useState(null);
  
  const axiosConfig = {
    headers: { Authorization: `Bearer ${token}` }
  };

  // Fetch projects list
  const fetchProjects = async () => {
    setLoading(true);
    try {
      const res = await axios.get("http://localhost:3001/api/transfer/projects-canteens", axiosConfig);
      setProjects(res.data);
      if (res.data.length > 0) {
        setSelectedProject(res.data[0].project_id.toString());
      }
    } catch (err) {
      console.error("Error fetching projects:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchProjects();
  }, []);

  const handleSearchOrCheck = async () => {
    if (!employeeId.trim()) return;
    try {
      const cleanId = employeeId.trim().toUpperCase();
      const res = await axios.get(`http://localhost:3001/api/auth/check-id/${cleanId}`);
      if (res.data) {
        const dataObj = res.data.data || res.data;
        setName(dataObj.name || "");
        setDepartment(dataObj.department || "");
        setPhone(dataObj.phone || "");
        setMessage({ type: "info", text: "Found employee details. Fill remaining details to register." });
      }
    } catch (err) {
      if (err.response?.status === 400 && err.response?.data?.data) {
        const dataObj = err.response.data.data;
        setName(dataObj.name || "");
        setDepartment(dataObj.department || "");
        setPhone(dataObj.phone || "");
        setMessage({ type: "info", text: "Found existing employee details." });
      } else {
        console.log("Check ID note:", err.response?.data?.message || err.message);
        setMessage({ type: "error", text: err.response?.data?.message || "Error checking ID" });
      }
    }
  };

  const handleUpsert = async (e) => {
    e.preventDefault();
    
    if (!employeeId.trim() || !name.trim() || !department.trim() || !phone.trim() || !role) {
      setMessage({ type: "error", text: "Please fill all mandatory fields (Employee ID, Name, Department, Phone, Role)" });
      return;
    }

    const matchedProject = projects.find(p => p.project_id.toString() === selectedProject);
    const projectId = matchedProject ? matchedProject.project_id : 1;
    const canteenId = matchedProject ? matchedProject.canteen_id : 1;

    setSubmitting(true);
    setMessage(null);

    try {
      const payload = {
        employeeId: employeeId.trim().toUpperCase(),
        admin_id: adminUserId.trim() || null,
        name: name.trim(),
        department: department.trim(),
        phone: phone.trim(),
        password: password, // Send raw, backend handles hashing
        role: role,
        project_id: projectId,
        canteen_id: canteenId
      };

      const res = await axios.post("http://localhost:3001/api/auth/upsert-user", payload, axiosConfig);
      
      if (res.data.success) {
        setMessage({ type: "success", text: res.data.message });
        // Clear fields on success except if it's an update, let's just clear password
        setPassword("");
      } else {
        setMessage({ type: "error", text: res.data.message || "Failed to update user account." });
      }
    } catch (err) {
      console.error("Upsert user error:", err);
      setMessage({ type: "error", text: err.response?.data?.message || "Server error while saving account." });
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="menu-card fade-in" style={{ maxWidth: "600px", margin: "0 auto" }}>
      <div className="menu-header">
        <h2>🔑 Administrative Accounts & Role elevation</h2>
        <p style={{ fontSize: "14px", color: "#666", marginTop: "4px" }}>
          IT Admin tool to register new users or elevate existing users to Canteen Admin, HR Admin, or IT Admin roles.
        </p>
      </div>

      <form className="menu-form" onSubmit={handleUpsert} style={{ marginTop: "20px" }}>
        
        {message && (
          <div style={{
            padding: "12px",
            borderRadius: "8px",
            marginBottom: "16px",
            fontSize: "14px",
            fontWeight: "500",
            backgroundColor: message.type === "success" ? "#d1e7dd" : message.type === "info" ? "#cff4fc" : "#f8d7da",
            color: message.type === "success" ? "#0f5132" : message.type === "info" ? "#055160" : "#842029",
            border: `1px solid ${message.type === "success" ? "#badbcc" : message.type === "info" ? "#b6effb" : "#f5c2c7"}`
          }}>
            {message.text}
          </div>
        )}

        <label style={{ fontWeight: "bold" }}>
          Employee ID *
          <div style={{ display: "flex", gap: "8px", width: "100%" }}>
            <input
              type="text"
              value={employeeId}
              onChange={(e) => setEmployeeId(e.target.value)}
              placeholder="e.g. EMP001"
              required
              style={{ flex: 1, margin: "8px 0" }}
            />
            <button 
              type="button" 
              onClick={handleSearchOrCheck}
              style={{
                margin: "8px 0",
                padding: "0 16px",
                background: "#6c757d",
                fontSize: "14px"
              }}
            >
              Verify
            </button>
          </div>
        </label>

        <label style={{ fontWeight: "bold" }}>
          Admin User ID (For Portal Login)
          <input
            type="text"
            value={adminUserId}
            onChange={(e) => setAdminUserId(e.target.value)}
            placeholder="e.g. admin123 (Optional)"
            style={{ width: "100%", boxSizing: "border-box", margin: "8px 0" }}
          />
        </label>

        <label style={{ fontWeight: "bold" }}>
          Full Name *
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="e.g. John Doe"
            required
            style={{ width: "100%", boxSizing: "border-box", margin: "8px 0" }}
          />
        </label>

        <label style={{ fontWeight: "bold" }}>
          Department *
          <input
            type="text"
            value={department}
            onChange={(e) => setDepartment(e.target.value)}
            placeholder="e.g. IT, HR, Finance"
            required
            style={{ width: "100%", boxSizing: "border-box", margin: "8px 0" }}
          />
        </label>

        <label style={{ fontWeight: "bold" }}>
          Phone Number *
          <input
            type="text"
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            placeholder="e.g. 9876543210"
            required
            style={{ width: "100%", boxSizing: "border-box", margin: "8px 0" }}
          />
        </label>

        <label style={{ fontWeight: "bold" }}>
          Password {password ? "" : "(Optional for existing users)"}
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="Enter password"
            style={{ width: "100%", boxSizing: "border-box", margin: "8px 0" }}
          />
          <small style={{ color: "#666", fontSize: "11px", display: "block", marginTop: "-4px", marginBottom: "8px" }}>
            Mandatory for new accounts. Leave blank for existing accounts to keep the old password.
          </small>
        </label>

        <label style={{ fontWeight: "bold" }}>
          Assigned Project & Canteen
          {loading ? (
            <span style={{ fontSize: "12px", color: "#888", marginLeft: "10px" }}>Loading locations...</span>
          ) : (
            <select
              value={selectedProject}
              onChange={(e) => setSelectedProject(e.target.value)}
              style={{ width: "100%", margin: "8px 0" }}
            >
              {projects.map((proj) => (
                <option key={proj.project_id} value={proj.project_id}>
                  {proj.project_name} ({proj.canteen_name})
                </option>
              ))}
            </select>
          )}
        </label>

        <label style={{ fontWeight: "bold" }}>
          System Role *
          <select
            value={role}
            onChange={(e) => setRole(e.target.value)}
            style={{ width: "100%", margin: "8px 0" }}
          >
            <option value="employee">Employee (View-Only / Order Access)</option>
            <option value="canteen_admin">Canteen Admin (Menu & Order Acceptance)</option>
            <option value="hr_admin">HR Admin (Billing & Transfers)</option>
            <option value="it_admin">IT Admin (Central Settings & Account Upsert)</option>
          </select>
        </label>

        <button
          type="submit"
          disabled={submitting}
          className="save-btn"
          style={{ width: "100%", marginTop: "16px", padding: "12px" }}
        >
          {submitting ? "Saving user details..." : "Save Account & Apply Permissions"}
        </button>
      </form>
    </div>
  );
}
