# Multi-Riwayah Quranic Text & Combined Block Repetition Engine

A comprehensive enhancement to the Zen Hifz memorization suite: delivering authentic Uthmanic digital scripts with specific diacritics for each Quranic Riwayah (Hafs 'an 'Asim, Warsh 'an Nafi', and Qalun 'an Nafi'), coupled with a flexible repetition engine that switches seamlessly between single-verse cycles and combined multi-verse block loops.

## User Review & Critical Decisions

> [!IMPORTANT]
> The following architectural decisions have been synthesized directly from your requirements and confirmed via Phase 1 clarification:

- **Confirmed Quranic Text Presentation**: Digital Uthmanic calligraphy with Riwayah-specific diacritics (*dabt*, *naql*, *imala*, and stopping signs). When switching between Hafs, Warsh, or Qalun, the application immediately updates the rendered Mushaf text to the verified digital Uthmanic script of that narration.
- **Confirmed Repetition Mode Behavior**: Dual-mode repetition switchable in the session configuration sheet:
  1. **Combined Block Loop (`combined_block`)**: Plays the entire selected Ayah range (e.g. Ayahs 3 to 5: $3 \rightarrow 4 \rightarrow 5$) consecutively as a unified passage, pauses for the configurable recitation delay, and repeats the entire block $N$ times.
  2. **Single-Verse Cycle (`verse_by_verse`)**: Progresses verse-by-verse ($N$ repetitions per verse) followed by group linking loops ($M$ repetitions of connected verses).
- **Offline Reliability & Performance**: Pre-cached digital Uthmanic datasets for Hafs, Warsh, and Qalun served locally with zero external network lag, complemented by resilient online fallbacks.

---

## 1. Overview & Core Concept

- **What It Delivers**: 
  1. **Authentic Riwayah Mushaf Experience**: Students and Huffaz memorizing according to Warsh or Qalun will no longer see Hafs text mismatched with their recitation. The Mushaf view displays the exact orthography, vocalization signs, and Madani verse counts appropriate for their chosen Riwayah.
  2. **Passage-Level Block Repetition**: Huffaz often memorize connected passages or stories (e.g., a 3-to-5 verse section) as a cohesive unit. The combined block mode enables reciting and looping the whole section together before moving to the next portion.
- **Target Audience / Persona**: Huffaz, Quran teachers, and students in North Africa, West Africa, and across the Islamic world who study diverse Qira'at and need tailored passage repetition.
- **Key Value**: Unifies recitation audio, calligraphy, and repetition logic into an authentic, distraction-free environment that mirrors physical Mushafs and traditional memorization methods (*al-Lawh* and block review).

---

## 2. User Experience & Visual Design

### Key User Flows

1. **Selecting Riwayah & Instant Text Transformation**:
   - The user opens "إعداد جلسة الحفظ والتكرار" (Repetition Setup Sheet).
   - Under "الرواية القرآنية", selecting **حفص عن عاصم**, **قالون عن نافع**, or **ورش عن نافع** instantly reflects in the reciter selection and updates the active Mushaf script in the background.
   - When the session is active, a subtle Riwayah badge (e.g., `مصحف قالون عن نافع · الرسم العثماني`) appears in the top status bar.
   - Any Riwayah-specific orthography (e.g., `مَلِكِ يَوْمِ ٱلدِّينِ` without dagger alif in Warsh/Qalun vs. `مَـٰلِكِ` in Hafs, or distinct dotting conventions) renders cleanly with crisp Uthmanic typography.

2. **Configuring Combined Block vs. Verse-by-Verse Repetition**:
   - In the Setup Sheet, a segment controller allows toggling:
     - `[تكرار الآيات مجمعة (كتلة واحدة)]` (*Combined Block*)
     - `[تكرار آية بآية (فردي ثم ربط)]` (*Verse by Verse*)
   - When **Combined Block** is active:
     - The user picks their verse range (e.g., Ayahs 1 to 5 of Surah Nuh).
     - Steppers configure: **عدد تكرار المقطع (N)** (Block loops: e.g. $\times 5$), and **فترة الصمت للترديد (X ثوانٍ)** (Recitation pause after each pass: e.g. $4\text{s}$).
     - The floating player status dynamically reads: `"المقطع المجمع (١-٥) · دورة ٢ من ٥ · تلاوة الآية ٣"`.
   - When **Verse by Verse** is active:
     - Shows the traditional dual-tier controls: Single Ayah repeat ($N$) + Link group repeat ($M$).

