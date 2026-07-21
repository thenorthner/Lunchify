import React, { useEffect, useState } from "react";
import api from "../services/api";
import { CircularProgress } from "@mui/material";

// Icons
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import PeopleIcon from '@mui/icons-material/People';
import RestaurantMenuIcon from '@mui/icons-material/RestaurantMenu';
import SearchIcon from '@mui/icons-material/Search';
import LocationOnIcon from '@mui/icons-material/LocationOn';
import AccessTimeIcon from '@mui/icons-material/AccessTime';
import BusinessIcon from '@mui/icons-material/Business';

import "../styles/CanteenInspector.css";

/* ── role badge helper ── */
const roleMeta = {
  it_admin:       { label: "IT ADMIN",       bg: "#ede9fe", color: "#7c3aed", border: "#ddd6fe" },
  hr_admin:       { label: "HR ADMIN",       bg: "#fef3c7", color: "#b45309", border: "#fde68a" },
  canteen_admin:  { label: "CANTEEN ADMIN",  bg: "#dbeafe", color: "#2563eb", border: "#bfdbfe" },
  scanner:        { label: "SCANNER",        bg: "#d1fae5", color: "#059669", border: "#a7f3d0" },
  employee:       { label: "EMPLOYEE",       bg: "#f1f5f9", color: "#64748b", border: "#e2e8f0" },
};

const RoleBadge = ({ role }) => {
  const m = roleMeta[role] || roleMeta.employee;
  return (
    <span
      className="ci-role-badge"
      style={{ background: m.bg, color: m.color, border: `1px solid ${m.border}` }}
    >
      {m.label}
    </span>
  );
};

/* ── initials avatar ── */
const Avatar = ({ name }) => {
  const initials = (name || "??")
    .split(" ")
    .map((w) => w[0])
    .slice(0, 2)
    .join("")
    .toUpperCase();
  const hue = [...(name || "")].reduce((a, c) => a + c.charCodeAt(0), 0) % 360;
  return (
    <div
      className="ci-avatar"
      style={{ background: `hsl(${hue}, 55%, 92%)`, color: `hsl(${hue}, 55%, 38%)` }}
    >
      {initials}
    </div>
  );
};

