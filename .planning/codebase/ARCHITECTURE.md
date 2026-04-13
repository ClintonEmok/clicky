# Architecture

**Analysis Date:** 2026-04-13

## Pattern Overview

**Overall:** Menu bar-only macOS app with a central orchestrator and AppKit/SwiftUI bridges.

**Key Characteristics:**
- `leanring-buddy/leanring_buddyApp.swift` bootstraps a status-bar-only app (`LSUIElement=true`) and hands lifecycle to `CompanionAppDelegate`.
- `leanring-buddy/CompanionManager.swift` acts as the main state machine for voice, permissions, onboarding, overlay visibility, and AI response flow.
- SwiftUI handles most UI, while AppKit provides the `NSStatusItem`, `NSPanel`, `NSWindow`, event tap, and screen APIs that SwiftUI does not cover cleanly.
- API calls are proxied through `worker/src/index.ts`; the macOS app does not hold raw API keys.

## Layers

**Application Shell:**
- Purpose: Launch the menu bar app and initialize shared managers.
- Location: `leanring-buddy/leanring_buddyApp.swift`
- Contains: `@main` app entry, `CompanionAppDelegate`, login-item registration, app launch lifecycle.
- Depends on: `SwiftUI`, `ServiceManagement`, `Sparkle`, `CompanionManager`, `MenuBarPanelManager`, `ClickyAnalytics`.
- Used by: The whole app.

**UI Layer:**
- Purpose: Render the floating menu bar panel, cursor overlay, response bubble, and design system components.
- Location: `leanring-buddy/CompanionPanelView.swift`, `leanring-buddy/OverlayWindow.swift`, `leanring-buddy/CompanionResponseOverlay.swift`, `leanring-buddy/DesignSystem.swift`.
- Contains: SwiftUI views, button styles, geometry preferences, visual state.
- Depends on: `CompanionManager`, `AppKit` bridging types, `DS` design tokens.
- Used by: `MenuBarPanelManager`, `OverlayWindowManager`, `CompanionResponseOverlayManager`.

**Orchestration / Domain Layer:**
- Purpose: Coordinate voice capture, transcription, screenshots, Claude, TTS, onboarding, and pointing.
- Location: `leanring-buddy/CompanionManager.swift`, `leanring-buddy/BuddyDictationManager.swift`.
- Contains: Published app state, permission polling, onboarding sequencing, transcript/response pipeline, cancellation logic.
- Depends on: `BuddyTranscriptionProvider`, `GlobalPushToTalkShortcutMonitor`, `OverlayWindowManager`, `ClaudeAPI`, `ElevenLabsTTSClient`, `CompanionScreenCaptureUtility`, `ElementLocationDetector`.
- Used by: Panel UI, overlay UI, app delegate.

**Platform Integration Layer:**
- Purpose: Wrap macOS-specific APIs and system services.
- Location: `leanring-buddy/MenuBarPanelManager.swift`, `leanring-buddy/GlobalPushToTalkShortcutMonitor.swift`, `leanring-buddy/WindowPositionManager.swift`, `leanring-buddy/CompanionScreenCaptureUtility.swift`, `leanring-buddy/ElementLocationDetector.swift`.
- Contains: Event taps, screen capture, window positioning, permissions, accessibility interactions.
- Depends on: `AppKit`, `ScreenCaptureKit`, `ApplicationServices`, `CoreGraphics`.
- Used by: `CompanionManager` and the UI layer.

**API Client Layer:**
- Purpose: Encapsulate external API requests and response parsing.
- Location: `leanring-buddy/ClaudeAPI.swift`, `leanring-buddy/ElevenLabsTTSClient.swift`, `leanring-buddy/OpenAIAPI.swift`, `leanring-buddy/AssemblyAIStreamingTranscriptionProvider.swift`, `leanring-buddy/OpenAIAudioTranscriptionProvider.swift`, `leanring-buddy/AppleSpeechTranscriptionProvider.swift`.
- Contains: Request builders, streaming parsing, audio playback, transient token fetch, provider-specific error types.
- Depends on: `Foundation`, `AVFoundation`, `Speech`.
- Used by: `CompanionManager` and `BuddyDictationManager`.

