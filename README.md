# Noor Athkar

**Noor Athkar** is a premium digital sanctuary for daily Islamic remembrance — a Flutter-powered mobile companion that brings together prayer times, Quran reading, tasbeeh, athkar, Qibla direction, and nearby mosques in one beautifully crafted experience.

Built with **Material 3**, a rich dual-language interface (Arabic/English), and **offline-first** principles, the app combines modern design with the timeless traditions of Islamic practice.

## Features

| Feature | Description |
|---|---|
| **Prayer Times** | GPS-aware calculations (Adhan library, Egyptian method) with live countdowns and scheduled notifications |
| **Athkar** | 10 categories of daily remembrances with tap-to-count, transliteration, translation, and progress persistence |
| **Tasbeeh** | Digital counter with 7 dhikr presets, radial progress ring, and haptic feedback |
| **Quran Reader** | Full Mushaf-style page-by-page reader (604 pages) with offline Hive caching and Surah/Juz/Page index |
| **Qibla Compass** | Real-time direction using the device magnetometer, corrected for magnetic declination |
| **Mosques** | Nearby mosque locator via a FastAPI proxy to OpenStreetMap's Overpass API |
| **Reminders** | 17 built-in notification types (prayer, fasting, Surah Al-Kahf, etc.) + user-defined custom reminders |
| **Dashboard** | Home screen with Hijri date, current prayer countdown, and quick-access grid |

## Architecture

```
lib/
├── main.dart              ← App entry, providers, bottom navigation shell
├── core/                  ← Shared infrastructure
│   ├── constants/         ← Static data (Kaaba coords, prayer names)
│   ├── providers/         ← ChangeNotifier state managers (Provider)
│   ├── services/          ← Business logic & API integrations
│   ├── storage/           ← Hive & SharedPreferences persistence
│   ├── theme/             ← Design system (colors, typography, themes)
│   └── widgets/           ← Reusable UI components
├── modules/               ← Pure data models & static content
└── screens/               ← Feature-organized UI pages
```

**State management:** Provider (3 app-level `ChangeNotifier`s — `SettingsProvider`, `PrayerTimeProvider`, `TasbeehProvider`).

## App Flow

```
Splash Screen → Onboarding (3 pages) → AppShell (5-tab bottom nav)
    ↑                                    ↑
    └───── first launch only ────────────┘
```

### Start-up Sequence
1. Lock portrait orientation, initialize Hive (6 boxes)
2. Load persisted settings (theme, locale, toggles)
3. Load cached location & calculate prayer times
4. `MultiProvider` wraps the app → `SplashScreen` → onboarding or main app

### Bottom Navigation
| Tab | Screen | Purpose |
|-----|--------|---------|
| 0 | Dashboard | Home — prayer times, countdowns, quick access |
| 1 | Athkar | 10 categories of daily remembrances |
| 2 | Tasbeeh | Digital counter with progress ring |
| 3 | Quran | Surah/Juz/Page index + reader |
| 4 | Settings | Language, theme, toggles, about |

## Feature Deep-Dive

### Dashboard
Home screen with staggered fade/slide animations containing:
- **Greeting header** — time-based greeting, Hijri date, GPS location with status & retry
- **Current prayer card** — gradient card showing current prayer name, live clock, countdown to next prayer (HH:MM:SS ticking every second)
- **Prayer times list** — all 6 prayers (Fajr → Isha) with custom icons, current prayer highlighted with gold dot
- **Today's special times** — 2×3 grid: Midnight, Last Third, Duha, Morning/Evening Athkar, 4th Sixth
- **Quick access grid** — 6 tiles: Athkar, Quran, Tasbeeh (tab switch) + Qibla, Mosques, Reminders (pushed screens)

### Athkar
10 category cards (Morning, Evening, Sleep, After Prayer, Travel, Home, Food, Bathroom, Ruqya Sunnah, Ruqya Quran) each with unique icon and color. Tap opens vertical `PageView` reader with:
- Arabic text (Amiri font), English translation, hadith reference
- Tap-to-count chip tracking repeat target progress
- Per-dhikr progress persisted in Hive, category-level reset

### Tasbeeh
Digital counter with gold radial progress `CustomPainter`:
- 7 dhikr presets as horizontal choice chips (33/34/100 counts)
- Tap center → increment with pulse animation + haptic feedback
- Lifetime total (never reset) and per-dhikr count persisted in Hive
- Reset dialog with confirmation

### Quran
**Index** (3 tabs): Surahs (114), Juz (30), Pages (1–604 grid with juz-boundary gold highlighting). Searchable quick-jump bottom sheet.

**Reader**: Full Mushaf-style page-by-page swipe reader. Fetches Uthmani script from `api.alquran.cloud`, cached in Hive for offline. Pre-loads adjacent pages. Features surah headers with ornament, Arabic-Indic numerals, tap-to-toggle controls, top bar (surah name/juz), bottom slider, and jump dialog (Surah/Juz/Page/Ayah tabs).

