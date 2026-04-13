# Codebase Concerns

**Analysis Date:** 2026-04-13

## Tech Debt

**Monolithic state managers:**
- Issue: `leanring-buddy/CompanionManager.swift` (1026 lines) and `leanring-buddy/BuddyDictationManager.swift` (866 lines) each own multiple unrelated responsibilities: permissions, onboarding, screen capture, analytics, AI orchestration, audio state, and UI state.
- Impact: changes in one area can break voice flow, onboarding, or overlay behavior because the state transitions are tightly coupled.
- Fix approach: split into smaller services for permissions, onboarding, AI response orchestration, and audio/transcription lifecycle.

**Hardcoded service endpoints and identifiers:**
- Issue: proxy URLs and external identifiers are embedded directly in `leanring-buddy/CompanionManager.swift`, `leanring-buddy/AssemblyAIStreamingTranscriptionProvider.swift`, `leanring-buddy/ElementLocationDetector.swift`, and `leanring-buddy/ClickyAnalytics.swift`.
- Impact: local development and environment switching require code edits, and mistakes leave the app pointed at placeholder or production services.
- Fix approach: move these values into `Info.plist`, build settings, or a runtime config layer.

**Placeholder and one-off integrations in app code:**
- Issue: `leanring-buddy/CompanionManager.swift` posts onboarding emails to `https://submit-form.com/RWbGJxmIs`, and `leanring-buddy/ClickyAnalytics.swift` configures PostHog inline.
- Impact: integration changes are scattered across UI and orchestration code, which makes auditing and replacement harder.
- Fix approach: centralize third-party endpoints in a dedicated config/integration layer.

## Known Bugs

**Potentially stale permission state on session launch:**
- Symptoms: `leanring-buddy/WindowPositionManager.swift` treats screen recording as granted if `CGPreflightScreenCaptureAccess()` previously succeeded and the UserDefaults fallback is set.
- Files: `leanring-buddy/WindowPositionManager.swift`, `leanring-buddy/CompanionManager.swift`.
- Trigger: launching after permissions were changed in System Settings or after macOS returns a false negative.
- Workaround: restart and re-check permissions from the panel.

**Regex parsing is brittle for pointing tags:**
- Symptoms: `leanring-buddy/CompanionManager.swift` only recognizes a very specific `[POINT:...]` format.
- Files: `leanring-buddy/CompanionManager.swift`.
- Trigger: any model output that varies spacing, formatting, or tag placement.
- Workaround: keep responses strictly aligned to the expected tag grammar.

**Force-cast heavy Accessibility window manipulation:**
- Symptoms: `leanring-buddy/WindowPositionManager.swift` force-casts AX values when shrinking overlapping windows.
- Files: `leanring-buddy/WindowPositionManager.swift`.
- Trigger: Accessibility API returning an unexpected object type.
- Workaround: none in code; failure just aborts the resize path.

## Security Considerations

**Raw transcript and response data are sent to analytics:**
- Risk: `leanring-buddy/ClickyAnalytics.swift` tracks `transcript` and `response` payloads in `user_message_sent` and `ai_response_received`.
- Files: `leanring-buddy/ClickyAnalytics.swift`, `leanring-buddy/CompanionManager.swift`.
- Current mitigation: analytics is centralized in one wrapper.
- Recommendations: redact or hash sensitive content before capture, or drop full-text payloads entirely.

**Screen and audio content leave the device by design:**
- Risk: `leanring-buddy/CompanionManager.swift` captures screenshots and transcripts and forwards them to Claude, ElevenLabs, and AssemblyAI through the Cloudflare Worker proxy.
- Files: `leanring-buddy/CompanionManager.swift`, `leanring-buddy/CompanionScreenCaptureUtility.swift`, `leanring-buddy/AssemblyAIStreamingTranscriptionProvider.swift`, `worker/src/index.ts`.
- Current mitigation: API keys stay in the worker, not the app binary.
- Recommendations: document retention boundaries and user-facing privacy expectations more explicitly.

