// Mock data shaped exactly like the screenshots; UI is wired against these.
export const ADMIN = {
  name: "Demo Canteen Admin",
  role: "Canteen Administrator",
  canteen: "Corporate Headquarters · CHQ",
  canteenId: "5",
};

export const IT_ADMIN = {
  name: "Demo IT Admin",
  role: "IT Administrator",
  department: "Governance · Systems",
};

export const HR_ADMIN = {
  name: "Demo HR Admin",
  role: "HR Reviewer",
  department: "Human Resources",
};

export const FOOD_MENU = ["Chole", "Dal", "Jeera Rice", "Tandoori Roti"];
export const FRUIT_MENU = ["Tarbooj", "Plum", "Anaar"];
export const SNACKS_MORNING = [
  { name: "Samosa", price: 25 },
  { name: "Masala Chai", price: 15 },
];
export const SNACKS_EVENING = [
  { name: "Pakora Platter", price: 40 },
  { name: "Filter Coffee", price: 20 },
];

export const SCAN_DAILY = [
  { date: "2026-06-30", count: 1 },
  { date: "2026-06-29", count: 2 },
  { date: "2026-06-23", count: 21 },
  { date: "2026-06-11", count: 6 },
  { date: "2026-06-05", count: 3 },
  { date: "2026-06-04", count: 2 },
  { date: "2026-06-03", count: 1 },
  { date: "2026-05-29", count: 2 },
  { date: "2026-05-21", count: 12 },
  { date: "2026-05-19", count: 1 },
  { date: "2026-05-15", count: 2 },
  { date: "2026-05-16", count: 1 },
  { date: "2026-05-13", count: 1 },
];

export const BILL_LEDGER = [
  { month: "2026-06", coupons: 11, rate: 60, total: 660, status: "APPROVED" },
  { month: "2026-05", coupons: 19, rate: 64, total: 1216, status: "SUBMITTED" },
  { month: "2026-04", coupons: 22, rate: 60, total: 1320, status: "APPROVED" },
  { month: "2026-03", coupons: 18, rate: 60, total: 1080, status: "APPROVED" },
];

export const ORDERS = [
  { id: 12, emp: "30609", name: "Kshitij Sharma", date: "6/30/2026", status: "ACCEPTED" },
  { id: 11, emp: "30609", name: "Kshitij Sharma", date: "6/29/2026", status: "ACCEPTED" },
  { id: 10, emp: "30609", name: "Kshitij Sharma", date: "6/29/2026", status: "PENDING" },
  { id: 9,  emp: "30609", name: "Kshitij Sharma", date: "6/29/2026", status: "PENDING" },
  { id: 8,  emp: "30609", name: "Kshitij Sharma", date: "6/29/2026", status: "PENDING" },
  { id: 7,  emp: "30609", name: "Kshitij Sharma", date: "6/29/2026", status: "PENDING" },
  { id: 6,  emp: "30609", name: "Kshitij Sharma", date: "6/25/2026", status: "PENDING" },
  { id: 5,  emp: "30609", name: "Kshitij Sharma", date: "6/25/2026", status: "PENDING" },
  { id: 4,  emp: "21044", name: "Aarav Mehta",    date: "6/24/2026", status: "DELIVERED" },
  { id: 3,  emp: "18230", name: "Riya Kapoor",    date: "6/24/2026", status: "DELIVERED" },
];

export const SCAN_HISTORY = [
  { name: "Kshitij Sharma", id: "30609", kind: "FOOD",  ts: "6/11/2026 08:28 PM" },
  { name: "Kshitij Sharma", id: "30609", kind: "FOOD",  ts: "6/11/2026 08:27 PM" },
  { name: "Kshitij Sharma", id: "30609", kind: "FOOD",  ts: "6/11/2026 10:13 AM" },
  { name: "Aarav Mehta",    id: "21044", kind: "FRUIT", ts: "6/04/2026 03:36 PM" },
  { name: "Riya Kapoor",    id: "18230", kind: "FOOD",  ts: "6/04/2026 03:31 PM" },
  { name: "Vihaan Patel",   id: "30901", kind: "SNACK", ts: "6/03/2026 09:14 AM" },
  { name: "Diya Iyer",      id: "20155", kind: "FOOD",  ts: "6/03/2026 12:46 PM" },
];

