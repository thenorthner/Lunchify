import React, { useState } from "react";
import PageHeader from "@/components/PageHeader";
import { FOOD_MENU, FRUIT_MENU, SNACKS_MORNING, SNACKS_EVENING } from "@/lib/mock";
import { Calendar, Plus, X, Utensils, Apple, Coffee, Moon, Save, CalendarRange } from "lucide-react";

const Section = ({ icon: Icon, no, title, kicker, children }) => (
  <div className="atelier p-7 brass-corner" data-testid={`section-${title?.toString().toLowerCase().replace(/\s+/g, "-")}`}>
    <div className="flex items-start gap-5">
      <div
        className="grid place-items-center shrink-0"
        style={{
          width: 44,
          height: 44,
          borderRadius: 12,
          background: "var(--emerald-soft)",
          color: "var(--emerald)",
          border: "1px solid rgba(31,90,71,.18)",
        }}
      >
        <Icon size={18} strokeWidth={1.7} />
      </div>
      <div className="flex-1">
        <div className="flex items-baseline gap-3">
          <span className="font-display italic text-[14px]" style={{ color: "var(--brass)" }}>{no}</span>
          <h3 className="font-display text-[24px]" style={{ fontWeight: 500, letterSpacing: "-0.02em" }}>{title}</h3>
        </div>
        {kicker && <div className="eyebrow mt-1">{kicker}</div>}
      </div>
    </div>
    <div className="mt-6">{children}</div>
  </div>
);

const Tag = ({ children, onRemove }) => (
  <span
    className="inline-flex items-center gap-2 pl-3.5 pr-1.5 py-1.5 rounded-full"
    style={{
      background: "var(--paper)",
      border: "1px solid var(--hairline-strong)",
      color: "var(--ink)",
      fontSize: 13,
    }}
  >
    {children}
    <button
      onClick={onRemove}
      className="grid place-items-center rounded-full"
      style={{ width: 18, height: 18, background: "var(--bone)", color: "var(--ink-muted)" }}
      data-testid={`remove-${children}`}
    >
      <X size={11} />
    </button>
  </span>
);