**Public identifiers and form endpoint are embedded in the binary:**
- Risk: `leanring-buddy/ClickyAnalytics.swift` contains a PostHog project key, and `leanring-buddy/CompanionManager.swift` posts emails to a fixed FormSpark endpoint.
- Files: `leanring-buddy/ClickyAnalytics.swift`, `leanring-buddy/CompanionManager.swift`.
- Current mitigation: these are non-secret service identifiers, not raw API secrets.
- Recommendations: move to config to simplify rotation and reduce exposure.

## Performance Bottlenecks

**Full-screen multi-monitor capture on every response:**
- Problem: `leanring-buddy/CompanionManager.swift` calls `CompanionScreenCaptureUtility.captureAllScreensAsJPEG()` before every AI response.
- Files: `leanring-buddy/CompanionManager.swift`, `leanring-buddy/CompanionScreenCaptureUtility.swift`.
- Cause: every request sends all connected screens to the model, even when the user only needs one monitor.
- Improvement path: capture only the cursor screen by default, or downsample and gate multi-monitor capture by context.

**Heavy payloads to vision APIs:**
- Problem: `leanring-buddy/ClaudeAPI.swift` base64-encodes full screenshots and streams them to Anthropic; `leanring-buddy/ElementLocationDetector.swift` does the same for computer-use calls.
- Files: `leanring-buddy/ClaudeAPI.swift`, `leanring-buddy/ElementLocationDetector.swift`.
- Cause: image encoding and network upload dominate latency on slower networks.
- Improvement path: shrink images earlier, cache host connections, and avoid duplicate detection calls.

**Permission polling runs continuously:**
- Problem: `leanring-buddy/CompanionManager.swift` polls permissions every 1.5 seconds through `startPermissionPolling()`.
- Files: `leanring-buddy/CompanionManager.swift`.
- Cause: repeated refresh work keeps timers and permission checks active across the whole session.
- Improvement path: switch to event-driven refreshes where macOS supports them.

**Audio power sampling and history updates happen on the hot path:**
- Problem: `leanring-buddy/BuddyDictationManager.swift` computes RMS and maintains rolling power history for every input buffer.
- Files: `leanring-buddy/BuddyDictationManager.swift`.
- Cause: microphone buffers are processed continuously while recording.
- Improvement path: reduce sample frequency or move waveform derivation off the main thread.

## Fragile Areas

**Pointer logic depends on several coordinate transforms:**
- Files: `leanring-buddy/CompanionManager.swift`, `leanring-buddy/CompanionScreenCaptureUtility.swift`, `leanring-buddy/ElementLocationDetector.swift`, `leanring-buddy/OverlayWindow.swift`.
- Why fragile: screenshots, display frames, and AppKit coordinates all use different origins and scaling rules.
- Safe modification: change one transform at a time and verify cursor-screen mapping on multi-monitor setups.
- Test coverage: no automated tests cover coordinate mapping.

**Global keyboard shortcut handling is highly stateful:**
- Files: `leanring-buddy/GlobalPushToTalkShortcutMonitor.swift`, `leanring-buddy/BuddyDictationManager.swift`, `leanring-buddy/CompanionManager.swift`.
- Why fragile: shortcut press/release, async permission prompts, and cancellation all race each other.
- Safe modification: preserve the single in-flight start request pattern and the current release-cancel flow.
- Test coverage: only permission helper tests exist in `leanring-buddyTests/leanring_buddyTests.swift`.

**Accessibility window resizing uses low-level AX APIs:**
- Files: `leanring-buddy/WindowPositionManager.swift`.
- Why fragile: the logic assumes the focused window exposes position/size attributes and belongs to a compatible app.
- Safe modification: keep the same nil/guard checks around AX calls and avoid expanding the scope without mocks.
- Test coverage: no tests cover `shrinkOverlappingFocusedWindow(targetDisplayID:)`.

