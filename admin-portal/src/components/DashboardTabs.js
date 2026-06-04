import React from "react";
import "../styles/Tabs.css";

export default function DashboardTabs({ activeTab, setActiveTab, role }) {
  if (role === "canteen_admin") {
    return (
      <div className="tabs">

        <div
          className={`tab-card ${activeTab === "reports" ? "active" : ""}`}
          onClick={() => setActiveTab("reports")}
        >
          <div className="tab-icon">📈</div>
          <span>Scan Reports</span>
        </div>

        <div
          className={`tab-card ${activeTab === "canteen_billing" ? "active" : ""}`}
          onClick={() => setActiveTab("canteen_billing")}
        >
          <div className="tab-icon">💳</div>
          <span>Generate Bill</span>
        </div>

        <div
          className={`tab-card ${activeTab === "item_feedbacks" ? "active" : ""}`}
          onClick={() => setActiveTab("item_feedbacks")}
        >
          <div className="tab-icon">⭐</div>
          <span>Menu Ratings</span>
        </div>
      </div>
    );
  }

  if (role === "hr_admin") {
    return (
      <div className="tabs">
        <div
          className={`tab-card ${activeTab === "billing" ? "active" : ""}`}
          onClick={() => setActiveTab("billing")}
        >
          <div className="tab-icon">💳</div>
          <span>Billing Management</span>
        </div>

        <div
          className={`tab-card ${activeTab === "transfers" ? "active" : ""}`}
          onClick={() => setActiveTab("transfers")}
        >
          <div className="tab-icon">🔄</div>
          <span>Employee Transfers</span>
        </div>
      </div>
    );
  }

  if (role === "it_admin") {
    return (
      <div className="tabs">
        <div
          className={`tab-card ${activeTab === "canteen_projects" ? "active" : ""}`}
          onClick={() => setActiveTab("canteen_projects")}
        >
          <div className="tab-icon">🏢</div>
          <span>Projects & Canteens</span>
        </div>

        <div
          className={`tab-card ${activeTab === "feedbacks" ? "active" : ""}`}
          onClick={() => setActiveTab("feedbacks")}
        >
          <div className="tab-icon">💬</div>
          <span>System Feedbacks</span>
        </div>

        <div
          className={`tab-card ${activeTab === "item_feedbacks" ? "active" : ""}`}
          onClick={() => setActiveTab("item_feedbacks")}
        >
          <div className="tab-icon">⭐</div>
          <span>Menu Ratings</span>
        </div>

        <div
          className={`tab-card ${activeTab === "admin_accounts" ? "active" : ""}`}
          onClick={() => setActiveTab("admin_accounts")}
        >
          <div className="tab-icon">🔑</div>
          <span>Admin Accounts</span>
        </div>
      </div>
    );
  }

  return null;
}
