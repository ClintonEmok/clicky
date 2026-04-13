# Phase 2: Write with Guidance - Research

**Researched:** 2026-04-13
**Phase:** 2 (Write with Guidance)
**Confidence:** HIGH

## Overview

Phase 2 adds writing assistance to the existing menu bar companion. Users trigger a writing panel via hotkey (ctrl+option+W), paste or type target-language text, and receive annotated suggestions with explanations. The flow is panel-based, non-blocking, and annotation-driven — consistent with Phase 1's concise, contextual philosophy.

## Key Findings

### 1. Invocation and State Management

**What:** Writing assist is triggered by `ctrl+option+W`, mirroring how Phase 1 uses `ctrl+option` for reading lookup.

**How:**
- `CompanionManager` already has a `ReadingLookupState` enum and `readingLookupState` published property. The same pattern should be used for writing assist state.
- A new `WritingAssistState` enum (idle/showingInput/processing/suggestionsReady/error) tracks the writing flow.
- The hotkey handler in `GlobalPushToTalkShortcutMonitor` is currently voice-only. A separate write-mode hotkey handler should be added that opens the panel and sets `writingAssistState = .showingInput`.

**Dependencies on Phase 1:**
- `CompanionManager` orchestration pattern — already `@MainActor`, already centralizes state
- `CompanionPanelView` panel infrastructure — can host a new writing input section
- `ReadingLookupManager` request/result pattern — `WritingAssistManager` follows the same pattern

### 2. Text Revision Request Flow

**What:** User pastes text into the panel, clicks "Get Suggestions", panel sends text to Claude, returns annotated suggestions.

**How:**
- `WritingAssistManager` (new) accepts `WritingAssistRequest(sourceText: String, targetLanguage: String, context: String?)` and returns `WritingAssistResult(suggestions: [Suggestion], originalText: String)`.
- Each `Suggestion` contains: `originalSegment`, `revisedSegment`, `explanation`, `startIndex`, `endIndex`.
- The manager calls `ClaudeAPI` with a prompt that asks for:
  1. Revised version of the text
  2. Annotations explaining WHY each change was made (supports language learning)
  3. Tone/grammar feedback aligned to the request (WRITE-01, WRITE-02)

**Prompt design:**
```
Given the following text in [target language], provide:
1. A revised version with inline corrections
2. Annotations next to each change explaining the reason
3. Note if the tone is formal/informal and suggest adjustments if needed

Text: {sourceText}
```

### 3. Annotation Presentation in Overlay

**What:** Suggestions appear as annotations in the overlay or panel, not as a blocking modal.

**How:**
- `CompanionPanelView` gets a new `WritingAssistSection` that shows when `writingAssistState == .suggestionsReady`.
- Each suggestion is rendered as an `AnnotationChip` (original text → arrow → revised text + explanation on hover/tap).
- The existing `CompanionResponseOverlay.swift` pattern (response text bubble + waveform next to cursor) can inform the annotation layout.
- Annotations are dismissible — user can accept individual suggestions or dismiss all.

**Pitfall to avoid (from PITFALLS.md):**
- "Too much correction — Users feel judged and stop using it." Annotations should explain, not correct aggressively. Prefer "you might consider..." over "this is wrong."

### 4. Panel Input Area

**What:** The panel needs a text input area for writing assist, distinct from the existing reading lookup display.

**How:**
- `CompanionPanelView` has a `TextField` or `TextEditor` (dark themed, matching `DS.Colors`) where user pastes text.
- A "Get Suggestions" button triggers the API call.
- While processing, a loading spinner replaces the input area.
- On completion, input collapses and suggestions appear.

### 5. Connection to Existing Architecture

**Key files to modify:**
- `CompanionManager.swift` — add `WritingAssistState`, `WritingAssistManager` instance, `writeWithGuidance` methods
- `CompanionPanelView.swift` — add `WritingAssistSection` with text input and suggestion display
- New: `WritingAssistManager.swift` — request/result types, API call logic
- New: `WritingAssistAnnotationView.swift` — individual annotation chip UI

**Reuse patterns:**
- `ReadingLookupManager.swift` as template for `WritingAssistManager`
- `DesignSystem.swift` for colors and corner radii (`DS.Colors.background`, `DS.CornerRadius.panel`)
- `CompanionManager`'s lazy `claudeAPI` initialization

### 6. Success Criteria Mapping

| Success Criterion | Implementation |
|-------------------|----------------|
| "draft or rewrite text in the target language from within their normal desktop workflow" | ctrl+option+W opens panel, user pastes text, gets suggestions back — no context switch |
| "ask for tone or grammar suggestions and see them applied" | Suggestions include tone note and grammar correction with explanation |
| "Suggestions appear as part of the writing flow, not as a separate lesson or blocking dialog" | Annotations are inline in panel, dismissible, non-modal |

### 7. Dependencies and Risks

**Dependencies:**
- Phase 1 components: `CompanionManager`, `CompanionPanelView`, `ClaudeAPI` — all already in place
- No new external services needed — same Cloudflare Worker proxy used

**Risks:**
- Text length handling — long emails/forms may need truncation or chunking. Set a reasonable limit (2000 chars) and warn user if exceeded.
- Latency (Pitfall 4 from research) — writing assist is text-only, faster than voice+vision. Should complete in 3-5s on good network.
- Immersion breaking (Pitfall 5) — keep annotations subtle, non-judgmental, and easy to dismiss. Don't auto-apply changes.

## Gaps in Context

The CONTEXT.md does not specify:
- Maximum input text length
- Whether to support multiple revision rounds (submit → get annotations → edit → resubmit)
- How to handle mixed-language input (some English, some target language)

These are deferred to implementation discretion.

---

*Research for: Phase 2 Write with Guidance*
*Completed: 2026-04-13*