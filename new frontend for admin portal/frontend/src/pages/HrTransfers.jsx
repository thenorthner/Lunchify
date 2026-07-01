import React, { useState } from "react";
import PageHeader from "@/components/PageHeader";
import { TRANSFER_LOGS, TARGET_PROJECTS } from "@/lib/mock";
import {
  Users, ArrowRight, ChevronDown, ShieldCheck, BookOpen, MapPin,
  ScrollText, Send, AlertTriangle, History
} from "lucide-react";

export default function HrTransfers() {
  const [empId, setEmpId] = useState("");
  const [target, setTarget] = useState(TARGET_PROJECTS[0]);

  return (
    <>
      <PageHeader
        eyebrow="Chapter XI · Mobility"
        title="Employee project"
        italicTail="transfers"
        description="Relocate an employee to another project location. The system preserves their remaining coupon balance and realigns their active canteen association. Associated Project · 05."
        right={
          <div className="chip" data-testid="audit-badge">
            <BookOpen size={13} />
            <span className="eyebrow">Audit Trail</span>
            <span className="font-mono-tab text-[12px]">{TRANSFER_LOGS.length}</span>
          </div>
        }
      />

      <div className="grid lg:grid-cols-[1.05fr_1fr] gap-6 mb-10">
        {/* Relocate form */}
        <div className="atelier p-7 brass-corner" data-testid="relocate-form">
          <div className="flex items-start gap-4 mb-6">
            <div
              className="grid place-items-center rounded-[12px] shrink-0"
              style={{
                width: 48, height: 48,
                background: "linear-gradient(140deg, #54bdf5, #1e4dd6)",
                color: "#fff",
                boxShadow: "0 10px 24px -12px rgba(30,77,214,.5)",
              }}
            >
              <Users size={20} strokeWidth={1.7} />
            </div>
            <div>
              <div className="eyebrow mb-1" style={{ color: "var(--brass)" }}>Mobility</div>
              <h3 className="font-display" style={{ fontSize: 26, fontWeight: 500, letterSpacing: "-0.02em" }}>
                Relocate an employee
              </h3>
              <p className="text-[13px] mt-1" style={{ color: "var(--ink-muted)" }}>
                Provide the employee&apos;s ID and choose their new project. Coupon ledger reconciles automatically.
              </p>
            </div>
          </div>

          <div className="space-y-5">
            <div data-testid="empid-field">
              <label className="eyebrow flex items-center gap-2 mb-2">
                <Users size={12} style={{ color: "var(--ink-muted)" }} />
                Employee ID
              </label>
              <input
                value={empId}
                onChange={(e) => setEmpId(e.target.value)}
                className="input-atelier font-mono-tab"
                placeholder="e.g. EMP101"
                data-testid="transfer-empid"
              />
            </div>

            <div data-testid="target-field">
              <label className="eyebrow flex items-center gap-2 mb-2">
                <MapPin size={12} style={{ color: "var(--ink-muted)" }} />
                Target Project Location
              </label>
              <div className="relative">
                <select
                  value={target}
                  onChange={(e) => setTarget(e.target.value)}
                  className="input-atelier pr-10 appearance-none"
                  data-testid="transfer-target"
                >
                  {TARGET_PROJECTS.map((p) => <option key={p} value={p}>{p}</option>)}
                </select>
                <ChevronDown
                  size={14}
                  className="absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none"
                  style={{ color: "var(--ink-muted)" }}
                />
              </div>
            </div>

            {/* Visual journey preview */}
            <div
              className="p-4 rounded-[12px] flex items-center gap-3 flex-wrap"
              style={{ background: "var(--paper-2)", border: "1px solid var(--hairline)" }}
              data-testid="journey-preview"
            >
              <div className="flex items-center gap-2 text-[12.5px]" style={{ color: "var(--ink-muted)" }}>
                <span className="eyebrow">From</span>
                <span className="font-mono-tab" style={{ color: "var(--ink)" }}>
                  {empId.trim() || "—"}&apos;s current project
                </span>
              </div>
              <ArrowRight size={14} style={{ color: "var(--brass)" }} />
              <div className="flex items-center gap-2 text-[12.5px]">
                <span className="eyebrow">To</span>
                <span style={{ color: "var(--emerald)", fontWeight: 500 }}>
                  {target}
                </span>
              </div>
            </div>

            <button
              className="btn-brass w-full flex items-center justify-center gap-2"
              data-testid="execute-transfer"
              disabled={!empId.trim()}
            >
              <Send size={15} />
              Execute Project Transfer
            </button>
          </div>
        </div>

        {/* Side: audit stat + rules */}
        <div className="flex flex-col gap-5">
          {/* Audit counter */}
          <div
            className="p-6"
            style={{
              background: "linear-gradient(135deg, var(--navy-2), var(--navy))",
              color: "var(--on-dark)",
              border: "1px solid rgba(84,189,245,.22)",
              borderRadius: 14,
            }}
            data-testid="audit-card"
          >
            <div className="flex items-center justify-between">
              <div className="eyebrow" style={{ color: "var(--on-dark-accent)" }}>Transfers audited</div>
              <div className="grid place-items-center rounded-[10px]"
                style={{ width: 36, height: 36, background: "rgba(84,189,245,.15)", color: "var(--on-dark-accent)" }}>
                <ScrollText size={16} />
              </div>
            </div>
            <div className="font-display tnum mt-5" style={{ fontSize: 60, fontWeight: 400, lineHeight: 1, letterSpacing: "-0.04em" }}>
              {TRANSFER_LOGS.length}
            </div>
            <div className="text-[12px] mt-2" style={{ color: "var(--on-dark-muted)" }}>
              all journalled · immutable · signed
            </div>
          </div>

          {/* Rules */}
          <div
            className="atelier p-6"
            style={{
              background:
                "linear-gradient(180deg, rgba(251,234,203,.55), rgba(251,247,238,.45))",
              borderColor: "rgba(176,122,22,.32)",
            }}
            data-testid="rules-card"
          >
            <div className="flex items-center gap-3 mb-3">
              <div
                className="grid place-items-center rounded-[10px]"
                style={{ width: 36, height: 36, background: "rgba(176,122,22,.18)", color: "#8a6018" }}
              >
                <AlertTriangle size={16} />
              </div>
              <div>
                <div className="eyebrow" style={{ color: "#8a6018" }}>Transfer Rules</div>
                <div className="font-display text-[20px] mt-0.5" style={{ fontWeight: 500 }}>The four canons</div>
              </div>
            </div>
            <ul className="space-y-2.5 text-[13px]" style={{ color: "var(--ink-2)" }}>
              {[
                <><b>1 Project = 1 Canteen</b> mapping is strictly enforced.</>,
                "Coupons automatically deduct/preserve from the prior project balance.",
                "Each transfer log is immutable and archived for audit compliance.",
                "Reversal requires a counter-entry; nothing is mutated retroactively.",
              ].map((line, i) => (
                <li key={i} className="flex items-start gap-2">
                  <span
                    className="mt-2 inline-block"
                    style={{ width: 4, height: 4, borderRadius: 4, background: "#8a6018" }}
                  />
                  <span>{line}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>

      {/* Archive */}
      <div className="atelier overflow-hidden" data-testid="archive">
        <div className="p-5 flex items-center justify-between" style={{ borderBottom: "1px solid var(--hairline)" }}>
          <div className="flex items-center gap-3">
            <div
              className="grid place-items-center rounded-[10px]"
              style={{ width: 36, height: 36, background: "var(--emerald-soft)", color: "var(--emerald)" }}
            >
              <History size={16} />
            </div>
            <div>
              <div className="eyebrow">Project Relocation Archives</div>
              <div className="font-display text-[20px] mt-0.5" style={{ fontWeight: 500 }}>
                Every move, signed and shelved
              </div>
            </div>
          </div>
          <span className="chip">
            <ShieldCheck size={12} />
            Immutable
          </span>
        </div>

        <table className="atelier-table">
          <thead>
            <tr>
              <th>Log</th>
              <th>Employee</th>
              <th>Name</th>
              <th>From</th>
              <th></th>
              <th>To</th>
              <th>Coupons</th>
              <th>Initiated by</th>
              <th>Date &amp; Time</th>
            </tr>
          </thead>
          <tbody>
            {TRANSFER_LOGS.map((t) => (
              <tr key={t.id} data-testid={`log-${t.id}`}>
                <td>
                  <span className="font-display italic" style={{ color: "var(--brass)", fontSize: 14 }}>№</span>
                  <span className="font-mono-tab ml-1.5">{String(t.id).padStart(4, "0")}</span>
                </td>
                <td className="font-mono-tab">{t.emp}</td>
                <td>
                  <span className="text-[14px]" style={{ fontWeight: 500 }}>{t.name}</span>
                </td>
                <td>
                  <span
                    className="px-2.5 py-1 rounded-full text-[11px]"
                    style={{
                      background: "var(--rust-soft)",
                      color: "var(--rust)",
                      border: "1px solid rgba(214,51,39,.25)",
                      letterSpacing: "0.02em",
                    }}
                  >
                    {t.from}
                  </span>
                </td>
                <td style={{ width: 24, padding: "18px 4px" }}>
                  <ArrowRight size={14} style={{ color: "var(--brass)" }} />
                </td>
                <td>
                  <span
                    className="px-2.5 py-1 rounded-full text-[11px]"
                    style={{
                      background: "var(--emerald-soft)",
                      color: "var(--emerald)",
                      border: "1px solid rgba(30,77,214,.25)",
                      letterSpacing: "0.02em",
                    }}
                  >
                    {t.to}
                  </span>
                </td>
                <td>
                  <span className="chip chip-sky" style={{ padding: "4px 10px", fontSize: 12 }}>
                    {t.coupons} coupons
                  </span>
                </td>
                <td className="text-[13px]" style={{ color: "var(--ink-2)" }}>{t.by}</td>
                <td className="font-mono-tab text-[12px]" style={{ color: "var(--ink-muted)" }}>{t.when}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}
