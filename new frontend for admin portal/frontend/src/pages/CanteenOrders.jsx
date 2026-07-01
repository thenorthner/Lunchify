import React, { useState } from "react";
import PageHeader from "@/components/PageHeader";
import { ORDERS, ADMIN } from "@/lib/mock";
import { Building2, RefreshCcw, CheckCircle2, XCircle, ShoppingBag, Apple, Coffee } from "lucide-react";

const SUBTABS = [
  { k: "food",   label: "Food Lunch",       icon: ShoppingBag },
  { k: "fruit",  label: "Fruit Lunch",      icon: Apple },
  { k: "snacks", label: "Morning · Evening", icon: Coffee },
];

const StatusChip = ({ status }) => {
  const cfg = {
    ACCEPTED:  { cls: "chip-emerald", dot: "var(--emerald)" },
    PENDING:   { cls: "chip-amber",   dot: "#b07a16" },
    DELIVERED: { cls: "chip-emerald", dot: "var(--emerald)" },
    CANCELLED: { cls: "chip-rust",    dot: "var(--rust)" },
  }[status] || { cls: "", dot: "var(--ink)" };
  return (
    <span className={`chip ${cfg.cls}`} data-testid={`status-${status}`}>
      <span className="inline-block h-1.5 w-1.5 rounded-full" style={{ background: cfg.dot }} />
      {status}
    </span>
  );
};

