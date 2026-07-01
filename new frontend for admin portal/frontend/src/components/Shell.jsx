import React from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import { LogOut, User2, Cog, ShieldCheck, Briefcase } from "lucide-react";
import Brand from "./Brand";
import {
  OPS_TABS, GOV_TABS, HR_TABS,
  OPS_KEYS, GOV_KEYS, HR_KEYS,
  ADMIN, IT_ADMIN, HR_ADMIN,
} from "@/lib/mock";

export default function Shell({ children }) {
  const location = useLocation();
  const navigate = useNavigate();
  const active = location.pathname.replace("/", "") || "menu";

  const isGov = GOV_KEYS.includes(active);
  const isHr  = HR_KEYS.includes(active);
  const role  = isGov ? "gov" : isHr ? "hr" : "ops";

  const tabs   = isGov ? GOV_TABS : isHr ? HR_TABS : OPS_TABS;
  const person = isGov ? IT_ADMIN : isHr ? HR_ADMIN : ADMIN;
  const groupLabel = isGov ? "Governance" : isHr ? "HR Review" : "Operations";

  const switchRole = (target) => {
    if (target === role) return;
    if (target === "gov") navigate("/projects");
    if (target === "hr")  navigate("/billing");
    if (target === "ops") navigate("/menu");
  };

  return (
    <div className="min-h-screen w-full">
      {/* TOP BAR */}
      <header
        className="sticky top-0 z-30"
        style={{
          backdropFilter: "blur(14px) saturate(120%)",
          WebkitBackdropFilter: "blur(14px) saturate(120%)",
          background:
            "linear-gradient(180deg, rgba(238,243,251,0.88), rgba(238,243,251,0.68))",
          borderBottom: "1px solid var(--hairline)",
        }}
        data-testid="top-bar"
      >
        <div className="mx-auto max-w-[1400px] px-8 py-5 flex items-center justify-between gap-4">
          <Link to={isGov ? "/projects" : isHr ? "/billing" : "/menu"} data-testid="brand-link">
            <Brand />
          </Link>

          <div className="flex items-center gap-3">
            {/* Role segmented toggle */}
            <div
              className="hidden md:flex items-center p-1 rounded-full"
              style={{
                background: "var(--paper)",
                border: "1px solid var(--hairline-strong)",
              }}
              data-testid="role-toggle"
            >
              {[
                { k: "ops", label: "Operations", icon: Cog },
                { k: "gov", label: "Governance", icon: ShieldCheck },
                { k: "hr",  label: "HR Review",  icon: Briefcase },
              ].map((r) => {
                const on = r.k === role;
                return (
                  <button
                    key={r.k}
                    onClick={() => switchRole(r.k)}
                    data-active={on}
                    data-testid={`role-${r.k}`}
                    className="flex items-center gap-2 px-3.5 py-1.5 rounded-full text-[12px] font-medium transition-all"
                    style={{
                      background: on ? "var(--ink)" : "transparent",
                      color: on ? "var(--paper)" : "var(--ink-muted)",
                    }}
                  >
                    <r.icon size={12} />
                    {r.label}
                  </button>
                );
              })}
            </div>

            <div
              className="flex items-center gap-3 pl-2 pr-1 py-1 rounded-full"
              style={{
                background: "rgba(255,255,255,0.7)",
                border: "1px solid var(--hairline-strong)",
              }}
              data-testid="user-chip"
            >
              <div
                className="grid place-items-center rounded-full"
                style={{
                  width: 32,
                  height: 32,
                  background:
                    "linear-gradient(140deg, #54bdf5, #1e4dd6)",
                  color: "#ffffff",
                }}
              >
                <User2 size={16} strokeWidth={1.8} />
              </div>
              <div className="leading-tight pr-3">
                <div
                  className="text-[13px] font-medium"
                  style={{ color: "var(--ink)" }}
                >
                  {person.name}
                </div>
                <div
                  className="text-[10px]"
                  style={{
                    letterSpacing: "0.22em",
                    color: "var(--ink-muted)",
                    textTransform: "uppercase",
                  }}
                >
                  {person.role}
                </div>
              </div>
            </div>

            <button
              onClick={() => navigate("/login")}
              data-testid="logout-btn"
              className="btn-ghost flex items-center gap-2 text-[13px]"
            >
              <LogOut size={14} />
              Sign out
            </button>
          </div>
        </div>

        {/* TABS */}
        <nav
          className="mx-auto max-w-[1400px] px-8 flex items-center gap-8 overflow-x-auto"
          style={{ borderTop: "1px solid var(--hairline)" }}
          data-testid="tabs-nav"
        >
          <span
            className="eyebrow shrink-0"
            style={{ color: "var(--brass)", paddingBlock: 18 }}
            data-testid="tabs-section-label"
          >
            {groupLabel}
          </span>
          <span
            className="shrink-0"
            style={{ width: 16, height: 1, background: "var(--hairline-strong)" }}
          />
          {tabs.map((t) => (
            <Link
              key={t.key}
              to={`/${t.key}`}
              data-active={active === t.key}
              data-testid={`tab-${t.key}`}
              className="atelier-tab shrink-0"
            >
              <span className="tab-num">{t.num}</span>
              <span>{t.label}</span>
            </Link>
          ))}
          <div className="ml-auto py-4 hidden lg:block shrink-0">
            <span className="eyebrow">Session</span>{" "}
            <span
              className="font-mono-tab text-[12px] ml-2"
              style={{ color: "var(--ink-muted)" }}
            >
              {new Date().toLocaleDateString("en-GB", {
                day: "2-digit",
                month: "short",
                year: "numeric",
              })}
            </span>
          </div>
        </nav>
      </header>

      <main
        className="mx-auto max-w-[1400px] px-8 py-12 rise"
        data-testid="main-content"
      >
        {children}
      </main>

      <footer
        className="mx-auto max-w-[1400px] px-8 pb-12 pt-4 flex items-center justify-between"
        style={{ color: "var(--ink-muted)" }}
        data-testid="footer"
      >
        <div className="eyebrow">SJVN Lunchify · Atelier Console</div>
        <div className="flex items-center gap-6">
          <span className="font-mono-tab text-[11px]">v 4.2 · MMXXVI</span>
          <span
            style={{
              width: 24,
              height: 1,
              background: "var(--hairline-strong)",
            }}
          />
          <span
            className="eyebrow"
            style={{ color: "var(--brass)" }}
          >
            Scan · Redeem · Enjoy
          </span>
        </div>
      </footer>
    </div>
  );
}