3. **Active Zen Memorization with 3-Tier Masking & Audio Speed**:
   - The user toggles masking mode (`ظاهر` / `مموه` / `مخفي`) and playback speed ($0.75\times$ to $1.5\times$).
   - In Combined Block mode, the active Ayah currently being recited is highlighted with a gentle sage glow, while the surrounding block remains visible or peekable according to the masking tier.

### Visual Identity & Layout Harmony

- **Color Tokens**:
  - Light mode: Paper parchment `#FBF8F3` with soft stone cards `#F2ECE1` and deep charcoal typography `#1E201D`.
  - Dark mode: Nocturnal slate `#121615` with warm amber calligraphy `#E6D5B8` to protect nocturnal vision during Tahajjud and Fajr.
  - Accent: Muted sage `#4A6B5D` (light) / `#7FA695` (dark).
- **Calligraphic Typography**:
  - `Amiri Quran` and `KFGQPC Uthmanic Script` styled with authentic Quranic ligature rendering (`font-feature-settings: "cv01", "ss01"`).
  - Scalable font sizing ($24\text{px}$ to $44\text{px}$) with zero horizontal reflow.
- **Ergonomic Touch Targets**:
  - All mode segment switches, steppers, and audio controls conform to minimum $44 \times 44\text{px}$ touch envelopes.

---

## 3. Key Product Decisions & Trade-Offs

- **Decision 1: Verified Riwayah Digital Script Integration**
  - *Chosen Approach*: Embed structured digital Uthmanic text datasets for Hafs, Warsh, and Qalun in `assets/quran_script/` (e.g. `Warsh.json`, `Qalun.json`, `Uthmani.json`) with an automatic API fallback to Quranpedia/Quran.com.
  - *Why*: Eliminates network dependence and latency during daily memorization sessions. Digital text allows instant font scaling, 3-tier masking (blur/hide/reveal), and high-contrast rendering that image-based Mushafs cannot support.
  - *Alternatives Considered*: Scanned Mushaf page images (discarded because they cannot support interactive font scaling, tap-to-peek masking on individual verses, or night-mode amber recoloring).

- **Decision 2: Dual Repetition Pipeline (`combined_block` vs `verse_by_verse`)**
  - *Chosen Approach*: Parameterize the playlist generation in `HifzAudioEngine` and Flutter `AudioPlayerService` with `repetitionMode: 'verse_by_verse' | 'combined_block'`.
  - *Why*: Accommodates both foundational memorization (where single-ayah drilling is essential) and intermediate review/consolidation (where hearing the entire phrase or scene linked together is crucial).
  - *Alternatives Considered*: Forcing users to set Single Repeat to 1 and Link Group to 100% (counter-intuitive and confusing to configure).