/* ---------- IT Admin / Governance mock ---------- */

export const PROJECTS = [
  {
    id: 1,
    name: "Corporate Headquarters (CHQ)",
    location: "Shimla",
    canteen: { id: 1, name: "Corporate Headquarters (CHQ) Canteen", loc: "Shimla", hours: "09:00 – 18:00", status: "Active" },
  },
  {
    id: 2,
    name: "Nathpa Jhakri Hydro Power Station",
    short: "NJHPS",
    location: "Jhakri, Nathpa",
    canteen: { id: 2, name: "Nathpa Jhakri (NJHPS) Canteen", loc: "Jhakri, Nathpa", hours: "09:00 – 18:00", status: "Active" },
  },
  {
    id: 3,
    name: "Buxar Thermal Power Project",
    short: "BTPP",
    location: "Buxar, Chausha",
    canteen: { id: 3, name: "Buxar Thermal (BTPP) Canteen", loc: "Buxar, Chausha", hours: "09:00 – 18:00", status: "Active" },
  },
  {
    id: 4,
    name: "Naitwar Mori Hydro Electric Project",
    short: "NMHEP",
    location: "Mori",
    canteen: { id: 4, name: "Naitwar Mori (NMHEP) Canteen", loc: "Mori", hours: "09:00 – 18:00", status: "Active" },
  },
  {
    id: 5,
    name: "Sunni Dam Hydro Electric Project",
    location: "Sunni",
    canteen: { id: 5, name: "Sunni Dam Canteen", loc: "Sunni", hours: "09:00 – 18:00", status: "Active" },
  },
];

export const FEEDBACKS = [
  {
    canteen: "Corporate Headquarters (CHQ) Canteen",
    when: "6/23/2026 · 6:12 PM",
    subject: "QR Code Not Working",
    message: "QR code intermittently fails to scan during peak lunch hours. Camera focuses but no payload is read.",
    by: { name: "Nikhil Sharma", id: "30210", dept: "IT" },
    priority: "HIGH",
  },
  {
    canteen: "Corporate Headquarters (CHQ) Canteen",
    when: "6/02/2026 · 1:41 PM",
    subject: "hello",
    message: "hello, just trying out the feedback widget.",
    by: { name: "Kshitij Sharma", id: "30609", dept: "IT" },
    priority: "LOW",
  },
  {
    canteen: "Nathpa Jhakri (NJHPS) Canteen",
    when: "5/28/2026 · 11:08 AM",
    subject: "Need vegan option flag on menu",
    message: "Could the daily menu indicate vegan vs. veg vs. non-veg with small markers? Helpful for dietary planning.",
    by: { name: "Riya Kapoor", id: "18230", dept: "Finance" },
    priority: "MEDIUM",
  },
];

export const MENU_RATINGS = [
  { name: "Plum",       category: "Fruit", rating: 3.0, reviews: 1, remarks: [{ by: "Aarav", text: "Plums were slightly under-ripe today." }] },
  { name: "Tarbooj",    category: "Fruit", rating: 5.0, reviews: 1, remarks: [{ by: "Diya",  text: "Perfectly chilled and sweet — thank you!" }] },
  { name: "Chole",      category: "Food",  rating: 4.5, reviews: 12, remarks: [{ by: "Kshitij", text: "Spice level was just right today." }] },
  { name: "Dal",        category: "Food",  rating: 4.2, reviews: 9,  remarks: [{ by: "Vihaan", text: "Could use a touch more tadka." }] },
  { name: "Jeera Rice", category: "Food",  rating: 4.7, reviews: 14, remarks: [{ by: "Riya", text: "Fragrant and fluffy. Loved it." }] },
];

export const ADMIN_USERS = [
  { id: "30609", name: "Kshitij Sharma", role: "Canteen Admin", canteen: "CHQ",    status: "Active" },
  { id: "30210", name: "Nikhil Sharma",  role: "IT Admin",      canteen: "—",     status: "Active" },
  { id: "21044", name: "Aarav Mehta",    role: "Employee",      canteen: "NJHPS", status: "Active" },
  { id: "18230", name: "Riya Kapoor",    role: "HR Reviewer",   canteen: "—",     status: "Active" },
  { id: "30901", name: "Vihaan Patel",   role: "Scanner",       canteen: "BTPP",  status: "Suspended" },
];