**Worker Proxy Layer:**
- Purpose: Hold secrets and forward app requests to Anthropic, ElevenLabs, and AssemblyAI.
- Location: `worker/src/index.ts`, `worker/wrangler.toml`.
- Contains: HTTP routing for `/chat`, `/tts`, `/transcribe-token`.
- Depends on: Cloudflare Workers runtime.
- Used by: `leanring-buddy/CompanionManager.swift` and `leanring-buddy/AssemblyAIStreamingTranscriptionProvider.swift`.

**Testing Layer:**
- Purpose: Validate permission and launch behavior.
- Location: `leanring-buddyTests/leanring_buddyTests.swift`, `leanring-buddyUITests/leanring_buddyUITests.swift`, `leanring-buddyUITests/leanring_buddyUITestsLaunchTests.swift`.
- Contains: Swift Testing unit tests and XCTest UI scaffolding.
- Depends on: `WindowPositionManager` and the app target.
- Used by: Xcode test targets.

## Data Flow

**Voice Interaction Flow:**

1. `GlobalPushToTalkShortcutMonitor` captures the system shortcut (`ctrl + option` by default) via a listen-only CGEvent tap.
2. `BuddyDictationManager` starts mic capture, forwards audio into the selected transcription provider, and updates recording state.
3. `CompanionManager` receives the finalized transcript, stores conversation history, and captures the relevant screen(s) through `CompanionScreenCaptureUtility`.
4. `ClaudeAPI.analyzeImageStreaming(...)` sends transcript + screenshots through the Cloudflare Worker and streams SSE text back.
5. `ElevenLabsTTSClient.speakText(_:)` plays the response audio after the assistant text is ready.
6. If Claude emits a point tag or the element detector finds a target, `OverlayWindowManager` animates the cursor to the location using `ElementLocationDetector` coordinates.

**Onboarding Flow:**

1. `CompanionAppDelegate.applicationDidFinishLaunching(_:)` creates managers and calls `CompanionManager.start()`.
2. If onboarding is incomplete or permissions are missing, `MenuBarPanelManager.showPanelOnLaunch()` opens the panel.
3. `CompanionManager` updates onboarding state, plays onboarding media, and drives the cursor overlay video/text sequence.

**Permission Flow:**

1. `CompanionManager.start()` refreshes accessibility, microphone, screen recording, and screen content state.
2. `WindowPositionManager` provides request/open helpers for Accessibility and Screen Recording.
3. The panel reflects permission state via published properties in `CompanionManager`.

**State Management:**
- Primary mutable state lives in `@MainActor` observable objects: `CompanionManager`, `BuddyDictationManager`, `GlobalPushToTalkShortcutMonitor`, and overlay managers.
- Cross-view state is shared by reference instead of via a global store.
- Persistent preferences use `UserDefaults` in `CompanionManager` and `WindowPositionManager`.

## Key Abstractions

**`CompanionManager` (`leanring-buddy/CompanionManager.swift`):**
- Purpose: Owns the high-level interaction state machine.
- Examples: voice state, onboarding state, permission state, `selectedModel`, overlay visibility.
- Pattern: Single coordinating `@MainActor ObservableObject`.

**`BuddyDictationManager` (`leanring-buddy/BuddyDictationManager.swift`):**
- Purpose: Owns push-to-talk recording and transcript finalization.
- Examples: mic-button sessions, keyboard-shortcut sessions, audio power history.
- Pattern: Provider-driven dictation engine with start/stop/finalize phases.

