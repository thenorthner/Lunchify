import React from "react";
import "./Navbar.css";

export default function Navbar({ onLogout }) {
  return (
    <div className="navbar">
      <span>SJVN Admin</span>
      <button className="logout-btn" onClick={onLogout}>
        Logout
      </button>
    </div>
  );
}
