import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import Brand from "@/components/Brand";
import { ArrowRight, Eye, EyeOff, ShieldCheck } from "lucide-react";

const TICKER = [
  "Specific Date · Weekly Template · Mains · Fruit · Snacks ",
  "Coupons Scanned · Verified · Reconciled · Submitted to HR ",
  "Service No. 21 · CHQ Canteen · Atelier of Mindful Dining ",
  "Canteen Orders · Accepted · Delivered · Composed with Care ",
];

export default function Login() {
  const navigate = useNavigate();
  const [show, setShow] = useState(false);
  const [email, setEmail] = useState("");
  const [pwd, setPwd] = useState("");

  const submit = (e) => {
    e.preventDefault();
    navigate("/menu");
  };

  return (
    <div className="min-h-screen w-full grid lg:grid-cols-[1.1fr_1fr]">
      {/* LEFT — editorial cover */}
      <div
        className="relative px-10 py-10 lg:px-14 lg:py-14 flex flex-col justify-between overflow-hidden"
        style={{
          background:
            "linear-gradient(165deg, #06122e 0%, #0c1d44 55%, #14275a 100%)",
          color: "var(--on-dark)",
        }}
        data-testid="login-cover"
      >
        {/* Glow grain */}
        <div
          className="absolute inset-0 opacity-60"
          style={{
            backgroundImage:
              "radial-gradient(800px 400px at 20% 10%, rgba(84,189,245,.22), transparent 60%), radial-gradient(700px 400px at 90% 90%, rgba(30,77,214,.30), transparent 60%), radial-gradient(400px 240px at 75% 30%, rgba(226,58,48,.10), transparent 60%)",
            pointerEvents: "none",
          }}
        />
        {/* Cover frame */}
        <div className="relative z-10">
          <Brand on="dark" />
        </div>

        <div className="relative z-10 my-12 lg:my-0">
          <div className="flex items-center gap-3 mb-6">
            <span style={{ width: 26, height: 1, background: "var(--on-dark-accent)" }} />
            <span className="eyebrow" style={{ color: "var(--on-dark-accent)" }}>Vol. IV · No. 26</span>
          </div>
          <h1
            className="font-display"
            style={{
              fontSize: "clamp(48px, 6vw, 86px)",
              lineHeight: 0.98,
              fontWeight: 400,
              letterSpacing: "-0.035em",
            }}
          >
            The art of
            <br />
            <span style={{ fontStyle: "italic", fontWeight: 300, color: "var(--on-dark-accent)" }}>mindful canteen</span>
            <br />
            administration.
          </h1>
          <p className="mt-7 max-w-md text-[15px] leading-relaxed" style={{ color: "#aeb9d3" }}>
            A console crafted for the ones who tend to lunch with the rigour of a Michelin pass — where menus, coupons and ledgers find their quiet equilibrium.
          </p>

          <div className="hairline my-9" style={{ background: "linear-gradient(90deg, transparent, rgba(84,189,245,.5), transparent)" }} />

          <div className="grid grid-cols-3 gap-6 max-w-md">
            {[
              { v: "5", l: "Canteens" },
              { v: "1,284", l: "Coupons / mo" },
              { v: "₹76k", l: "Settled" },
            ].map((s, i) => (
              <div key={i} data-testid={`cover-stat-${i}`}>
                <div className="font-display tnum" style={{ fontSize: 32, fontWeight: 400, color: "var(--on-dark)" }}>{s.v}</div>
                <div className="eyebrow mt-1" style={{ color: "var(--on-dark-muted)" }}>{s.l}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Ticker */}
        <div className="relative z-10 overflow-hidden" style={{ borderTop: "1px solid rgba(84,189,245,.22)", paddingTop: 16 }}>
          <div className="flex gap-12 drift whitespace-nowrap" style={{ width: "fit-content" }}>
            {[...TICKER, ...TICKER].map((t, i) => (
              <span key={i} className="eyebrow" style={{ color: "var(--on-dark-accent)", letterSpacing: "0.3em" }}>
                ✦ {t}
              </span>
            ))}
          </div>
        </div>
      </div>

      {/* RIGHT — form */}
      <div className="relative px-8 py-12 lg:px-16 lg:py-20 flex flex-col justify-center" data-testid="login-form-side">
        <div className="max-w-md w-full mx-auto">
          <div className="eyebrow mb-4" style={{ color: "var(--brass)" }}>Members&#39; Entrance</div>
          <h2 className="font-display" style={{ fontSize: 44, fontWeight: 400, lineHeight: 1.05 }}>
            Sign in to the
            <span style={{ fontStyle: "italic", color: "var(--emerald)" }}> console</span>.
          </h2>
          <p className="mt-3 text-[14px]" style={{ color: "var(--ink-muted)" }}>
            Authorised canteen administrators only. Each session is signed and recorded.
          </p>

          <form onSubmit={submit} className="mt-9 space-y-5" data-testid="login-form">
            <div>
              <label className="eyebrow">Administrator ID</label>
              <input
                type="text"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="e.g. canteen.admin@sjvn"
                className="input-atelier mt-2"
                data-testid="login-email"
                required
              />
            </div>
            <div>
              <label className="eyebrow">Passphrase</label>
              <div className="mt-2 relative">
                <input
                  type={show ? "text" : "password"}
                  value={pwd}
                  onChange={(e) => setPwd(e.target.value)}
                  placeholder="••••••••"
                  className="input-atelier pr-12"
                  data-testid="login-password"
                  required
                />
                <button
                  type="button"
                  onClick={() => setShow(!show)}
                  className="absolute right-3 top-1/2 -translate-y-1/2"
                  style={{ color: "var(--ink-muted)" }}
                  data-testid="toggle-password"
                >
                  {show ? <EyeOff size={16} /> : <Eye size={16} />}
                </button>
              </div>
            </div>

            <button
              type="submit"
              className="btn-ink w-full flex items-center justify-center gap-2"
              data-testid="login-submit"
            >
              Enter the Console
              <ArrowRight size={16} />
            </button>
          </form>

          <div className="hairline my-9" />

          <div className="flex items-center gap-3 text-[12px]" style={{ color: "var(--ink-muted)" }}>
            <ShieldCheck size={14} style={{ color: "var(--emerald)" }} />
            <span>Secured with SJVN&#39;s enterprise SSO · session expires at sundown.</span>
          </div>

          <div className="mt-10 flex items-center justify-between text-[11px]" style={{ color: "var(--ink-faint)" }}>
            <span className="eyebrow">© MMXXVI · SJVN Lunchify</span>
            <span className="font-mono-tab">build · atelier.4.2</span>
          </div>
        </div>
      </div>
    </div>
  );
}
