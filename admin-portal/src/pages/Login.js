import React, { useState } from "react";
import "./Login.css";
import api from "../services/api";
import Brand from "../components/Brand";
import ArrowForwardIcon from "@mui/icons-material/ArrowForward";
import VisibilityIcon from "@mui/icons-material/Visibility";
import VisibilityOffIcon from "@mui/icons-material/VisibilityOff";
import VerifiedUserIcon from "@mui/icons-material/VerifiedUser";

const TICKER = [
  "Specific Date · Weekly Template · Mains · Fruit · Snacks ",
  "Coupons Scanned · Verified · Reconciled · Submitted to HR ",
  "Service No. 21 · CHQ Canteen · Atelier of Mindful Dining ",
  "Canteen Orders · Accepted · Delivered · Composed with Care ",
];

export default function Login() {
  const [employeeId, setEmployeeId] = useState("");
  const [password, setPassword] = useState("");
  const [show, setShow] = useState(false);

  const handleLogin = async (e) => {
    e.preventDefault();

    try {
      const res = await api.post("/auth/admin/login", {
        employeeId: employeeId.trim(),
        password,
      });

      if (!res.data.success && !res.data.token) throw new Error();

      // 🔥 hard redirect — stops refresh loop
      window.location.replace("/dashboard");
    } catch (err) {
      alert("Invalid credentials");
    }
  };

  return (
    <div className="login-wrapper">
      {/* LEFT — editorial cover */}
      <div className="login-cover" data-testid="login-cover">
        {/* Glow grain */}
        <div className="login-cover-glow" />
        
        {/* Cover frame */}
        <div className="login-z-10">
          <Brand on="dark" />
        </div>

        <div className="login-z-10 login-hero-container">
          <h1 className="login-heading font-display">
            Every meal.
            <br />
            <span style={{ fontStyle: "italic", fontWeight: 300, color: "var(--on-dark-accent)" }}>Every coupon.</span>
            <br />
            One platform.
          </h1>
          <p className="login-subtext">
            A unified system for managing canteen operations across the organization.
          </p>

          <div className="hairline my-9" style={{ margin: "36px 0", background: "linear-gradient(90deg, transparent, rgba(84,189,245,.5), transparent)" }} />

          <div className="login-stats-grid">
            {["ONBOARD", "MANAGE", "MONITOR"].map((label, i) => (
              <div key={i} data-testid={`cover-stat-${i}`}>
                <div className="eyebrow" style={{ color: "var(--on-dark)", fontSize: 14, letterSpacing: "0.15em" }}>
                  {label}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Ticker */}
        <div className="login-z-10 login-ticker-container">
          <div className="drift">
            {[...TICKER, ...TICKER].map((t, i) => (
              <span key={i} className="eyebrow" style={{ color: "var(--on-dark-accent)", letterSpacing: "0.3em" }}>
                ✦ {t}
              </span>
            ))}
          </div>
        </div>
      </div>

      {/* RIGHT — form */}
      <div className="login-form-side" data-testid="login-form-side">
        <div className="login-form-container">
          <div className="eyebrow" style={{ marginBottom: 16, color: "var(--brass)" }}>Members&#39; Entrance</div>
          <h2 className="login-form-heading font-display">
            Sign in to the
            <span style={{ fontStyle: "italic", color: "var(--emerald)" }}> console</span>.
          </h2>
          <p className="login-form-subtext">
            Authorised canteen administrators only. Each session is signed and recorded.
          </p>

          <form onSubmit={handleLogin} className="login-form" data-testid="login-form">
            <div>
              <label htmlFor="employeeId" className="eyebrow">Administrator ID</label>
              <input
                id="employeeId"
                type="text"
                value={employeeId}
                onChange={(e) => setEmployeeId(e.target.value)}
                placeholder="e.g. IT001"
                className="input-atelier"
                data-testid="login-email"
                required
              />
            </div>
            <div>
              <label htmlFor="password" className="eyebrow">Passphrase</label>
              <div style={{ position: 'relative', marginTop: 8 }}>
                <input
                  id="password"
                  type={show ? "text" : "password"}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  className="input-atelier"
                  style={{ paddingRight: 48 }}
                  data-testid="login-password"
                  required
                />
                <button
                  type="button"
                  onClick={() => setShow(!show)}
                  style={{ 
                    position: 'absolute', 
                    right: 12, 
                    top: '50%', 
                    transform: 'translateY(-50%)', 
                    color: "var(--ink-muted)",
                    background: 'none',
                    border: 'none',
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    padding: 0
                  }}
                  data-testid="toggle-password"
                >
                  {show ? <VisibilityOffIcon sx={{ fontSize: 20 }} /> : <VisibilityIcon sx={{ fontSize: 20 }} />}
                </button>
              </div>
            </div>

            <button
              type="submit"
              className="btn-ink"
              style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8, marginTop: 16 }}
              data-testid="login-submit"
            >
              Enter the Console
              <ArrowForwardIcon sx={{ fontSize: 18 }} />
            </button>
          </form>

          <div className="hairline" style={{ margin: "36px 0", background: "var(--hairline-strong)" }} />

          <div className="login-footer-info">
            <VerifiedUserIcon sx={{ fontSize: 16, color: "var(--emerald)" }} />
            <span>Secured with SJVN&#39;s enterprise SSO · session expires at sundown.</span>
          </div>

          <div className="login-footer-bottom">
            <span className="eyebrow">© MMXXVI · SJVN Lunchify</span>
            <span className="font-mono-tab">build · atelier.4.2</span>
          </div>
        </div>
      </div>
    </div>
  );
}
