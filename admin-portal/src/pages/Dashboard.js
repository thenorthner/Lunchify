import React, { useState } from "react";
import DashboardTabs from "../components/DashboardTabs";
import MenuManager from "../components/MenuManager";
import ReportsPanel from "../components/ReportsPanel";
import BillingPanel from "../components/BillingPanel";
import CanteenBillingPanel from "../components/CanteenBillingPanel";
import TransferPanel from "../components/TransferPanel";
import CanteenProjectsPanel from "../components/CanteenProjectsPanel";
import FeedbackViewer from "../components/FeedbackViewer";
import ItemFeedbackViewer from "../components/ItemFeedbackViewer";
import AdminAccountsPanel from "../components/AdminAccountsPanel";
import "./Dashboard.css";

export default function Dashboard() {
  const user = JSON.parse(localStorage.getItem("adminUser") || "{}");
  const role = user.role || "canteen_admin";

  const getInitialTab = (userRole) => {
    if (userRole === "canteen_admin") return "reports";
    if (userRole === "hr_admin") return "billing";
    if (userRole === "it_admin") return "canteen_projects";
    return "reports";
  };

  const [activeTab, setActiveTab] = useState(() => getInitialTab(role));

  const handleLogout = () => {
    localStorage.removeItem("adminToken");
    localStorage.removeItem("adminUser");
    window.location.href = "/";
  };

  return (
    <>
      <div className="dashboard-container" style={{ paddingTop: '20px' }}>
        <div className="dashboard-banner">
          <h1>🏢 SJVN Lunchify Admin Panel</h1>
          <div style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
            <div className="admin-profile-badge">
              <span className="profile-icon">👤</span>
              <div className="profile-text">
                <strong>{user.name || "Administrator"}</strong>
                <span className="role-subtext">{role.replace("_", " ").toUpperCase()}</span>
              </div>
            </div>
            <button 
              onClick={handleLogout} 
              style={{
                background: 'rgba(255, 255, 255, 0.2)',
                border: 'none',
                color: '#ffffff',
                padding: '8px 16px',
                borderRadius: '8px',
                fontWeight: '600',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                gap: '6px'
              }}
              onMouseOver={(e) => e.currentTarget.style.background = 'rgba(255, 255, 255, 0.3)'}
              onMouseOut={(e) => e.currentTarget.style.background = 'rgba(255, 255, 255, 0.2)'}
            >
              🚪 Logout
            </button>
          </div>
        </div>

        <DashboardTabs
          activeTab={activeTab}
          setActiveTab={setActiveTab}
          role={role}
        />

        {/* CONTENT AREA */}
        <div className="dashboard-content-area">
          {activeTab === "menu" && <MenuManager />}
          {activeTab === "reports" && <ReportsPanel />}
          {activeTab === "canteen_billing" && <CanteenBillingPanel />}
          {activeTab === "billing" && <BillingPanel />}
          {activeTab === "transfers" && <TransferPanel />}
          {activeTab === "canteen_projects" && <CanteenProjectsPanel />}
          {activeTab === "feedbacks" && <FeedbackViewer />}
          {activeTab === "item_feedbacks" && <ItemFeedbackViewer />}
          {activeTab === "admin_accounts" && <AdminAccountsPanel />}
        </div>
      </div>
    </>
  );
}