export default function CanteenOrders() {
  const [tab, setTab] = useState("food");
  const [orders, setOrders] = useState(ORDERS);

  const markDelivered = (id) => setOrders((o) => o.map((x) => (x.id === id ? { ...x, status: "DELIVERED" } : x)));
  const cancel = (id) => setOrders((o) => o.map((x) => (x.id === id ? { ...x, status: "CANCELLED" } : x)));

  const counts = {
    pending: orders.filter((o) => o.status === "PENDING").length,
    accepted: orders.filter((o) => o.status === "ACCEPTED").length,
    delivered: orders.filter((o) => o.status === "DELIVERED").length,
  };

  return (
    <>
      <PageHeader
        eyebrow="Chapter IV · Service"
        title="Canteen orders,"
        italicTail="orchestrated"
        description="Each ticket is a promise. Accept, deliver, and document — with the calm precision of a well-run dining room."
        right={
          <div className="chip" data-testid="canteen-badge">
            <Building2 size={13} />
            <span className="eyebrow">Canteen</span>
            <span className="font-mono-tab text-[12px]">{ADMIN.canteen}</span>
          </div>
        }
      />

      {/* Sub-tabs */}
      <div className="flex items-center gap-1 p-1 atelier w-fit mb-6" data-testid="subtabs">
        {SUBTABS.map((s) => (
          <button
            key={s.k}
            onClick={() => setTab(s.k)}
            data-active={tab === s.k}
            data-testid={`subtab-${s.k}`}
            className="flex items-center gap-2 px-5 py-2.5 rounded-[10px] text-[13px] font-medium transition-all"
            style={{
              background: tab === s.k ? "var(--ink)" : "transparent",
              color: tab === s.k ? "var(--paper)" : "var(--ink-muted)",
            }}
          >
            <s.icon size={14} />
            {s.label}
          </button>
        ))}
      </div>

      <div className="grid md:grid-cols-3 gap-4 mb-6">
        {[
          { label: "Pending", value: counts.pending,   tone: "amber" },
          { label: "Accepted", value: counts.accepted, tone: "emerald" },
          { label: "Delivered", value: counts.delivered, tone: "ink" },
        ].map((s, i) => (
          <div
            key={i}
            className="p-5 atelier flex items-center justify-between"
            data-testid={`order-stat-${s.label.toLowerCase()}`}
          >
            <div>
              <div className="eyebrow">{s.label}</div>
              <div className="font-display tnum mt-1" style={{ fontSize: 36, fontWeight: 400 }}>{s.value}</div>
            </div>
            <div
              className="h-12 w-12 rounded-full grid place-items-center"
              style={{
                background:
                  s.tone === "emerald" ? "var(--emerald-soft)" :
                  s.tone === "amber"   ? "#fbeacb" :
                                         "var(--navy-2)",
                color:
                  s.tone === "emerald" ? "var(--emerald)" :
                  s.tone === "amber"   ? "#8a6018" :
                                         "var(--on-dark-accent)",
                border: "1px solid var(--hairline)",
              }}
            >
              <ShoppingBag size={16} />
            </div>
          </div>
        ))}
      </div>

      <div className="atelier overflow-hidden" data-testid="orders-table">
        <div className="flex items-center justify-between p-5" style={{ borderBottom: "1px solid var(--hairline)" }}>
          <div>
            <div className="eyebrow">Today&#39;s docket</div>
            <div className="font-display text-[20px] mt-0.5" style={{ fontWeight: 500 }}>
              {orders.length} tickets in queue
            </div>
          </div>
          <button className="btn-ghost flex items-center gap-2 text-[12px]" data-testid="refresh-orders">
            <RefreshCcw size={13} />
            Refresh
          </button>
        </div>

        <table className="atelier-table">
          <thead>
            <tr>
              <th>Order</th>
              <th>Employee</th>
              <th>Name</th>
              <th>Date</th>
              <th>Status</th>
              <th className="text-right" style={{ textAlign: "right" }}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {orders.map((o) => (
              <tr key={o.id} data-testid={`order-${o.id}`}>
                <td>
                  <span className="font-display italic" style={{ color: "var(--brass)", fontSize: 14 }}>№</span>
                  <span className="font-mono-tab ml-1.5">{String(o.id).padStart(4, "0")}</span>
                </td>
                <td className="font-mono-tab">{o.emp}</td>
                <td>
                  <div className="flex items-center gap-3">
                    <div
                      className="grid place-items-center rounded-full font-display"
                      style={{
                        width: 32, height: 32,
                        background: "var(--paper-2)",
                        border: "1px solid var(--hairline)",
                        color: "var(--ink)",
                        fontSize: 13,
                        fontWeight: 500,
                      }}
                    >
                      {o.name.split(" ").map((p) => p[0]).slice(0, 2).join("")}
                    </div>
                    <span className="text-[14px]">{o.name}</span>
                  </div>
                </td>
                <td className="font-mono-tab" style={{ color: "var(--ink-muted)" }}>{o.date}</td>
                <td><StatusChip status={o.status} /></td>
                <td style={{ textAlign: "right" }}>
                  <div className="flex items-center gap-2 justify-end">
                    {o.status === "ACCEPTED" && (
                      <button
                        onClick={() => markDelivered(o.id)}
                        className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-full text-[12px] font-medium"
                        style={{
                          background: "var(--emerald)",
                          color: "var(--paper)",
                          border: "1px solid var(--emerald-2)",
                        }}
                        data-testid={`deliver-${o.id}`}
                      >
                        <CheckCircle2 size={12} />
                        Mark Delivered
                      </button>
                    )}
                    {(o.status === "PENDING" || o.status === "ACCEPTED") && (
                      <button
                        onClick={() => cancel(o.id)}
                        className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-full text-[12px] font-medium"
                        style={{
                          background: "transparent",
                          color: "var(--ink)",
                          border: "1px solid var(--hairline-strong)",
                        }}
                        data-testid={`cancel-${o.id}`}
                      >
                        <XCircle size={12} />
                        Cancel
                      </button>
                    )}
                    {o.status === "DELIVERED" && (
                      <span className="text-[12px] italic font-display" style={{ color: "var(--ink-muted)" }}>
                        served at {o.date}
                      </span>
                    )}
                    {o.status === "CANCELLED" && (
                      <span className="text-[12px] italic font-display" style={{ color: "var(--rust)" }}>
                        voided
                      </span>
                    )}
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}
