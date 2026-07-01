import React, { useState, useMemo } from "react";
import PageHeader from "@/components/PageHeader";
import { BILL_LEDGER, ADMIN } from "@/lib/mock";
import { Calendar, FileText, Download, Sparkles, ScrollText } from "lucide-react";

export default function GenerateBill() {
  const [rate, setRate] = useState(60);
  const [month, setMonth] = useState("2026-06");
  const coupons = 35;
  const total = useMemo(() => coupons * rate, [rate]);

  return (
    <>
      <PageHeader
        eyebrow="Chapter III · Treasury"
        title="Monthly canteen"
        italicTail="invoicing & reconciliation"
        description={`Canteen ${ADMIN.canteenId} · Administrator Desk. Consolidate coupon counts, set the per-lunch rate, and submit the invoice to Human Resources.`}
        right={
          <div className="chip chip-emerald" data-testid="fy-chip">
            <Sparkles size={13} />
            <span>FY 2026 · Q2</span>
          </div>
        }
      />

      <div className="grid lg:grid-cols-[1.05fr_1fr] gap-6">
        {/* Invoice composer */}
        <div className="atelier p-8 brass-corner" data-testid="invoice-composer">
          <div className="eyebrow mb-2">Consolidate · Monthly Invoice</div>
          <h2 className="font-display text-[34px] leading-tight" style={{ fontWeight: 400 }}>
            Compose the
            <span style={{ fontStyle: "italic", color: "var(--emerald)" }}> June</span> invoice
          </h2>

          <div className="mt-7 grid sm:grid-cols-2 gap-4">
            <div>
              <label className="eyebrow">Billing Month</label>
              <div className="mt-2 relative">
                <Calendar size={14} className="absolute left-4 top-1/2 -translate-y-1/2" style={{ color: "var(--ink-muted)" }} />
                <input
                  type="month"
                  value={month}
                  onChange={(e) => setMonth(e.target.value)}
                  className="input-atelier pl-10 font-mono-tab"
                  data-testid="bill-month"
                />
              </div>
            </div>
            <div>
              <label className="eyebrow">Rate per Lunch Coupon (₹)</label>
              <div className="mt-2 relative">
                <span className="absolute left-4 top-1/2 -translate-y-1/2 font-mono-tab text-[14px]" style={{ color: "var(--ink-muted)" }}>₹</span>
                <input
                  type="number"
                  value={rate}
                  onChange={(e) => setRate(Number(e.target.value) || 0)}
                  className="input-atelier pl-9 font-mono-tab"
                  data-testid="bill-rate"
                />
              </div>
            </div>
          </div>

          <div className="mt-6 grid sm:grid-cols-2 gap-4">
            <div
              className="p-5 rounded-[14px] relative overflow-hidden"
              style={{ background: "var(--emerald-soft)", border: "1px solid rgba(31,90,71,.18)" }}
              data-testid="coupon-tile"
            >
              <div className="eyebrow" style={{ color: "var(--emerald)" }}>Coupons Scanned</div>
              <div className="font-display tnum mt-2" style={{ fontSize: 56, fontWeight: 400, lineHeight: 1, letterSpacing: "-0.04em" }}>{coupons}</div>
              <div className="text-[12px] mt-2" style={{ color: "var(--emerald)" }}>verified entries</div>
            </div>
            <div
              className="p-5 rounded-[14px] relative overflow-hidden"
              style={{
                background: "linear-gradient(135deg, var(--navy-2), var(--navy))",
                color: "var(--on-dark)",
                border: "1px solid rgba(84,189,245,.22)",
              }}
              data-testid="total-tile"
            >
              <div className="eyebrow" style={{ color: "var(--on-dark-accent)" }}>Calculated Total</div>
              <div className="font-display tnum mt-2" style={{ fontSize: 56, fontWeight: 400, lineHeight: 1, letterSpacing: "-0.04em" }}>
                <span style={{ color: "var(--on-dark-accent)", fontSize: 32 }}>₹</span>
                {total.toLocaleString("en-IN")}
              </div>
              <div className="text-[12px] mt-2" style={{ color: "var(--on-dark-muted)" }}>{coupons} × ₹{rate}</div>
            </div>
          </div>

          <button className="btn-ink w-full mt-7 flex items-center justify-center gap-2" data-testid="generate-submit">
            <ScrollText size={16} />
            Generate &amp; Submit Bill to HR
          </button>

          <div className="hairline my-7" />

          <div className="flex items-start gap-5">
            <div className="grid place-items-center shrink-0" style={{ width: 44, height: 44, borderRadius: 12, background: "var(--paper-2)", border: "1px solid var(--hairline-strong)", color: "var(--brass)" }}>
              <FileText size={18} />
            </div>
            <div className="flex-1">
              <div className="font-display text-[18px]" style={{ fontWeight: 500 }}>Fruit Lunch Report</div>
              <p className="text-[13px] mt-1" style={{ color: "var(--ink-muted)" }}>
                Download the current month&#39;s fruit lunch orders for this canteen — a parallel ledger for fruit-only consumers.
              </p>
            </div>
            <button className="btn-brass flex items-center gap-2" data-testid="download-fruit-pdf">
              <Download size={15} />
              PDF
            </button>
          </div>
        </div>

        {/* Ledger */}
        <div className="atelier p-8" data-testid="ledger-card">
          <div className="flex items-start justify-between mb-6">
            <div>
              <div className="eyebrow">Submission Ledger</div>
              <h3 className="font-display text-[26px] mt-1" style={{ fontWeight: 500 }}>Recent invoices</h3>
            </div>
            <span className="chip">All time</span>
          </div>

          <div className="space-y-3">
            {BILL_LEDGER.map((b, i) => {
              const isApproved = b.status === "APPROVED";
              return (
                <div
                  key={i}
                  className="p-5 rounded-[12px] grid grid-cols-[1fr_auto_auto] items-center gap-5 lift"
                  style={{ background: "var(--paper)", border: "1px solid var(--hairline)" }}
                  data-testid={`ledger-${b.month}`}
                >
                  <div>
                    <div className="font-mono-tab text-[12px]" style={{ color: "var(--ink-muted)" }}>{b.month}</div>
                    <div className="font-display text-[22px] mt-0.5" style={{ fontWeight: 500 }}>
                      ₹<span className="tnum">{b.total.toLocaleString("en-IN")}</span>
                    </div>
                    <div className="text-[12px]" style={{ color: "var(--ink-muted)" }}>
                      {b.coupons} coupons × ₹{b.rate}
                    </div>
                  </div>
                  <span className={`chip ${isApproved ? "chip-emerald" : "chip-amber"}`}>
                    <span
                      className="inline-block h-1.5 w-1.5 rounded-full"
                      style={{ background: isApproved ? "var(--emerald)" : "#b07a16" }}
                    />
                    {b.status}
                  </span>
                  <button className="btn-ghost flex items-center gap-1.5 text-[12px]" data-testid={`pdf-${b.month}`}>
                    <Download size={13} />
                    PDF
                  </button>
                </div>
              );
            })}
          </div>

          <div className="hairline my-6" />
          <div className="flex items-center justify-between text-[12px]" style={{ color: "var(--ink-muted)" }}>
            <span className="eyebrow">YTD Settled</span>
            <span className="font-mono-tab">
              ₹{BILL_LEDGER.reduce((a, b) => a + b.total, 0).toLocaleString("en-IN")}
            </span>
          </div>
        </div>
      </div>
    </>
  );
}
