import React, { useState } from "react";
import PageHeader from "@/components/PageHeader";
import { PROJECTS } from "@/lib/mock";
import { Building2, Plus, RefreshCw, Trash2, MapPin, Clock, Activity, ChevronRight, ScanLine } from "lucide-react";

const ProjectCard = ({ p }) => (
  <div className="atelier overflow-hidden flex flex-col" data-testid={`project-${p.id}`}>
    {/* Navy header */}
    <div
      className="px-6 pt-6 pb-5 relative overflow-hidden"
      style={{
        background:
          "linear-gradient(140deg, var(--navy) 0%, var(--navy-2) 70%, var(--navy-3) 100%)",
        color: "var(--on-dark)",
      }}
    >
      <div
        className="absolute -right-12 -top-12 opacity-30"
        style={{
          width: 180, height: 180, borderRadius: "50%",
          background: "radial-gradient(circle, rgba(84,189,245,.45), transparent 60%)",
        }}
      />
      <div className="relative">
        <div className="flex items-center gap-2 mb-3">
          <span
            className="px-2 py-0.5 rounded-full text-[9.5px]"
            style={{
              background: "rgba(84,189,245,.18)",
              color: "var(--on-dark-accent)",
              border: "1px solid rgba(84,189,245,.32)",
              letterSpacing: "0.22em",
              fontWeight: 600,
              textTransform: "uppercase",
            }}
          >
            Project · 0{p.id}
          </span>
          {p.short && (
            <span className="font-mono-tab text-[10px]" style={{ color: "var(--on-dark-muted)" }}>
              {p.short}
            </span>
          )}
        </div>
        <h3 className="font-display" style={{ fontSize: 22, fontWeight: 500, lineHeight: 1.12 }}>
          {p.name}
        </h3>
        <div className="flex items-center gap-1.5 mt-2 text-[12px]" style={{ color: "var(--on-dark-muted)" }}>
          <MapPin size={11} />
          <span>{p.location}</span>
        </div>
      </div>
    </div>

    {/* Body */}
    <div className="p-6 flex flex-col flex-1">
      <div className="flex items-center justify-between">
        <div>
          <div className="eyebrow">Project DB ID</div>
          <div className="font-display tnum mt-1" style={{ fontSize: 22, fontWeight: 500 }}>#{p.id}</div>
        </div>
        <button
          className="flex items-center gap-1.5 px-3 py-1.5 rounded-full text-[11.5px]"
          style={{
            background: "var(--spark-soft)",
            color: "var(--spark)",
            border: "1px solid rgba(226,58,48,.3)",
          }}
          data-testid={`delete-${p.id}`}
        >
          <Trash2 size={11} />
          Delete
        </button>
      </div>

      <div className="hairline my-5" />

      {/* Associated canteen */}
      <div className="rounded-[12px] p-4" style={{ background: "var(--paper-2)", border: "1px solid var(--hairline)" }}>
        <div className="eyebrow mb-2" style={{ color: "var(--brass)" }}>Associated Canteen</div>
        <div className="font-display text-[15px] leading-snug" style={{ fontWeight: 500 }}>
          {p.canteen.name}
        </div>
        <div className="mt-4 space-y-2.5 text-[12.5px]">
          <Row icon={ScanLine}  label="Module ID"   value={`#${p.canteen.id}`} mono />
          <Row icon={MapPin}    label="Location"    value={p.canteen.loc} />
          <Row icon={Clock}     label="Hours"       value={p.canteen.hours} mono />
          <Row icon={Activity}  label="Status"      value={p.canteen.status} status />
        </div>
      </div>

      <button
        className="mt-5 flex items-center justify-between px-4 py-2.5 rounded-[10px] text-[13px] hover:bg-[var(--paper-2)] transition"
        style={{ color: "var(--ink)", border: "1px solid var(--hairline)" }}
        data-testid={`view-${p.id}`}
      >
        <span className="font-medium">Inspect module</span>
        <ChevronRight size={14} />
      </button>
    </div>
  </div>
);

const Row = ({ icon: Icon, label, value, mono, status }) => (
  <div className="flex items-center justify-between">
    <span className="flex items-center gap-2" style={{ color: "var(--ink-muted)" }}>
      <Icon size={11} />
      <span className="eyebrow" style={{ fontSize: 9.5, letterSpacing: "0.2em" }}>{label}</span>
    </span>
    <span
      className={mono ? "font-mono-tab" : ""}
      style={{
        color: status ? "var(--emerald)" : "var(--ink)",
        fontWeight: status ? 600 : 500,
        fontSize: 12.5,
      }}
    >
      {status && (
        <span
          className="inline-block h-1.5 w-1.5 rounded-full mr-1.5"
          style={{ background: "var(--emerald)" }}
        />
      )}
      {value}
    </span>
  </div>
);

export default function ItProjects() {
  const [q, setQ] = useState("");
  const list = PROJECTS.filter((p) =>
    !q || p.name.toLowerCase().includes(q.toLowerCase()) || (p.short || "").toLowerCase().includes(q.toLowerCase())
  );

  return (
    <>
      <PageHeader
        eyebrow="Chapter VI · Estate"
        title="Projects across"
        italicTail="the network"
        description="IT Admin's view of isolated projects and their associated food modules. The architecture rule is firm: one project, one canteen."
        right={
          <div className="flex items-center gap-2">
            <button className="btn-ghost flex items-center gap-2 text-[13px]" data-testid="sync-mappings">
              <RefreshCw size={13} />
              Sync Mappings
            </button>
            <button className="btn-ink flex items-center gap-2 text-[13px]" data-testid="new-project">
              <Plus size={14} />
              New Project &amp; Canteen
            </button>
          </div>
        }
      />

      {/* Architecture rule */}
      <div
        className="atelier p-5 mb-8 flex items-start gap-4"
        style={{
          background:
            "linear-gradient(180deg, rgba(224,236,253,.85), rgba(241,246,252,.6))",
          borderColor: "rgba(30,77,214,.22)",
        }}
        data-testid="architecture-rule"
      >
        <div
          className="grid place-items-center rounded-full shrink-0"
          style={{
            width: 36, height: 36,
            background: "var(--emerald)",
            color: "#fff",
          }}
        >
          <Building2 size={16} />
        </div>
        <div className="flex-1">
          <div className="eyebrow mb-1" style={{ color: "var(--emerald)" }}>System Architecture Rule</div>
          <div className="font-display text-[18px]" style={{ fontWeight: 500, letterSpacing: "-0.015em" }}>
            <span style={{ fontStyle: "italic", color: "var(--emerald)" }}>One project</span> · one canteen · isolated menus &amp; orders.
          </div>
          <p className="text-[12.5px] mt-1" style={{ color: "var(--ink-muted)" }}>
            Each project location is strictly mapped to a single food module. Employees only see their own project&#39;s menu and ordering surface.
          </p>
        </div>
      </div>

      {/* Search */}
      <div className="mb-6 flex items-center justify-between">
        <input
          className="input-atelier max-w-md"
          placeholder="Search project or short code…"
          value={q}
          onChange={(e) => setQ(e.target.value)}
          data-testid="project-search"
        />
        <span className="eyebrow">{list.length} project{list.length === 1 ? "" : "s"}</span>
      </div>

      <div className="grid md:grid-cols-2 xl:grid-cols-3 gap-6">
        {list.map((p) => <ProjectCard key={p.id} p={p} />)}
      </div>
    </>
  );
}
