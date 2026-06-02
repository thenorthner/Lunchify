import React, { useState } from "react";
import Navbar from "../components/Navbar";
import DashboardTabs from "../components/DashboardTabs";
import MenuManager from "../components/MenuManager";
import OrdersManager from "../components/OrdersManager";
import ReportsPanel from "../components/ReportsPanel";
import BillingPanel from "../components/BillingPanel";
import CanteenBillingPanel from "../components/CanteenBillingPanel";
import TransferPanel from "../components/TransferPanel";
import CanteenProjectsPanel from "../components/CanteenProjectsPanel";
import FeedbackViewer from "../components/FeedbackViewer";
import AdminAccountsPanel from "../components/AdminAccountsPanel";
import "./Dashboard.css";

export default function Dashboard() {
  const user = JSON.parse(localStorage.getItem("adminUser") || "{}");
  const role = user.role || "canteen_admin";

  const getInitialTab = (userRole) => {
    if (userRole === "canteen_admin") return "orders";
    if (userRole === "hr_admin") return "billing";
    if (userRole === "it_admin") return "canteen_projects";
    return "orders";
  };

  const [activeTab, setActiveTab] = useState(() => getInitialTab(role));

  const handleLogout = () => {
    localStorage.removeItem("adminToken");
    localStorage.removeItem("adminUser");
    window.location.href = "/";
  };

  return (
    <>
      <Navbar onLogout={handleLogout} />

      <div className="dashboard-container">
        <div className="dashboard-banner">
          <h1>SJVN Lunchify Admin Panel</h1>
          <div className="admin-profile-badge">
            <span className="profile-icon">👤</span>
            <div className="profile-text">
              <strong>{user.name || "Administrator"}</strong>
              <span className="role-subtext">{role.replace("_", " ").toUpperCase()}</span>
            </div>
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
          {activeTab === "orders" && <OrdersManager />}
          {activeTab === "reports" && <ReportsPanel />}
          {activeTab === "canteen_billing" && <CanteenBillingPanel />}
          {activeTab === "billing" && <BillingPanel />}
          {activeTab === "transfers" && <TransferPanel />}
          {activeTab === "canteen_projects" && <CanteenProjectsPanel />}
          {activeTab === "feedbacks" && <FeedbackViewer />}
          {activeTab === "admin_accounts" && <AdminAccountsPanel />}
        </div>
      </div>
    </>
  );
}
