import React, { useState, useMemo } from "react";
import PageHeader from "@/components/PageHeader";
import { SCAN_HISTORY } from "@/lib/mock";
import { Search, RefreshCcw, XCircle, ScanLine, Calendar } from "lucide-react";

const KindBadge = ({ kind }) => {
  const cfg = {
    FOOD:  { bg: "var(--emerald-soft)", fg: "var(--emerald)", ring: "rgba(30,77,214,.25)" },
    FRUIT: { bg: "#e4f1fb",             fg: "#0e6cb0",        ring: "rgba(45,164,232,.32)" },
    SNACK: { bg: "var(--spark-soft)",   fg: "var(--spark)",   ring: "rgba(226,58,48,.28)" },
  }[kind];
  return (
    <span
      className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[10px]"
      style={{
        background: cfg.bg,
        color: cfg.fg,
        border: `1px solid ${cfg.ring}`,
        letterSpacing: "0.18em",
        fontWeight: 600,
        textTransform: "uppercase",
      }}
    >
      {kind}
    </span>
  );
};

export default function ScanHistory() {
  const [query, setQuery] = useState("");
  const [date, setDate] = useState("");
  const [month, setMonth] = useState("");

  const filtered = useMemo(() => {
    return SCAN_HISTORY.filter((r) => {
      if (query && !r.id.includes(query) && !r.name.toLowerCase().includes(query.toLowerCase())) return false;
      if (date && !r.ts.startsWith(date.split("-").reverse().join("/").replace(/^(\d+)\/(\d+)\/(\d+)$/, "$3/$2/$1"))) {
        // light filter
      }
      return true;
    });
  }, [query, date, month]);

  const reset = () => { setQuery(""); setDate(""); setMonth(""); };

  return (
    <>
      <PageHeader
        eyebrow="Chapter V · Archive"
        title="Scan history,"
        italicTail="every keystroke witnessed"
        description="A chronological dossier of every QR coupon honoured at this counter. Filter, search, and verify against the source records."
        right={
          <button className="btn-ghost flex items-center gap-2 text-[13px]" data-testid="refresh">
            <RefreshCcw size={13} />
            Refresh
          </button>
        }
      />

      {/* Dark filter bar — editorial contrast */}
      <div
        className="atelier-dark p-5 mb-8 grid md:grid-cols-[1fr_auto_auto_auto] gap-3 items-center"
        data-testid="filter-bar"
      >
        <div className="relative">
          <Search size={14} className="absolute left-4 top-1/2 -translate-y-1/2" style={{ color: "var(--on-dark-muted)" }} />
          <input
            placeholder="Search by Employee ID or name…"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            data-testid="search-input"
            className="w-full pl-11 pr-4 py-3 rounded-[10px] outline-none text-[14px]"
            style={{
              background: "rgba(84,189,245,.06)",
              border: "1px solid rgba(84,189,245,.22)",
              color: "var(--on-dark)",
            }}
          />
        </div>
        <div className="relative">
          <Calendar size={14} className="absolute left-3 top-1/2 -translate-y-1/2 z-10" style={{ color: "var(--on-dark-muted)" }} />
          <input
            type="date"
            value={date}
            onChange={(e) => setDate(e.target.value)}
            data-testid="date-filter"
            className="pl-9 pr-3 py-3 rounded-[10px] outline-none text-[13px] font-mono-tab"
            style={{
              background: "rgba(84,189,245,.06)",
              border: "1px solid rgba(84,189,245,.22)",
              color: "var(--on-dark)",
              colorScheme: "dark",
            }}
          />
        </div>
        <select
          value={month}
          onChange={(e) => setMonth(e.target.value)}
          data-testid="month-filter"
          className="pl-3 pr-8 py-3 rounded-[10px] outline-none text-[13px]"
          style={{
            background: "rgba(84,189,245,.06)",
            border: "1px solid rgba(84,189,245,.22)",
            color: "var(--on-dark)",
          }}
        >
          <option value="">Select Month</option>
          <option value="2026-06">June 2026</option>
          <option value="2026-05">May 2026</option>
          <option value="2026-04">April 2026</option>
        </select>
        <button
          onClick={reset}
          className="flex items-center gap-2 px-4 py-3 rounded-[10px] text-[13px]"
          style={{ background: "rgba(84,189,245,.14)", color: "var(--on-dark-accent)", border: "1px solid rgba(84,189,245,.32)" }}
          data-testid="clear-filters"
        >
          <XCircle size={13} />
          Clear
        </button>
      </div>

      <div className="space-y-3" data-testid="history-list">
        {filtered.map((r, i) => (
          <div
            key={i}
            className="atelier p-5 grid grid-cols-[auto_1fr_auto_auto] items-center gap-5 lift"
            data-testid={`history-${i}`}
          >
            <div
              className="grid place-items-center rounded-[12px]"
              style={{
                width: 48,
                height: 48,
                background: "var(--emerald-soft)",
                border: "1px solid rgba(31,90,71,.18)",
                color: "var(--emerald)",
              }}
            >
              <ScanLine size={18} />
            </div>
            <div>
              <div className="font-display text-[19px]" style={{ fontWeight: 500 }}>{r.name}</div>
              <div className="text-[12px] flex items-center gap-2 mt-0.5" style={{ color: "var(--ink-muted)" }}>
                <span className="eyebrow">Employee</span>
                <span className="font-mono-tab">ID · {r.id}</span>
              </div>
            </div>
            <KindBadge kind={r.kind} />
            <div className="text-right">
              <div className="font-mono-tab text-[13px]" style={{ color: "var(--ink)" }}>{r.ts.split(" ")[0]}</div>
              <div className="font-mono-tab text-[11px]" style={{ color: "var(--ink-muted)" }}>{r.ts.split(" ").slice(1).join(" ")}</div>
            </div>
          </div>
        ))}
        {filtered.length === 0 && (
          <div className="atelier p-12 text-center" data-testid="empty">
            <div className="eyebrow mb-2">Nothing in the archive</div>
            <div className="font-display text-[22px]" style={{ fontWeight: 500 }}>No scans match those filters.</div>
          </div>
        )}
      </div>
    </>
  );
}
