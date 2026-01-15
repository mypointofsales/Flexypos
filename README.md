# Flexypos — Multi-tenant POS & Laundry SaaS

**Tech Stack:** Flutter (Dart) • Node.js/Express • MySQL • Nginx/SSL  
**Focus:** Multi-tenant data isolation, CRUD modules, sync-ready architecture, production deployment

## Overview
Flexypos is a B2B SaaS platform for POS (Retail) and Laundry operations. It includes client apps and backend services designed with strict tenant scoping and operational reliability.

## Key Features
- Multi-tenant scoping (account-level + business-unit scope)
- CRUD modules with soft delete and audit-safe filtering
- Sync-ready patterns (delta/updated_since, LWW upsert, tombstones) *(if applicable)*
- Deployment behind Nginx reverse proxy with HTTPS

## Architecture
- `apps/` (Flutter clients)
- `api/` (Node.js/Express services)
- `db/` (MySQL schema/migrations)
- `deploy/` (Nginx configs, service scripts)

## Screenshots / Demo
- Screenshots: `/docs/screenshots`
- Demo link: (optional)

## Getting Started (Local)
### Requirements
- Node.js >= XX
- Flutter >= XX
- MySQL >= XX

### Setup
1. Copy environment template:
   - `cp .env.example .env`
2. Install dependencies:
   - `npm install` (API)
   - `flutter pub get` (App)
3. Run API:
   - `npm run dev`
4. Run Flutter:
   - `flutter run`

## Environment Variables
See `.env.example`.

## License
(Choose a license or state: “All rights reserved”)
