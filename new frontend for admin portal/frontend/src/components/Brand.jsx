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
    <div className="flex items-center gap-3" data-testid="brand">
      {/* Glass mark with droplet + lightning */}
      <div
        className="relative grid place-items-center rounded-[12px] overflow-hidden"
        style={{
          width: 42 * scale,
          height: 42 * scale,
          background:
            "linear-gradient(150deg, #ffffff 0%, #eaf4ff 60%, #d6e8fb 100%)",
          border: "1px solid rgba(30, 77, 214, 0.25)",
          boxShadow:
            "inset 0 1px 0 rgba(255,255,255,.9), 0 8px 20px -12px rgba(30,77,214,.55)",
        }}
      >
        {/* Droplet ring */}
        <svg
          width={26 * scale}
          height={26 * scale}
          viewBox="0 0 32 32"
          fill="none"
        >
          {/* Outer circle (sky) */}
          <circle cx="16" cy="16" r="13" stroke="#2da4e8" strokeWidth="1.6" />
          {/* Droplet */}
          <path
            d="M16 5 C 11 12, 9 16, 11 21 C 12.5 25, 19.5 25, 21 21 C 23 16, 21 12, 16 5 Z"
            stroke="#1e4dd6"
            strokeWidth="1.6"
            strokeLinejoin="round"
          />
          {/* Lightning spark */}
          <path
            d="M16.5 10 L 13.5 17 L 16 17 L 14.5 23 L 19 15 L 16.5 15 L 18 10 Z"
            fill="#e23a30"
            className="spark-pulse"
          />
        </svg>
      </div>

      <div className="leading-none">
        <div
          className="font-display"
          style={{
            color: ink,
            fontSize: 22 * scale,
            fontWeight: 500,
            letterSpacing: "-0.03em",
            lineHeight: 1,
          }}
        >
          SJVN<span style={{ color: "var(--spark)" }}>.</span>
          <span style={{ fontStyle: "italic", fontWeight: 400, marginLeft: 6, color: "var(--emerald)" }}>
            Lunchify
          </span>
        </div>
        <div
          className="mt-1.5 flex items-center gap-2"
          style={{ color: muted }}
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
