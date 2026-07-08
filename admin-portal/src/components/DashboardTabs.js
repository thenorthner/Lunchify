import React from "react";
import "../styles/Tabs.css";

const TAB_CONFIG = {
  reports: { label: "Scan Reports" },
  canteen_billing: { label: "Generate Bill" },
  item_feedbacks: { label: "Menu Ratings" },
  menu: { label: "Menu Management" },
  orders: { label: "Canteen Orders" },
  scan_history: { label: "Scan History" },
  billing: { label: "Billing Management" },
  transfers: { label: "Employee Transfers" },
  canteen_projects: { label: "Projects & Canteens" },
  feedbacks: { label: "System Feedbacks" },
  admin_accounts: { label: "Admin Accounts" },
};

export default function DashboardTabs({ activeTab, setActiveTab, allowedTabs = [] }) {
  if (allowedTabs.length === 0) return null;

  // Determine active module based on tabs content
  const isIT = allowedTabs.includes("canteen_projects") || allowedTabs.includes("admin_accounts");
  const isHR = allowedTabs.includes("billing") || allowedTabs.includes("transfers") || (allowedTabs.includes("item_feedbacks") && !isIT);
  const moduleName = isIT ? "Governance" : isHR ? "HR Review" : "Operations";

  // Format current date: e.g., "01 Jul 2026"
  const formatDate = () => {
    const d = new Date();
    const day = String(d.getDate()).padStart(2, "0");
    const month = d.toLocaleString("en-US", { month: "short" });
    const year = d.getFullYear();
    return `${day} ${month} ${year}`;
  };

  return (
    <div className="tabs" role="tablist" aria-label="Admin navigation">
      <div className="tabs-left-side">
        <span className="tabs-module-name">{moduleName}</span>
        <span className="tabs-divider">—</span>
        
        <div className="tabs-list">
          {allowedTabs.map((tabId, idx) => {
            const config = TAB_CONFIG[tabId];
            if (!config) return null;
            const indexStr = String(idx + 1).padStart(2, "0");
            
            return (
              <div
                key={tabId}
                className={`tab-item ${activeTab === tabId ? "active" : ""}`}
                onClick={() => setActiveTab(tabId)}
                role="tab"
                aria-selected={activeTab === tabId}
                tabIndex={0}
                onKeyDown={(e) => { if (e.key === 'Enter' || e.key === ' ') setActiveTab(tabId); }}
              >
                <span className="tab-number">{indexStr}</span>
                <span className="tab-label">{config.label}</span>
              </div>
            );
          })}
        </div>
      </div>

      <div className="tabs-right-side">
        <span>Session</span>
        <span className="tabs-session-date">{formatDate()}</span>
      </div>
    </div>
  );
}
