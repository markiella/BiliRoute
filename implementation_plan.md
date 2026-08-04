# BiliRoute Phase 2A — Admin Management System
## Implementation Plan

### Overview
Add a fully functional **Tourism Office Admin CMS** to the existing BiliRoute Flutter project. The admin portal lives behind an `/admin` route gate, uses a dedicated navigation shell with a collapsible side drawer, and operates on an **in-memory repository layer** that is structured to swap in Firebase or REST APIs without UI changes.

---

## User Review Required

> [!IMPORTANT]
> **Platform target**: The admin portal will be built as **Flutter screens inside the same mobile app**, accessible via a separate admin login flow (`/admin/login`). It will be usable on tablets and large phones. If you want a **separate Flutter Web** admin panel instead, please say so before I start — the architecture changes significantly.

> [!IMPORTANT]
> **Authentication**: Admin login will be **local credential check** (hardcoded `admin@biliroute.ph` / `biliroute2025`) for Phase 2A. No Firebase Auth yet. Role simulation (Super Admin / Tourism Officer / Viewer) will be done in-memory. Is this acceptable?

> [!WARNING]
> **Existing hardcoded data**: After Phase 2A, the mobile app will still read from the existing `destination_model.dart` static data. The **live sync** from admin → mobile (mobile reads from admin repository) will be wired up but will NOT persist between app restarts until Phase 2B (Firebase integration). This is intentional for the prototype phase.

---

## Open Questions

> [!NOTE]
> 1. Should the admin portal be accessible from the tourist app (e.g., a hidden admin button on the Profile screen), or should it be **completely separate** (launched via a special URL/deeplink)?
> 2. Should `flutter_charts` or `fl_chart` be added for the Reports & Analytics charts?
> 3. For **Gallery Management**, since this is prototype-only, should uploaded images be in-memory only (no actual file I/O), or do you want real device file picking via `image_picker`?

---

## Proposed Changes

### New Dependencies (pubspec.yaml)
```yaml
fl_chart: ^0.68.0          # Reports & Analytics charts
image_picker: ^1.1.2        # Gallery image picking (optional)
data_table_2: ^2.5.12      # Responsive admin tables with sorting/filtering
```

---

### Core — Data Architecture

#### [NEW] `lib/admin/data/models/`
| File | Purpose |
|---|---|
| `admin_destination.dart` | Full CRUD-capable destination model (superset of `DestinationItem`) |
| `admin_route.dart` | Multi-step route model with builder support |
| `admin_provider.dart` | Service provider model (boat/van/guide) |
| `admin_schedule.dart` | Transport departure schedule model |
| `admin_advisory.dart` | Travel advisory with severity + date range |
| `admin_gallery.dart` | Gallery image with destination link + attribution |
| `admin_user.dart` | Tourist user account model |
| `admin_auth.dart` | Admin session/role model |

#### [NEW] `lib/admin/data/repositories/`
| File | Purpose |
|---|---|
| `destination_repository.dart` | In-memory list with CRUD ops + `ChangeNotifier` |
| `route_repository.dart` | Route CRUD + step builder |
| `provider_repository.dart` | Provider CRUD + verification |
| `schedule_repository.dart` | Schedule CRUD |
| `advisory_repository.dart` | Advisory CRUD + publish/draft |
| `gallery_repository.dart` | Gallery CRUD + cover assignment |
| `user_repository.dart` | User account management |
| `admin_auth_repository.dart` | Admin session management |

All repositories implement a common `BaseRepository<T>` interface with `getAll()`, `getById()`, `create()`, `update()`, `delete()` — ready for Firebase swap.

---

### Admin Portal — UI Layer