## Scaling Limits

**Conversation history is capped, but only after requests complete:**
- Current capacity: `leanring-buddy/CompanionManager.swift` retains the last 10 exchanges in memory.
- Limit: long sessions still pay full image and transcript costs on each turn.
- Scaling path: add summarization or context pruning before the request payload is built.

**Worker design is single-route, pass-through oriented:**
- Current capacity: `worker/src/index.ts` only proxies `/chat`, `/tts`, and `/transcribe-token`.
- Limit: no auth, quota, or usage segmentation lives in the worker layer.
- Scaling path: add request validation, rate limiting, and per-route observability.

**No durable app-side queueing for failed AI/TTS requests:**
- Current capacity: `leanring-buddy/CompanionManager.swift` cancels and restarts the current response task.
- Limit: interrupted requests are dropped rather than retried.
- Scaling path: introduce retry/backoff only where idempotency is guaranteed.

## Dependencies at Risk

**Cloudflare Worker proxy:**
- Risk: the app depends on a manually configured worker URL in `leanring-buddy/CompanionManager.swift` and `leanring-buddy/AssemblyAIStreamingTranscriptionProvider.swift`.
- Impact: a mismatch between deployed worker and app config breaks chat, TTS, and token fetches.
- Migration plan: move the base URL into a single shared config source.

**Sparkle updater:**
- Risk: `leanring-buddy/leanring_buddyApp.swift` imports Sparkle and references updater startup.
- Impact: release flow depends on appcast and signing config remaining valid.
- Migration plan: keep `leanring-buddy/Info.plist` appcast keys aligned with the update host.

**PostHog analytics:**
- Risk: `leanring-buddy/ClickyAnalytics.swift` sends all events through one SDK configuration.
- Impact: analytics failures are silent and can skew onboarding/permission metrics.
- Migration plan: add explicit failure logging or opt-out handling.

## Missing Critical Features

**No privacy controls for captured content:**
- Problem: `leanring-buddy/CompanionManager.swift` and `leanring-buddy/ClickyAnalytics.swift` move transcripts, screenshots, and responses through external services without a user-facing data retention control.
- Blocks: privacy-sensitive deployments and enterprise usage.

**No real configuration management layer:**
- Problem: runtime URLs, keys, and service IDs are spread across `leanring-buddy/*.swift` and `worker/wrangler.toml`.
- Blocks: environment-specific builds and safe rotation.

## Test Coverage Gaps

**Permission and window behavior are barely exercised:**
- What's not tested: keyboard shortcut transitions, onboarding gating, screen recording fallback, and Accessibility window resizing.
- Files: `leanring-buddy/GlobalPushToTalkShortcutMonitor.swift`, `leanring-buddy/CompanionManager.swift`, `leanring-buddy/WindowPositionManager.swift`.
- Risk: regressions can break the core interaction flow without any test failure.
- Priority: High.

**Parsing and protocol handling are untested:**
- What's not tested: `[POINT:...]` parsing, SSE streaming parsing, AssemblyAI token exchange, and Worker route behavior.
- Files: `leanring-buddy/CompanionManager.swift`, `leanring-buddy/ClaudeAPI.swift`, `leanring-buddy/AssemblyAIStreamingTranscriptionProvider.swift`, `worker/src/index.ts`.
- Risk: format drift from external services can silently break response handling.
- Priority: High.

**Current test suite is minimal:**
- What's not tested: only permission helper logic is covered in `leanring-buddyTests/leanring_buddyTests.swift`; `leanring-buddyUITests/leanring_buddyUITests.swift` is a placeholder harness.
- Files: `leanring-buddyTests/leanring_buddyTests.swift`, `leanring-buddyUITests/leanring_buddyUITests.swift`.
- Risk: most of the voice, screen, and overlay pipeline remains unverified.
- Priority: High.

---

*Concerns audit: 2026-04-13*
