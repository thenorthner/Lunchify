import React from "react";

export default function PageHeader({
  eyebrow,
  title,
  italicTail,
  description,
  right,
}) {
  return (
    <div style={{ marginBottom: "40px" }} data-testid="page-header">
      <div style={{ display: "flex", alignItems: "flex-start", justifyContent: "space-between", gap: "32px", flexWrap: "wrap" }}>
        <div style={{ maxWidth: "768px", textAlign: "left" }}>
          {eyebrow && (
            <div style={{ display: "flex", alignItems: "center", gap: "12px", marginBottom: "16px" }}>
              <span
                style={{
                  width: 26,
                  height: 1,
                  background: "var(--brass)",
                  display: "inline-block",
                }}
              />
              <span className="eyebrow" style={{ color: "var(--brass)" }}>
                {eyebrow}
              </span>
            </div>
          )}
          <h1
            className="font-display"
            style={{
              fontSize: "clamp(40px, 5vw, 64px)",
              lineHeight: 1.02,
              fontWeight: 400,
              color: "var(--ink)",
              margin: 0
            }}
            data-testid="page-title"
          >
            {title}
            {italicTail && (
              <span
                className="font-display"
                style={{
                  fontStyle: "italic",
                  fontWeight: 300,
                  color: "var(--emerald)",
                }}
              >
                {" "}
                {italicTail}
              </span>
            )}
          </h1>
          {description && (
            <p
              style={{
                marginTop: "16px",
                fontSize: "15px",
                lineHeight: 1.6,
                maxWidth: "672px",
                color: "var(--ink-muted)",
              }}
              data-testid="page-description"
            >
              {description}
            </p>
          )}
        </div>
        {right && (
          <div style={{ flexShrink: 0, marginTop: "8px" }}>{right}</div>
        )}
      </div>
      <div
        style={{
          width: "100%",
          height: 1,
          background: "linear-gradient(90deg, var(--hairline-strong) 0%, transparent 100%)",
          marginTop: "40px",
          opacity: 0.6,
        }}
      />
    </div>
  );
}