#### [NEW] `lib/admin/` directory structure
```
lib/admin/
├── admin_app.dart               ← Admin MaterialApp shell
├── core/
│   ├── admin_colors.dart        ← BiliRoute admin palette
│   ├── admin_router.dart        ← GoRouter sub-tree for /admin/*
│   └── admin_theme.dart         ← Admin-specific ThemeData
├── data/
│   ├── models/                  ← (listed above)
│   └── repositories/            ← (listed above)
├── widgets/
│   ├── admin_nav_drawer.dart    ← Collapsible left-side drawer
│   ├── admin_scaffold.dart      ← Shell with drawer + content area
│   ├── stat_card.dart           ← Dashboard overview cards
│   ├── admin_data_table.dart    ← Reusable sortable/filterable table
│   ├── admin_form_field.dart    ← Styled form input widget
│   ├── admin_modal.dart         ← Slide-up add/edit modal
│   ├── severity_badge.dart      ← Advisory severity chip
│   └── verification_badge.dart  ← Verified/unverified status chip
└── screens/
    ├── auth/
    │   └── admin_login_screen.dart
    ├── dashboard/
    │   └── dashboard_screen.dart
    ├── destinations/
    │   ├── destinations_screen.dart
    │   └── destination_form_screen.dart
    ├── routes/
    │   ├── routes_screen.dart
    │   └── route_form_screen.dart
    ├── providers/
    │   ├── providers_screen.dart
    │   └── provider_form_screen.dart
    ├── gallery/
    │   └── gallery_screen.dart
    ├── schedules/
    │   └── schedules_screen.dart
    ├── advisories/
    │   ├── advisories_screen.dart
    │   └── advisory_form_screen.dart
    ├── users/
    │   └── users_screen.dart
    ├── reports/
    │   └── reports_screen.dart
    └── settings/
        └── settings_screen.dart
```

---

### Router Integration

#### [MODIFY] `lib/core/router/app_router.dart`
Add `/admin` and `/admin/login` routes pointing to the admin shell. Admin routes will be completely separate from the tourist app routes and will redirect non-admin sessions to `/admin/login`.

---

### Mobile App Integration

#### [MODIFY] `lib/features/profile/profile_screen.dart`
Add a hidden **"Admin Portal"** button at the bottom of the Profile page (visible only in debug mode or when a specific tap sequence is detected) that routes to `/admin/login`.

#### [MODIFY] `lib/features/home/home_page.dart` (future)
After Phase 2B: swap static `allBiliranDestinations` list with `DestinationRepository.getAll()`.

---

## Build Order (Phased)

### Phase 1 — Foundation (Data + Auth)
1. Add dependencies to `pubspec.yaml`
2. Create all admin data models
3. Seed repositories with existing BiliRoute data (migrate from `destination_model.dart`)
4. Build `AdminAuthRepository` (local credentials)
5. Build `AdminLoginScreen` with BiliRoute branding
6. Register `/admin/*` routes in `AppRouter`

### Phase 2 — Shell + Dashboard
7. Build `AdminNavDrawer` (10 module items, BiliRoute navy theme)
8. Build `AdminScaffold` (drawer + content area responsive shell)
9. Build `DashboardScreen` with 6 stat cards + Recent Activities + Quick Actions

### Phase 3 — Core CRUD Modules
10. **Destinations** — Table + Add/Edit full form (all fields from spec)
11. **Routes** — Table + multi-step route builder
12. **Verified Providers** — Table + form with verification status

### Phase 4 — Supporting Modules
13. **Gallery Management** — Grid view + upload form
14. **Transport Schedules** — Table + schedule form
15. **Travel Advisories** — Table + publish/draft form

### Phase 5 — Users + Reports + Settings
16. **User Management** — Tourist accounts table
17. **Reports & Analytics** — `fl_chart` charts (bar, line, pie)
18. **System Settings** — Config form

---

## Verification Plan

### Automated Tests
```bash
flutter analyze lib/admin/
flutter build apk --debug  # Verify no build errors
```

### Manual Verification
- Admin login with credentials → lands on Dashboard
- Add new destination → appears in destination table
- Edit destination → changes reflected in table
- Delete destination → removed from table
- Create a route with 3 steps → total fare/time calculated correctly
- Verify a provider → status chip updates to ✓ Verified
- Publish an advisory → appears in advisory list
- Navigate all 10 drawer modules without crashes
