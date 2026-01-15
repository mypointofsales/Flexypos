# Flexypos — POS & Laundry (Flutter Client)

**Tech Stack (this repo):** Flutter (Dart)  
**Backend (separate service):** Node.js/Express • MySQL • Nginx/SSL *(kept in a separate repository / deployment)*  
**Focus:** B2B operations, multi-tenant ready UI, CRUD workflows, sync-ready integration

---

## Overview
Flexypos is a B2B platform for **POS (Retail)** and **Laundry** operations.  
This repository contains the **Flutter client application** (Android/iOS/Web/Desktop). The backend/API and deployment configuration are managed separately.

---

## What’s inside this repository
- Flutter client app (UI + business flows)
- Multi-platform targets: Android, iOS, Web, Windows, macOS, Linux *(depending on your environment)*
- Assets and app resources

---

## Key Capabilities (Client)
- Authentication & tenant-aware navigation *(depends on API integration)*
- CRUD workflows for operational modules (e.g., products/services/customers/orders)
- Prepared for sync-ready patterns (e.g., delta updates / LWW) when connected to backend services

> Note: Backend services (API, database schema, Nginx deployment) are not included in this public repository.

---

## Repository Structure
- `lib/` — main Flutter app source
- `assets/` — images/fonts/resources
- `test/` — unit/widget tests
- `android/`,  `web/`, `windows/` — platform scaffolding

---

## Getting Started (Local)

### Requirements
- Flutter SDK (latest stable recommended)
- Dart (comes with Flutter)
- Android Studio / Xcode (for mobile) or relevant desktop toolchain

### Setup
```bash
flutter pub get
flutter run
