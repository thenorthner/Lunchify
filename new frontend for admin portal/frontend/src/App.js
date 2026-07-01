import React from "react";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import "@/App.css";

import Shell from "@/components/Shell";
import Login from "@/pages/Login";
import MenuManagement from "@/pages/MenuManagement";
import ScanReports from "@/pages/ScanReports";
import GenerateBill from "@/pages/GenerateBill";
import CanteenOrders from "@/pages/CanteenOrders";
import ScanHistory from "@/pages/ScanHistory";

import ItProjects from "@/pages/ItProjects";
import ItFeedbacks from "@/pages/ItFeedbacks";
import ItMenuRatings from "@/pages/ItMenuRatings";
import ItAccounts from "@/pages/ItAccounts";

import HrBilling from "@/pages/HrBilling";
import HrTransfers from "@/pages/HrTransfers";

function Page({ children }) {
  return <Shell>{children}</Shell>;
}

export default function App() {
  return (
    <div className="App">
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Navigate to="/login" replace />} />
          <Route path="/login" element={<Login />} />

          {/* Operations (Canteen Admin) */}
          <Route path="/menu"    element={<Page><MenuManagement /></Page>} />
          <Route path="/reports" element={<Page><ScanReports /></Page>} />
          <Route path="/bill"    element={<Page><GenerateBill /></Page>} />
          <Route path="/orders"  element={<Page><CanteenOrders /></Page>} />
          <Route path="/history" element={<Page><ScanHistory /></Page>} />

          {/* Governance (IT Admin) */}
          <Route path="/projects"  element={<Page><ItProjects /></Page>} />
          <Route path="/feedbacks" element={<Page><ItFeedbacks /></Page>} />
          <Route path="/ratings"   element={<Page><ItMenuRatings /></Page>} />
          <Route path="/accounts"  element={<Page><ItAccounts /></Page>} />

          {/* HR Review */}
          <Route path="/billing"   element={<Page><HrBilling /></Page>} />
          <Route path="/transfers" element={<Page><HrTransfers /></Page>} />
          <Route path="/hrratings" element={<Page><ItMenuRatings /></Page>} />

          <Route path="*" element={<Navigate to="/login" replace />} />
        </Routes>
      </BrowserRouter>
    </div>
  );
}
