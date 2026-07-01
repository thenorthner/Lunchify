import React, { useState, useMemo } from "react";
import PageHeader from "@/components/PageHeader";
import { MENU_RATINGS, PROJECTS } from "@/lib/mock";
import { Star, Calendar, MessageCircle, ChevronDown, Apple, Utensils, TrendingUp } from "lucide-react";

const Stars = ({ value }) => {
  const full = Math.floor(value);
  const half = value - full >= 0.5;
  return (
    <span className="star-row" aria-label={`${value} out of 5`}>
      {Array.from({ length: 5 }).map((_, i) => {
        const isFilled = i < full || (i === full && half);
        return (
          <Star
            key={i}
            className={isFilled ? "filled" : "empty"}
            strokeWidth={1.2}
          />
        );
      })}
    </span>
  );
};

const RatingCard = ({ r, expanded, onToggle }) => {
  const isFruit = r.category === "Fruit";
  return (
    <div className="atelier p-6 lift" data-testid={`rating-${r.name}`}>
      <div className="flex items-start justify-between gap-4">
        <div className="flex items-start gap-4">
          <div
            className="grid place-items-center rounded-[12px] shrink-0"
            style={{
              width: 56, height: 56,
              background: isFruit
                ? "linear-gradient(140deg, #fbe1de, #fbeacb)"
                : "var(--emerald-soft)",
              color: isFruit ? "var(--spark)" : "var(--emerald)",
              border: "1px solid var(--hairline)",
            }}
          >
            {isFruit ? <Apple size={22} strokeWidth={1.5} /> : <Utensils size={22} strokeWidth={1.5} />}
          </div>
          <div>
            <div className="eyebrow mb-1">{r.category}</div>
            <h3 className="font-display" style={{ fontSize: 24, fontWeight: 500, letterSpacing: "-0.02em" }}>{r.name}</h3>
            <div className="flex items-center gap-3 mt-2">
              <Stars value={r.rating} />
              <span className="font-display tnum" style={{ fontSize: 18, fontWeight: 500 }}>{r.rating.toFixed(1)}</span>
              <span className="text-[12px]" style={{ color: "var(--ink-muted)" }}>
                ({r.reviews} review{r.reviews === 1 ? "" : "s"})
              </span>
            </div>
          </div>
        </div>
        <div
          className="px-3 py-1 rounded-full text-[10.5px]"
          style={{
            background: r.rating >= 4.5 ? "var(--emerald-soft)" : r.rating >= 3.5 ? "#e4f1fb" : "var(--amber-soft)",
            color:      r.rating >= 4.5 ? "var(--emerald)"      : r.rating >= 3.5 ? "#0e6cb0" : "#6a4a0e",
            border: "1px solid var(--hairline-strong)",
            letterSpacing: "0.18em",
            fontWeight: 600,
            textTransform: "uppercase",
          }}
        >
          {r.rating >= 4.5 ? "Acclaimed" : r.rating >= 3.5 ? "Solid" : "Mixed"}
        </div>
      </div>

      <div className="hairline my-5" />

      <button
        onClick={onToggle}
        className="flex items-center justify-between w-full text-[13px]"
        style={{ color: "var(--ink)" }}
        data-testid={`toggle-remarks-${r.name}`}
      >
        <span className="flex items-center gap-2" style={{ color: "var(--emerald)" }}>
          <MessageCircle size={14} />
          View {r.remarks.length} remark{r.remarks.length === 1 ? "" : "s"}
        </span>
        <ChevronDown
          size={15}
          style={{ transform: expanded ? "rotate(180deg)" : "rotate(0)", transition: "transform .2s ease", color: "var(--ink-muted)" }}
        />
      </button>

      {expanded && (
        <div className="mt-4 space-y-3" data-testid={`remarks-${r.name}`}>
          {r.remarks.map((rm, i) => (
            <div
              key={i}
              className="p-4 rounded-[10px]"
              style={{ background: "var(--paper-2)", border: "1px solid var(--hairline)" }}
            >
              <div className="eyebrow mb-1" style={{ color: "var(--brass)" }}>{rm.by}</div>
              <div className="text-[14px]" style={{ color: "var(--ink-2)" }}>&ldquo;{rm.text}&rdquo;</div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default function ItMenuRatings() {
  const [canteen, setCanteen] = useState(PROJECTS[0].canteen.name);
  const [date, setDate] = useState("2026-06-30");
  const [open, setOpen] = useState(null);

  const avg = useMemo(
    () => MENU_RATINGS.reduce((a, b) => a + b.rating, 0) / MENU_RATINGS.length,
    []
  );
  const totalReviews = MENU_RATINGS.reduce((a, b) => a + b.reviews, 0);

  return (
    <>
      <PageHeader
        eyebrow="Chapter VIII · Resonance"
        title="Voice of the room,"
        italicTail="daily menu ratings"
        description="Aggregated feedback for each item on the day's menu — sentiment captured, course-corrected, repeated tomorrow."
      />

      {/* Filter strip */}
      <div className="atelier p-4 mb-8 flex flex-wrap items-center gap-3 justify-between" data-testid="ratings-filters">
        <div className="flex flex-wrap items-center gap-3">
          <div className="relative">
            <select
              value={canteen}
              onChange={(e) => setCanteen(e.target.value)}
              data-testid="canteen-select"
              className="input-atelier pr-10 appearance-none min-w-[300px]"
            >
              {PROJECTS.map((p) => <option key={p.id} value={p.canteen.name}>{p.canteen.name}</option>)}
            </select>
            <ChevronDown size={14} className="absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none" style={{ color: "var(--ink-muted)" }} />
          </div>
          <div className="relative">
            <Calendar size={13} className="absolute left-3 top-1/2 -translate-y-1/2 z-10" style={{ color: "var(--ink-muted)" }} />
            <input
              type="date"
              value={date}
              onChange={(e) => setDate(e.target.value)}
              className="input-atelier pl-9 font-mono-tab"
              data-testid="ratings-date"
            />
          </div>
        </div>
        <div className="flex items-center gap-4">
          <div className="text-right">
            <div className="eyebrow">Day average</div>
            <div className="flex items-center gap-2 mt-1">
              <Stars value={avg} />
              <span className="font-display tnum text-[20px]" style={{ fontWeight: 500 }}>{avg.toFixed(2)}</span>
            </div>
          </div>
          <div className="text-right">
            <div className="eyebrow">Total reviews</div>
            <div className="font-display tnum text-[20px] mt-1" style={{ fontWeight: 500 }}>{totalReviews}</div>
          </div>
        </div>
      </div>

      {/* Highlight strip */}
      <div
        className="atelier-dark p-5 mb-8 flex items-center justify-between flex-wrap gap-3"
        data-testid="top-item"
      >
        <div className="flex items-center gap-3">
          <div
            className="grid place-items-center rounded-[12px]"
            style={{ width: 40, height: 40, background: "rgba(84,189,245,.15)", color: "var(--on-dark-accent)" }}
          >
            <TrendingUp size={18} />
          </div>
          <div>
            <div className="eyebrow" style={{ color: "var(--on-dark-accent)" }}>Top of the day</div>
            <div className="font-display text-[20px] mt-0.5" style={{ fontWeight: 500 }}>
              <span style={{ fontStyle: "italic", color: "var(--on-dark-accent)" }}>Jeera Rice</span> — guests are praising the fragrance.
            </div>
          </div>
        </div>
        <Stars value={4.7} />
      </div>

      <div className="grid lg:grid-cols-2 gap-5">
        {MENU_RATINGS.map((r) => (
          <RatingCard
            key={r.name}
            r={r}
            expanded={open === r.name}
            onToggle={() => setOpen(open === r.name ? null : r.name)}
          />
        ))}
      </div>
    </>
  );
}