### Qibla
Real-time compass pointing to Kaaba (21.4225°N, 39.8262°E):
- Great-circle bearing calculation from GPS location
- `flutter_compass` for magnetometer readings
- `geomag` for magnetic declination correction
- Exponential moving average smoothing (alpha=0.25)
- Custom painted dial with tick marks, cardinal labels (AR/EN), red North
- Rotating Qibla marker arrow with label
- Calibration instructions and recalibrate button

### Mosques
- Fetches GPS location → calls FastAPI backend → proxies OpenStreetMap Overpass API (3 fallback mirrors)
- Results sorted by distance, displayed with name, address, distance, and "Directions" button (Google Maps via url_launcher)
- Error/empty states handled

### Reminders
**17 built-in types:** Prayer alerts (6 + 10min pre-alerts), Duha, Morning/Evening Athkar, Midnight/Last Third/4th Sixth, Monday/Thursday fasting, White Days, Surah Al-Kahf (Friday 6AM), Month Entrance Dua. Each toggleable + "Try" test button.

**Personal reminders (CRUD):** User-created notifications with fixed time or prayer-relative scheduling (before/after N minutes of selected prayer). Persisted as JSON in SharedPreferences.

### Settings
6 tiles: Language toggle (AR/EN → triggers provider + reschedule), Theme cycle (System/Light/Dark), Prayer notifications master switch, Athkar reminders master switch, Haptic feedback toggle, About dialog with guidance.

## State Management (Provider)

| Provider | Key State | Persistence |
|----------|-----------|-------------|
| `SettingsProvider` | themeMode, locale, onboarding flag, haptic, prayer/athkar toggles | SharedPreferences |
| `PrayerTimeProvider` | prayer times, Hijri date, special times, location, loading/error | SharedPreferences (cached location) |
| `TasbeehProvider` | count, totalCount, target, current dhikr, progress | Hive |

## Service Layer

| Service | Role | Dependencies |
|---------|------|-------------|
| `PrayerTimeService` | Singleton — 6 prayer times (Egyptian method, Shafi madhab), derived times (midnight, last third, duha, 4th sixth), Hijri date, 12h formatting | `adhan`, `hijri_date` |
| `LocationService` | Singleton — GPS resolution chain (cached → last known → high accuracy → medium → Makkah default), geocoding | `geolocator`, `geocoding` |
| `NotificationService` | Singleton — daily/weekly scheduling, 2 Android channels (prayer with Athan sound, general), 17+ notification types, personal CRUD | `flutter_local_notifications`, `timezone` |
| `QuranPageService` | Fetch pages from Alquran.cloud, cache in Hive for offline | `http`, Hive |
| `MosqueService` | HTTP client for FastAPI `/api/mosques/nearby` | `http` |

## Storage Layer

| Storage | Data |
|---------|------|
| SharedPreferences | Theme, locale, onboarding, toggles, cached GPS, disabled reminders, personal notifications metadata |
| Hive (6 boxes) | Quran pages (offline cache), Quran juz data, athkar favorites, tasbeeh history + lifetime, app cache, athkar progress per dhikr |

## Backend (FastAPI — `backend/main.py`)

| Endpoint | Description |
|----------|-------------|
| `GET /` | Health check `{status, service, version}` |
| `GET /api/mosques/nearby?lat=&lng=&radius=` | Proxies OSM Overpass API (3 fallback mirrors, 25s timeout), returns `List[MosqueResult]` with name, address, lat, lng |

Shared `httpx.AsyncClient` with connection pooling, CORS open (dev mode), env vars via `python-dotenv`, runs on uvicorn port 8000.

## Theme & Design System

- **Colors**: Deep greens (#0A3D2C, #004337), warm gold (#C99B3B), cream, sand, mutedSage. Full Material 3 color schemes for light + dark.
- **Typography**: Manrope (Google Font) for English UI, Amiri for Arabic sacred text (20% larger).
- **Components**: GlassCard with frosted-glass effect, decorative dot-pattern background, custom gradients.

## Data Flow

```
User opens app
  → Splash → Onboarding (if first) → AppShell
  → PrayerTimeProvider.init()
      → LocationService.resolve() (GPS → cached → Makkah)
      → PrayerTimeService.setCoordinates()
          → Adhan → 6 prayer times + derived times
      → NotificationService schedules all 17+ types
  → UI renders from providers

Location/date change → PrayerTimeProvider.refresh()
  → Recalculate → Notify → Reschedule notifications

Athkar: tap → Hive.saveDhikrProgress() → UI update
Quran: fetch → Hive cache → return → render page
Tasbeeh: tap → HapticFeedback + Hive.cacheValue() → UI
Mosques: GPS → FastAPI → Overpass API → sort → display
Qibla: GPS → bearing calc → compass stream → smooth → rotate dial
```

## Setup

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

Run tests:

```bash
flutter test
```

## Backend

The optional local backend lives in `backend/`. Copy `backend/.env.example` to `backend/.env`, fill in any required keys, then install and run the Python service from that folder.
