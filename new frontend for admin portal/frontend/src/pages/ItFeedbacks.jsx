import React, { useState, useMemo } from "react";
import PageHeader from "@/components/PageHeader";
import { FEEDBACKS } from "@/lib/mock";
import { RefreshCcw, Search, MessageSquare, Zap, AlertTriangle, Info } from "lucide-react";

const PRIORITY = {
  HIGH:   { cls: "chip-spark",   icon: Zap,           dot: "var(--spark)" },
  MEDIUM: { cls: "chip-amber",   icon: AlertTriangle, dot: "#b07a16" },
  LOW:    { cls: "chip-sky",     icon: Info,          dot: "#2da4e8" },
};

const Initials = (name) => name.split(" ").map((p) => p[0]).slice(0, 2).join("");

const TicketCard = ({ t, idx }) => {
  const p = PRIORITY[t.priority];
  return (
    <div className="atelier p-6 lift" data-testid={`ticket-${idx}`}>
      {/* Top row */}
      <div className="flex items-start justify-between gap-4 flex-wrap mb-4">
        <div className="flex items-center gap-3">
          <span
            className="px-3 py-1 rounded-full text-[10px]"
            style={{
              background: "var(--emerald-soft)",
              color: "var(--emerald)",
              border: "1px solid rgba(30,77,214,.22)",
              letterSpacing: "0.18em",
              fontWeight: 600,
              textTransform: "uppercase",
            }}
          >
            {t.canteen}
          </span>
          <span className={`chip ${p.cls}`}>
            <p.icon size={11} />
            {t.priority}
          </span>
        </div>
        <div className="font-mono-tab text-[11.5px]" style={{ color: "var(--ink-muted)" }}>
          {t.when}
        </div>
      </div>

      <h3 className="font-display" style={{ fontSize: 24, fontWeight: 500, letterSpacing: "-0.02em" }}>
        {t.subject}
      </h3>
      <p className="text-[14px] mt-2 leading-relaxed" style={{ color: "var(--ink-2)" }}>
        {t.message}
      </p>

      <div className="hairline my-5" />

      {/* Submitter */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div
            className="grid place-items-center rounded-full font-display text-[13px]"
            style={{
              width: 36, height: 36,
              background: "linear-gradient(140deg, #54bdf5, #1e4dd6)",
              color: "#fff",
              fontWeight: 500,
            }}
          >
            {Initials(t.by.name)}
          </div>
          <div>
            <div className="text-[14px]" style={{ fontWeight: 500 }}>{t.by.name}</div>
            <div className="text-[11px] flex items-center gap-2" style={{ color: "var(--ink-muted)" }}>
              <span className="font-mono-tab">ID · {t.by.id}</span>
              <span style={{ width: 12, height: 1, background: "var(--hairline-strong)" }} />
              <span className="eyebrow" style={{ fontSize: 9.5 }}>{t.by.dept}</span>
            </div>
          </div>
        </div>
        <button
          className="btn-ghost flex items-center gap-2 text-[12px]"
          data-testid={`reply-${idx}`}
        >
          <MessageSquare size={12} />
          Respond
        </button>
      </div>
    </div>
  );
};

export default function ItFeedbacks() {
  const [q, setQ] = useState("");
  const filtered = useMemo(
    () => FEEDBACKS.filter((t) => {
      const text = `${t.subject} ${t.message} ${t.by.name} ${t.by.id} ${t.canteen}`.toLowerCase();
      return !q || text.includes(q.toLowerCase());
    }),
    [q]
  );

  const counts = {
    high: FEEDBACKS.filter((t) => t.priority === "HIGH").length,
    medium: FEEDBACKS.filter((t) => t.priority === "MEDIUM").length,
    low: FEEDBACKS.filter((t) => t.priority === "LOW").length,
  };

  return (
    <>
      <PageHeader
        eyebrow="Chapter VII · Voices"
        title="System problems,"
        italicTail="attended to"
        description="A centralised portal where IT Admin audits system tickets and employee reports — each voice heard, every issue traced."
        right={
          <button className="btn-ghost flex items-center gap-2 text-[13px]" data-testid="refresh-tickets">
            <RefreshCcw size={13} />
            Refresh
          </button>
        }
      />

      {/* Triage stats */}
      <div className="grid md:grid-cols-3 gap-4 mb-6">
        {[
          { k: "high",   label: "High priority",   v: counts.high,   color: "var(--spark)",   bg: "var(--spark-soft)" },
          { k: "medium", label: "Medium",          v: counts.medium, color: "#8a6018",        bg: "var(--amber-soft)" },
          { k: "low",    label: "Low / general",   v: counts.low,    color: "#0e6cb0",        bg: "#e4f1fb" },
        ].map((s) => (
          <div
            key={s.k}
            className="atelier p-5 flex items-center justify-between"
            data-testid={`triage-${s.k}`}
          >
            <div>
              <div className="eyebrow">{s.label}</div>
              <div className="font-display tnum mt-1" style={{ fontSize: 38, fontWeight: 400, color: s.color }}>{s.v}</div>
            </div>
            <div
              className="grid place-items-center rounded-[12px]"
              style={{ width: 44, height: 44, background: s.bg, color: s.color, border: `1px solid ${s.color}30` }}
            >
              {s.k === "high" ? <Zap size={16} /> : s.k === "medium" ? <AlertTriangle size={16} /> : <Info size={16} />}
            </div>
          </div>
        ))}
      </div>

      {/* Search */}
      <div className="atelier-dark p-4 mb-6 flex items-center gap-3" data-testid="ticket-search-bar">
        <div className="relative flex-1">
          <Search size={14} className="absolute left-4 top-1/2 -translate-y-1/2" style={{ color: "var(--on-dark-muted)" }} />
          <input
            placeholder="Search tickets by Employee ID, Name, Subject or Message…"
            value={q}
            onChange={(e) => setQ(e.target.value)}
            className="w-full pl-11 pr-4 py-3 rounded-[10px] outline-none text-[14px]"
            style={{
              background: "rgba(84,189,245,.06)",
              border: "1px solid rgba(84,189,245,.22)",
              color: "var(--on-dark)",
            }}
            data-testid="ticket-search"
          />
        </div>
        <span className="eyebrow" style={{ color: "var(--on-dark-accent)" }}>
          {filtered.length} ticket{filtered.length === 1 ? "" : "s"}
        </span>
      </div>

      <div className="space-y-4">
        {filtered.map((t, i) => <TicketCard key={i} t={t} idx={i} />)}
        {filtered.length === 0 && (
          <div className="atelier p-12 text-center" data-testid="empty">
            <div className="eyebrow mb-2">All quiet</div>
            <div className="font-display text-[22px]" style={{ fontWeight: 500 }}>No tickets match those filters.</div>
          </div>
        )}
      </div>
    </>
  );
}
