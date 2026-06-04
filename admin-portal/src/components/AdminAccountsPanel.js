import React, { useState, useEffect } from "react";
import axios from "axios";
import PersonIcon from '@mui/icons-material/Person';
import BusinessIcon from '@mui/icons-material/Business';
import PhoneIcon from '@mui/icons-material/Phone';
import LockIcon from '@mui/icons-material/Lock';
import StorefrontIcon from '@mui/icons-material/Storefront';
import SecurityIcon from '@mui/icons-material/Security';
import VpnKeyIcon from '@mui/icons-material/VpnKey';
import InfoIcon from '@mui/icons-material/Info';
import "./MenuManager.css";
import "./AdminAccountsPanel.css";
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
    <div className="admin-accounts-container fade-in">
      <div className="admin-accounts-header">
        <div className="header-icon-box"><VpnKeyIcon fontSize="large" /></div>
        <div className="header-text">
          <h2>Administrative Accounts & Role elevation</h2>
          <p>
            IT Admins tool to register new users or elevate existing users to Canteen Admin, HR Admin, or IT Admin roles.
          </p>
        </div>
      </div>

      <form onSubmit={handleUpsert}>
        {message && (
          <div style={{
            padding: "16px",
            borderRadius: "10px",
            marginBottom: "20px",
            fontSize: "14px",
            fontWeight: "500",
            backgroundColor: message.type === "success" ? "#dcfce7" : message.type === "info" ? "#e0f2fe" : "#fee2e2",
            color: message.type === "success" ? "#166534" : message.type === "info" ? "#075985" : "#991b1b",
            border: `1px solid ${message.type === "success" ? "#bbf7d0" : message.type === "info" ? "#bae6fd" : "#fecaca"}`
          }}>
            {message.text}
          </div>
        )}

        <div className="admin-form-grid">
          {/* Employee ID */}
          <div className="admin-form-group">
            <div className="field-icon"><PersonIcon /></div>
            <div className="field-content">
              <label>Employee ID <span className="required-asterisk">*</span></label>
              <div className="input-with-button">
                <input
                  type="text"
                  className="admin-input"
                  value={employeeId}
                  onChange={(e) => setEmployeeId(e.target.value)}
                  placeholder="e.g. EMP001"
                  required
                />
                <button 
                  type="button" 
                  className="admin-verify-btn"
                  onClick={handleSearchOrCheck}
                >
                  Verify
                </button>
              </div>
            </div>
          </div>

          {/* Admin User ID */}
          <div className="admin-form-group">
            <div className="field-icon"><PersonIcon /></div>
            <div className="field-content">
              <label>Admin User ID (For Portal Login)</label>
              <input
                type="text"
                className="admin-input"
                value={adminUserId}
                onChange={(e) => setAdminUserId(e.target.value)}
                placeholder="e.g. admin123 (Optional)"
              />
            </div>
          </div>

          {/* Full Name */}
          <div className="admin-form-group">
            <div className="field-icon"><PersonIcon /></div>
            <div className="field-content">
              <label>Full Name <span className="required-asterisk">*</span></label>
              <input
                type="text"
                className="admin-input"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="e.g. John Doe"
                required
              />
            </div>
          </div>

          {/* Department */}
          <div className="admin-form-group">
            <div className="field-icon"><BusinessIcon /></div>
            <div className="field-content">
              <label>Department <span className="required-asterisk">*</span></label>
              <input
                type="text"
                className="admin-input"
                value={department}
                onChange={(e) => setDepartment(e.target.value)}
                placeholder="e.g. IT, HR, Finance"
                required
              />
            </div>
          </div>

          {/* Phone Number */}
          <div className="admin-form-group">
            <div className="field-icon"><PhoneIcon /></div>
            <div className="field-content">
              <label>Phone Number <span className="required-asterisk">*</span></label>
              <input
                type="text"
                className="admin-input"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                placeholder="e.g. 9876543210"
                required
              />
            </div>
          </div>

          {/* Password */}
          <div className="admin-form-group">
            <div className="field-icon"><LockIcon /></div>
            <div className="field-content">
              <label>Password (Optional for existing users)</label>
              <input
                type="password"
                className="admin-input"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Enter password"
              />
              <span className="field-help-text">Mandatory for new accounts. Leave blank for existing accounts to keep the old password.</span>
            </div>
          </div>

          {/* Assigned Project & Canteen */}
          <div className="admin-form-group">
            <div className="field-icon"><StorefrontIcon /></div>
            <div className="field-content">
              <label>Assigned Project & Canteen</label>
              {loading ? (
                <span style={{ fontSize: "12px", color: "#888" }}>Loading locations...</span>
              ) : (
                <select
                  className="admin-select"
                  value={selectedProject}
                  onChange={(e) => setSelectedProject(e.target.value)}
                >
                  {projects.map((proj) => (
                    <option key={proj.project_id} value={proj.project_id}>
                      {proj.project_name} ({proj.canteen_name})
                    </option>
                  ))}
                </select>
              )}
            </div>
          </div>

          {/* System Role */}
          <div className="admin-form-group">
            <div className="field-icon"><SecurityIcon /></div>
            <div className="field-content">
              <label>System Role <span className="required-asterisk">*</span></label>
              <select
                className="admin-select"
                value={role}
                onChange={(e) => setRole(e.target.value)}
              >
                <option value="employee">Employee (View-Only / Order Access)</option>
                <option value="canteen_admin">Canteen Admin (Generate Bill & View Rating)</option>
                <option value="hr_admin">HR Admin (Billing & Transfers)</option>
                <option value="it_admin">IT Admin (Central Settings & Account Upsert)</option>
              </select>
            </div>
          </div>
        </div>

        <button
          type="submit"
          disabled={submitting}
          className="admin-save-btn"
        >
          💾 {submitting ? "Saving user details..." : "Save Account & Apply Permissions"}
        </button>
      </form>

      <div className="admin-info-box">
        <div className="info-icon"><InfoIcon /></div>
        <div className="info-content">
          <p>Ensure the details are correct before saving. You can update role and permissions anytime.</p>
        </div>
      </div>
    </div>
  );
}
