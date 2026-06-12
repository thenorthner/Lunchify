import React from "react";
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import CreditCardIcon from '@mui/icons-material/CreditCard';
import StarIcon from '@mui/icons-material/Star';
import SyncIcon from '@mui/icons-material/Sync';
import BusinessIcon from '@mui/icons-material/Business';
import ChatIcon from '@mui/icons-material/Chat';
import VpnKeyIcon from '@mui/icons-material/VpnKey';
import RestaurantMenuIcon from '@mui/icons-material/RestaurantMenu';
import ShoppingCartIcon from '@mui/icons-material/ShoppingCart';
import HistoryIcon from '@mui/icons-material/History';
import "../styles/Tabs.css";

export default function DashboardTabs({ activeTab, setActiveTab, role }) {
  if (role === "canteen_admin") {
    return (
      <div className="tabs">

        <div
          className={`tab-card ${activeTab === "reports" ? "active" : ""}`}
          onClick={() => setActiveTab("reports")}
        >
          <div className="tab-icon"><TrendingUpIcon fontSize="large" /></div>
          <span>Scan Reports</span>
        </div>

        <div
          className={`tab-card ${activeTab === "canteen_billing" ? "active" : ""}`}
          onClick={() => setActiveTab("canteen_billing")}
        >
          <div className="tab-icon"><CreditCardIcon fontSize="large" /></div>
          <span>Generate Bill</span>
        </div>

        <div
          className={`tab-card ${activeTab === "item_feedbacks" ? "active" : ""}`}
          onClick={() => setActiveTab("item_feedbacks")}
        >
          <div className="tab-icon"><StarIcon fontSize="large" /></div>
          <span>Menu Ratings</span>
        </div>

        <div
          className={`tab-card ${activeTab === "menu" ? "active" : ""}`}
          onClick={() => setActiveTab("menu")}
        >
          <div className="tab-icon"><RestaurantMenuIcon fontSize="large" /></div>
          <span>Menu Management</span>
        </div>

        <div
          className={`tab-card ${activeTab === "orders" ? "active" : ""}`}
          onClick={() => setActiveTab("orders")}
        >
          <div className="tab-icon"><ShoppingCartIcon fontSize="large" /></div>
          <span>Canteen Orders</span>
        </div>

        <div
          className={`tab-card ${activeTab === "scan_history" ? "active" : ""}`}
          onClick={() => setActiveTab("scan_history")}
        >
          <div className="tab-icon"><HistoryIcon fontSize="large" /></div>
          <span>Scan History</span>
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
          <div className="tab-icon"><CreditCardIcon fontSize="large" /></div>
          <span>Billing Management</span>
        </div>

        <div
          className={`tab-card ${activeTab === "transfers" ? "active" : ""}`}
          onClick={() => setActiveTab("transfers")}
        >
          <div className="tab-icon"><SyncIcon fontSize="large" /></div>
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
          <div className="tab-icon"><BusinessIcon fontSize="large" /></div>
          <span>Projects & Canteens</span>
        </div>

        <div
          className={`tab-card ${activeTab === "feedbacks" ? "active" : ""}`}
          onClick={() => setActiveTab("feedbacks")}
        >
          <div className="tab-icon"><ChatIcon fontSize="large" /></div>
          <span>System Feedbacks</span>
        </div>

        <div
          className={`tab-card ${activeTab === "item_feedbacks" ? "active" : ""}`}
          onClick={() => setActiveTab("item_feedbacks")}
        >
          <div className="tab-icon"><StarIcon fontSize="large" /></div>
          <span>Menu Ratings</span>
        </div>

        <div
          className={`tab-card ${activeTab === "admin_accounts" ? "active" : ""}`}
          onClick={() => setActiveTab("admin_accounts")}
        >
          <div className="tab-icon"><VpnKeyIcon fontSize="large" /></div>
          <span>Admin Accounts</span>
        </div>
      </div>
    );
  }

  return null;
}