export default function MenuManagement() {
  const [mode, setMode] = useState("specific");
  const [food, setFood] = useState(FOOD_MENU);
  const [fruit, setFruit] = useState(FRUIT_MENU);
  const [foodInput, setFoodInput] = useState("");
  const [fruitInput, setFruitInput] = useState("");
  const [morning, setMorning] = useState(SNACKS_MORNING);
  const [evening, setEvening] = useState(SNACKS_EVENING);
  const [mName, setMName] = useState("");
  const [mPrice, setMPrice] = useState("");
  const [eName, setEName] = useState("");
  const [ePrice, setEPrice] = useState("");

  const addFood = () => { if (foodInput.trim()) { setFood([...food, foodInput.trim()]); setFoodInput(""); } };
  const addFruit = () => { if (fruitInput.trim()) { setFruit([...fruit, fruitInput.trim()]); setFruitInput(""); } };
  const addMorning = () => { if (mName && mPrice) { setMorning([...morning, { name: mName, price: Number(mPrice) }]); setMName(""); setMPrice(""); } };
  const addEvening = () => { if (eName && ePrice) { setEvening([...evening, { name: eName, price: Number(ePrice) }]); setEName(""); setEPrice(""); } };

  return (
    <>
      <PageHeader
        eyebrow="Chapter I · Curation"
        title="Compose the day's"
        italicTail="culinary programme"
        description="Set the canteen's offerings with the deliberation of a maître d'. Items here flow directly to coupon generation and downstream billing."
        right={
          <div className="flex items-center gap-2 chip" data-testid="date-chip">
            <Calendar size={14} />
            <span className="eyebrow">Service Date</span>
            <span className="font-mono-tab text-[12px]">30 · 06 · 2026</span>
          </div>
        }
      />

      {/* Mode toggle */}
      <div className="flex items-center gap-1 p-1 atelier w-fit mb-8" data-testid="mode-toggle">
        {[
          { k: "specific", label: "Specific Date", icon: Calendar },
          { k: "weekly", label: "Weekly Template", icon: CalendarRange },
        ].map((m) => (
          <button
            key={m.k}
            onClick={() => setMode(m.k)}
            data-active={mode === m.k}
            data-testid={`mode-${m.k}`}
            className="flex items-center gap-2 px-5 py-2.5 rounded-[10px] text-[13px] font-medium transition-all"
            style={{
              background: mode === m.k ? "var(--ink)" : "transparent",
              color: mode === m.k ? "var(--paper)" : "var(--ink-muted)",
            }}
          >
            <m.icon size={14} />
            {m.label}
          </button>
        ))}
      </div>

      {/* Date override */}
      <div className="atelier p-6 mb-8 flex items-center justify-between" data-testid="date-override">
        <div>
          <div className="eyebrow mb-1">Date Override</div>
          <div className="font-display text-[20px]" style={{ fontWeight: 500 }}>
            Monday, 30 June 2026
          </div>
        </div>
        <input
          type="date"
          defaultValue="2026-06-30"
          className="input-atelier max-w-[200px] font-mono-tab"
          data-testid="date-input"
        />
      </div>

      <div className="grid lg:grid-cols-2 gap-6">
        <Section icon={Utensils} no="i." title="Food Menu" kicker="Lunch · Mains">
          <div className="flex flex-wrap gap-2 mb-4">
            {food.map((f, i) => (
              <Tag key={i} onRemove={() => setFood(food.filter((_, j) => j !== i))}>{f}</Tag>
            ))}
            {food.length === 0 && <span className="text-[13px]" style={{ color: "var(--ink-faint)" }}>No items yet.</span>}
          </div>
          <div className="flex gap-2">
            <input
              className="input-atelier"
              placeholder="Enter food item…"
              value={foodInput}
              onChange={(e) => setFoodInput(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && addFood()}
              data-testid="food-input"
            />
            <button onClick={addFood} className="btn-ink px-5" data-testid="add-food"><Plus size={16} /></button>
          </div>
        </Section>

        <Section icon={Apple} no="ii." title="Fruit Menu" kicker="Seasonal · Fresh">
          <div className="flex flex-wrap gap-2 mb-4">
            {fruit.map((f, i) => (
              <Tag key={i} onRemove={() => setFruit(fruit.filter((_, j) => j !== i))}>{f}</Tag>
            ))}
          </div>
          <div className="flex gap-2">
            <input
              className="input-atelier"
              placeholder="Enter fruit name…"
              value={fruitInput}
              onChange={(e) => setFruitInput(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && addFruit()}
              data-testid="fruit-input"
            />
            <button onClick={addFruit} className="btn-ink px-5" data-testid="add-fruit"><Plus size={16} /></button>
          </div>
        </Section>

        <Section icon={Coffee} no="iii." title="Morning Snacks" kicker="à la carte · Priced">
          <div className="space-y-2 mb-4">
            {morning.map((s, i) => (
              <div key={i} className="flex items-center justify-between px-4 py-2.5 rounded-[10px]" style={{ background: "var(--paper)", border: "1px solid var(--hairline)" }}>
                <span className="text-[14px]">{s.name}</span>
                <div className="flex items-center gap-3">
                  <span className="font-mono-tab text-[13px]" style={{ color: "var(--emerald)" }}>₹{s.price.toFixed(2)}</span>
                  <button onClick={() => setMorning(morning.filter((_, j) => j !== i))} className="text-[var(--ink-faint)] hover:text-[var(--rust)]" data-testid={`remove-morning-${i}`}>
                    <X size={14} />
                  </button>
                </div>
              </div>
            ))}
          </div>
          <div className="grid grid-cols-[1fr_120px_auto] gap-2">
            <input className="input-atelier" placeholder="Snack name…" value={mName} onChange={(e) => setMName(e.target.value)} data-testid="morning-name" />
            <input className="input-atelier font-mono-tab" placeholder="₹ Price" value={mPrice} onChange={(e) => setMPrice(e.target.value)} data-testid="morning-price" />
            <button onClick={addMorning} className="btn-ink px-4" data-testid="add-morning"><Plus size={16} /></button>
          </div>
        </Section>

        <Section icon={Moon} no="iv." title="Evening Snacks" kicker="à la carte · Priced">
          <div className="space-y-2 mb-4">
            {evening.map((s, i) => (
              <div key={i} className="flex items-center justify-between px-4 py-2.5 rounded-[10px]" style={{ background: "var(--paper)", border: "1px solid var(--hairline)" }}>
                <span className="text-[14px]">{s.name}</span>
                <div className="flex items-center gap-3">
                  <span className="font-mono-tab text-[13px]" style={{ color: "var(--emerald)" }}>₹{s.price.toFixed(2)}</span>
                  <button onClick={() => setEvening(evening.filter((_, j) => j !== i))} className="text-[var(--ink-faint)] hover:text-[var(--rust)]" data-testid={`remove-evening-${i}`}>
                    <X size={14} />
                  </button>
                </div>
              </div>
            ))}
          </div>
          <div className="grid grid-cols-[1fr_120px_auto] gap-2">
            <input className="input-atelier" placeholder="Snack name…" value={eName} onChange={(e) => setEName(e.target.value)} data-testid="evening-name" />
            <input className="input-atelier font-mono-tab" placeholder="₹ Price" value={ePrice} onChange={(e) => setEPrice(e.target.value)} data-testid="evening-price" />
            <button onClick={addEvening} className="btn-ink px-4" data-testid="add-evening"><Plus size={16} /></button>
          </div>
        </Section>
      </div>

      <div className="mt-10 atelier p-6 flex items-center justify-between flex-wrap gap-4" data-testid="save-bar">
        <div>
          <div className="eyebrow">Ready for service</div>
          <div className="font-display text-[20px] mt-1" style={{ fontWeight: 500 }}>
            {food.length + fruit.length + morning.length + evening.length} items composed across 4 chapters
          </div>
        </div>
        <button className="btn-brass flex items-center gap-2" data-testid="save-all">
          <Save size={16} />
          Commit Menu
        </button>
      </div>
    </>
  );
}
