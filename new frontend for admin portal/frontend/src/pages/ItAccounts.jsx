import React, { useState } from "react";
import PageHeader from "@/components/PageHeader";
import { PROJECTS, ADMIN_USERS } from "@/lib/mock";
import {
  User, Mail, Phone, Lock, Building2, ShieldCheck, KeyRound,
  Save, Search, UserCheck, UserX, ChevronDown, BadgeCheck, Info
} from "lucide-react";

const Field = ({ icon: Icon, label, required, children, hint }) => (
  <div data-testid={`field-${label.toLowerCase().replace(/\s+/g, "-")}`}>
    <label className="flex items-center gap-2 mb-2">
      <Icon size={13} style={{ color: "var(--ink-muted)" }} />
      <span className="eyebrow">
        {label}
        {required && <span style={{ color: "var(--spark)", marginLeft: 4 }}>*</span>}
      </span>
    </label>
    {children}
    {hint && <div className="text-[11px] mt-1.5" style={{ color: "var(--ink-faint)" }}>{hint}</div>}
  </div>
);

const ROLES = [
  "Employee (View-only / Order)",
  "Canteen Administrator",
  "HR Reviewer",
  "Scanner",
  "IT Administrator",
];

export default function ItAccounts() {
  const [empId, setEmpId] = useState("");
  const [name, setName] = useState("");
  const [dept, setDept] = useState("");
  const [phone, setPhone] = useState("");
  const [pwd, setPwd] = useState("");
  const [assigned, setAssigned] = useState(PROJECTS[0].canteen.name);
  const [role, setRole] = useState(ROLES[0]);
  const [verified, setVerified] = useState(false);
  const [search, setSearch] = useState("");

  const verify = () => setVerified(Boolean(empId.trim()));

  const filtered = ADMIN_USERS.filter((u) =>
    !search || u.id.includes(search) || u.name.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <>
      <PageHeader
        eyebrow="Chapter IX · Stewardship"
        title="User &amp; admin"
        italicTail="account provisioning"
        description="Add new employees or elevate existing users to admin roles — Canteen Admin, HR, IT, or Scanner. Every change is journalled."
        right={
          <div className="chip chip-emerald" data-testid="active-admins-chip">
            <BadgeCheck size={13} />
            {ADMIN_USERS.filter((u) => u.status === "Active").length} active admins
          </div>
        }
      />

      <div className="grid lg:grid-cols-[1.15fr_1fr] gap-6">
        {/* PROVISIONING FORM */}
        <div className="atelier p-7 brass-corner" data-testid="provision-form">
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
              <KeyRound size={20} strokeWidth={1.7} />
            </div>
            <div>
              <div className="eyebrow mb-1" style={{ color: "var(--brass)" }}>Provisioning</div>
              <h3 className="font-display" style={{ fontSize: 26, fontWeight: 500, letterSpacing: "-0.02em" }}>
                Compose an account
              </h3>
              <p className="text-[13px] mt-1" style={{ color: "var(--ink-muted)" }}>
                Verify the employee, set role &amp; canteen, and apply permissions in one stroke.
              </p>
            </div>
          </div>

          <div className="grid sm:grid-cols-2 gap-5">
            <Field icon={User} label="Employee ID" required>
              <div className="flex gap-2">
                <input
                  className="input-atelier flex-1 font-mono-tab"
                  placeholder="e.g. EMP001"
                  value={empId}
                  onChange={(e) => { setEmpId(e.target.value); setVerified(false); }}
                  data-testid="empid-input"
                />
                <button
                  onClick={verify}
                  className={verified ? "btn-brass px-4 text-[12px]" : "btn-ink px-4 text-[12px]"}
                  data-testid="empid-verify"
                >
                  {verified ? "Verified" : "Verify"}
                </button>
              </div>
            </Field>

            <Field icon={Mail} label="Full Name" required>
              <input
                className="input-atelier"
                placeholder="e.g. John Doe"
                value={name}
                onChange={(e) => setName(e.target.value)}
                data-testid="name-input"
              />
            </Field>

            <Field icon={Building2} label="Department" required>
              <input
                className="input-atelier"
                placeholder="e.g. IT, HR, Finance"
                value={dept}
                onChange={(e) => setDept(e.target.value)}
                data-testid="dept-input"
              />
            </Field>

            <Field icon={Phone} label="Phone Number" required>
              <input
                className="input-atelier font-mono-tab"
                placeholder="e.g. 9876543210"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                data-testid="phone-input"
              />
            </Field>

            <Field
              icon={Lock}
              label="Password (optional for existing)"
              hint="Mandatory for new accounts. Leave blank on existing users to keep the old passphrase."
            >
              <input
                type="password"
                className="input-atelier"
                placeholder="Enter password"
                value={pwd}
                onChange={(e) => setPwd(e.target.value)}
                data-testid="pwd-input"
              />
            </Field>

            <Field icon={Building2} label="Assigned Project & Canteen">
              <div className="relative">
                <select
                  className="input-atelier pr-10 appearance-none"
                  value={assigned}
                  onChange={(e) => setAssigned(e.target.value)}
                  data-testid="assigned-select"
                >
                  {PROJECTS.map((p) => <option key={p.id} value={p.canteen.name}>{p.canteen.name}</option>)}
                </select>
                <ChevronDown size={14} className="absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none" style={{ color: "var(--ink-muted)" }} />
              </div>
            </Field>
          </div>

          <div className="mt-5">
            <Field icon={ShieldCheck} label="System Role" required>
              <div className="relative">
                <select
                  className="input-atelier pr-10 appearance-none"
                  value={role}
                  onChange={(e) => setRole(e.target.value)}
                  data-testid="role-select"
                >
                  {ROLES.map((r) => <option key={r}>{r}</option>)}
                </select>
                <ChevronDown size={14} className="absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none" style={{ color: "var(--ink-muted)" }} />
              </div>
            </Field>
          </div>

          <button className="btn-brass w-full mt-7 flex items-center justify-center gap-2" data-testid="save-account">
            <Save size={15} />
            Save Account &amp; Apply Permissions
          </button>

          {/* Info banner */}
          <div
            className="mt-5 p-4 rounded-[10px] flex items-start gap-3"
            style={{
              background: "var(--emerald-soft)",
              border: "1px solid rgba(30,77,214,.22)",
            }}
            data-testid="info-banner"
          >
            <Info size={14} className="mt-0.5" style={{ color: "var(--emerald)" }} />
            <div className="text-[12.5px]" style={{ color: "var(--ink)" }}>
              Ensure the details are correct before saving. Roles &amp; permissions can be updated any time from this very form.
            </div>
          </div>
        </div>

        {/* DEACTIVATION + LIST */}
        <div className="flex flex-col gap-5">
          {/* Dark deactivation panel */}
          <div className="atelier-dark p-6" data-testid="deactivation-panel">
            <div className="flex items-center gap-3">
              <div
                className="grid place-items-center rounded-[12px]"
                style={{ width: 40, height: 40, background: "rgba(226,58,48,.15)", color: "var(--spark)", border: "1px solid rgba(226,58,48,.3)" }}
              >
                <UserX size={18} />
              </div>
              <div>
                <div className="eyebrow" style={{ color: "var(--on-dark-accent)" }}>Sentinel</div>
                <h3 className="font-display" style={{ fontSize: 22, fontWeight: 500 }}>Employee Deactivation</h3>
              </div>
            </div>
            <p className="text-[12.5px] mt-3" style={{ color: "var(--on-dark-muted)" }}>
              Search any employee to suspend or reinstate their account. The action is reversible and audit-logged.
            </p>
            <div className="mt-5 flex gap-2">
              <div className="relative flex-1">
                <Search size={14} className="absolute left-4 top-1/2 -translate-y-1/2" style={{ color: "var(--on-dark-muted)" }} />
                <input
                  className="w-full pl-11 pr-4 py-3 rounded-[10px] outline-none text-[14px] font-mono-tab"
                  placeholder="Enter Employee ID…"
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  data-testid="deactivate-search"
                  style={{
                    background: "rgba(84,189,245,.06)",
                    border: "1px solid rgba(84,189,245,.22)",
                    color: "var(--on-dark)",
                  }}
                />
              </div>
              <button className="btn-spark text-[12.5px]" data-testid="deactivate-search-btn">
                Search
              </button>
            </div>
          </div>

          {/* Admin list */}
          <div className="atelier p-6" data-testid="admin-list">
            <div className="flex items-center justify-between mb-4">
              <div>
                <div className="eyebrow">Privileged users</div>
                <h3 className="font-display text-[22px] mt-1" style={{ fontWeight: 500 }}>Recent accounts</h3>
              </div>
              <span className="chip">{filtered.length} users</span>
            </div>
            <div className="space-y-2">
              {filtered.map((u) => (
                <div
                  key={u.id}
                  className="flex items-center gap-3 p-3 rounded-[10px] lift"
                  style={{ background: "var(--paper)", border: "1px solid var(--hairline)" }}
                  data-testid={`admin-row-${u.id}`}
                >
                  <div
                    className="grid place-items-center rounded-full font-display"
                    style={{
                      width: 36, height: 36,
                      background: u.status === "Active"
                        ? "linear-gradient(140deg, #54bdf5, #1e4dd6)"
                        : "linear-gradient(140deg, #f6c7c3, #d63327)",
                      color: "#fff",
                      fontWeight: 500,
                      fontSize: 13,
                    }}
                  >
                    {u.name.split(" ").map((p) => p[0]).slice(0, 2).join("")}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="text-[14px] truncate" style={{ fontWeight: 500 }}>{u.name}</div>
                    <div className="text-[11px] flex items-center gap-2 truncate" style={{ color: "var(--ink-muted)" }}>
                      <span className="font-mono-tab">{u.id}</span>
                      <span style={{ width: 10, height: 1, background: "var(--hairline-strong)" }} />
                      <span>{u.role}</span>
                      <span style={{ width: 10, height: 1, background: "var(--hairline-strong)" }} />
                      <span className="eyebrow" style={{ fontSize: 9.5 }}>{u.canteen}</span>
                    </div>
                  </div>
                  <span className={`chip ${u.status === "Active" ? "chip-emerald" : "chip-rust"}`}>
                    <span
                      className="inline-block h-1.5 w-1.5 rounded-full"
                      style={{ background: u.status === "Active" ? "var(--emerald)" : "var(--rust)" }}
                    />
                    {u.status}
                  </span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
