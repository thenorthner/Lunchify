# 🍽️ Lunchify – Smart Lunch & Snack Management App for Employees

> Built with Flutter + Firebase | Developed for SJVN Employees  
> A smart app to manage daily lunch coupons, fruit preferences, menu visibility, and snack orders.

![GitHub last commit](https://img.shields.io/github/last-commit/Ajay0008-cloud/lunchify-app?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Firebase-blueviolet?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Active-success?style=for-the-badge)

---

## 🚀 About the Project

**Lunchify** is a smart, mobile-first application built for managing employee lunch services at corporate or government offices. It enables SJVN employees to:
- Track their monthly lunch coupons
- Choose daily fruit-lunch preferences
- View "Today’s Menu"
- Place snack orders
- Allow Admins to set menus and analyze real-time lunch data via Firebase

This project streamlines food service management using real-time features and a clean UI.

---

## ✨ Features

### 🎫 Employee Features
- 🔐 Secure Login (Employee ID + Department + Password)
- 🍱 View and manage **Lunch Coupons** (used/left)
- 🥭 Submit **Fruit Lunch Preference** before 11 AM
- 📅 View **Today’s Menu**
- 🍟 Place **Snacks Orders** with quantity
- 💬 Submit Feedback

### 🔧 Admin Features
- 🔑 Admin-only Login
- 📋 Set or update **Today's Menu**
- 📊 View **Fruit Lunch Preferences**
- 📥 View **Snack Orders**
- 📈 HR Dashboard for weekly/monthly reports (coming soon)

---

## 🛠️ Tech Stack

### Frontend
- `Flutter`
- `Dart`
- `Google Fonts`
- `fl_chart`

### Backend
- `Firebase Authentication`
- `Cloud Firestore`
- `Firebase Storage`

### Tools
- Android Studio
- Figma (UI Design)
- GitHub Projects (Kanban)

---

## 📸 Screenshots

| Home Screen (Employee) | Today's Menu | Snack Ordering |
|------------------------|--------------|----------------|
| ![Home](screenshots/home.png) | ![Menu](screenshots/menu.png) | ![Snacks](screenshots/snacks.png) |

---

## 🔐 Login Structure

| User Type | Login Requirement | Landing Page |
|-----------|-------------------|--------------|
| Employee  | Employee ID, Dept, Password | Employee Home Page |
| Admin     | Admin Password               | Admin Dashboard     |

---

## ⚙️ How to Run Locally

```bash
git clone https://github.com/Ajay0008-cloud/lunchify-app.git
cd lunchify-app
flutter pub get
flutter run
