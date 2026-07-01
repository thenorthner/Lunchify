import React, { useState, useEffect } from "react";
import api from "../services/api";
import PageHeader from "./PageHeader";
import PersonIcon from '@mui/icons-material/Person';
import BusinessIcon from '@mui/icons-material/Business';
import PhoneIcon from '@mui/icons-material/Phone';
import LockIcon from '@mui/icons-material/Lock';
import StorefrontIcon from '@mui/icons-material/Storefront';
import SecurityIcon from '@mui/icons-material/Security';
import InfoOutlinedIcon from '@mui/icons-material/InfoOutlined';
import SearchIcon from '@mui/icons-material/Search';
import BadgeIcon from '@mui/icons-material/Badge';
import VpnKeyIcon from '@mui/icons-material/VpnKey';
import SaveOutlinedIcon from '@mui/icons-material/SaveOutlined';
import PersonOffIcon from '@mui/icons-material/PersonOff';
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';
import "./MenuManager.css";
import "./AdminAccountsPanel.css";
import "../styles/Tabs.css";

const Field = ({ icon: Icon, label, required, children, hint, style }) => (
  <div style={{ marginBottom: "16px", ...style }}>
    <label style={{ display: "flex", alignItems: "center", gap: "8px", marginBottom: "8px" }}>
      <Icon style={{ fontSize: 13, color: "var(--ink-muted)" }} />
      <span className="eyebrow">
        {label}
        {required && <span style={{ color: "var(--spark)", marginLeft: 4 }}>*</span>}
      </span>
    </label>
    {children}
    {hint && <div style={{ fontSize: "11px", marginTop: "6px", color: "var(--ink-faint)" }}>{hint}</div>}
  </div>
);