**`BuddyTranscriptionProvider` (`leanring-buddy/BuddyTranscriptionProvider.swift`):**
- Purpose: Abstracts transcription backend selection.
- Examples: `AssemblyAIStreamingTranscriptionProvider`, `OpenAIAudioTranscriptionProvider`, `AppleSpeechTranscriptionProvider`.
- Pattern: Protocol + factory.

**`OverlayWindowManager` / `BlueCursorView` (`leanring-buddy/OverlayWindow.swift`):**
- Purpose: Render and animate the full-screen cursor overlay per display.
- Examples: cursor-following mode, navigation mode, pointing mode, onboarding video bubble.
- Pattern: One `NSWindow` per screen hosting SwiftUI.

**`MenuBarPanelManager` (`leanring-buddy/MenuBarPanelManager.swift`):**
- Purpose: Manage the menu bar icon and dropdown panel lifecycle.
- Examples: status item creation, click-outside dismissal, initial launch open.
- Pattern: AppKit panel controller with SwiftUI content.

**`ClaudeAPI` (`leanring-buddy/ClaudeAPI.swift`):**
- Purpose: Send labeled screenshots to Claude and stream assistant text.
- Examples: SSE parsing, TLS warmup, image media type detection.
- Pattern: thin network client with request serialization and stream decoding.

**`CompanionScreenCaptureUtility` (`leanring-buddy/CompanionScreenCaptureUtility.swift`):**
- Purpose: Capture all connected displays and label them for model context.
- Examples: cursor-screen ordering, screen coordinate normalization, exclusion of app windows.
- Pattern: async capture utility around `ScreenCaptureKit`.

## Entry Points

**App Launch:**
- Location: `leanring-buddy/leanring_buddyApp.swift`
- Triggers: macOS app start.
- Responsibilities: instantiate the app delegate, register login item, configure analytics, start companion services.

**Menu Bar Interaction:**
- Location: `leanring-buddy/MenuBarPanelManager.swift`
- Triggers: clicking the status item or posting `.clickyDismissPanel`.
- Responsibilities: show/hide the panel, manage outside-click dismissal, host SwiftUI panel content.

**Push-to-Talk Shortcut:**
- Location: `leanring-buddy/GlobalPushToTalkShortcutMonitor.swift`
- Triggers: global key events.
- Responsibilities: detect press/release transitions and publish them to the voice pipeline.

**Worker HTTP Entry:**
- Location: `worker/src/index.ts`
- Triggers: POST requests to `/chat`, `/tts`, `/transcribe-token`.
- Responsibilities: validate method, forward requests, return API responses, keep secrets server-side.

## Error Handling

**Strategy:**
- Fail fast for malformed URLs and invalid HTTP responses.
- Return `LocalizedError` or `NSError` where user-facing or transport errors must propagate.
- Use `print(...)` logging for diagnostic visibility in launch and network paths.

**Patterns:**
- Network clients throw on non-2xx responses and preserve upstream error bodies (`leanring-buddy/ClaudeAPI.swift`, `leanring-buddy/ElevenLabsTTSClient.swift`, `leanring-buddy/AssemblyAIStreamingTranscriptionProvider.swift`).
- Permission helpers return explicit enum states (`leanring-buddy/WindowPositionManager.swift`) so the UI can branch deterministically.
- Overlay and panel managers guard against missing windows/screens instead of crashing.

## Cross-Cutting Concerns

**Logging:** `print(...)` in launch, permission, and network code; PostHog capture in `leanring-buddy/ClickyAnalytics.swift`.
**Validation:** request/response validation in `leanring-buddy/ClaudeAPI.swift`, `leanring-buddy/ElevenLabsTTSClient.swift`, and `worker/src/index.ts`.
**Authentication:** API keys stay in Cloudflare Worker secrets; the app uses proxy URLs only.
**Persistence:** `UserDefaults` stores onboarding, model, and permission memory.
**Concurrency:** UI/state code is `@MainActor`; async/await is used for networking and screen capture.

---

*Architecture analysis: 2026-04-13*
