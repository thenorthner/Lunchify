import React, { useState } from "react";
import api from "../services/api";
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
import OrdersManager from "../components/OrdersManager";
import ScanHistoryPanel from "../components/ScanHistoryPanel";
import Brand from "../components/Brand";
import PersonIcon from '@mui/icons-material/Person';
import LogoutIcon from '@mui/icons-material/Logout';
import ExploreIcon from '@mui/icons-material/Explore';
import SecurityIcon from '@mui/icons-material/Security';
import ReceiptIcon from '@mui/icons-material/Receipt';
import "./Dashboard.css";

export default function Dashboard({ user = {} }) {
  const role = user.role || "canteen_admin";

  const getInitialTab = (userRole) => {
    if (userRole === "canteen_admin") return "reports";
    if (userRole === "hr_admin") return "billing";
    if (userRole === "it_admin") return "canteen_projects";
    return "reports";
  };

  const [activeTab, setActiveTab] = useState(() => getInitialTab(role));

  const handleLogout = async () => {
    try {
      await api.post("/auth/logout");
    } catch(e) {}
    localStorage.removeItem("adminToken");
    localStorage.removeItem("adminLoggedIn");
    localStorage.removeItem("adminRole");
    localStorage.removeItem("adminCanteenId");
    window.location.href = "/";
  };

  return (
    <>
      <div className="dashboard-container" style={{ padding: 0 }}>
        <header className="dashboard-banner">
          <Brand size="md" on="light" />

          {/* Core Module Selector (Pills) */}
          <div className="module-selector-pills">
            <button className={`module-pill ${role === 'canteen_admin' ? 'active' : 'disabled'}`}>
              <ExploreIcon style={{ fontSize: 16 }} />
              <span>Operations</span>
            </button>
            <button className={`module-pill ${role === 'it_admin' ? 'active' : 'disabled'}`}>
              <SecurityIcon style={{ fontSize: 16 }} />
              <span>Governance</span>
            </button>
            <button className={`module-pill ${role === 'hr_admin' ? 'active' : 'disabled'}`}>
              <ReceiptIcon style={{ fontSize: 16 }} />
              <span>HR Review</span>
            </button>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div style={{
              display: 'flex', alignItems: 'center', gap: '10px',
              padding: '6px 20px 6px 6px',
              background: '#fff',
              border: '1px solid #cbd5e1',
              borderRadius: '9999px',
            }}>
              <div style={{
                width: '32px', height: '32px',
                borderRadius: '50%',
                background: '#2563eb',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                color: '#fff'
              }}>
                <PersonIcon style={{ fontSize: 18 }} />
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', lineHeight: 1.2 }}>
                <span style={{ fontSize: '14px', fontWeight: 600, color: '#1e293b' }}>{user.name || "Demo Canteen Admin"}</span>
                <span style={{ fontSize: '10px', fontWeight: 600, letterSpacing: '0.1em', color: '#64748b', textTransform: 'uppercase' }}>{role.replace("_", " ")}</span>
              </div>
            </div>
            <button 
              onClick={handleLogout} 
              style={{
                display: 'flex', alignItems: 'center', gap: '8px',
                padding: '10px 20px',
                background: '#fff',
                border: '1px solid #cbd5e1',
                borderRadius: '9999px',
                color: '#0f172a',
                fontSize: '14px',
                fontWeight: 500,
                cursor: 'pointer',
                transition: 'all 0.2s ease'
              }}
              onMouseOver={(e) => e.currentTarget.style.background = '#f8fafc'}
              onFocus={(e) => e.currentTarget.style.background = '#f8fafc'}
              onMouseOut={(e) => e.currentTarget.style.background = '#fff'}
              onBlur={(e) => e.currentTarget.style.background = '#fff'}
            >
              <LogoutIcon style={{ fontSize: 18, color: '#475569' }} /> Sign out
            </button>
          </div>
        </header>

        <DashboardTabs
          activeTab={activeTab}
          setActiveTab={setActiveTab}
          allowedTabs={user.allowedTabs || []}
        />

        {/* CONTENT AREA */}
        <main className="dashboard-content-area">
          {activeTab === "menu" && <MenuManager user={user} />}
          {activeTab === "reports" && <ReportsPanel user={user} />}
          {activeTab === "canteen_billing" && <CanteenBillingPanel user={user} />}
          {activeTab === "billing" && <BillingPanel user={user} />}
          {activeTab === "transfers" && <TransferPanel user={user} />}
          {activeTab === "canteen_projects" && <CanteenProjectsPanel user={user} />}
          {activeTab === "feedbacks" && <FeedbackViewer user={user} />}
          {activeTab === "item_feedbacks" && <ItemFeedbackViewer user={user} />}
          {activeTab === "admin_accounts" && <AdminAccountsPanel user={user} />}
          {activeTab === "orders" && <OrdersManager user={user} />}
          {activeTab === "scan_history" && <ScanHistoryPanel user={user} />}
        </main>
      </div>
    </>
  );
}