export default function CanteenInspector({ canteenId, canteenName, projectName, projectLocation, openTime, closeTime, onBack }) {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [tab, setTab] = useState("personnel"); // "personnel" | "menu"
  const [search, setSearch] = useState("");

  useEffect(() => {
    const fetchDetails = async () => {
      setLoading(true);
      try {
        const res = await api.get(`/canteens/${canteenId}/details`);
        setData(res.data);
      } catch (err) {
        console.error("Error fetching canteen details:", err);
      } finally {
        setLoading(false);
      }
    };
    if (canteenId) fetchDetails();
  }, [canteenId]);

  if (loading) {
    return (
      <div className="ci-loading">
        <CircularProgress size={28} style={{ color: "var(--ink)" }} />
        <span>Loading canteen details…</span>
      </div>
    );
  }

  if (!data) {
    return (
      <div className="ci-loading">
        <span>Could not load canteen details.</span>
        <button className="btn-ghost" onClick={onBack}>← Go back</button>
      </div>
    );
  }

  const { users = [], menu = {}, canteen = {} } = data;

  /* ── filter users ── */
  const q = search.toLowerCase();
  const filtered = users.filter((u) =>
    !q ||
    (u.name || "").toLowerCase().includes(q) ||
    (u.id || "").toLowerCase().includes(q) ||
    (u.role || "").toLowerCase().includes(q) ||
    (u.department || "").toLowerCase().includes(q) ||
    (u.designation || "").toLowerCase().includes(q)
  );

  const adminCount = users.filter((u) => u.role !== "employee").length;
  const employeeCount = users.filter((u) => u.role === "employee").length;

  /* ── parse menu items ── */
  let foodItems = [];
  try {
    if (menu.food) {
      const parsed = typeof menu.food === "string" ? JSON.parse(menu.food) : menu.food;
      foodItems = Array.isArray(parsed) ? parsed : [];
    }
  } catch { foodItems = []; }

  let fruitItems = [];
  try {
    if (menu.fruit) {
      const parsed = typeof menu.fruit === "string" ? JSON.parse(menu.fruit) : menu.fruit;
      fruitItems = Array.isArray(parsed) ? parsed : [];
    }
  } catch { fruitItems = []; }

  return (
    <div className="ci-container fade-in">
      {/* ── HEADER ── */}
      <div className="ci-header">
        <div className="ci-header-glow" />
        <div className="ci-header-content">
          <button className="ci-back-btn" onClick={onBack}>
            <ArrowBackIcon style={{ fontSize: 18 }} />
            <span>Back to Projects</span>
          </button>

          <div className="ci-header-icon">
            <BusinessIcon style={{ fontSize: 28, color: "#fff" }} />
          </div>

          <h1 className="ci-title font-display">
            {canteenName || canteen.name} <em>details</em>
          </h1>
          <p className="ci-subtitle">
            Associated with {projectName} located in {projectLocation || canteen.location}.
            <br />
            Active from {(openTime || canteen.open_time || "07:00").substring(0, 5)} to {(closeTime || canteen.close_time || "22:00").substring(0, 5)}.
          </p>
        </div>
      </div>

      {/* ── TABS ── */}
      <div className="ci-tabs">
        <button
          className={`ci-tab ${tab === "personnel" ? "active" : ""}`}
          onClick={() => setTab("personnel")}
        >
          <PeopleIcon style={{ fontSize: 16 }} />
          <span>Personnel & Directory</span>
        </button>
        <button
          className={`ci-tab ${tab === "menu" ? "active" : ""}`}
          onClick={() => setTab("menu")}
        >
          <RestaurantMenuIcon style={{ fontSize: 16 }} />
          <span>Active Menus</span>
        </button>
      </div>

      {/* ── PERSONNEL TAB ── */}
      {tab === "personnel" && (
        <div className="ci-panel fade-in">
          {/* Search + count */}
          <div className="ci-search-row">
            <div className="ci-search-box">
              <SearchIcon style={{ fontSize: 18, color: "#94a3b8" }} />
              <input
                type="text"
                placeholder="Search by name, ID, role or department..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="ci-search-input"
              />
            </div>
            <div className="ci-member-count">
              <PeopleIcon style={{ fontSize: 18, color: "#64748b" }} />
              <span className="ci-count-number">{filtered.length}</span>
              <span className="ci-count-label">Members Found</span>
            </div>
          </div>

          {/* Stats pills */}
          <div className="ci-stats-row">
            <div className="ci-stat-pill">
              <span className="ci-stat-value">{users.length}</span>
              <span className="ci-stat-label">Total</span>
            </div>
            <div className="ci-stat-pill">
              <span className="ci-stat-value" style={{ color: "#2563eb" }}>{adminCount}</span>
              <span className="ci-stat-label">Admins</span>
            </div>
            <div className="ci-stat-pill">
              <span className="ci-stat-value" style={{ color: "#059669" }}>{employeeCount}</span>
              <span className="ci-stat-label">Employees</span>
            </div>
          </div>

          {/* Table header */}
          <div className="ci-table-header">
            <span className="ci-th ci-th-employee">Employee</span>
            <span className="ci-th ci-th-role">Role</span>
            <span className="ci-th ci-th-dept">Department</span>
            <span className="ci-th ci-th-location">Location</span>
          </div>

          {/* Table rows */}
          <div className="ci-table-body">
            {filtered.length === 0 ? (
              <div className="ci-empty">No members match your search.</div>
            ) : (
              filtered.map((u) => (
                <div key={u.id} className="ci-row">
                  <div className="ci-cell ci-cell-employee">
                    <Avatar name={u.name} />
                    <div>
                      <div className="ci-emp-name">{u.name || "—"}</div>
                      <div className="ci-emp-id">{u.id}</div>
                    </div>
                  </div>
                  <div className="ci-cell ci-cell-role">
                    <RoleBadge role={u.role} />
                  </div>
                  <div className="ci-cell ci-cell-dept">
                    <div className="ci-dept-name">{u.department || "—"}</div>
                    <div className="ci-dept-desig">{u.designation || ""}</div>
                  </div>
                  <div className="ci-cell ci-cell-location">
                    {u.location ? (
                      <>
                        <LocationOnIcon style={{ fontSize: 14, color: "#2563eb" }} />
                        <span>{u.location}</span>
                      </>
                    ) : (
                      <span style={{ color: "#94a3b8" }}>—</span>
                    )}
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      )}

      {/* ── MENU TAB ── */}
      {tab === "menu" && (
        <div className="ci-panel fade-in">
          <div className="ci-menu-section">
            <h3 className="ci-menu-heading">
              <RestaurantMenuIcon style={{ fontSize: 18 }} />
              Today's Lunch Menu
            </h3>
            {foodItems.length === 0 ? (
              <div className="ci-empty">No food menu set for today.</div>
            ) : (
              <div className="ci-menu-grid">
                {foodItems.map((item, i) => (
                  <div key={i} className="ci-menu-card">
                    <span className="ci-menu-index">{String(i + 1).padStart(2, "0")}</span>
                    <span className="ci-menu-item-name">{typeof item === "string" ? item : item.name || item.item || JSON.stringify(item)}</span>
                  </div>
                ))}
              </div>
            )}
          </div>

          <div className="ci-menu-section" style={{ marginTop: "24px" }}>
            <h3 className="ci-menu-heading">
              <span style={{ fontSize: 18 }}>🍎</span>
              Today's Fruit Menu
            </h3>
            {fruitItems.length === 0 ? (
              <div className="ci-empty">No fruit menu set for today.</div>
            ) : (
              <div className="ci-menu-grid">
                {fruitItems.map((item, i) => (
                  <div key={i} className="ci-menu-card ci-menu-card-fruit">
                    <span className="ci-menu-index">{String(i + 1).padStart(2, "0")}</span>
                    <span className="ci-menu-item-name">{typeof item === "string" ? item : item.name || item.item || JSON.stringify(item)}</span>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
