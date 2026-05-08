# Phase 4: Stay Immersed - Research

**Researched:** 2026-05-08
**Phase:** 4 (Stay Immersed)
**Confidence:** HIGH

## Overview

Phase 4 makes the companion app itself model immersion. The interface should present mostly in the target language, help should appear inline without interruption, and the user should stay in their existing app flow. This builds on Phases 1-3 (reading lookup, OpenAPI/TTS configuration, writing assistance) by minimizing the English chrome and ensuring help stays subtle and non-blocking.

## Key Findings

### 1. SwiftUI Localization (IMMR-01)

**What:** The companion panel, overlay, and response UI all use hardcoded English strings. To present the interface in the target language, we need proper localization.

**How:**
- SwiftUI supports `LocalizedStringKey` and automatic `Text("key")` string lookup via `Localizable.xcstrings` (String Catalog).
- Xcode 15+ imports/creates String Catalogs that merge seamlessly with `xcstrings` files.
- The development language stays English; the target language is added as an additional localization.
- `Bundle.main.localizedString(forKey:value:table:)` provides fallback to development language (English) when a key is missing in the target language.

**Key approach:**
1. Create `Localizable.xcstrings` in the project (not as a separate `.strings` file — `xcstrings` is the modern format).
2. Extract all user-facing strings from `CompanionPanelView.swift`, `CompanionResponseOverlay.swift`, `WritingAssistAnnotationView.swift`, and any other view files.
3. Replace `Text("literal string")` with localizable patterns where needed. In SwiftUI, `Text("Hello")` is already localizable by default — it looks up "Hello" as a key in the String Catalog. For view code, mostly just ensure strings are surfaced to the catalog.
4. Add a target language preference in the settings section of the panel — "What language are you learning?" picker.

**Language behavior:**
- The app uses the target language as the UI language for all app-provided text.
- When a string is missing in the target language, English is shown as fallback (SwiftUI/Foundation behavior).
- The system language is NOT changed — only the app's localization is overridden.
- `AppleLanguages` UserDefaults key can override per-app language without system-wide change.

**Relevant existing patterns:**
- `DesignSystem.swift` centralizes tokens — no design-token changes needed, but localized strings may need helpers.
- `CompanionManager.swift` already stores per-user preferences via `UserDefaults`.
- `AppBundleConfiguration.swift` reads Info.plist values — language preference can follow the same pattern.

### 2. Non-Disruptive Help Interaction (IMMR-02 + SC 3)

**What:** Help should appear inline and contextual, never as a modal interruption. The user should keep working in their app while the companion helps subtly.

**How:**
- The existing overlay pattern (`OverlayWindow.swift`) already provides non-blocking help presentation — it's a transparent, non-activating NSPanel.
- The transient cursor mode (documented in AGENTS.md) already auto-dismisses after 1s of inactivity.
- Need to ensure NO user-facing confirmation dialogs, blocking alerts, or modal sheets interrupt the help flow.

**Specific patterns to preserve/enforce:**
1. **No blocking dialogs** — All help is opt-in via hotkey. Never auto-trigger help that requires dismissal.
2. **Auto-dismiss** — After a help interaction completes (reading lookup, writing assist), auto-dismiss the overlay after a configurable timeout. The transient cursor pattern already does this — extend to all help surfaces.
3. **Click-outside dismiss** — The panel already dismisses on click-outside (MenuBarPanelManager). Ensure all help surfaces follow this pattern.

### 3. Immersion Mode Toggle

**What:** Users should be able to choose between "learning mode" (more English guidance, slower dismiss) and "immersion mode" (mostly target language, faster dismiss, minimal chrome).

**How:**
- Add an `immersionLevel` enum to CompanionManager: `.learning`, `.balanced`, `.immersed`
- Learning mode: bilingual labels, longer auto-dismiss timeout (8s), full explanations
- Balanced mode (default): target language UI, normal dismiss (4s), concise help
- Immersed mode: target language only, fast dismiss (2s), minimal help surface
- The setting lives in the companion panel's settings section

### 4. Dependency on Prior Phases

**Phase 1 (Read in Place):** Core reading lookup, vocabulary save, and panel/overlay patterns already exist.

**Phase 2 (OpenAPI/Local TTS):** Model configuration is already wired.

**Phase 3 (Write with Guidance):** Writing assist hotkey and annotation patterns are already planned — Phase 4 localization applies to those UI surfaces too.

**No new external dependencies needed.** All work uses existing frameworks (SwiftUI localization, Foundation, UserDefaults).

### 5. Success Criteria Mapping

| Success Criterion | Implementation |
|-------------------|----------------|
| "app can present its interface mostly in the target language" | Localizable.xcstrings with target language, language picker in settings, override system language per-app |
| "Help appears inline and contextually instead of forcing modal interruptions" | No blocking dialogs — audit all help flows, ensure non-blocking path |
| "Users can keep working in their existing app with help staying subtle" | Auto-dismiss help after configurable timeout, support click-outside dismiss, transient overlay |

### 6. Risks

- **Incomplete localization coverage** — Some strings may be missed in the String Catalog, causing English fallback. Mitigation: use a lint step or script to scan for unlocalized strings.
- **Language override complexity** — Per-app language override via `AppleLanguages` can have edge cases. Mitigation: test with 3+ target languages and system language mismatch.
- **Immersion mode tuning** — Auto-dismiss timing is subjective. Mitigation: make timeout configurable with sensible defaults.

## Gaps in Context

No CONTEXT.md exists for Phase 4 — decisions in plans are at the agent's discretion within the roadmap's success criteria.

---

*Research for: Phase 4 Stay Immersed*
*Completed: 2026-05-08*