- **Decision 3: Multi-Riwayah Verse Numbering & Metadata Normalization**
  - *Chosen Approach*: Handle the Madani count differences (e.g., Warsh and Qalun having 6,214 verses where certain verses are merged or split compared to Hafs' 6,236 Kufic count) cleanly in `quranService.ts` and `ZenHifzView.tsx`, so the Ayah pickers and counters accurately reflect the chosen Riwayah.

---

## 4. Technical Architecture & Data Strategy

### System Architecture Diagram

```
┌────────────────────────────────────────────────────────────────────────┐
│                        AL-FURKAN: ZEN HIFZ                             │
└──────────────────────────────────┬─────────────────────────────────────┘
                                   │
       ┌───────────────────────────┴───────────────────────────┐
       ▼                                                       ▼
┌──────────────────────────────┐              ┌──────────────────────────────┐
│     MUSHAF TEXT ENGINE       │              │    HIFZ REPETITION CORE      │
│  (Multi-Riwayah Rendering)   │              │     (Dual-Mode Playlist)     │
├──────────────────────────────┤              ├──────────────────────────────┤
│ • Hafs: Uthmani.json         │              │ • Mode: 'combined_block'     │
│ • Warsh: Warsh.json          │              │   [A -> B -> C] x N loops    │
│ • Qalun: Qalun.json          │              │ • Mode: 'verse_by_verse'     │
│ • Fallback: Quranpedia / API │              │   [A x N] -> [B x N] -> Link │
│ • 3-Tier Masking (Peekable)  │              │ • Configurable Silence Delay │
│ • Riwayah Badge & Metadata   │              │ • Voice Speed (0.75x - 1.5x) │
└──────────────┬───────────────┘              └──────────────┬───────────────┘
               │                                             │
               └──────────────────────┬──────────────────────┘
                                      ▼
                      ┌───────────────────────────────┐
                      │    ZEN HIFZ VIEW CONTROLLER   │
                      │  • Synchronized Verse Glow    │
                      │  • Loop Stage Indicator       │
                      │  • Web + Flutter Parity       │
                      └───────────────────────────────┘
```

### Data Models & State Contracts

```typescript
// src/types/hifz.ts
export type Riwayah = 'hafs' | 'qalun' | 'warsh';
export type RepetitionMode = 'verse_by_verse' | 'combined_block';

export interface HifzSessionConfig {
  surahNumber: number;
  startAyah: number;
  endAyah: number;
  repetitionMode: RepetitionMode; // NEW: 'verse_by_verse' | 'combined_block'
  blockRepeatCount: number;       // NEW: N repetitions for the combined block
  singleRepeatCount: number;      // N repetitions per verse (verse_by_verse)
  linkGroupSize: number;          // G verses linked
  linkGroupRepeatCount: number;   // M repetitions for linked groups
  pauseDelaySeconds: number;      // Silence gap for student recitation
  riwayah: Riwayah;               // Selected narration
  reciterId: string;
  maskingMode: MaskingMode;
  fontSize: number;
  playbackRate: number;           // 0.75x, 1.0x, 1.25x, 1.5x
}
```

### Component & File Implementation Blueprint

1. **`src/types/hifz.ts`**:
   - Add `RepetitionMode = 'verse_by_verse' | 'combined_block'`.
   - Add `repetitionMode` and `blockRepeatCount` to `HifzSessionConfig`.
2. **`src/services/quranService.ts`**:
   - Update `getSurahAyahs(surahNumber: number, riwayah: Riwayah = 'hafs')` to dynamically load the corresponding Riwayah dataset (`Uthmani.json`, `Warsh.json`, or `Qalun.json`).
   - Implement multi-tier caching and fallback mechanisms.
3. **`assets/quran_script/`**:
   - Provide verified, complete Uthmanic JSON datasets for `Warsh.json` and `Qalun.json` alongside the existing `Uthmani.json`.
4. **`src/services/hifzAudioEngine.ts`**:
   - In `buildPlaylist()`:
     - If `repetitionMode === 'combined_block'`: Construct $N$ block loops where each loop plays all verses from `startAyah` to `endAyah` in sequence, followed by the pause delay at the end of each block pass.
     - If `repetitionMode === 'verse_by_verse'`: Maintain the granular single-verse + link-group repetition sequence.
   - Update `HifzPlaybackState` description to clearly communicate block progress (e.g. `المقطع (١-٣) • تكرار ٢ من ٥`).
5. **`src/components/RepetitionSetupSheet.tsx`**:
   - Add Repetition Mode toggle (`تكرار مقطع مجمع` vs `تكرار آية بآية`).
   - Adjust input fields dynamically: show Block Repetition stepper when in combined mode, and Single/Link steppers when in verse-by-verse mode.
   - Update Riwayah selector to indicate that both text and recitation will adapt.
6. **`src/components/ZenHifzView.tsx`**:
   - Trigger verse reload when `sessionConfig.riwayah` changes as well as `sessionConfig.surahNumber`.
   - Render Riwayah name pill in the top header.
   - Synchronize block highlight and audio tracking.
7. **Flutter Companion App Parity (`flutter_app/`)**:
   - Update `audio_player_service.dart` and `zen_hifz_screen.dart` with `HifzRepetitionMode` enum and block looping logic.
   - Update `public/flutter_app.zip` to reflect all latest changes.