export default function AdminAccountsPanel() {
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

  // --- Employee Deactivation State ---
  const [deactSearchId, setDeactSearchId] = useState("");
  const [deactEmployee, setDeactEmployee] = useState(null);
  const [deactLoading, setDeactLoading] = useState(false);
  const [deactToggling, setDeactToggling] = useState(false);
  const [deactMessage, setDeactMessage] = useState(null);

  // Fetch projects list
  const fetchProjects = async () => {
    setLoading(true);
    try {
      const res = await api.get("/transfer/projects-canteens");
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

  const handleSearchOrCheck = async (e) => {
    if (e) e.preventDefault();
    if (!employeeId.trim()) return;
    try {
      const cleanId = employeeId.trim().toUpperCase();
      const res = await api.get(`/auth/admin-check-id/${cleanId}`);
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
    if (e) e.preventDefault();
    
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

      const res = await api.post("/auth/upsert-user", payload);
      
      if (res.data.success) {
        setMessage({ type: "success", text: res.data.message });
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

  const handleDeactSearch = async () => {
    if (!deactSearchId.trim()) return;
    setDeactLoading(true);
    setDeactMessage(null);
    setDeactEmployee(null);
    try {
      const cleanId = deactSearchId.trim().toUpperCase();
      const res = await api.get(`/auth/admin-check-id/${cleanId}`);
      if (res.data) {
        setDeactEmployee(res.data.data || res.data);
      }
    } catch (err) {
      if (err.response?.status === 400 && err.response?.data?.data) {
        setDeactEmployee(err.response.data.data);
      } else {
        setDeactMessage({ type: "error", text: err.response?.data?.message || "Error finding employee" });
      }
    } finally {
      setDeactLoading(false);
    }
  };

  const handleToggleDeact = async () => {
    if (!deactEmployee) return;
    setDeactToggling(true);
    setDeactMessage(null);
    try {
      const res = await api.patch(`/auth/toggle-active/${deactEmployee.employee_id}`);
      setDeactMessage({ type: "success", text: res.data.message || "Status updated successfully" });
      setDeactEmployee({ ...deactEmployee, is_active: res.data.is_active !== undefined ? res.data.is_active : !deactEmployee.is_active });
    } catch (err) {
      setDeactMessage({ type: "error", text: err.response?.data?.message || "Failed to update status" });
    } finally {
      setDeactToggling(false);
    }
  };

  return (
    <div style={{ paddingBottom: "40px" }} className="fade-in">
      <PageHeader
        eyebrow="Chapter X · Identity"
        title="Admin Accounts,"
        italicTail="role management"
        description="Add new employees or elevate existing users to admin roles (Canteen Admin, HR, IT, or Scanner)."
      />

      <div style={{ display: "flex", flexDirection: "column", gap: "24px", marginTop: "24px", alignItems: "stretch" }}>
        {/* PROVISIONING FORM */}
        <div className="atelier brass-corner" style={{ width: "100%", padding: "28px" }}>
          <div style={{ display: "flex", alignItems: "flex-start", gap: "16px", marginBottom: "24px" }}>
            <div
              style={{
                display: "grid",
                placeItems: "center",
                borderRadius: "12px",
                flexShrink: 0,
                width: "48px",
                height: "48px",
                background: "linear-gradient(140deg, #54bdf5, #1e4dd6)",
                color: "#fff",
                boxShadow: "0 10px 24px -12px rgba(30,77,214,.5)",
              }}
            >
              <VpnKeyIcon style={{ fontSize: 20 }} />
            </div>
            <div>
              <div className="eyebrow" style={{ color: "var(--brass)", marginBottom: "4px" }}>Provisioning</div>
              <h3 className="font-display" style={{ fontSize: 26, fontWeight: 500, letterSpacing: "-0.02em", margin: 0 }}>
                Compose an account
              </h3>
              <p style={{ fontSize: "13px", marginTop: "4px", color: "var(--ink-muted)", margin: "4px 0 0 0", lineHeight: 1.5 }}>
                Verify the employee, set role &amp; canteen, and apply permissions in one stroke.
              </p>
            </div>
          </div>

          {message && (
            <div style={{
              padding: "16px",
              borderRadius: "8px",
              marginBottom: "24px",
              fontSize: "13px",
              backgroundColor: message.type === "success" ? "var(--emerald-soft)" : message.type === "info" ? "#f0f9ff" : "var(--rust-soft)",
              color: message.type === "success" ? "var(--emerald)" : message.type === "info" ? "#0369a1" : "var(--rust)",
              border: `1px solid ${message.type === "success" ? "rgba(30,77,214,0.25)" : message.type === "info" ? "#bae6fd" : "rgba(214,51,39,0.3)"}`
            }}>
              {message.text}
            </div>
          )}

          <div style={{ display: "grid", gridTemplateColumns: "repeat(5, 1fr)", gap: "20px" }}>
            <Field icon={BadgeIcon} label="Employee ID" required>
              <div style={{ display: "flex", gap: "8px" }}>
                <input
                  className="input-atelier font-mono-tab"
                  style={{ flex: 1, minWidth: 0 }}
                  placeholder="e.g. EMP001"
                  value={employeeId}
                  onChange={(e) => setEmployeeId(e.target.value)}
                />
                <button
                  type="button"
                  onClick={handleSearchOrCheck}
                  className="btn-ink"
                  style={{ padding: "8px 16px", fontSize: "12px", whiteSpace: "nowrap", width: "auto", flexShrink: 0 }}
                >
                  Verify
                </button>
              </div>
            </Field>

            {role !== 'employee' && (
              <Field icon={SecurityIcon} label="Admin User ID">
                <input
                  className="input-atelier"
                  placeholder="e.g. admin123 (Optional)"
                  value={adminUserId}
                  onChange={(e) => setAdminUserId(e.target.value)}
                />
              </Field>
            )}

            <Field icon={PersonIcon} label="Full Name" required>
              <input
                className="input-atelier"
                placeholder="e.g. John Doe"
                value={name}
                onChange={(e) => setName(e.target.value)}
              />
            </Field>

            <Field icon={BusinessIcon} label="Department" required>
              <input
                className="input-atelier"
                placeholder="e.g. IT, HR, Finance"
                value={department}
                onChange={(e) => setDepartment(e.target.value)}
              />
            </Field>

            <Field icon={PhoneIcon} label="Phone Number" required>
              <input
                className="input-atelier font-mono-tab"
                placeholder="e.g. 9876543210"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
              />
            </Field>

            <Field
              icon={LockIcon}
              label="Password (optional for existing)"
              hint="Mandatory for new accounts. Leave blank on existing users to keep the old passphrase."
            >
              <input
                type="password"
                className="input-atelier"
                placeholder="Enter password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
            </Field>

            <Field icon={StorefrontIcon} label="Assigned Project & Canteen" style={{ gridColumn: "span 2" }}>
              <div style={{ position: "relative" }}>
                <select
                  className="input-atelier"
                  style={{ paddingRight: "40px", appearance: "none", width: "100%" }}
                  value={selectedProject}
                  onChange={(e) => setSelectedProject(e.target.value)}
                >
                  {projects.map((proj) => (
                    <option key={proj.project_id} value={proj.project_id}>
                      {proj.project_name} ({proj.canteen_name})
                    </option>
                  ))}
                  {projects.length === 0 && <option value="">Loading...</option>}
                </select>
                <ExpandMoreIcon style={{ position: "absolute", right: "12px", top: "50%", transform: "translateY(-50%)", fontSize: 18, color: "var(--ink-muted)", pointerEvents: "none" }} />
              </div>
            </Field>

            <Field icon={SecurityIcon} label="System Role" required style={{ gridColumn: "span 3" }}>
              <div style={{ position: "relative" }}>
                <select
                  className="input-atelier"
                  style={{ paddingRight: "40px", appearance: "none", width: "100%" }}
                  value={role}
                  onChange={(e) => setRole(e.target.value)}
                >
                  <option value="employee">Employee (View-Only / Order Access)</option>
                  <option value="canteen_admin">Canteen Admin (Generate Bill & View Rating)</option>
                  <option value="hr_admin">HR Admin (Billing & Transfers)</option>
                  <option value="it_admin">IT Admin (Central Settings & Account Upsert)</option>
                  <option value="scanner">Canteen Scanner (Scan Coupons & Verify)</option>
                </select>
                <ExpandMoreIcon style={{ position: "absolute", right: "12px", top: "50%", transform: "translateY(-50%)", fontSize: 18, color: "var(--ink-muted)", pointerEvents: "none" }} />
              </div>
            </Field>
          </div>

          <button 
            type="button" 
            onClick={handleUpsert} 
            disabled={submitting}
            className="btn-brass" 
            style={{ width: "100%", marginTop: "28px", display: "flex", alignItems: "center", justifyContent: "center", gap: "8px" }}
          >
            <SaveOutlinedIcon style={{ fontSize: 18 }} />
            {submitting ? "Saving..." : "Save Account & Apply Permissions"}
          </button>

          {/* Info banner */}
          <div
            style={{
              marginTop: "20px",
              padding: "16px",
              borderRadius: "10px",
              display: "flex",
              alignItems: "flex-start",
              gap: "12px",
              background: "var(--emerald-soft)",
              border: "1px solid rgba(30,77,214,.22)",
            }}
          >
            <InfoOutlinedIcon style={{ fontSize: 18, marginTop: "2px", color: "var(--emerald)" }} />
            <div style={{ fontSize: "12.5px", color: "var(--ink)", lineHeight: 1.5 }}>
              Ensure the details are correct before saving. Roles &amp; permissions can be updated any time from this very form.
            </div>
          </div>
        </div>

        {/* DEACTIVATION + LIST */}
        <div style={{ display: "flex", flexDirection: "column", gap: "20px", width: "100%" }}>
          {/* Dark deactivation panel */}
          <div className="atelier-dark" style={{ padding: "24px" }}>
            <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
              <div
                style={{
                  display: "grid",
                  placeItems: "center",
                  borderRadius: "12px",
                  width: "40px",
                  height: "40px",
                  background: "rgba(226,58,48,.15)",
                  color: "var(--spark)",
                  border: "1px solid rgba(226,58,48,.3)"
                }}
              >
                <PersonOffIcon style={{ fontSize: 20 }} />
              </div>
              <div>
                <div className="eyebrow" style={{ color: "var(--on-dark-accent)", marginBottom: "2px" }}>Sentinel</div>
                <h3 className="font-display" style={{ fontSize: 22, fontWeight: 500, margin: 0 }}>Employee Deactivation</h3>
              </div>
            </div>
            <p style={{ fontSize: "12.5px", marginTop: "12px", color: "var(--on-dark-muted)", lineHeight: 1.5, marginBottom: "20px" }}>
              Search any employee to suspend or reinstate their account. The action is reversible and audit-logged.
            </p>
            <div style={{ display: "flex", gap: "8px" }}>
              <div style={{ position: "relative", flex: 1 }}>
                <SearchIcon style={{ position: "absolute", left: "12px", top: "50%", transform: "translateY(-50%)", fontSize: 16, color: "var(--on-dark-muted)" }} />
                <input
                  className="font-mono-tab"
                  placeholder="Enter Employee ID…"
                  value={deactSearchId}
                  onChange={(e) => setDeactSearchId(e.target.value)}
                  style={{
                    width: "100%",
                    padding: "10px 16px 10px 36px",
                    borderRadius: "10px",
                    outline: "none",
                    fontSize: "14px",
                    background: "rgba(84,189,245,.06)",
                    border: "1px solid rgba(84,189,245,.22)",
                    color: "var(--on-dark)",
                  }}
                />
              </div>
              <button onClick={handleDeactSearch} disabled={deactLoading} className="btn-spark" style={{ fontSize: "12.5px", padding: "8px 16px" }}>
                {deactLoading ? "Searching..." : "Search"}
              </button>
            </div>

            {deactMessage && (
              <div style={{
                marginTop: "16px",
                padding: "12px",
                borderRadius: "8px",
                fontSize: "12.5px",
                backgroundColor: deactMessage.type === "success" ? "rgba(34, 197, 94, 0.1)" : "rgba(226, 58, 48, 0.1)",
                color: deactMessage.type === "success" ? "#4ADE80" : "var(--spark)",
                border: `1px solid ${deactMessage.type === "success" ? "rgba(34, 197, 94, 0.25)" : "rgba(226, 58, 48, 0.25)"}`
              }}>
                {deactMessage.text}
              </div>
            )}

            {deactEmployee && (
              <div className="lift" style={{ marginTop: "16px", background: "rgba(0,0,0,0.2)", padding: "16px", borderRadius: "10px", border: "1px solid rgba(84,189,245,.15)" }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", flexWrap: "wrap", gap: "12px" }}>
                  <div>
                    <h4 style={{ color: "var(--on-dark)", margin: "0 0 4px 0", fontSize: "15px", fontWeight: 500 }}>{deactEmployee.name}</h4>
                    <div style={{ display: "flex", flexWrap: "wrap", gap: "12px", color: "var(--on-dark-muted)", fontSize: "12px", fontFamily: "var(--font-mono-tab)", alignItems: "center" }}>
                      <span>ID: {deactEmployee.employee_id}</span>
                      <span style={{ width: "4px", height: "4px", borderRadius: "50%", background: "var(--on-dark-muted)" }}></span>
                      <span>Dept: {deactEmployee.department}</span>
                      <span style={{ width: "4px", height: "4px", borderRadius: "50%", background: "var(--on-dark-muted)" }}></span>
                      <span style={{ textTransform: "capitalize" }}>Role: {deactEmployee.role}</span>
                    </div>
                  </div>
                </div>
                <div style={{ display: "flex", alignItems: "center", gap: "12px", marginTop: "16px" }}>
                  <span style={{
                    padding: "4px 10px",
                    borderRadius: "999px",
                    fontSize: "11px",
                    fontWeight: "600",
                    fontFamily: "var(--font-mono-tab)",
                    backgroundColor: (deactEmployee.is_active === 1 || deactEmployee.is_active === true || deactEmployee.is_active === "1") ? "rgba(34, 197, 94, 0.15)" : "rgba(226, 58, 48, 0.15)",
                    color: (deactEmployee.is_active === 1 || deactEmployee.is_active === true || deactEmployee.is_active === "1") ? "#4ADE80" : "var(--spark)",
                    border: `1px solid ${(deactEmployee.is_active === 1 || deactEmployee.is_active === true || deactEmployee.is_active === "1") ? "rgba(34, 197, 94, 0.3)" : "rgba(226, 58, 48, 0.3)"}`
                  }}>
                    {(deactEmployee.is_active === 1 || deactEmployee.is_active === true || deactEmployee.is_active === "1") ? "ACTIVE" : "INACTIVE"}
                  </span>
                  <button
                    onClick={handleToggleDeact}
                    disabled={deactToggling}
                    style={{
                      background: (deactEmployee.is_active === 1 || deactEmployee.is_active === true || deactEmployee.is_active === "1") ? "var(--spark)" : "#10B981",
                      color: "#fff",
                      border: "none",
                      padding: "6px 16px",
                      fontSize: "12px",
                      borderRadius: "6px",
                      cursor: "pointer",
                      fontWeight: 500,
                      transition: "all 0.2s"
                    }}
                  >
                    {deactToggling ? "Wait..." : ((deactEmployee.is_active === 1 || deactEmployee.is_active === true || deactEmployee.is_active === "1") ? "Deactivate" : "Reactivate")}
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

