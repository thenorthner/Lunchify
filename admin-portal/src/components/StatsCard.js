import React from "react";

export default function StatsCard({ title, count, icon, onClick }) {
  return (
    <div className="stats-card" onClick={onClick}>
      <div className="stats-icon">{icon}</div>
      <h4>{title}</h4>
      <span>{count}</span>
    </div>
  );
}
