import React, { useState, useMemo } from "react";
import PageHeader from "@/components/PageHeader";
import { SCAN_DAILY, ADMIN } from "@/lib/mock";
import { Ticket, Zap, TrendingUp, ArrowUpRight } from "lucide-react";

const Stat = ({ label, value, suffix, tone = "emerald", trend, icon: Icon }) => {
  const palette = {
    emerald: { bg: "var(--emerald-soft)", fg: "var(--emerald)", ring: "rgba(30,77,214,.2)" },
    brass:   { bg: "#e4f1fb",             fg: "#0e6cb0",        ring: "rgba(45,164,232,.3)" },
    ink:     { bg: "var(--navy-2)",       fg: "var(--on-dark)", ring: "rgba(84,189,245,.22)" },
  }[tone];
  const dark = tone === "ink";
  return (
    <div
      className="p-7 lift"
      style={{
        background: dark ? palette.bg : "linear-gradient(180deg, rgba(255,255,255,.92), rgba(241,246,252,.78))",
        border: `1px solid ${palette.ring}`,
        borderRadius: 14,
        color: dark ? palette.fg : "var(--ink)",
      }}
      data-testid={`stat-${label?.toLowerCase().replace(/\s+/g, "-")}`}
    >
      <div className="flex items-start justify-between">
        <div className="eyebrow" style={{ color: dark ? "var(--on-dark-muted)" : "var(--ink-muted)" }}>{label}</div>
        <div
          className="grid place-items-center rounded-[10px]"
          style={{ width: 36, height: 36, background: dark ? "rgba(84,189,245,.15)" : palette.bg, color: dark ? "var(--on-dark-accent)" : palette.fg }}
        >
          <Icon size={16} strokeWidth={1.7} />
        </div>
      </div>
      <div className="flex items-baseline gap-2 mt-6">
        <span className="font-display tnum" style={{ fontSize: 56, fontWeight: 400, lineHeight: 1, letterSpacing: "-0.04em" }}>
          {value}
        </span>
        {suffix && <span className="text-[13px]" style={{ color: dark ? "var(--on-dark-muted)" : "var(--ink-muted)" }}>{suffix}</span>}
      </div>
      {trend && (
        <div className="flex items-center gap-1.5 mt-4 text-[12px]" style={{ color: dark ? "var(--on-dark-accent)" : "var(--emerald)" }}>
          <ArrowUpRight size={13} />
          <span>{trend}</span>
        </div>
      )}
    </div>
  );
};

const RANGES = [
  { k: "daily",   label: "Daily" },
  { k: "monthly", label: "Monthly" },
  { k: "yearly",  label: "Yearly" },
];

export default function ScanReports() {
  const [range, setRange] = useState("daily");

  const max = useMemo(() => Math.max(...SCAN_DAILY.map((r) => r.count)), []);
  const peak = useMemo(() => SCAN_DAILY.reduce((a, b) => (a.count > b.count ? a : b)), []);
  const sum = SCAN_DAILY.reduce((a, b) => a + b.count, 0);

  return (
    <>
      <PageHeader
        eyebrow="Chapter II · Ledger"
        title="Scanned Coupons,"
        italicTail="precisely recorded"
        description={`Canteen ${ADMIN.canteenId} · ${ADMIN.name}. A historiographic view of verified scans — the source of truth for monthly reconciliation.`}
        right={
          <div className="flex items-center p-1 atelier" data-testid="range-toggle">
            {RANGES.map((r) => (
              <button
                key={r.k}
                onClick={() => setRange(r.k)}
                data-active={range === r.k}
                data-testid={`range-${r.k}`}
                className="px-4 py-2 rounded-[10px] text-[12px] font-medium transition-all"
                style={{
                  background: range === r.k ? "var(--ink)" : "transparent",
                  color: range === r.k ? "var(--paper)" : "var(--ink-muted)",
                }}
              >
                {r.label}
              </button>
            ))}
          </div>
        }
      />

      <div className="grid md:grid-cols-3 gap-6 mb-10">
        <Stat label="Total Scans · Latest Day" value="1" icon={Ticket} tone="emerald" trend="On track for the week" />
        <Stat label="Peak Activity Count" value={peak.count} suffix={`on ${peak.date}`} icon={Zap} tone="brass" trend="3.4× the daily average" />
        <Stat label="Aggregate · This Window" value={sum} suffix="coupons" icon={TrendingUp} tone="ink" trend="+18% vs prior period" />
      </div>

      {/* Sparkline strip */}
      <div className="atelier p-7 mb-8" data-testid="sparkline-card">
        <div className="flex items-center justify-between mb-5">
          <div>
            <div className="eyebrow">Cadence of Service</div>
            <div className="font-display text-[22px] mt-1" style={{ fontWeight: 500 }}>
              Last <span style={{ fontStyle: "italic", color: "var(--emerald)" }}>{SCAN_DAILY.length}</span> service days
            </div>
          </div>
          <div className="font-mono-tab text-[11px]" style={{ color: "var(--ink-muted)" }}>
            min 1 · max {max} · avg {(sum / SCAN_DAILY.length).toFixed(1)}
          </div>
        </div>
        <div className="flex items-end gap-2 h-[140px]">
          {SCAN_DAILY.slice().reverse().map((r, i) => {
            const h = (r.count / max) * 100;
            return (
              <div key={i} className="flex-1 flex flex-col items-center group" data-testid={`bar-${r.date}`}>
                <div
                  className="w-full rounded-t-[4px] transition-all duration-500"
                  style={{
                    height: `${h}%`,
                    minHeight: 4,
                    background: r.count === max
                      ? "linear-gradient(180deg, #e23a30, #b51f17)"
                      : "linear-gradient(180deg, rgba(30,77,214,.78), rgba(30,77,214,.38))",
                  }}
                />
                <div className="font-mono-tab text-[9px] mt-1.5" style={{ color: "var(--ink-faint)" }}>
                  {r.date.slice(8)}
                </div>
              </div>
            );
          })}
        </div>
      </div>

      <div className="atelier overflow-hidden" data-testid="ledger-table">
        <table className="atelier-table">
          <thead>
            <tr>
              <th style={{ width: "40%" }}>Date · {range}</th>
              <th style={{ width: "20%" }}>Delivered</th>
              <th style={{ width: "20%" }}>Trend</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            {SCAN_DAILY.map((r, i) => {
              const w = (r.count / max) * 100;
              return (
                <tr key={i} data-testid={`row-${r.date}`}>
                  <td className="font-mono-tab">{r.date}</td>
                  <td>
                    <span className="font-display tnum" style={{ fontSize: 22, fontWeight: 500 }}>{r.count}</span>
                  </td>
                  <td>
                    <div className="h-[3px] rounded-full" style={{ background: "var(--hairline)", maxWidth: 180 }}>
                      <div className="h-full rounded-full" style={{ width: `${w}%`, background: "var(--emerald)" }} />
                    </div>
                  </td>
                  <td>
                    <span className="chip chip-emerald">
                      <span className="inline-block h-1.5 w-1.5 rounded-full" style={{ background: "var(--emerald)" }} />
                      Verified · Scanned
                    </span>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </>
  );
}
