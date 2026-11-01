# Al-Furkan: Zen Hifz Edition (Distraction-Free Quran Memorization)

A serene, ultra-focused Quran memorization (Hifz) application engineered with a calm "Zen Hifz" aesthetic, 3-tier verse masking, multi-Riwayah audio repetition engine, live WebRTC friends audio circle (Halaqa), escalating Fajr alarms, and dual delivery as an offline-first PWA for browser preview plus an exported native Flutter Android codebase.

## User Review & Critical Decisions

> [!IMPORTANT]
> The following architectural decisions have been synthesized from your requirements and confirmed via Phase 1 clarification:

- **Confirmed Delivery Strategy**: Dual-architecture delivery. We will build the fully functional, interactive, offline-ready Zen Hifz PWA directly in the AI Studio live preview, and simultaneously generate a clean, modular Flutter project (`flutter_app/`) configured with `pubspec.yaml`, `AndroidManifest.xml`, `adhan_dart`, `alarm`, `just_audio`, and `livekit_client` ready for `flutter build apk --release`.
- **Confirmed Verse Masking Interaction**: Three-tier progressive masking (`Visible` ➔ `Blurred` ➔ `Hidden` with tap-to-peek).
- **Confirmed Default Riwayah & Reciter**: Hafs 'an 'Asim with Sheikh Mahmoud Khalil Al-Husary (Muallim edition) as the default reciter.
- **Audio Delivery Mode**: Dual audio architecture utilizing Ayah-by-Ayah MP3s (EveryAyah CDN for Hafs & Warsh) and Surah timestamp slicing for Qalun recitation.

---

## 1. Overview & Core Concept

- **What It Does**: Strips away all non-essential Quranic tools (lengthy tafsirs, 200+ translation books, complex multi-tier menus) to provide an uncompromising, distraction-free memorization haven. The interface focuses strictly on loop repetition, connecting linked verses in memory, audio recitation with friends, and unignorable prayer/Fajr memorization alarms.
- **Target Audience / Persona**: Serious Huffaz, students of sacred knowledge, and circles of friends preparing to memorize and review the Holy Quran daily.
- **Key Value**: Eliminates cognitive fatigue through calm earth tones, automatic UI chrome hiding during recitation, and deterministic gapless repetition with programmable silence pauses for reciting along.

---

## 2. User Experience & Visual Design

### Key User Flows

1. **Active Memorization ("Zen Focus Mode")**:
   - The user opens the app and immediately resumes at their active Surah & Ayah range.
   - When repetition or playback starts, top headers and bottom navigation gracefully fade out.
   - Only the target verses occupy the screen in high-contrast Uthmanic calligraphy with generous vertical spacing.
   - A floating translucent bottom pill displays the current loop count (`"Ayah 2:255 · Loop 3/7"`), an eye icon to toggle masking on the fly, and play/pause controls.
2. **One-Sheet Repetition Setup**:
   - Clicking `"Setup Session"` pulls up a single clean bottom sheet with intuitive steppers:
     `[Riwayah: Hafs | Qalun | Warsh]` ➔ `[Reciter]` ➔ `[From Ayah A to Ayah B]` ➔ `[Single Repeat: N]` ➔ `[Link Group: M]` ➔ `[Pause Delay: X sec]`.
3. **Halaqa (Friends Audio Room)**:
   - One-tap audio room entry with a room code.
   - Clean speaker avatar bubbles with a gentle sage pulse around the active reciter.
   - Live synchronization of current Surah, verse range, and active turn across all devices.
4. **Schedule & Escalating Alarms**:
   - 5-prayer timeline calculated via the Tunisia method (18° Fajr, 18° Isha).
   - Strict 4-tier escalating alarms spaced 5 minutes apart that require completing a Hifz session or snooze.

### Visual Identity & Theme

- **Light Mode Palette**:
  - Background Canvas: Warm paper `#FBF8F3` (60%)
  - Surface Cards & Sheets: Soft stone `#F2ECE1` (30%)
  - Deep Typography: Charcoal `#1E201D`
  - Accent Color: Calm Sage Green `#4A6B5D` (10%)
- **Dark / Night Hifz Mode Palette**:
  - Background Canvas: Deep nocturnal slate `#121615` (60%)
  - Surface Cards: Subtle charcoal slate `#1A201D` (30%)
  - Quranic Typography: Warm amber cream `#E6D5B8` (specifically calibrated to prevent blue-light eye strain during Fajr and Tahajjud memorization)
  - Accent Color: Muted sage `#7FA695` (10%)
- **Typography & Scale**:
  - Quranic Calligraphy: `Amiri Quran` / `KFGQPC Uthmanic Script` (font size adjustable from 22px to 44px with zero layout shift).
  - UI Labels: Clean, unboxed typography using `Cairo` and `Plus Jakarta Sans`.
  - Tabular Numerals: Tabular monospace figures for loop countdowns and prayer times.
