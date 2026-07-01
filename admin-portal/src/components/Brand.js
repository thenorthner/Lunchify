import React from "react";

/**
 * Refined SJVN Lunchify wordmark.
 * Echoes the original mark: blue droplet silhouette + red lightning spark + QR mark.
 */
export default function Brand({ size = "md", on = "light" }) {
  const scale = size === "lg" ? 1.4 : size === "sm" ? 0.82 : 1;
  const ink = on === "dark" ? "var(--on-dark)" : "var(--ink)";
  const muted = on === "dark" ? "var(--on-dark-muted)" : "var(--ink-muted)";

  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }} data-testid="brand">
      <div style={{ lineHeight: 1 }}>
        <div
          style={{
            color: ink,
            fontSize: 22 * scale,
            fontWeight: 500,
            letterSpacing: "-0.03em",
            lineHeight: 1,
            fontFamily: "system-ui, -apple-system, sans-serif"
          }}
        >
          SJVN<span style={{ color: "var(--spark)" }}>.</span>
          <span style={{ fontStyle: "italic", fontWeight: 400, marginLeft: 6, color: "var(--emerald)" }}>
            Lunchify
          </span>
        </div>
        <div
          style={{ 
            marginTop: '6px', 
            display: 'flex', 
            alignItems: 'center', 
            gap: '8px',
            color: muted 
          }}
        >
          <span
            style={{
              fontSize: 9.5 * scale,
              letterSpacing: "0.28em",
              textTransform: "uppercase",
              fontWeight: 500,
            }}
          >
            Atelier Console
          </span>
          <span
            style={{
              width: 18,
              height: 1,
              background: "var(--hairline-strong)",
              display: "inline-block",
            }}
          />
          <span
            style={{
              fontSize: 9.5 * scale,
              letterSpacing: "0.28em",
              textTransform: "uppercase",
              fontWeight: 500,
              color: "var(--brass)",
            }}
          >
            Scan · Redeem · Enjoy
          </span>
        </div>
      </div>
    </div>
  );
}
