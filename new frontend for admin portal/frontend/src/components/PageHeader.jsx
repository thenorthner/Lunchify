import React from "react";

/**
 * Editorial page header: eyebrow + display-serif title + thin description,
 * with a brass rule and an optional right-side accessory.
 */
export default function PageHeader({
  eyebrow,
  title,
  italicTail,
  description,
  right,
}) {
  return (
    <div className="mb-10" data-testid="page-header">
      <div className="flex items-start justify-between gap-8 flex-wrap">
        <div className="max-w-3xl">
          {eyebrow && (
            <div className="flex items-center gap-3 mb-4">
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
              className="mt-4 text-[15px] leading-relaxed max-w-2xl"
              style={{ color: "var(--ink-muted)" }}
            >
              {description}
            </p>
          )}
        </div>
        {right && <div className="shrink-0">{right}</div>}
      </div>
      <div className="hairline mt-8" />
    </div>
  );
}