- **Strict Anti-Slop & Zero-Pill Discipline**:
  - No static pill capsules or decorative green pulsing dots on non-live content.
  - No code comments or fake technical telemetry tags (`// 01_CORE`).
  - No thick left accent borders; clean hairline dividers and natural spatial margins.

---

## 3. Key Product Decisions & Trade-Offs

- **Decision 1: Dual-Platform Strategy (Interactive PWA + Exported Flutter APK Codebase)**
  - *Chosen Approach*: Deliver the complete Zen Hifz experience inside the AI Studio web container as a PWA, while structuring a clean, self-contained `flutter_app/` folder with complete Dart/Flutter source files, dependencies, and build configs.
  - *Why*: AI Studio runs on a Linux Node.js environment without native Android SDK / Flutter CLI. Building the live app as a PWA allows instant testing and daily use on mobile browsers (with home-screen install and offline caching), while the Flutter export enables building the private Android release APK (`flutter build apk --release`).
- **Decision 2: Three-Tier Masking (Visible ➔ Blurred ➔ Hidden)**
  - *Chosen Approach*: Instant toggle between unmasked text, CSS-blurred text (revealed on tap or hover), and completely hidden placeholder dots.
  - *Why*: Allows graduated memorization testing without requiring continuous, battery-draining mic permissions or cloud ASR round-trips.
- **Decision 3: Multi-Riwayah Verse Mapping**
  - *Chosen Approach*: Store verse mapping offsets between Kufic (6,236 verses for Hafs) and Madani (6,214 verses for Qalun and Warsh) to ensure accurate numbering and audio synchronization.

---

## 4. Technical Architecture & Data Strategy

### System & Component Architecture Diagram

```
┌────────────────────────────────────────────────────────────────────────┐
│                        AL-FURKAN: ZEN HIFZ                             │
└──────────────────────────────────┬─────────────────────────────────────┘
                                   │
      ┌────────────────────────────┼───────────────────────────┐
      ▼                            ▼                           ▼
┌──────────────┐          ┌────────────────┐          ┌────────────────┐
│  Hifz &      │          │  Halaqa        │          │  Schedule &    │
│  Mushaf View │          │  Friends Room  │          │  Alarms View   │
└──────┬───────┘          └───────┬────────┘          └────────┬───────┘
       │                          │                            │
       ├─ Zen Focus Mode          ├─ WebRTC Audio Channel      ├─ Tunisia Method
       ├─ 3-Tier Masking          ├─ Active Reciter Pulse      ├─ 5 Prayer Timeline
       ├─ One-Sheet Setup         └─ Room Sync DataChannel     └─ Escalating Chain
       │
       ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    HYBRID AUDIO & STORAGE CORE                       │
├──────────────────────────────────┬───────────────────────────────────┤
│ Audio Repetition Engine          │ Local Storage & Cache             │
│ • Single Verse: N loops          │ • Last active Surah & Ayah        │
│ • Linked Group: M loops          │ • Riwayah preference (Hafs/Qalun) │
│ • Pause Delay: X seconds silence │ • Completed loop history          │
│ • EveryAyah CDN / Sliced Timings │ • Scheduled alarm configurations  │
└──────────────────────────────────┴───────────────────────────────────┘
```

### Data Models & State Stores

1. **HifzSessionState**:
   - `surahNumber`: number (1–114)
   - `startAyah`: number, `endAyah`: number
   - `singleRepeatCount`: number (e.g. 5)
   - `linkGroupSize`: number (e.g. 3)
   - `linkGroupRepeatCount`: number (e.g. 3)
   - `pauseDelaySeconds`: number (e.g. 2)
   - `riwayah`: `'hafs' | 'qalun' | 'warsh'`
   - `reciterId`: string
   - `maskingMode`: `'visible' | 'blurred' | 'hidden'`
   - `currentLoop`: number, `totalLoops`: number
2. **HalaqaRoomState**:
   - `roomId`: string, `userName`: string
   - `participants`: Array<{ id: string; name: string; isSpeaking: boolean; currentTurn: boolean }>
   - `sharedAyahRange`: { surah: number; startAyah: number; endAyah: number }
3. **AlarmSchedule**:
   - `prayerId`: `'fajr' | 'dhuhr' | 'asr' | 'maghrib' | 'isha'`
   - `time`: string, `isEnabled`: boolean
   - `escalationCount`: number (default: 4 alarms spaced 5 minutes apart)

### Flutter APK Export Structure (`flutter_app/`)

- `pubspec.yaml`: Preconfigured with `hive_ce`, `just_audio: ^0.10.6`, `audio_service`, `recite_quran: ^1.0.5`, `livekit_client: ^2.9.0`, `adhan_dart: ^2.0.1`, and `alarm: ^5.15.0`.
- `android/app/src/main/AndroidManifest.xml`: Clean configuration with all required permissions (`INTERNET`, `RECORD_AUDIO`, `WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM`, `USE_FULL_SCREEN_INTENT`).
- `lib/main.dart` & `lib/core/theme/app_theme.dart`: The Zen Hifz theme, bottom navigation, and core screen implementations matching the specification.
