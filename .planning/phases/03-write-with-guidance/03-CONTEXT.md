# Phase 3: Write with Guidance - Context

**Gathered:** 2026-04-13
**Status:** Ready for planning

<domain>
## Phase Boundary

Let users draft and revise text in the target language from within their normal desktop workflow. Suggestions appear as part of the writing flow without blocking or forcing a separate lesson experience.

</domain>

<decisions>
## Implementation Decisions

### Invocation
- **D-01:** Hotkey-triggered (ctrl+option+W) — works from any app without leaving context
- **D-02:** Consistent with Phase 1 lookup invocation pattern

### Draft flow
- **D-03:** User pastes or types text into the panel for revision
- **D-04:** Panel-based workflow — text is submitted to the panel, not written in-place in the source app

### Suggestion presentation
- **D-05:** Annotated overlay — notes appear next to specific words/phrases explaining changes
- **D-06:** Annotations explain the "why" of changes, not just the "what" — supports language learning
- **D-07:** Fits the concise, contextual philosophy carried from Phase 1

### Draft scope
- **D-08:** User-configurable scope — user picks what to submit for revision (sentence, paragraph, email, form field)

### Agent's Discretion
- Exact annotation placement and styling
- How annotations are dismissed or accepted
- Default scope setting (if any)
- Panel layout and text input area design

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase scope and product intent
- `.planning/ROADMAP.md` — Phase 3 scope, dependencies, and success criteria
- `.planning/PROJECT.md` — Core value, active requirements, constraints, and out-of-scope items
- `.planning/REQUIREMENTS.md` — `WRITE-01` and `WRITE-02` define the writing MVP

### Prior phase context
- `.planning/phases/01-read-in-place/01-CONTEXT.md` — Phase 1 decisions carrying forward

### Existing app constraints
- `.planning/codebase/ARCHITECTURE.md` — Menu-bar macOS app, overlay, state machine, and platform integration patterns
- `.planning/codebase/STACK.md` — Swift/AppKit/ScreenCaptureKit stack and external service boundaries
- `.planning/codebase/CONVENTIONS.md` — Naming, code style, and SwiftUI/AppKit patterns

### Research guidance
- `.planning/research/STACK.md` — Recommended stack for a macOS language-learning assistant
- `.planning/research/FEATURES.md` — Table stakes and differentiators
- `.planning/research/PITFALLS.md` — Risks around immersion-breaking UX

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `leanring-buddy/OverlayWindow.swift`: existing overlay presentation patterns can inform the annotation overlay
- `leanring-buddy/CompanionPanelView.swift`: existing panel UI can host the text input area for drafts
- `leanring-buddy/CompanionManager.swift`: already centralizes state — should host writing assist state
- `leanring-buddy/ReadingLookupResultView.swift`: existing result presentation pattern for annotations

### Established Patterns
- `@MainActor` orchestration via CompanionManager
- AppKit bridging for panel and overlay behavior
- Design tokens in `DesignSystem.swift` (DS.Colors, DS.CornerRadius)
- Concise, contextual UI — no large blocking surfaces

### Integration Points
- Writing assist connects to existing overlay/panel layer
- Reuses hotkey infrastructure from Phase 1 (CompanionManager shortcut handling)
- Draft text and annotations should persist session state like vocabulary does

</code_context>

<specifics>
## Specific Ideas

- Writing assist should feel like a natural extension of the lookup flow
- Annotations should teach, not just correct
- Immersion-first — help should stay subtle and not turn into a lesson

</specifics>

<deferred>
## Deferred Ideas

- Writing in-place within the source app — deferred (requires deeper app integration)
- Dictation → draft workflow — deferred (Phase 3 uses paste-into-panel)

</deferred>

---

*Phase: 03-write-with-guidance*
*Context gathered: 2026-04-13*