/* ---------- Tabs (grouped by role) ---------- */

export const OPS_TABS = [
  { key: "menu",    label: "Menu Management", num: "01" },
  { key: "reports", label: "Scan Reports",    num: "02" },
  { key: "bill",    label: "Generate Bill",   num: "03" },
  { key: "orders",  label: "Canteen Orders",  num: "04" },
  { key: "history", label: "Scan History",    num: "05" },
];

export const GOV_TABS = [
  { key: "projects",  label: "Projects & Canteens", num: "01" },
  { key: "feedbacks", label: "System Feedbacks",    num: "02" },
  { key: "ratings",   label: "Menu Ratings",        num: "03" },
  { key: "accounts",  label: "Admin Accounts",      num: "04" },
];

export const HR_TABS = [
  { key: "billing",    label: "Billing Management", num: "01" },
  { key: "transfers",  label: "Employee Transfers", num: "02" },
  { key: "hrratings",  label: "Menu Ratings",       num: "03" },
];

export const OPS_KEYS = OPS_TABS.map((t) => t.key);
export const GOV_KEYS = GOV_TABS.map((t) => t.key);
export const HR_KEYS  = HR_TABS.map((t) => t.key);

/* HR-only mocks */
export const BILLS_FOR_HR = [
  { id: 10, canteen: "Corporate Headquarters (CHQ) Canteen", month: "2026-06", coupons: 11, rate: 60, total: 660,  status: "APPROVED", comments: "—" },
  { id: 7,  canteen: "Corporate Headquarters (CHQ) Canteen", month: "2026-05", coupons: 19, rate: 64, total: 1216, status: "SUBMITTED", comments: "Awaiting HR" },
  { id: 6,  canteen: "Nathpa Jhakri (NJHPS) Canteen",        month: "2026-05", coupons: 28, rate: 60, total: 1680, status: "APPROVED", comments: "—" },
  { id: 5,  canteen: "Buxar Thermal (BTPP) Canteen",         month: "2026-05", coupons: 17, rate: 60, total: 1020, status: "SUBMITTED", comments: "Rate dispute" },
  { id: 4,  canteen: "Naitwar Mori (NMHEP) Canteen",         month: "2026-04", coupons: 22, rate: 60, total: 1320, status: "REJECTED", comments: "Resubmit with corrections" },
  { id: 3,  canteen: "Sunni Dam Canteen",                    month: "2026-04", coupons: 15, rate: 60, total: 900,  status: "APPROVED", comments: "—" },
];

export const TRANSFER_LOGS = [
  { id: 5, emp: "30612", name: "Ankit Sharma", from: "Bikaner Solar Project & Others (SGEL)", to: "Corporate Headquarters (CHQ)", coupons: 13, by: "Demo HR Admin", when: "6/22/2026 · 6:09 PM" },
  { id: 4, emp: "30612", name: "Ankit Sharma", from: "Corporate Headquarters (CHQ)", to: "Bikaner Solar Project & Others (SGEL)", coupons: 13, by: "Demo HR Admin", when: "6/19/2026 · 12:04 PM" },
  { id: 3, emp: "EMP001", name: "Demo Employee", from: "Corporate Headquarters (CHQ)", to: "Corporate Headquarters (CHQ)", coupons: 12, by: "Demo HR Admin", when: "5/21/2026 · 1:08 PM" },
  { id: 2, emp: "20155", name: "Diya Iyer",     from: "Naitwar Mori (NMHEP)", to: "Sunni Dam Hydro Electric Project", coupons: 8,  by: "Demo HR Admin", when: "5/12/2026 · 9:42 AM" },
  { id: 1, emp: "18230", name: "Riya Kapoor",   from: "Buxar Thermal (BTPP)", to: "Corporate Headquarters (CHQ)", coupons: 5,  by: "Demo HR Admin", when: "5/03/2026 · 4:18 PM" },
];

export const TARGET_PROJECTS = [
  ...PROJECTS.map((p) => p.canteen.name),
  "Arun-3 Hydro Electric Project (Nepal Sites)",
  "Bikaner Solar Project & Others (SGEL)",
];

/* Legacy export still used by Shell (will pick by role) */
export const TABS = OPS_TABS;
