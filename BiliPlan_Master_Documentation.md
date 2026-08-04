# BiliPlan — Master System Documentation

> **Multi-Route Smart Travel Decision Support System with Official Fare Integration and Verified Local Service Provider Assistance**
>
> Version: 1.0.0 · Platform: Flutter / Dart · Target: Biliran Island, Eastern Visayas, Philippines

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Core System Identity](#2-core-system-identity)
3. [User Flow](#3-user-flow)
4. [Core Features](#4-core-features)
5. [System Architecture](#5-system-architecture)
6. [Data Models](#6-data-models)
7. [Route Generation Logic](#7-route-generation-logic)
8. [Provider Recommendation System](#8-provider-recommendation-system)
9. [Messaging System](#9-messaging-system)
10. [Map System](#10-map-system)
11. [UI / UX Analysis](#11-ui--ux-analysis)
12. [Database Structure Recommendation](#12-database-structure-recommendation)
13. [Technology Stack](#13-technology-stack)
14. [Security & Verification](#14-security--verification)
15. [Future Enhancements](#15-future-enhancements)
16. [Thesis Contribution](#16-thesis-contribution)
17. [Defense-Ready Explanation](#17-defense-ready-explanation)

---

## 1. System Overview

### 1.1 Purpose

BiliPlan is a Flutter-based mobile tourism application designed specifically for **Biliran Island, Eastern Visayas, Philippines**. Its core purpose is to transform the fragmented, uninformed experience of travelling to Biliran into a structured, data-driven, and guided process — from initial planning all the way to on-the-ground execution.

### 1.2 Problem Being Solved

| Problem | Impact Without BiliPlan |
|---|---|
| No single authoritative source for transport fares | Tourists are overcharged or misled by informal quotes |
| Multiple route options exist but are undocumented | Tourists default to the most obvious (often most expensive) route |
| Unverified service providers cannot be distinguished from verified ones | Safety risks and exploitation of first-time visitors |
| Tourist information is scattered or verbal-only | Poor trip preparation, missed opportunities |
| No structured itinerary with transport timing included | Tourists arrive unprepared and improvise dangerously |

### 1.3 Target Users

| User Type | Role in the System |
|---|---|
| **Tourists / Travellers** | Primary users who browse destinations, compare routes, view fares, and execute itineraries |
| **Local Service Providers** | Drivers, boat operators, tour guides, and tricycle operators who are matched to tourist itineraries |
| **Biliran Tourism Office** | Data authority — provides and verifies official fares, routes, and provider registrations |

### 1.4 System Objectives

1. Provide **officially verified transport fare data** from the Biliran Tourism Office and LTFRB guidelines.
2. Generate **multiple route options** per destination so tourists can make informed decisions.
3. Match tourists with **verified, accredited service providers** for each route segment.
4. Produce a **complete, timestamped itinerary** with transport, fares, and provider contacts embedded.
5. Enable **direct tourist-to-provider communication** to confirm bookings and availability.
6. Deliver **safety advisories and warnings** relevant to the chosen destinations and routes.
7. Serve as a **standalone, offline-capable reference** for Biliran Island tourism.

### 1.5 Real-World Tourism Impact

- Reduces tourist exploitation by publishing official, non-negotiable fare rates.
- Increases tourist confidence by providing verified contact numbers for transport providers.
- Supports local economy by channelling bookings to verified, registered providers.
- Promotes lesser-known tourist sites by making their routes accessible and clear.
- Reduces barriers to entry for first-time or solo travellers to Biliran Island.

---

## 2. Core System Identity

### 2.1 What BiliPlan Is NOT

BiliPlan is **not** a basic itinerary generator that only lists places to visit. It is **not** a simple map application that draws lines between destinations. It is **not** an aggregator of user-submitted reviews or unverified information.

### 2.2 What BiliPlan IS

BiliPlan is a **Smart Travel Decision Support System** — a category that sits at the intersection of:

| Dimension | Description |
|---|---|
| **Decision Support** | Presents multiple route options with cost, time, and comfort dimensions so the tourist can make an informed choice |
| **Transport-Aware Tourism** | Every destination recommendation is paired with the exact transport modes, segments, and fares needed to reach it |
| **Execution-Focused Travel Assistant** | Goes beyond planning — embeds provider contacts, call-to-action messaging, and real-time advisory notes directly into the itinerary |
| **Official Data Integration** | All fare data is sourced from the Biliran Tourism Office and LTFRB — not estimated, crowdsourced, or range-based |
| **Verified Provider Matching** | Connects tourists to accredited providers filtered by route segment and transport compatibility |

### 2.3 The Thesis Innovation Statement

> *"BiliPlan addresses the gap between tourism information and tourism execution by integrating official fare data, multi-route decision support, and verified provider matching into a single mobile platform — enabling tourists to not only plan their Biliran Island trip but also carry it out safely and cost-effectively."*

---

## 3. User Flow

```
User Opens BiliPlan
        │
        ▼
┌──────────────────────────────┐
│   Onboarding / Welcome       │  3-page swipe introduction
│   (OnboardingScreen)         │  to the BiliPlan platform
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│   Home Dashboard             │  Browse featured destinations,
│   (HomePage)                 │  categories, and highlights
└──────────────┬───────────────┘
               │  User taps "Plan Trip" (centre nav button)
               ▼
┌──────────────────────────────┐
│   Plan Trip / Preferences    │  Tourist selects destination,
│   (PlanTripScreen)           │  travel date, group size,
└──────────────┬───────────────┘  budget preference
               │
               ▼
┌──────────────────────────────┐
│   Route Selection            │  System presents 3–5 official
│   (RouteSelectionScreen)     │  route options with:
└──────────────┬───────────────┘  • RouteLabel (Recommended /
               │                    Cheapest / Fastest / etc.)
               │                  • Official fares per segment
               │                  • Total fare + travel time
               │                  • Transport type icons
               │                  • Sea travel warning (if any)
               │                  • Provider preview (on select)
               │
               │  User selects a route
               ▼
┌──────────────────────────────┐
│   Generating Screen          │  Lottie animation loading state
│   (GeneratingScreen)         │  while itinerary is assembled
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│   Itinerary Result           │  Full timestamped day-trip plan:
│   (ItineraryResultScreen)    │  • Hero image header
└──────────────┬───────────────┘  • Summary stats (fare/time/safety)
               │                  • Official Fare Breakdown card
               │                  • Transport & Contacts section
               │                  • Timeline with stops
               │                  • Action buttons (Edit/Map/Save)
               │
               ├──── User taps Edit ────► EditItineraryScreen
               ├──── User taps Map  ────► MapPreviewScreen
               └──── User taps provider contact ─► Phone Dialer
```

### 3.1 Step-by-Step Explanation

| Step | Screen | What Happens |
|---|---|---|
| **1. Onboarding** | `OnboardingScreen` | 3-page swipe flow introduces BiliPlan features. Transitions to Home on completion. |
| **2. Home** | `HomePage` | Displays featured destinations by category. Tourist can browse or immediately start planning. |
| **3. Plan Trip** | `PlanTripScreen` | Tourist inputs preferences: destination, travel type, number of days, group size. |
| **4. Route Selection** | `RouteSelectionScreen` | System queries `BiliranRouteOptions.forDestination()` and renders route cards. Tourist selects one. Upon selection, `_ProviderPreview` is shown inline. |
| **5. Generating** | `GeneratingScreen` | Lottie animation plays to simulate itinerary processing. Adds perceived intelligence to the flow. |
| **6. Itinerary Result** | `ItineraryResultScreen` | Displays complete day-trip: stops, times, fares, transport icons, provider cards with contact numbers. |
| **7. Provider Contact** | Phone dialer via `url_launcher` | Tourist taps a provider card → `tel:` URI launches the native phone app. |
| **8. Map Preview** | `MapPreviewScreen` | `google_maps_flutter` renders the route for spatial understanding only. No fare logic here. |
| **9. Edit Itinerary** | `EditItineraryScreen` | Tourist can customise stop order, adjust times, or add personal notes. |

---

## 4. Core Features

### 4.1 Tourist Side

#### 4.1.1 Destination Browsing
- Home page presents destinations organised by category (beaches, waterfalls, islands, cultural sites).
- Each destination card shows a preview image, category tag, and estimated travel time from Naval.
- `CategoryListPage` and `DestinationsListPage` allow deeper browsing beyond featured items.

#### 4.1.2 Route Comparison
- `RouteSelectionScreen` presents 3–5 `RouteOption` cards per destination.
- Each card displays: `RouteLabel` badge (Recommended ⭐ / Cheapest 💸 / Fastest ⚡ / Alternative 🔀 / Comfort 🛋️), route summary path, total official fare, total travel time, transport-type icon chain, and applicable tags.
- Cards are animated sequentially with staggered `flutter_animate` delays.
- A `_SourceBanner` prominently states all fares are official Tourism Office data.

#### 4.1.3 Fare Guide
- `FareGuideScreen` (accessible from the bottom nav `Fare` tab) presents the complete `BiliranFareData.allRoutes` dataset in a browsable, searchable list.
- Routes are filterable by transport type.
- Each entry shows origin → destination, fare, transport mode icon, duration, and the `fareSource` authority.

#### 4.1.4 Route Selection
- Tourist taps a `_RouteCard` to select it. The card animates to a selected state (coloured border, check icon).
- Upon selection, `_ProviderPreview` expands inline, showing up to 2 verified providers per segment.
- The `_ProceedButton` activates with the selected route's total fare displayed on it.

#### 4.1.5 Provider Recommendation
- `BiliranProviders.forSegment()` matches verified providers by `routeSegment` string and `TransportType` compatibility.
- Up to 3 providers per segment are shown in the itinerary result screen.
- The first provider listed represents the highest-rated option for that segment.

#### 4.1.6 Messaging / Contact System
- Each `ProviderCard` displays the provider's contact number and a call button.
- Tapping the call button fires `url_launcher` with the `tel:` URI (`provider.dialUri`).
- Advisory notes prompt tourists to "contact providers in advance to confirm availability."

#### 4.1.7 Itinerary Generation
- The `ItineraryResultScreen` assembles a complete timed stop sequence (`_Stop[]`).
- Each stop includes: time, landmark name, description, and the `TransportRoute` segment used to get there.
- The `_FareBreakdownCard` totals all official fares automatically via `fold`.
- The `_buildSummaryRow` produces three stat cards: Total Fare, Total Time, Safety status.

#### 4.1.8 Safety Warnings
- `SafetyScreen` (accessible from the `Safety` tab) provides category-specific safety advisories.
- Sea travel routes automatically display a `🌊 Includes Sea Travel` warning tag on the route card.
- Route-specific notes (e.g., "Includes rough trail section" for Tinago Falls) are embedded in `TransportRoute.notes`.

---

### 4.2 Provider Side

#### 4.2.1 Verified Registration System
- Every `ServiceProvider` in the `BiliranProviders._all` dataset carries:
  - A unique `id` (e.g., `sp-001`)
  - A `registrationCode` issued by the Tourism Office (e.g., `BTO-DRV-0001`, `BTO-BOT-0001`)
  - `isVerified = true` (the default and enforced constraint)
- Non-verified providers are excluded from all UI via `BiliranProviders.verified` getter.

#### 4.2.2 Provider Profile
Each provider exposes:
| Field | Description |
|---|---|
| `name` | Full name or business name |
| `type` | `ProviderType` enum (Driver, Boat Operator, Tour Guide, Tricycle Driver, Van Driver) |
| `contactNumber` | Phone number for direct contact |
| `routeSegment` | Exact `"origin → destination"` string this provider services |
| `compatibleTransportTypes` | List of `TransportType` values this provider can handle |
| `registrationCode` | Tourism Office accreditation code |
| `availability` | Human-readable hours and conditions |
| `rating` | Average rating out of 5.0 |
| `note` | Advisory note (e.g., capacity limits, advance booking required) |

#### 4.2.3 Route Assignment
- Providers are statically assigned to route segments in `BiliranProviders._all`.
- Assignment is based on the exact `"origin → destination"` route label matching.
- A provider may be assigned to multiple segments (e.g., Pedro Boat Services covers both directions of Sambawan).

#### 4.2.4 Messaging Support
- Providers are callable directly from the app via the `tel:` URI scheme.
- The `ServiceProvider.dialUri` property strips spaces from the contact number and prepends `tel:`.
- Future architecture can extend this to in-app messaging.

---

### 4.3 Tourism Office Role

#### 4.3.1 Fare Standardisation
- The `BiliranFareData` class is the authoritative fare dataset.
- All `TransportRoute.officialFare` values are documented as sourced from the **Biliran Tourism Office** and **LTFRB Eastern Visayas** guidelines.
- The `fareSource` field on every `TransportRoute` explicitly attributes: `'Biliran Tourism Office'`.
- Fares are fixed integers (never ranges or estimates).

#### 4.3.2 Provider Verification
- The Tourism Office is the implied verification authority for all `ServiceProvider` entries.
- `registrationCode` values follow a structured format: `BTO-{TYPE}-{NUMBER}` (e.g., `BTO-BOT-0001` = Boat Operator #1).
- The UI explicitly states "Verified by Biliran Tourism Office" in the provider section header.

#### 4.3.3 Route Data Authority
- `BiliranRouteOptions` and `BiliranFareData` represent the Tourism Office's structured route knowledge.
- Municipalities, ports, landmarks, and tourist sites are named exactly as they appear in official records.

---

## 5. System Architecture

### 5.1 Architectural Pattern

BiliPlan follows **Feature-First Clean Architecture** — a layered approach where each feature is self-contained, and shared infrastructure lives in `core/` and `widgets/`.

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # MaterialApp + ScreenUtil + GoRouter
│
├── core/                        # Infrastructure & cross-cutting concerns
│   ├── constants/
│   │   ├── app_strings.dart     # Centralised UI text strings
│   │   └── app_assets.dart      # Asset path constants
│   ├── router/
│   │   └── app_router.dart      # GoRouter configuration (all routes)
│   └── theme/
│       ├── app_colors.dart      # Design token: colours, gradients
│       ├── app_text_styles.dart # Design token: typography
│       └── app_theme.dart       # ThemeData configuration
│
├── data/                        # Business data layer (models + datasets)
│   ├── transport/
│   │   ├── transport_route.dart         # TransportRoute model + TransportType enum
│   │   ├── route_option.dart            # RouteOption model + RouteLabel enum
│   │   ├── biliran_fare_data.dart       # Official fare dataset (static)
│   │   └── biliran_route_options.dart   # Pre-defined route options per destination
│   └── providers/
│       ├── service_provider.dart        # ServiceProvider model + ProviderType enum
│       └── biliran_providers.dart       # Official provider registry + query API
│
├── features/                    # UI feature modules (feature-first)
│   ├── onboarding/
│   │   ├── screens/
│   │   │   ├── onboarding_screen.dart   # 3-page swipe onboarding
│   │   │   └── welcome_screen.dart      # Legacy single-page welcome
│   │   └── widgets/                     # Onboarding-specific widgets
│   ├── home/
│   │   ├── home_page.dart               # Featured destinations dashboard
│   │   ├── pages/
│   │   │   ├── category_list_page.dart  # Destination categories browse
│   │   │   └── destinations_list_page.dart
│   │   └── widgets/                     # Home-specific widgets
│   ├── itinerary/
│   │   ├── input/
│   │   │   └── plan_trip_screen.dart    # Trip preferences input form
│   │   ├── route_selection/
│   │   │   └── route_selection_screen.dart  # Multi-route comparison UI
│   │   ├── generating/
│   │   │   └── generating_screen.dart   # Lottie loading / "AI thinking" screen
│   │   ├── result/
│   │   │   └── itinerary_result_screen.dart  # Full itinerary output
│   │   └── edit/
│   │       └── edit_itinerary_screen.dart    # Itinerary customisation
│   ├── map/
│   │   └── map_preview_screen.dart      # Google Maps route visualisation
│   ├── fare/
│   │   └── fare_guide_screen.dart       # Official fare browsing + search
│   └── safety/
│       └── safety_screen.dart           # Safety advisories & warnings
│
├── navigation/
│   └── main_navigation.dart             # Tab shell (IndexedStack + floating nav bar)
│
└── widgets/                     # Shared reusable widgets
    ├── provider_card.dart               # ProviderCard + SegmentProviderSection
    ├── animated_button.dart             # AnimatedButton with press feedback
    └── fade_slide.dart                  # Reusable FadeSlide transition widget
```

### 5.2 Routing Structure

BiliPlan uses **`go_router`** for declarative, URL-based navigation.

| Route Path | Name | Screen | Access Pattern |
|---|---|---|---|
| `/` | `onboarding` | `OnboardingScreen` | App launch |
| `/home` | `home` | `MainNavigation` (tab shell) | After onboarding |
| `/generating` | `generating` | `GeneratingScreen` | After route selection |
| `/route-selection?destination=X` | `route-selection` | `RouteSelectionScreen` | After plan trip form |
| `/itinerary-result` | `itinerary-result` | `ItineraryResultScreen` | After generating |
| `/edit-itinerary` | `edit-itinerary` | `EditItineraryScreen` | From itinerary result |
| `/map-preview` | `map-preview` | `MapPreviewScreen` | From itinerary or tab |
| `/categories` | `categories` | `CategoryListPage` | From home |
| `/destinations` | `destinations` | `DestinationsListPage` | From categories |

**Navigation shell tabs (via `MainNavigation`):**

| Tab Index | Label | Screen | Nav Position |
|---|---|---|---|
| 0 | Home | `HomePage` | Left pill |
| 1 | Plan | `PlanTripScreen` | Centre circle button |
| 2 | Map | `MapPreviewScreen` | Left pill (inner) |
| 3 | Fare | `FareGuideScreen` | Right pill (inner) |
| 4 | Safety | `SafetyScreen` | Right pill |

### 5.3 State Management

BiliPlan currently uses **`StatefulWidget` + `setState`** for local screen state (e.g., selected route ID in `RouteSelectionScreen`, current tab index in `MainNavigation`).

**Recommendation for scaling:**
- Adopt **Riverpod** or **BLoC** as state management grows.
- Wrap `BiliranFareData` and `BiliranProviders` in providers to support filtering, search state, and user preferences persistence.

### 5.4 Reusable Widgets

| Widget | File | Purpose |
|---|---|---|
| `ProviderCard` | `widgets/provider_card.dart` | Displays a single `ServiceProvider` with contact and call button |
| `SegmentProviderSection` | `widgets/provider_card.dart` | Groups providers under a route segment label |
| `AnimatedButton` | `widgets/animated_button.dart` | Press-scale animated CTA button |
| `FadeSlide` | `widgets/fade_slide.dart` | Reusable fade + slide-in transition widget |

---

## 6. Data Models

### 6.1 `TransportType` (Enum)

**File:** [`transport_route.dart`](file:///c:/flutter-projects/mobile_tourism_ai_app/lib/data/transport/transport_route.dart)

**Purpose:** Classifies the mode of transport for a route segment.

| Value | Label | Icon | Color Class | Water? |
|---|---|---|---|---|
| `multicab` | Multicab | `airport_shuttle_rounded` | Primary (blue) | No |
| `van` | Van | `directions_car_rounded` | Success (green) | No |
| `jeepney` | Jeepney | `commute_rounded` | Accent soft | No |
| `habalHabal` | Habal-habal | `two_wheeler_rounded` | Warning (amber) | No |
| `boat` | Boat | `directions_boat_rounded` | Info (cyan) | **Yes** |
| `boatCharter` | Boat Charter | `sailing_rounded` | Info (cyan) | **Yes** |
| `tricycle` | Tricycle | `electric_rickshaw_rounded` | Warning (amber) | No |
| `bus` | Bus | `directions_bus_rounded` | Purple | No |
| `ferry` | Ferry | `directions_boat_filled_rounded` | Info (cyan) | **Yes** |

**Key computed property:** `isWater` → used by `RouteOption.hasSeaTravel` and the sea-travel warning system.

---

### 6.2 `TransportRoute`

**File:** [`transport_route.dart`](file:///c:/flutter-projects/mobile_tourism_ai_app/lib/data/transport/transport_route.dart)

**Purpose:** Represents a single official point-to-point transport segment with a fixed Tourism Office fare.

| Attribute | Type | Description |
|---|---|---|
| `origin` | `String` | Starting municipality or landmark |
| `destination` | `String` | Ending municipality or landmark |
| `type` | `TransportType` | Mode of transport |
| `officialFare` | `int` | Fixed fare in PHP (₱) — never estimated |
| `durationMinutes` | `int` | Approximate travel time in minutes |
| `fareSource` | `String` | Attribution (default: `'Biliran Tourism Office'`) |
| `perPerson` | `bool` | `true` = per person; `false` = per vehicle/charter |
| `notes` | `String?` | Optional clarification (e.g., schedule, capacity) |

**Computed helpers:** `fareLabel`, `durationLabel`, `routeLabel`, `officialFareDisplay`

**Relationships:** Used as segments in `RouteOption`; referenced by `ServiceProvider.routeSegment`; displayed in `_FareBreakdownCard` and `_TimelineStop`.

---

### 6.3 `RouteLabel` (Enum)

**File:** [`route_option.dart`](file:///c:/flutter-projects/mobile_tourism_ai_app/lib/data/transport/route_option.dart)

**Purpose:** Categorises a route option by its primary benefit to the tourist.

| Value | Text | Emoji | Meaning |
|---|---|---|---|
| `cheapest` | Cheapest | 💸 | Lowest total official fare |
| `fastest` | Fastest | ⚡ | Shortest total travel time |
| `recommended` | Recommended | ⭐ | Best balance of cost and comfort |
| `alternative` | Alternative | 🔀 | Scenic or multi-stop variation |
| `comfort` | Comfort | 🛋️ | Private vehicle / higher comfort |

---

### 6.4 `RouteOption`

**File:** [`route_option.dart`](file:///c:/flutter-projects/mobile_tourism_ai_app/lib/data/transport/route_option.dart)

**Purpose:** A selectable, labelled travel option consisting of one or more `TransportRoute` segments.

| Attribute | Type | Description |
|---|---|---|
| `id` | `String` | Unique identifier (e.g., `sambawan_recommended`) |
| `label` | `RouteLabel` | Categorisation badge |
| `description` | `String` | User-facing explanation of why this option is notable |
| `segments` | `List<TransportRoute>` | Ordered list of transport segments |
| `tags` | `List<String>` | Display tags (e.g., `['Sea Travel', 'Budget Friendly']`) |
| `note` | `String?` | Advisory note (e.g., booking deadline) |

**Computed properties:**
| Property | Derived From |
|---|---|
| `totalFare` | `fold` over `segments` → sum of `officialFare` |
| `totalDurationMinutes` | `fold` over `segments` → sum of `durationMinutes` |
| `hasSeaTravel` | `any((r) => r.type.isWater)` |
| `transportTypes` | Distinct `TransportType` values across segments |
| `routeSummary` | `"Naval → Kawayan → Sambawan Port → Sambawan Island"` |

**Relationships:** Contains `List<TransportRoute>`; displayed in `_RouteCard`; expanded with `_ProviderPreview` when selected.

---

### 6.5 `ProviderType` (Enum)

**File:** [`service_provider.dart`](file:///c:/flutter-projects/mobile_tourism_ai_app/lib/data/providers/service_provider.dart)

| Value | Label | Icon | Color |
|---|---|---|---|
| `driver` | Driver | `airport_shuttle_rounded` | Blue |
| `boatOperator` | Boat Operator | `sailing_rounded` | Sky blue |
| `guide` | Tour Guide | `person_pin_circle_rounded` | Green |
| `tricycleDriver` | Tricycle Driver | `electric_rickshaw_rounded` | Amber |
| `vanDriver` | Van Driver | `directions_car_rounded` | Purple |

---

### 6.6 `ServiceProvider`

**File:** [`service_provider.dart`](file:///c:/flutter-projects/mobile_tourism_ai_app/lib/data/providers/service_provider.dart)

**Purpose:** A Tourism Office-verified local transport provider linked to specific route segments.

| Attribute | Type | Description |
|---|---|---|
| `id` | `String` | Unique identifier (e.g., `sp-001`) |
| `name` | `String` | Full name or business name |
| `type` | `ProviderType` | Category of provider |
| `contactNumber` | `String` | Phone number for direct contact |
| `routeSegment` | `String` | `"origin → destination"` string this provider serves |
| `compatibleTransportTypes` | `List<TransportType>` | What transport modes this provider can service |
| `registrationCode` | `String?` | Tourism Office accreditation code |
| `availability` | `String?` | Hours and conditions (e.g., `"Daily 6:00 AM – 3:00 PM"`) |
| `isVerified` | `bool` | Must be `true` to appear in UI (default: `true`) |
| `rating` | `double?` | Average rating out of 5.0 |
| `note` | `String?` | Advisory note (booking lead time, capacity, etc.) |

**Computed helpers:**
- `dialUri` → `tel:09171234567` (spaces stripped)
- `formattedContact` → `📞 09171234567`
- `handles(TransportType t)` → checks `compatibleTransportTypes`
- `matchesSegment(origin, destination)` → case-insensitive `routeSegment` comparison

**Relationships:** Referenced by `BiliranProviders` registry; displayed in `ProviderCard` and `SegmentProviderSection`; triggered by `BiliranProviders.forSegment()` in both `RouteSelectionScreen` and `ItineraryResultScreen`.

---

### 6.7 `_Stop` (Internal Itinerary Model)

**File:** [`itinerary_result_screen.dart`](file:///c:/flutter-projects/mobile_tourism_ai_app/lib/features/itinerary/result/itinerary_result_screen.dart)

**Purpose:** Represents a single timestamped waypoint in the day-trip itinerary timeline.

| Attribute | Type | Description |
|---|---|---|
| `time` | `String` | Scheduled time (e.g., `"06:15 AM"`) |
| `landmark` | `String` | Name of the place |
| `description` | `String` | What happens at this stop |
| `transport` | `TransportRoute?` | How the tourist got here (`null` for starting point) |
| `isFirst` | `bool` | Start dot color → green |
| `isLast` | `bool` | End dot color → red |

---

## 7. Route Generation Logic

### 7.1 Architecture Overview

Route generation in BiliPlan is **data-driven and deterministic** — not algorithmic. Routes are pre-defined in the `BiliranRouteOptions` class based on structured data from the Biliran Tourism Office. This is a deliberate design decision that ensures:

- All displayed routes are **real, validated** routes known to the Tourism Office.
- Fares are never estimated — they always come from official records.
- Transport types are never inferred from maps — they are explicitly assigned in the dataset.

### 7.2 Multi-Route Generation

```
PlanTripScreen (user selects destination)
       │
       ▼ destination string passed via GoRouter query param
RouteSelectionScreen.initState()
       │
       └──► BiliranRouteOptions.forDestination(destination)
                    │
                    ├── "sambawan" → returns sambawanIsland (4 options)
                    ├── "agta"     → returns agtaBeach     (3 options)
                    ├── "tinago"   → returns tinagoFalls   (3 options)
                    └── default    → returns sambawanIsland
```

Each destination has multiple pre-defined `RouteOption` objects, each with a different `RouteLabel` and transport combination:

**Sambawan Island Route Options:**

| ID | Label | Segments | Total Fare | Time |
|---|---|---|---|---|
| `sambawan_recommended` | ⭐ Recommended | Multicab + Habal-habal + Boat Charter | ₱915 | ~1h 40m |
| `sambawan_cheapest` | 💸 Cheapest | Jeepney + Multicab + Habal-habal + Boat Charter | ₱918 | ~1h 50m |
| `sambawan_fastest` | ⚡ Fastest | Van + Habal-habal + Private Charter | ₱1,660 | ~1h 20m |
| `sambawan_alternative` | 🔀 Alternative | Multicab + Boat + Island-to-Island Charter | ₱855 | ~1h 55m |

### 7.3 Route Filtering

`BiliranRouteOptions.forDestination()` performs a **case-insensitive substring match** on the destination string:
```dart
final d = destination.toLowerCase();
if (d.contains('sambawan')) return sambawanIsland;
if (d.contains('agta'))     return agtaBeach;
if (d.contains('tinago'))   return tinagoFalls;
return sambawanIsland; // fallback
```

### 7.4 Transport-Type Detection

**Transport types are NOT detected from maps.** They are explicitly declared in the `TransportRoute` constructor via the `type:` field.

This is sourced from Tourism Office knowledge:
- Government road routes → `jeepney`, `multicab`, `van`
- Motorcycle-accessible trails → `habalHabal`
- Short sea crossings → `boatCharter`
- Scheduled sea routes → `boat`, `ferry`

The `TransportType` enum carries all display metadata (icon, color, label, `isWater`) so the UI never needs to infer transport from any other source.

### 7.5 User Preference Matching

The current architecture uses label-based preference matching:
- Budget-conscious users → identify `RouteLabel.cheapest` option
- Time-sensitive users → identify `RouteLabel.fastest` option
- Group travelers → identify `RouteLabel.comfort` option (van/private charter)
- Experience-seekers → identify `RouteLabel.alternative` option

Future enhancement: PlanTripScreen preference inputs (budget range, group size, comfort level) can be used to **pre-highlight** the matching `RouteLabel` for the user.

### 7.6 Official Fare Computation

```
RouteOption.totalFare = segments.fold(0, (sum, r) => sum + r.officialFare)
```

All segment fares are fixed integers from `BiliranFareData`. The `_FareBreakdownCard` in `ItineraryResultScreen` applies the same fold to display per-segment and total official fares.

`perPerson` is shown in the breakdown (per person vs. per trip/charter) so tourists understand shared charter costs.

### 7.7 Provider Matching

```
BiliranProviders.forSegment(
  origin:      seg.origin,
  destination: seg.destination,
  type:        seg.type,
  limit:       2–3,
)
```

Matching logic:
1. Filter `_all` to `isVerified == true` only.
2. Case-insensitive match on `routeSegment == "origin → destination"`.
3. Filter by `handles(type)` — provider's `compatibleTransportTypes` must contain the segment's `TransportType`.
4. Return up to `limit` results (preserving dataset order = highest-rated first by convention).

---

## 8. Provider Recommendation System

### 8.1 Recommendation Logic

BiliPlan uses a **segment-matched, verification-filtered** provider recommendation approach:

```
For each TransportRoute segment in a RouteOption:
  1. Build key: "${seg.origin} → ${seg.destination}" (lowercased)
  2. Filter verified providers where routeSegment matches key
  3. Filter by compatibleTransportTypes ∋ seg.type
  4. Take top N (N = 2 for preview, N = 3 for result screen)
  5. Display as SegmentProviderSection with the segment label as header
```

The first provider in the dataset for a given segment is treated as the **primary recommendation** (highest-rated by dataset ordering convention).

### 8.2 Provider Selection Flow

```
RouteSelectionScreen:
  User selects RouteOption
       │
       ▼
  _ProviderPreview expands inline
       │
       ├── SegmentProviderSection per segment
       │       ├── ProviderCard (compact mode)
       │       └── ProviderCard (compact mode)
       └── Advisory note: "Contact providers in advance"

ItineraryResultScreen:
  _buildProvidersSection()
       │
       ├── SegmentProviderSection per segment (full mode)
       │       ├── ProviderCard (full mode)
       │       ├── ProviderCard (full mode)
       │       └── ProviderCard (full mode)
       └── Advisory note (dismissible)
```

### 8.3 Verification Mechanism

| Gate | Implementation |
|---|---|
| `isVerified == true` | Enforced by `BiliranProviders.verified` getter before any query |
| `registrationCode != null` | Present on all official providers (e.g., `BTO-BOT-0001`) |
| UI badge | Provider section header reads "Verified by Biliran Tourism Office" |
| No user-submitted providers | All providers are pre-loaded official data — no public submissions |

### 8.4 Recommended Provider Labels

The `ProviderCard` widget uses visual cues to indicate the primary recommendation:
- First provider in the list → **top card position** (de-facto recommendation by ordering)
- Future enhancement: explicit `isRecommended` flag on `ServiceProvider`
- The `SegmentProviderSection` header identifies the route segment so users know which provider handles which leg of the trip.

### 8.5 User Override Selection

Tourists are **not forced** to use the first (recommended) provider. They can:
1. View all listed providers for each segment.
2. Compare names, ratings, availability notes, and capacity limits.
3. Contact any provider directly by tapping the call button.
4. Choose based on their own criteria (e.g., prior experience, availability timing).

---

## 9. Messaging System

### 9.1 Tourist-Provider Communication Flow

BiliPlan's current messaging model uses the **native phone dialer** as the communication channel:

```
Tourist views ProviderCard
        │
        └── Taps 📞 Call button
                  │
                  └── url_launcher fires tel:{contactNumber}
                              │
                              └── Native phone app opens
                                        │
                                        └── Tourist calls provider directly
```

This approach was chosen because:
- It requires no backend infrastructure.
- It is universally accessible on all Android and iOS devices.
- It matches real-world Biliran transport booking behaviour (phone-first culture).
- It requires no authentication or account creation.

### 9.2 Provider Card Structure

The `ProviderCard` widget displays:
| Element | Source |
|---|---|
| Provider name | `provider.name` |
| Type badge (with icon + color) | `provider.type.label`, `provider.type.icon`, `provider.type.color` |
| Route segment | `provider.routeSegment` |
| Rating stars | `provider.rating` (rendered as star icons) |
| Registration code | `provider.registrationCode` |
| Availability | `provider.availability` |
| Contact number | `provider.formattedContact` |
| Advisory note | `provider.note` |
| Call button | `url_launcher` → `provider.dialUri` |

### 9.3 Quick Messages (Advisory Notes)

Providers include pre-written advisory notes that serve as contextual quick-messages:
- `"Book at least 1 day in advance"` (Pedro Boat Services)
- `"Capacity: 8–12 passengers"` (Lito's Sea Express)
- `"Public ferry — fixed schedule"` (Higatangan Ferry Coop)
- `"Official accredited guide — Biliran Tourism Office"` (Tourism Guide Carlo)

### 9.4 Future Scalability — In-App Chat

The messaging architecture can be extended to a full in-app chat system:

```dart
// Future ChatMessage model
class ChatMessage {
  final String id;
  final String senderId;     // tourist or provider ID
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final MessageType type;    // text, image, quickReply
}
```

**Firebase Firestore** is the recommended backend for real-time chat:
- Collection: `chats/{chatId}/messages/`
- Real-time listener via `StreamBuilder`
- Offline support via Firestore local cache
- Push notifications via Firebase Cloud Messaging (FCM)

---

## 10. Map System

### 10.1 Role of Maps in BiliPlan

Maps in BiliPlan serve a **purely visual and spatial** purpose. The `MapPreviewScreen` uses `google_maps_flutter` to render the geographical context of a route.

**Maps ARE used for:**
- Route path visualisation (polylines between waypoints)
- Location preview (placing destination markers)
- Navigation understanding (tourist sees approximate geography)
- Spatial orientation (understanding island layout, ferry crossing distances)

**Maps are NOT used for:**
- Determining transport type (all types are pre-assigned in the dataset)
- Calculating fares (all fares come from `BiliranFareData`)
- Validating route existence (routes are pre-defined by Tourism Office data)
- Real-time traffic or transport tracking

### 10.2 Architecture Boundary

```
Data Layer (BiliranFareData, BiliranRouteOptions)
    ↓  provides route segments with coordinates
    
MapPreviewScreen (google_maps_flutter)
    ↓  renders only — no fare/transport logic
    
User sees: "Here is where you'll go"
System says: "Here is how much it costs and how to get there" ← from data layer
```

### 10.3 Map Integration Points

| Feature | Map Role |
|---|---|
| `MapPreviewScreen` (tab) | General island overview with landmark markers |
| `MapPreviewScreen` (from itinerary) | Route-specific path from action button on result screen |
| Route card tags | No map — transport type comes from `TransportType` enum |
| Fare calculation | No map — fares come from `officialFare` field |

---

## 11. UI / UX Analysis

### 11.1 Design System

BiliPlan uses a centralized design token system defined in `core/theme/`:

**Color Palette (`AppColors`):**
| Token | Usage |
|---|---|
| `primary` | Main brand color (navy blue) — navigation, headers, primary actions |
| `primarySoft` | Softer variant for gradients |
| `accent` | Warm amber/orange — fare amounts, highlight values |
| `accentSoft` | Alternative routes, soft accent |
| `success` | Green — verified status, safety OK, starting point |
| `warning` | Amber — advisories, notes, habal-habal type |
| `danger` | Red — ending point in timeline |
| `info` | Cyan — water transport, time indicators |
| `primaryGradient` | Linear gradient for headers and hero sections |
| `backgroundStart` | Light background base |
| `textPrimary` / `textSecondary` | Typography hierarchy |
| `divider` | Subtle separator color |

**Typography:** Google Fonts via `google_fonts` package — consistent, modern sans-serif.

**Spacing:** `flutter_screenutil` ensures adaptive sizing across device sizes (`.w`, `.h`, `.sp`, `.r` extensions).

### 11.2 Onboarding Flow

The `OnboardingScreen` delivers a 3-page horizontally swipeable introduction:
- Page 1: What is BiliPlan (platform overview)
- Page 2: How routes and fares work
- Page 3: Provider and execution features
- Smooth page transitions with animated indicators
- "Get Started" CTA navigates to `/home`

### 11.3 Navigation Design

The `MainNavigation` implements a **floating capsule navigation bar** — a premium mobile design pattern:
- White pill capsule floating above content (20px margin, rounded corners)
- 4 regular icon-label tabs flanking a centre gap
- Elevated gradient circle button in the centre (Plan tab) — the primary action
- Haptic feedback on tab switches (`HapticFeedback.selectionClick()`)
- Animated slide-in on first render (`flutter_animate`)
- `IndexedStack` preserves tab state across switches

### 11.4 Route Selection UI

The `_RouteCard` implements a high-information-density comparison card:
- Animated selection state (border color, shadow, check icon)
- `RouteLabel` badge with emoji and colour coding
- Route summary path string
- Total fare chip + total duration chip
- Transport type icon chain with connector lines
- Tag chips (Budget Friendly, Sea Travel warning, etc.)
- Advisory note with warning styling
- `_ProviderPreview` expands inline on selection (no separate screen)

### 11.5 Itinerary Screen

The `ItineraryResultScreen` uses a **`CustomScrollView` with `SliverList`** for performance:
- Gradient hero image header with Tourism Office verification badge
- 3-stat summary row (fare, time, safety)
- `_FareBreakdownCard` — per-segment transport rows + total
- `_buildProvidersSection` — `SegmentProviderSection` per transport leg
- Timeline list of `_TimelineStop` widgets (dot + line + time + content card)
- Action row: Edit, View Map, Save

### 11.6 Provider Cards

`ProviderCard` (non-compact mode) includes:
- Type badge (colored icon + label)
- Provider name (title)
- Route segment subtitle
- Rating display (star icons)
- Registration code badge
- Availability note
- Advisory note (amber highlight)
- 📞 Contact number with call button (launches phone dialer)

`ProviderCard` (compact mode — inside route cards) collapses to:
- Name + type badge
- Truncated contact
- Inline call icon

### 11.7 Animation System

BiliPlan uses **`flutter_animate`** extensively:
- Staggered fade + slideY for route cards (`delay: (120 + index * 80).ms`)
- Fade + slideY for section headers and summary rows
- Animated container transitions on route card selection (250ms easeOutCubic)
- Navigation bar slide-up animation (480ms easeOutCubic)
- Centre nav button AnimatedScale on active state

---

## 12. Database Structure Recommendation

### 12.1 Recommended Backend: Firebase Firestore

Firebase is recommended for BiliPlan's phase 2 (live data) due to:
- Real-time sync for provider availability and chat messages
- Offline-first support (critical for island connectivity)
- Easy Flutter integration via `cloud_firestore` package
- Scalable NoSQL collections matching BiliPlan's document structure

### 12.2 Collections Structure

#### `destinations`
```json
{
  "id": "sambawan-island",
  "name": "Sambawan Island",
  "category": "islands",
  "municipality": "Kawayan",
  "description": "...",
  "imageUrls": ["..."],
  "coordinates": { "lat": 11.6789, "lng": 124.4567 },
  "travelTimeFromNaval": 100,
  "difficulty": "moderate",
  "isActive": true
}
```

#### `transport_routes`
```json
{
  "id": "naval-kawayan-multicab",
  "origin": "Naval",
  "destination": "Kawayan",
  "type": "multicab",
  "officialFare": 55,
  "durationMinutes": 45,
  "fareSource": "Biliran Tourism Office",
  "perPerson": true,
  "notes": "Via Biliran-Kawayan road",
  "updatedAt": "timestamp",
  "updatedBy": "tourism-office"
}
```

#### `route_options`
```json
{
  "id": "sambawan_recommended",
  "destinationId": "sambawan-island",
  "label": "recommended",
  "description": "Most popular route...",
  "segmentIds": ["naval-kawayan-multicab", "kawayan-sambawan-port-habal", "sambawan-charter"],
  "tags": ["Sea Travel", "Island Hopping", "Popular"],
  "note": "Book charter early",
  "totalFare": 915,
  "totalDurationMinutes": 100,
  "isActive": true
}
```

#### `providers`
```json
{
  "id": "sp-001",
  "name": "Juan dela Cruz Transport",
  "type": "driver",
  "contactNumber": "09171234567",
  "routeSegment": "Naval → Kawayan Port",
  "compatibleTransportTypes": ["multicab", "van"],
  "registrationCode": "BTO-DRV-0001",
  "availability": "Daily 5:00 AM – 8:00 PM",
  "isVerified": true,
  "rating": 4.8,
  "note": null,
  "verifiedAt": "timestamp",
  "verifiedBy": "biliran-tourism-office"
}
```

#### `itineraries`
```json
{
  "id": "itin-user123-001",
  "userId": "user123",
  "destinationId": "sambawan-island",
  "routeOptionId": "sambawan_recommended",
  "travelDate": "2026-06-15",
  "groupSize": 4,
  "stops": [
    {
      "time": "06:00 AM",
      "landmark": "Naval Town Plaza",
      "description": "Starting point",
      "transportRouteId": null
    },
    {
      "time": "06:15 AM",
      "landmark": "Kawayan",
      "description": "Board multicab from Naval",
      "transportRouteId": "naval-kawayan-multicab"
    }
  ],
  "totalFare": 1830,
  "totalDuration": 220,
  "isSaved": true,
  "createdAt": "timestamp"
}
```

#### `chats`
```json
{
  "id": "chat-user123-sp004",
  "touristId": "user123",
  "providerId": "sp-004",
  "itineraryId": "itin-user123-001",
  "lastMessage": "Is the boat available on June 15?",
  "lastMessageAt": "timestamp",
  "unreadCount": 1,
  "messages": [
    {
      "id": "msg-001",
      "senderId": "user123",
      "content": "Is the boat available on June 15?",
      "timestamp": "timestamp",
      "isRead": false,
      "type": "text"
    }
  ]
}
```

### 12.3 MySQL Alternative Structure

For thesis prototyping with a traditional backend:

```sql
-- Destinations
CREATE TABLE destinations (
  id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  category VARCHAR(50),
  municipality VARCHAR(100),
  description TEXT,
  coordinates_lat DECIMAL(10,7),
  coordinates_lng DECIMAL(10,7),
  is_active BOOLEAN DEFAULT TRUE
);

-- Transport Routes
CREATE TABLE transport_routes (
  id VARCHAR(80) PRIMARY KEY,
  origin VARCHAR(100) NOT NULL,
  destination VARCHAR(100) NOT NULL,
  transport_type ENUM('multicab','van','jeepney','habal_habal','boat','boat_charter','tricycle','bus','ferry') NOT NULL,
  official_fare INT NOT NULL,
  duration_minutes INT NOT NULL,
  fare_source VARCHAR(100) DEFAULT 'Biliran Tourism Office',
  per_person BOOLEAN DEFAULT TRUE,
  notes TEXT,
  updated_at TIMESTAMP
);

-- Route Options
CREATE TABLE route_options (
  id VARCHAR(80) PRIMARY KEY,
  destination_id VARCHAR(50) REFERENCES destinations(id),
  label ENUM('cheapest','fastest','recommended','alternative','comfort') NOT NULL,
  description TEXT,
  note TEXT,
  total_fare INT,
  total_duration_minutes INT,
  is_active BOOLEAN DEFAULT TRUE
);

-- Route Option Segments (junction table)
CREATE TABLE route_option_segments (
  route_option_id VARCHAR(80) REFERENCES route_options(id),
  transport_route_id VARCHAR(80) REFERENCES transport_routes(id),
  segment_order INT NOT NULL,
  PRIMARY KEY (route_option_id, transport_route_id)
);

-- Providers
CREATE TABLE providers (
  id VARCHAR(20) PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  provider_type ENUM('driver','boat_operator','guide','tricycle_driver','van_driver') NOT NULL,
  contact_number VARCHAR(20) NOT NULL,
  route_segment VARCHAR(200) NOT NULL,
  registration_code VARCHAR(30),
  availability VARCHAR(200),
  is_verified BOOLEAN DEFAULT TRUE,
  rating DECIMAL(2,1),
  note TEXT,
  verified_at TIMESTAMP
);

-- Provider Compatible Transport Types (junction)
CREATE TABLE provider_transport_types (
  provider_id VARCHAR(20) REFERENCES providers(id),
  transport_type ENUM('multicab','van','jeepney','habal_habal','boat','boat_charter','tricycle','bus','ferry') NOT NULL,
  PRIMARY KEY (provider_id, transport_type)
);

-- Itineraries
CREATE TABLE itineraries (
  id VARCHAR(50) PRIMARY KEY,
  user_id VARCHAR(50),
  destination_id VARCHAR(50) REFERENCES destinations(id),
  route_option_id VARCHAR(80) REFERENCES route_options(id),
  travel_date DATE,
  group_size INT,
  total_fare INT,
  is_saved BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP
);

-- Chats
CREATE TABLE chats (
  id VARCHAR(50) PRIMARY KEY,
  tourist_id VARCHAR(50),
  provider_id VARCHAR(20) REFERENCES providers(id),
  itinerary_id VARCHAR(50) REFERENCES itineraries(id),
  created_at TIMESTAMP
);

CREATE TABLE chat_messages (
  id VARCHAR(50) PRIMARY KEY,
  chat_id VARCHAR(50) REFERENCES chats(id),
  sender_id VARCHAR(50) NOT NULL,
  content TEXT NOT NULL,
  message_type ENUM('text','image','quick_reply') DEFAULT 'text',
  is_read BOOLEAN DEFAULT FALSE,
  sent_at TIMESTAMP
);
```

---

## 13. Technology Stack

### 13.1 Frontend

| Technology | Version | Role |
|---|---|---|
| **Flutter** | SDK ^3.10.8 | Cross-platform mobile UI framework |
| **Dart** | (bundled with Flutter) | Programming language |

### 13.2 Packages

#### Navigation
| Package | Version | Purpose |
|---|---|---|
| `go_router` | ^14.0.0 | Declarative URL-based routing with query parameter support |

#### Maps
| Package | Version | Purpose |
|---|---|---|
| `google_maps_flutter` | ^2.9.0 | Route visualisation and landmark markers |

#### Animation
| Package | Version | Purpose |
|---|---|---|
| `lottie` | ^3.1.2 | JSON animation playback (generating screen, onboarding) |
| `rive` | ^0.13.13 | Advanced interactive vector animations |
| `flutter_animate` | ^4.5.0 | Chained micro-animations (fade, slideY, scale) |
| `animated_text_kit` | ^4.2.2 | Typewriter and animated text effects |

#### UI & Design
| Package | Version | Purpose |
|---|---|---|
| `google_fonts` | ^6.2.1 | Premium typography from Google Fonts |
| `flutter_screenutil` | ^5.9.3 | Responsive sizing for multiple screen densities |
| `cupertino_icons` | ^1.0.8 | iOS-style icon fallback set |

#### Platform Integration
| Package | Version | Purpose |
|---|---|---|
| `url_launcher` | ^6.3.2 | Launch `tel:` URIs for provider phone calls |

### 13.3 Assets

| Asset Directory | Contents |
|---|---|
| `assets/animations/` | Lottie JSON files (generating screen, onboarding) |
| `assets/images/` | Destination photos (agta.JPG, ulan-ulan.jpg, etc.) |

### 13.4 Optional Backend (Phase 2)

| Option | Use Case |
|---|---|
| **Firebase Firestore** | Real-time provider availability, live fare updates, in-app chat |
| **Firebase Auth** | Tourist accounts, saved itineraries |
| **Firebase Storage** | Provider photos, destination gallery uploads |
| **MySQL + REST API** | Traditional backend for institutional deployment |

---

## 14. Security & Verification

### 14.1 Tourism Office Verification Model

BiliPlan's security model is built around the **Biliran Tourism Office as the central authority**:

| Concern | Mechanism |
|---|---|
| **Fare authenticity** | All `officialFare` values are attributed to the Tourism Office with `fareSource = 'Biliran Tourism Office'`; no user-editable fare values |
| **Provider authenticity** | All providers carry `registrationCode` with `BTO-` prefix — structured, verifiable codes |
| **Provider filtering** | `isVerified` flag; `BiliranProviders.verified` getter enforces this filter before any UI query |
| **Route data integrity** | `BiliranFareData` and `BiliranRouteOptions` are compile-time constants — not user-modifiable |
| **Display transparency** | UI explicitly shows "Verified by Biliran Tourism Office" and "Official Fare (Biliran Tourism Office)" badges |

### 14.2 Official Fare Authority

The fare authority chain:

```
LTFRB Eastern Visayas (regulatory)
         │
         ▼
Biliran Tourism Office (local enforcement + data)
         │
         ▼
BiliranFareData.allRoutes (static dataset in app)
         │
         ▼
TransportRoute.officialFare (displayed in UI)
```

Fares are never estimated, averaged, or range-based. The `int` type for `officialFare` enforces exactness.

### 14.3 Verified Provider Restrictions

| Restriction | Enforcement |
|---|---|
| Only verified providers shown | `BiliranProviders.verified` filters `isVerified == true` |
| No unregistered providers | No public API to add providers — all are pre-loaded official data |
| No unverified contact numbers | All contact numbers are from Tourism Office records |
| Registration code required for display | `registrationCode` present on all official entries |

### 14.4 Future Security Enhancements

- JWT authentication for tourist accounts
- Admin portal for Tourism Office to update fares and provider status
- Provider rating system with abuse detection
- Cryptographic signing of official fare data snapshots

---

## 15. Future Enhancements

### 15.1 Real-Time Weather Integration

- Integrate **PAGASA (Philippine Atmospheric, Geophysical and Astronomical Services Administration)** API or OpenWeatherMap.
- Display weather advisories on routes involving sea travel.
- Auto-warn when wave height or wind conditions exceed safe thresholds for boat routes.
- Gate the Sambawan / Maripipi / Higatangan routes with a weather safety check.

### 15.2 Real-Time Transport Updates

- Provider availability updated in real-time via Firestore.
- Push notifications when a booked provider confirms or cancels.
- Live schedule boards for scheduled boats (Higatangan Ferry Coop, Maripipi pumpboat).
- Seasonal route availability flags (typhoon season restrictions).

### 15.3 Online Booking System

- In-app booking with provider confirmation flow.
- Tourist can send a booking request; provider accepts/declines.
- Payment gateway integration (GCash, Maya) for deposit payments.
- Booking reference number system for Tourism Office tracking.

### 15.4 AI Recommendation Engine

- Machine learning model trained on:
  - Past itinerary selections by user profile
  - Seasonal popularity of destinations
  - Group size / budget correlation
  - Repeat visitor preferences
- Personalised destination recommendations on the home screen.
- Smart route pre-selection based on stated preferences.

### 15.5 Live Provider Availability

- Provider availability status (Online / Busy / Offline) in real-time.
- Estimated wait times at terminals (Naval Multicab Terminal, Kawayan Port).
- Automatic provider suggestion when first-choice provider is unavailable.

### 15.6 Additional Features

| Enhancement | Description |
|---|---|
| Multi-day itineraries | Extend beyond single-day trips |
| Accommodation integration | Link verified guesthouses and resorts |
| Offline full mode | Download entire destination + fare dataset for offline use |
| Multilingual support | Filipino / Waray-Waray / English toggle |
| Accessibility features | Screen reader support, high-contrast mode |
| Tourist review system | Verified reviews for destinations (post-trip) |

---

## 16. Thesis Contribution

### 16.1 Innovation Statement

BiliPlan represents a **novel convergence of four innovations** in mobile tourism systems for Philippine local government tourism contexts:

#### Innovation 1: Multi-Route Decision Support for Local Tourism
Most tourism apps present a single "best route" to a destination. BiliPlan presents **3–5 labelled route options** (Recommended, Cheapest, Fastest, Alternative, Comfort) per destination — each with complete fare and time data — so tourists can make an informed, personalised decision. This decision support paradigm is rare in grassroots Philippine tourism technology.

#### Innovation 2: Official Fare Integration from Tourism Office Data
Tourist transport fare data in the Philippines is overwhelmingly informal, verbal, and inconsistent. BiliPlan is the **first mobile system designed for Biliran Island** to integrate structured, Tourism Office-validated fare data into an automated itinerary and route comparison system. Fares sourced from the Biliran Tourism Office and LTFRB Eastern Visayas guidelines are embedded as authoritative, fixed values — not estimates.

#### Innovation 3: Provider-Assisted Itinerary Execution
The gap between *planning* a trip and *executing* it is the most critical failure point in Philippine island tourism. BiliPlan bridges this gap by embedding **verified, contactable service providers** (drivers, boat operators, tour guides) directly into the itinerary — with one-tap phone access. This is execution-support technology, not just planning technology.

#### Innovation 4: User-Centered Tourism Platform for an Underserved Destination
Biliran Island is a relatively underdeveloped tourism destination compared to Boracay, Palawan, or Siargao. BiliPlan applies modern UX research and mobile design principles to a local context — giving Biliran Island a digital tourism infrastructure that most tier-1 Philippine destinations lack, and demonstrating replicability for other similar islands.

### 16.2 Contribution to Knowledge

| Dimension | Contribution |
|---|---|
| **Systems Design** | Architecture for integrating structured government data (Tourism Office) into a mobile decision-support app |
| **Information Systems** | Multi-route travel decision support model for local island tourism |
| **Human-Computer Interaction** | User-centered design for first-time tourists in low-connectivity, high-uncertainty environments |
| **Tourism Informatics** | Digital bridge between Tourism Office data authority and tourist end-users |
| **Local Government Technology** | Replicable model for other LGU tourism offices in Eastern Visayas and beyond |

---

## 17. Defense-Ready Explanation

### 17.1 What Problem Does BiliPlan Solve?

> *"Tourists visiting Biliran Island face three critical problems: they don't know how much transport should cost (leading to overcharging), they don't know which route is best for their budget and schedule (leading to suboptimal decisions), and they don't know who to contact to actually get them to their destination (leading to failed trips). BiliPlan solves all three with a single mobile application — by integrating official fare data from the Biliran Tourism Office, presenting multiple route options with transparent cost comparisons, and embedding verified, contactable service providers directly into the itinerary."*

### 17.2 Why Is It Impactful?

> *"The impact operates on three levels. For tourists, it transforms an uncertain, anxiety-provoking experience into a structured, informed one — reducing exploitation and improving trip success rates. For local service providers, it creates a digital presence and a legitimate channel for tourist bookings — supporting the local economy. For the Biliran Tourism Office, it digitalises their fare and provider data — making it accessible to a new generation of tech-savvy tourists without requiring them to physically visit the office."*

### 17.3 What Makes BiliPlan Different?

> *"Most tourism apps are either itinerary generators that ignore transport, or map apps that ignore cost. BiliPlan is unique in three ways: first, it uses officially verified fare data — not estimates. Second, it presents multiple route options rather than one, empowering the tourist to choose. Third, it integrates verified provider contacts directly into the itinerary so the tourist can act on the plan immediately. No other existing mobile system does all three for Biliran Island."*

### 17.4 Why Do Route Options Matter?

> *"A tourist with a limited budget and a tourist traveling with a large group have fundamentally different needs. The cheapest option for an individual may be a public multicab plus a shared habal-habal — costing ₱115. The same destination via private van charter may cost ₱350 but is far more comfortable for a family of six. Without route options, the system imposes a single decision on users with different constraints. With route options, the system becomes a genuine decision support tool — the tourist sees the tradeoff clearly and chooses rationally."*

### 17.5 Why Does Provider Integration Matter?

> *"Planning a trip is only half the battle. The most common failure point is execution — the tourist arrives at a port, doesn't know who the licensed boat operator is, and either gets overcharged by an unlicensed operator or misses the trip entirely. By embedding verified provider contacts into the itinerary — with one-tap phone access — BiliPlan eliminates this execution gap. The tourist doesn't just know the plan; they know exactly who to call to make it happen."*

### 17.6 Why Official Fares Matter (Key Defense Point)

> *"Fare transparency is the foundation of the entire system. If fares were estimated or range-based, the system loses credibility and utility. By partnering with the Biliran Tourism Office and using only fixed, official fare values — consistent with LTFRB Eastern Visayas guidelines — BiliPlan gives tourists an authoritative, non-negotiable price reference. This protects tourists from overcharging, creates accountability for transport providers, and demonstrates that the Tourism Office's data has real, direct value for tourists — which is an important policy argument for continued data sharing."*

---

## Appendix A: Current Destination Coverage

| Destination | Municipality | Route Options | Transport Types |
|---|---|---|---|
| Sambawan Island | Kawayan | 4 options | Multicab, Jeepney, Van, Habal-habal, Boat, Boat Charter |
| Agta Beach | Almeria | 3 options | Habal-habal, Multicab, Van |
| Tinago Falls | Almeria | 3 options | Habal-habal, Multicab, Van |
| Higatangan Island | Naval | (via alternative route) | Multicab, Boat, Ferry |
| Maripipi Island | Naval/Kawayan | (via fare guide) | Boat |
| Mainit Hot Spring | Caibiran | (via fare guide) | Habal-habal |
| Kasabangan Falls | Biliran town | (via fare guide) | Habal-habal |
| Ulan-Ulan Falls | Almeria | (via fare guide) | Habal-habal |
| Tomalistis Falls | Caibiran | (via fare guide) | Habal-habal |
| Binohang Beach | Culaba | (via fare guide) | Habal-habal |
| Dalutan Island | Almeria | (via fare guide) | Boat Charter |

---

## Appendix B: Official Provider Registry Summary

| ID | Name | Type | Route Segment | Rating |
|---|---|---|---|---|
| sp-001 | Juan dela Cruz Transport | Driver | Naval → Kawayan Port | 4.8 |
| sp-002 | Maria Santos Van Service | Van Driver | Naval → Kawayan Port | 4.7 |
| sp-003 | Reyes Multicab Services | Driver | Naval → Kawayan Port | 4.6 |
| sp-004 | Pedro Boat Services | Boat Operator | Kawayan Port → Sambawan Island | 4.9 |
| sp-005 | Lito's Sea Express | Boat Operator | Kawayan Port → Sambawan Island | 4.7 |
| sp-006 | Pedro Boat Services | Boat Operator | Sambawan Island → Kawayan Port | 4.9 |
| sp-007 | Bong Habal-habal Riders | Driver | Kawayan Port → Sambawan Port | 4.5 |
| sp-008 | Ramon Habal Riders | Driver | Sambawan Port → Kawayan | 4.6 |
| sp-009 | Higatangan Ferry Coop | Boat Operator | Naval Port → Higatangan Island | 4.6 |
| sp-010 | Bato Boat Charter Co. | Boat Operator | Naval Port → Higatangan Island | 4.8 |
| sp-011 | Almeria Tricycle Association | Tricycle Driver | Almeria → Ulan-ulan Falls | 4.5 |
| sp-012 | Danny's Tricycle Services | Tricycle Driver | Almeria → Ulan-ulan Falls | 4.4 |
| sp-013 | Tourism Office Guide — Carlo | Tour Guide | Sambawan Island | 5.0 |
| sp-014 | Tourism Office Guide — Ana | Tour Guide | Higatangan Island | 4.9 |
| sp-015 | Naval Port Multicab Terminal | Driver | Naval → Almeria | 4.5 |
| sp-016 | Almeria → Naval Multicab Line | Driver | Kawayan → Naval | 4.4 |

---

## Appendix C: Transport Fare Reference (Biliran Tourism Office)

| Origin | Destination | Type | Official Fare | Duration | Per |
|---|---|---|---|---|---|
| Naval | Biliran (town) | Jeepney | ₱28 | 15 min | Person |
| Naval | Kawayan | Multicab | ₱55 | 45 min | Person |
| Naval | Almeria | Multicab | ₱70 | 50 min | Person |
| Naval | Caibiran | Van | ₱100 | 60 min | Person |
| Naval | Cabucgayan | Van | ₱110 | 70 min | Person |
| Naval | Culaba | Multicab | ₱80 | 55 min | Person |
| Naval | Agta Beach | Habal-habal | ₱100 | 40 min | Person |
| Naval | Tinago Falls | Habal-habal | ₱150 | 60 min | Person |
| Kawayan | Sambawan Port | Habal-habal | ₱60 | 25 min | Person |
| Caibiran | Mainit Hot Spring | Habal-habal | ₱40 | 20 min | Person |
| Biliran (town) | Kasabangan Falls | Habal-habal | ₱50 | 25 min | Person |
| Almeria | Ulan-Ulan Falls | Habal-habal | ₱80 | 35 min | Person |
| Caibiran | Tomalistis Falls | Habal-habal | ₱60 | 30 min | Person |
| Culaba | Binohang Beach | Habal-habal | ₱50 | 20 min | Person |
| Naval | Maripipi Island | Boat | ₱280 | 90 min | Person |
| Sambawan Port | Sambawan Island | Boat Charter | ₱800 | 30 min | **Trip** |
| Naval | Higatangan Island | Boat | ₱350 | 120 min | Person |
| Almeria | Dalutan Island | Boat Charter | ₱500 | 20 min | **Trip** |
| Kawayan | Maripipi Island | Boat | ₱220 | 75 min | Person |

---

*Document generated: May 2026 | System Version: 1.0.0 | Flutter SDK: ^3.10.8*
*Source: Direct codebase analysis of the BiliPlan Flutter project (`mobile_tourism_ai_app`)*
