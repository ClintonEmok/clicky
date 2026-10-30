# Phase 2: OpenAPI-Compatible Models and Local TTS - Context

**Gathered:** 2026-04-13
**Status:** Ready for planning

<domain>
## Phase Boundary

Let users choose an OpenAI-compatible model endpoint and use local text-to-speech for lower latency. Model and TTS selection remain configurable without changing the main reading flow. Phase 1 (Read in Place) remains the primary workflow — this phase adds flexibility and resilience.

</domain>

<decisions>
## Implementation Decisions

### API configuration
- **D-01:** Settings panel in the companion menu bar panel — user configures the OpenAI-compatible endpoint URL
- **D-02:** Model selection dropdown in the same settings panel — user picks from configured endpoints
- **D-03:** Both settings persist via UserDefaults or AppBundleConfiguration

### Model selection
- **D-04:** OpenAI-compatible API format — any endpoint that accepts OpenAI's chat completions format
- **D-05:** Works alongside the existing Cloudflare Worker proxy — user can switch between the two
- **D-06:** Graceful fallback to Cloudflare Worker if OpenAI-compatible endpoint is not configured or fails

### Local TTS integration
- **D-07:** Local TTS runs alongside ElevenLabs — user chooses which to use in settings
- **D-08:** Local TTS provider is configurable (e.g., system TTS, or a local server)
- **D-09:** If local TTS is unavailable or fails, fallback to ElevenLabs automatically

### Fallback behavior
- **D-10:** If OpenAI-compatible model API fails, fallback to existing Claude via Cloudflare Worker
- **D-11:** If local TTS fails, fallback to ElevenLabs TTS
- **D-12:** Failures are silent to user — the phase 1 workflow continues uninterrupted

### Agent's Discretion
- Exact local TTS provider implementation (system AVSpeechUtterance, local server, etc.)
- Panel layout for settings and model selection dropdown
- How to handle API key management for custom endpoints
- Exact fallback retry behavior

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase scope and product intent
- `.planning/ROADMAP.md` — Phase 2 scope, dependencies, and success criteria
- `.planning/PROJECT.md` — Core value, active requirements, constraints, and out-of-scope items
- `.planning/REQUIREMENTS.md` — Requirements TBD for OpenAPI and Local TTS

### Prior phase context
- `.planning/phases/01-read-in-place/01-CONTEXT.md` — Phase 1 decisions carrying forward

### Existing app constraints
- `.planning/codebase/ARCHITECTURE.md` — Menu-bar macOS app, overlay, state machine, and platform integration patterns
- `.planning/codebase/STACK.md` — Swift/AppKit/ScreenCaptureKit stack and external service boundaries
- `.planning/codebase/CONVENTIONS.md` — Naming, code style, and SwiftUI/AppKit patterns
- `.planning/codebase/CONCERNS.md` — Existing risks around capture, privacy, and brittle interaction flows

### Existing code patterns
- `leanring-buddy/ClaudeAPI.swift` — Existing Claude API client with streaming, model selection, proxy URL pattern
- `leanring-buddy/ElevenLabsTTSClient.swift` — Existing TTS client with speakText/stopPlayback/isPlaying API
- `leanring-buddy/CompanionPanelView.swift` — Existing panel UI for settings and controls

</canonical_refs>

<codebase_context>
## Existing Code Insights

### Reusable Assets
- `leanring-buddy/ClaudeAPI.swift`: existing API client pattern with streaming, model parameter, proxy URL — can be extended for OpenAI-compatible models
- `leanring-buddy/ElevenLabsTTSClient.swift`: existing TTS client with speakText/stopPlayback — local TTS can follow the same interface
- `leanring-buddy/CompanionPanelView.swift`: existing panel settings UI — model/TTS selection can be added here

### Established Patterns
- `@MainActor` orchestration via CompanionManager
- AppKit bridging for panel behavior
- UserDefaults or AppBundleConfiguration for settings persistence
- Proxy URL pattern — all API calls go through Cloudflare Worker
- Graceful fallback patterns in existing code

### Integration Points
- OpenAI-compatible model connects via existing ClaudeAPI with different URL/model
- Local TTS integrates alongside ElevenLabsTTSClient — both implement a common interface or are selected at runtime
- Settings in CompanionPanelView or a new settings subview
- CompanionManager orchestrates which API/TTS provider is active

</codebase_context>

<specifics>
## Specific Ideas

- User wants to use "any OpenAI-compatible model" — flexibility is the key value
- Lower latency with local TTS is the motivation for the TTS portion
- Both features should not disrupt the existing Phase 1 reading workflow

</specifics>

<deferred>
## Deferred Ideas

- Phase 3 (Write with Guidance) will use whichever model/TTS is configured in Phase 2
- Speaking practice — future phase after Immersion mode

</deferred>

---

*Phase: 02-openapi-local-tts*
*Context gathered: 2026-04-13*
