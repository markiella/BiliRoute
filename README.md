<div align="center">

<img src="assets/images/onboarding_1.png" alt="BiliPlan Banner" width="100%" style="border-radius: 12px;" />

# 🌴 BiliPlan
### A Mobile-Based Auto-Itinerary Generator using Weighted Heuristic Search for Sustainable Local Tourism

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Google Maps](https://img.shields.io/badge/Google_Maps-API-4285F4?style=for-the-badge&logo=googlemaps&logoColor=white)](https://developers.google.com/maps)
[![License](https://img.shields.io/badge/License-Academic-green?style=for-the-badge)](LICENSE)

**Biliran Province, Eastern Visayas, Philippines**

*Capstone / Undergraduate Thesis Project*

</div>

---

## 📋 Table of Contents

1. [Project Overview](#-project-overview)
2. [Problem Statement](#-problem-statement)
3. [Objectives](#-objectives)
4. [Scope and Limitations](#-scope-and-limitations)
5. [System Features](#-system-features)
6. [Methodology](#-methodology)
7. [Technology Stack](#-technology-stack)
8. [System Architecture](#-system-architecture)
9. [Installation Guide](#-installation-guide)
10. [Project Structure](#-project-structure)
11. [Screenshots](#-screenshots)
12. [Future Enhancements](#-future-enhancements)
13. [Research Team](#-research-team)

---

## 🌏 Project Overview

**BiliPlan** is a mobile application designed to simplify and enhance the tourism planning experience for visitors to **Biliran Island**, a landlocked island province in Eastern Visayas, Philippines. The application automatically generates personalised day-trip itineraries based on user preferences, available transport options, estimated fares, travel time, and safety conditions.

At its core, BiliPlan uses a **Weighted Heuristic Search algorithm** to evaluate and rank possible travel routes and destination combinations. The system selects the most optimal itinerary — balancing cost, time, accessibility, and safety — without requiring an internet connection to a live AI backend.

The project addresses a real and persistent gap in local tourism infrastructure: while Biliran Province possesses numerous natural and cultural attractions (waterfalls, hot springs, island sandbars, beaches), there is no dedicated digital tool to help tourists efficiently plan their visits.

> BiliPlan is not just a travel app — it is a **decision-support system** that empowers both first-time and returning visitors to explore Biliran confidently, affordably, and safely.

---

## ❓ Problem Statement

Tourism in Biliran Province remains underdeveloped relative to its natural assets. Travellers — both domestic and foreign — frequently encounter the following challenges:

| Challenge | Description |
|---|---|
| **Lack of trip planning tools** | No dedicated mobile application exists for Biliran tourism itinerary planning |
| **Unclear route information** | Inter-municipality routes are complex, with multiple transport types (multicab, van, habal-habal, boat) and no consolidated guide |
| **Uncertain transportation fares** | Fare prices vary by season, negotiation, and route — confusing for newcomers |
| **Safety concerns** | Biliran's mountainous terrain and coastal areas pose risks (landslides, weather, flooding) that tourists are often unaware of |
| **Hidden destinations** | Many scenic spots (Kasabangan Falls, Mainit Hot Spring, Agta Beach) lack digital visibility and are rarely visited due to poor routing information |

These problems collectively discourage tourism, result in poor visitor experiences, and represent a missed economic opportunity for local communities.

---

## 🎯 Objectives

### General Objective

To design and develop a mobile-based auto-itinerary generator that uses a Weighted Heuristic Search algorithm to provide tourists with optimised, safety-aware, and budget-conscious travel itineraries for Biliran Province.

### Specific Objectives

- **SO1** — To identify and catalogue the tourist spots, transport routes, fare estimates, and safety risk data of Biliran Province through primary data collection from relevant government agencies and local stakeholders.

- **SO2** — To design and implement a Weighted Heuristic Search algorithm that evaluates candidate itineraries based on multiple criteria: travel cost, travel time, destination relevance, and safety rating.

- **SO3** — To develop a cross-platform mobile application using Flutter that presents the generated itinerary in an accessible, visually rich, and interactive interface.

- **SO4** — To integrate a Fare Guide, Map Preview, and Safety Advisory module that supplements the generated itinerary with actionable travel information.

- **SO5** — To evaluate the usability and effectiveness of the system through user acceptance testing (UAT) with actual tourists and local tourism stakeholders.

---

## 📌 Scope and Limitations

### Scope

- The system covers tourist destinations, transport routes, and fare data exclusively within **Biliran Province** (Naval, Kawayan, Caibiran, Almeria, Cabucgayan, Culaba, Biliran town, Maripipi, and Sambawan Island).
- The application operates on **Android mobile devices** (Flutter-built, targeting Android SDK 21+).
- All destination, route, and fare data is **pre-loaded and curated** from government agencies and field research — the system does not depend on live third-party APIs for its core itinerary function.
- The map integration uses **Google Maps** for visual route display only; routing decisions are handled internally by the heuristic algorithm.

### Limitations

- The system does **not** provide real-time transportation schedules or live fare updates.
- The system uses a **heuristic (rule-based) algorithm**, not a machine learning model; recommendations improve with better data, not with usage patterns.
- The application is **not** connected to a booking or reservation system.
- Safety data is based on **historical and advisory information** from DRRMO and LGUs — it does not reflect real-time weather or disaster conditions.
- The initial release covers **day-trip** itineraries only; multi-day itinerary support is planned for a future version.

---

## ⚙️ System Features

### 1. 🤖 Auto Itinerary Generator
The core feature. Users input their starting point, budget range, available travel time, and preferred activities. The Weighted Heuristic Search engine then evaluates all feasible destination combinations and outputs a ranked, optimised day-trip itinerary — complete with transport modes, estimated fares, and time allocations per stop.

### 2. 🗺️ Map Preview
An interactive Google Maps view centred on Naval, Biliran. The screen displays:
- Colour-coded markers for each tourist spot in the generated itinerary
- A drawn polyline connecting the recommended travel sequence
- Markers appear with staggered animation for visual clarity
- A collapsible bottom panel summarising each route leg with transport type and fare

### 3. 💸 Fare Guide
A browsable, filterable reference of transport fares across Biliran routes. Fares are organised by transport type (Multicab, Van, Jeepney, Habal-habal, Boat) and displayed with route, estimated cost range, and transport badge. Users can filter by transport mode to find specific route pricing.

### 4. 🛡️ Safety Advisory
A curated advisory screen grouped by risk category (weather, landslide, flood, general). Each advisory is colour-coded by severity (Low / Moderate / High) and includes actionable guidance. Data is sourced from DRRMO and LGU advisories for Biliran Province.

### 5. ✏️ Editable Itinerary
After the system generates an itinerary, users can manually adjust it. Stops can be reordered, removed, or have transport modes changed. The system provides recommendations after each edit to maintain route coherence.

### 6. 🧭 Tourist Spot Explorer
*(Planned for next release)* A browsable gallery of Biliran tourist destinations with descriptions, categories (beach, waterfall, hot spring, island), photos, and entry information.

---

## 🔬 Methodology

### Data Collection

Primary data was gathered through coordinated field research and institutional consultations with the following agencies:

| Source | Data Provided |
|---|---|
| **Provincial Tourism Office, Biliran** | Tourist spot names, locations, categories, visitor guidelines |
| **DRRMO (Disaster Risk Reduction Management Office)** | Historical hazard data, safety advisories, flood/landslide zones |
| **Land Transportation Office (LTO) / Transport Groups** | Fare matrices, transport types per route, typical travel times |
| **Local Government Units (LGUs)** | Municipal road conditions, accessibility information, local events |
| **Field Survey / Direct Observation** | GPS coordinates, route traversal times, photo documentation |

### Data Used by the Algorithm

The following data parameters are loaded into the system and used during itinerary computation:

- **Tourist spot records** — name, location (lat/lng), category, accessibility rating
- **Route segments** — origin, destination, transport mode, distance (km)
- **Fare estimates** — minimum and maximum fare range per route segment
- **Travel time estimates** — average duration per route segment by transport type
- **Safety scores** — risk level per destination or route (derived from DRRMO data)

---

### Algorithm — Weighted Heuristic Search

BiliPlan's itinerary engine is based on a **Weighted Heuristic Search**, a decision-making algorithm that assigns numerical weights to multiple evaluation criteria and scores candidate itineraries to find the optimal one.

#### How it Works (Plain Language)

Think of it like a scoring system. When the user submits their preferences, the system:

1. **Generates candidate itineraries** — all feasible combinations of tourist stops reachable within the user's time and budget.
2. **Scores each candidate** using a weighted formula across four criteria:

| Criterion | Weight | Description |
|---|---|---|
| Total Cost (Fare) | High | Lower total fare = higher score |
| Total Travel Time | High | Shorter total time = higher score |
| Destination Relevance | Medium | Match to user's preferred activity type |
| Safety Rating | Medium | Safer routes/destinations score higher |

3. **Ranks candidates** by composite score (highest = recommended itinerary).
4. **Outputs the top-ranked itinerary** as the auto-generated plan.

The "heuristic" component means the algorithm uses educated estimates (averages, typical ranges) rather than exhaustive calculation of every possible permutation — making it efficient and suitable for mobile execution without a backend server.

#### Simplified Formula

```
Score(I) = W₁ × CostScore + W₂ × TimeScore + W₃ × RelevanceScore + W₄ × SafetyScore

Where:
  W₁ + W₂ + W₃ + W₄ = 1.0   (weights sum to 1)
  Each sub-score is normalised to [0, 1]
```

Weights are adjustable per user profile (budget-conscious travellers receive higher W₁; safety-conscious travellers receive higher W₄).

---

### System Workflow

```
┌─────────────────────────────────────────────────────┐
│                   USER INPUT                        │
│  Starting Point · Budget · Time · Activity Type     │
└─────────────────────┬───────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────┐
│              DATA FILTERING                         │
│  Filter destinations by accessibility, category,   │
│  reachability within budget and time constraints    │
└─────────────────────┬───────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────┐
│         WEIGHTED HEURISTIC SEARCH                   │
│  Generate candidate itineraries                     │
│  Score each by: Cost / Time / Relevance / Safety    │
│  Rank by composite score                            │
└─────────────────────┬───────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────┐
│           ITINERARY OUTPUT                          │
│  Display timeline with stops, transport, fares      │
│  Show on Map Preview with route polyline            │
└─────────────────────┬───────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────┐
│             USER EDITING (OPTIONAL)                 │
│  Reorder / remove stops                             │
│  System provides adjustment recommendations         │
└─────────────────────────────────────────────────────┘
```

---

## 🛠️ Technology Stack

| Layer | Technology | Purpose |
|---|---|---|
| **Frontend / UI** | Flutter 3.x | Cross-platform mobile UI framework |
| **Language** | Dart 3.x | Application logic and state management |
| **Navigation** | go_router | Declarative routing and deep linking |
| **Maps** | google_maps_flutter | Interactive map display, markers, polylines |
| **Animations** | flutter_animate, Lottie | Micro-animations and Lottie JSON playback |
| **UI Scaling** | flutter_screenutil | Responsive layout across screen sizes |
| **Typography** | google_fonts | Premium font rendering (Inter, Outfit) |
| **Database** | *(Firebase / MySQL — to be integrated)* | Persistent data storage and sync |
| **State Management** | *(Riverpod — planned)* | Reactive state management layer |

---

## 🏗️ System Architecture

BiliPlan follows a **Feature-First Clean Architecture** pattern, separating the codebase into independent, testable layers.

```
lib/
├── core/                          # Shared foundation
│   ├── constants/                 # App strings, asset paths
│   ├── router/                    # go_router configuration
│   └── theme/                     # Colors, text styles, spacing
│
├── features/                      # Feature modules (independent)
│   ├── onboarding/                # Welcome & onboarding flow
│   ├── home/                      # Dashboard / home screen
│   ├── itinerary/
│   │   ├── input/                 # PlanTripScreen (user preferences)
│   │   ├── generating/            # Loading interstitial (Lottie)
│   │   ├── result/                # ItineraryResultScreen (timeline)
│   │   └── edit/                  # EditItineraryScreen
│   ├── map/                       # MapPreviewScreen (Google Maps)
│   ├── fare/                      # FareGuideScreen
│   └── safety/                    # SafetyScreen
│
├── navigation/                    # MainNavigation (floating tab shell)
│   └── main_navigation.dart
│
└── main.dart                      # App entry point
```

### Architecture Principles

- **Core layer** — contains no feature-specific code; provides shared utilities consumed by all features.
- **Feature layer** — each feature is self-contained with its own `screens/`, `widgets/`, and (future) `data/` and `domain/` sub-directories.
- **Navigation layer** — the `MainNavigation` shell manages an `IndexedStack` of tab screens, preserving scroll position across tab switches.
- **No direct feature-to-feature imports** — features communicate via the router, preventing tight coupling.

---

## 💻 Installation Guide

### Prerequisites

Ensure the following are installed on your development machine:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) — version 3.x or higher
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter extension
- [Git](https://git-scm.com/)
- A Google Maps API key (for the map feature)

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/mobile_tourism_ai_app.git
cd mobile_tourism_ai_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Google Maps API Key

Open `android/app/src/main/AndroidManifest.xml` and replace the placeholder:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE" />
```

> Get your key from [Google Cloud Console](https://console.cloud.google.com) → Enable **Maps SDK for Android**.

### 4. Run the Application

```bash
# List available devices
flutter devices

# Run on a connected Android device or emulator
flutter run

# Run in release mode (for performance testing)
flutter run --release
```

### 5. Build APK (for distribution)

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📁 Project Structure

```
mobile_tourism_ai_app/
├── android/                       # Android platform files
│   └── app/src/main/
│       └── AndroidManifest.xml    # Maps API key configured here
├── assets/
│   ├── animations/                # Lottie JSON files
│   │   ├── travel.json
│   │   └── map_loading.json
│   └── images/                    # Destination photos
│       ├── onboarding_1.png       # Welcome screen image
│       ├── onboarding_2.png       # Problem screen image
│       └── onboarding_3.png       # Solution screen image
├── lib/
│   ├── core/
│   ├── features/
│   ├── navigation/
│   └── main.dart
├── pubspec.yaml                   # Dependencies and asset declarations
└── README.md
```

---

## 🖼️ Screenshots

> *Screenshots will be added after final UI stabilisation.*

| Onboarding | Home Dashboard | Plan Trip |
|:---:|:---:|:---:|
| *(coming soon)* | *(coming soon)* | *(coming soon)* |

| Generating | Itinerary Result | Map Preview |
|:---:|:---:|:---:|
| *(coming soon)* | *(coming soon)* | *(coming soon)* |

| Fare Guide | Safety Advisory | Edit Itinerary |
|:---:|:---:|:---:|
| *(coming soon)* | *(coming soon)* | *(coming soon)* |

---

## 🚀 Future Enhancements

The following features are identified for post-thesis or Version 2 development:

| Feature | Priority | Description |
|---|---|---|
| **Real-time weather integration** | High | Connect to PAGASA or OpenWeatherMap API for live safety updates |
| **Live transportation updates** | High | Partner with local transport cooperatives for real-time fare/schedule data |
| **Tourist Spot Explorer** | Medium | Full browsable gallery with photos, ratings, and visitor reviews |
| **Multi-day itinerary support** | Medium | Allow planning across 2–5 day trips with accommodation suggestions |
| **Offline-first mode** | Medium | Full offline capability for areas with poor connectivity in Biliran |
| **AI recommendation engine** | Low | Replace heuristic weights with a trained recommendation model |
| **iOS support** | Low | Extend the Flutter build to Apple App Store deployment |
| **Multilingual support** | Low | Add Waray and Filipino language options |

---

## 👥 Research Team

| Role | Name |
|---|---|
| **Lead Developer / Researcher** | *(Your Name)* |
| **Research Adviser** | *(Adviser Name)* |
| **Institution** | *(Your University / College)* |
| **Department** | *(e.g. BS Information Technology)* |
| **Academic Year** | 2025–2026 |

---

## 📄 Citation

If you reference this project in academic work, please cite as:

```
[Author(s)]. (2026). BiliPlan: A Mobile-Based Auto-Itinerary Generator using
Weighted Heuristic Search for Sustainable Local Tourism.
Undergraduate Thesis, [Institution Name], Biliran Province, Philippines.
```

---

## 📜 License

This project is developed for **academic and research purposes** as part of an undergraduate capstone thesis. Redistribution or commercial use without explicit permission from the authors is not permitted.

---

<div align="center">

Made with ❤️ for Biliran Island, Philippines 🌴

*"Explore smarter. Travel safer. Discover Biliran."*

</div>
