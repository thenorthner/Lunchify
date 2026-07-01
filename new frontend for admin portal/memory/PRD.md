# SJVN Lunchify · Atelier Console — PRD

## Problem statement (latest)
> "main aur images deta hu : inko bhi karde waisa hi karde" — User added 3 more HR Admin pages (Billing Management, Employee Transfers, Menu Ratings) to be styled in the same premium bluish editorial language.

## Final design system — "Editorial Blueprint"
- **Palette**: cool ivory bone background, deep navy ink, royal blue (italic accent), sky blue (highlight), brass/sky corner ornaments, SJVN red used sparingly as a "spark" (live dot, lightning in brand mark, danger/destruct).
- **Type**: `Fraunces` display serif (with italics) + `Geist` body sans + `JetBrains Mono` numerals/IDs.
- **Surfaces**: warm `atelier` glass cards, dark `atelier-dark` panels using deep navy gradient with sky-blue borders.
- **Logo**: brand mark redrawn as droplet + lightning spark inside a glass tile (matches the SJVN Lunchify identity).
- **Role toggle**: a segmented "Operations | Governance | HR Review" pill in the top bar swaps the 5 Canteen-Admin tabs, 4 IT-Admin tabs, and 3 HR-Reviewer tabs without leaving the shell.

## All 9 admin screens + Login (built)

**Operations (Canteen Admin)**
1. Menu Management — Specific/Weekly toggle, date override, four atelier sections (Food / Fruit / Morning / Evening) with chip tags and inline add.
2. Scan Reports — 3 stat tiles (latest day / peak / aggregate-navy), sparkline with red peak bar, ledger table with trend bars.
3. Generate Bill — composer with light Coupons tile + dark navy Calculated Total tile, Recent Invoices ledger, Fruit Lunch PDF card.
4. Canteen Orders — sub-tabs (Food / Fruit / Snacks), KPI cards, docket table with Mark Delivered / Cancel actions.
5. Scan History — dark filter bar (search + date + month + clear), list cards with FOOD/FRUIT/SNACK badges.

**Governance (IT Admin) — added previously**
6. Projects & Canteens — navy-headered project cards, architecture-rule banner ("one project · one canteen"), associated-canteen sub-cards with Module ID / Location / Hours / Status, plus New & Sync CTAs.
7. System Feedbacks — triage stats (HIGH/MED/LOW), dark search bar, ticket cards with canteen tag, subject, message, submitter avatar + Respond button.
8. Menu Ratings — canteen + date filter strip with day-avg & total reviews, dark "Top of the day" highlight, sky-blue star rating cards with expandable remarks.
9. Admin Accounts — provisioning form (Employee ID + Verify, Name, Dept, Phone, Password, Assigned Canteen, System Role) with brass-corner ornament; dark "Sentinel" Employee Deactivation panel; Privileged Users list with avatars and Active/Suspended chips.

**HR Review (HR Admin) — NEW**
10. Billing Management — three KPI cards (Total Consolidated · Pending amber · Approved navy), filter strip + search, canteen-generated bills table with PDF / Accept / Review actions.
11. Employee Transfers — Relocate form with target preview, navy "Transfers Audited" counter, amber "Transfer Rules" card, immutable Project Relocation Archives table with From → To project tags and coupon chips.
12. Menu Ratings (HR view) — reuses the IT Menu Ratings component at `/hrratings`.

**Login** — dark navy editorial cover with masthead headline, drift ticker, brand mark; light form side.

## Files
- `frontend/src/index.css` — new blueprint palette, atelier classes, dark surfaces.
- `frontend/src/App.js` — login + 9 routes.
- `frontend/src/components/Brand.jsx` — droplet + lightning spark mark.
- `frontend/src/components/Shell.jsx` — top bar, role toggle, dual-tab nav, footer.
- `frontend/src/components/PageHeader.jsx`
- `frontend/src/lib/mock.js` — full mock data including projects, feedbacks, ratings, admin users + tab groupings.
- `frontend/src/pages/{Login, MenuManagement, ScanReports, GenerateBill, CanteenOrders, ScanHistory}.jsx`
- `frontend/src/pages/{ItProjects, ItFeedbacks, ItMenuRatings, ItAccounts}.jsx`

## Implemented (2026-06-30)
- Full theme swap to bluish editorial (navy / royal blue / sky blue / red-spark).
- 4 new IT-Admin pages designed in the same atelier language.
- Role toggle pill ("Operations" / "Governance") in top bar — switches tab set seamlessly.
- All previously hardcoded warm-tone hex values replaced with cool navy/blue equivalents.
- `data-testid` attributes on every interactive element / informational tile.
- Old 5 pages now also render with new blue palette automatically (variable names re-mapped).

## Next action items (for user)
- Wire `lib/mock.js` records to your existing backend endpoints (replace mock imports with fetches).
- Hook login form's `submit` handler to your auth API.

## Backlog / P1
- Weekly Template editor body in Menu Management.
- Canteen switcher dropdown for IT Admin (currently single-canteen view).
- Server-side pagination, CSV exports, and inline ticket-reply composer.

## Enhancement
Want a per-canteen **"Daily Service Card"** generated as a shareable PDF/IG-story — the day's menu rendered in this editorial blueprint style, branded with SJVN Lunchify? Canteen admins drop it into the company's Slack/Teams every morning, IT admins get aggregated rating digests in their email. It markets the new console internally while quietly improving menu feedback velocity. Happy to add it next.
