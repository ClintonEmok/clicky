# Phase 1: Read in Place - Context

**Gathered:** 2026-04-13
**Status:** Ready for planning

<domain>
## Phase Boundary

Let users understand foreign-language text where they already are. Phase 1 covers selected-text and visible-text lookup, concise translation, short explanatory notes for ambiguity, and automatic saving of useful language with source context.

</domain>

<decisions>
## Implementation Decisions

### Invocation
- **D-01:** Support both selected-text lookup and a hotkey-triggered lookup path.
- **D-02:** Phase 1 should not require the user to leave the current app or paste text into a separate tool.

### Presentation
- **D-03:** Show help in an overlay popover anchored to the current context rather than a full-screen or blocking surface.
- **D-04:** Keep the help concise so it supports reading in flow instead of turning into a lesson screen.

### Vocabulary capture
- **D-05:** Auto-save items that are looked up so the user does not need a separate manual capture step.
- **D-06:** Saved vocabulary should preserve the original source context so later review is meaningful.

### Ambiguous text handling
- **D-07:** Default to a translation plus a short note when text is idiomatic or ambiguous.
- **D-08:** Prefer a concise explanation over long tutor-style prose.

### the agent's Discretion
- Exact overlay placement, animation, and dismissal behavior
- How much of the source text to include alongside the translation
- Review list UI and sorting for saved vocabulary

</decisions>

<specifics>
## Specific Ideas

- Immersion-first experience for expats using their computer in the target language
- Reading and writing first; speaking practice is later
- The app itself should stay mostly in the target language when possible

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase scope and product intent
- `.planning/ROADMAP.md` — Phase 1 scope, dependencies, and success criteria
- `.planning/PROJECT.md` — Core value, active requirements, constraints, and out-of-scope items
- `.planning/REQUIREMENTS.md` — `READ-01` through `READ-03` define the reading MVP

### Existing app constraints
- `.planning/codebase/ARCHITECTURE.md` — Menu-bar macOS app, overlay, state machine, and platform integration patterns
- `.planning/codebase/STACK.md` — Swift/AppKit/ScreenCaptureKit stack and external service boundaries
- `.planning/codebase/CONCERNS.md` — Existing risks around capture, privacy, and brittle interaction flows

### Research guidance
- `.planning/research/STACK.md` — Recommended stack for a macOS language-learning assistant
- `.planning/research/FEATURES.md` — Table stakes and differentiators for reading-first desktop language learning
- `.planning/research/ARCHITECTURE.md` — Session, capture, translation, and memory boundaries
- `.planning/research/PITFALLS.md` — Risks around ambiguity, privacy, and immersion-breaking UX

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `leanring-buddy/OverlayWindow.swift`: existing overlay and cursor presentation patterns can inform the lookup popover behavior.
- `leanring-buddy/CompanionManager.swift`: already centralizes interaction state and can host phase 1 lookup state.
- `leanring-buddy/CompanionScreenCaptureUtility.swift`: useful if phase 1 needs visible-text or screen-context capture.
- `leanring-buddy/ElementLocationDetector.swift`: existing text/element targeting logic may help anchor lookups to source context.

### Established Patterns
- `leanring-buddy/CompanionManager.swift` and related managers already use a central `@MainActor` orchestration model.
- AppKit is already used where SwiftUI needs help with overlay/window behavior.
- The product already favors concise, contextual UI over large standalone windows.

### Integration Points
- Phase 1 lookup should connect to the existing overlay/window layer rather than inventing a separate app shell.
- Saved vocabulary and source context should likely integrate with the existing manager/state pattern.
- Any capture or detection work should respect the current screen/permission flow.

</code_context>

<deferred>
## Deferred Ideas

- Speaking and listening practice — this is a later phase, not part of Phase 1.

</deferred>

---

*Phase: 01-read-in-place*
*Context gathered: 2026-04-13*
