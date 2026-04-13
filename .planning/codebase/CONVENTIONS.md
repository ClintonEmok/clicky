# Coding Conventions

**Analysis Date:** 2026-04-13

## Naming Patterns

**Files:**
- Swift source files use descriptive PascalCase names that match the primary type, such as `CompanionManager.swift`, `ClaudeAPI.swift`, and `GlobalPushToTalkShortcutMonitor.swift`.
- Test files mirror the target name, such as `leanring_buddyTests.swift` and `leanring_buddyUITests.swift`.
- Resource files remain explicit and functional, such as `AppIcon.appiconset` and `worker/src/index.ts`.

**Functions:**
- Prefer explicit verb-first names: `requestScreenRecordingPermission()`, `pinMainWindowToRight(onDisplayID:)`, `startStreamingSession(...)`.
- Use boolean predicates with `has*`, `should*`, and `is*` prefixes, for example `hasAccessibilityPermission()`, `shouldTreatScreenRecordingPermissionAsGrantedForSessionLaunch()`, and `isOverlayVisible`.
- Prefer domain-specific names over abbreviations; `currentAudioPowerLevel` and `detectedElementScreenLocation` are representative.

**Variables:**
- Use long, descriptive names when they reduce ambiguity, especially in state-heavy classes like `CompanionManager.swift` and `BuddyDictationManager.swift`.
- Preserve argument names when passing values through layers; `currentCardData`-style shortening is explicitly avoided in `AGENTS.md`.

**Types:**
- Use nouns for concrete services and managers: `CompanionManager`, `WindowPositionManager`, `AppleSpeechTranscriptionProvider`.
- Use enums for closed state sets: `CompanionVoiceState`, `PermissionRequestPresentationDestination`, `BuddyPushToTalkShortcut.ShortcutOption`.

## Code Style

**Formatting:**
- Swift files use 4-space indentation, vertical whitespace between logical sections, and `// MARK:` separators for large files such as `DesignSystem.swift` and `CompanionManager.swift`.
- Multi-line argument lists are preferred for readability in API and state-management code, such as `ClaudeAPI.analyzeImageStreaming(...)` and `WindowPositionManager.requestScreenRecordingPermission()`.
- UI and design constants are centralized in `DesignSystem.swift` under `DS` namespaces.

**Linting:**
- No dedicated lint configuration is detected in the repository root.
- Style is enforced through local convention rather than automated lint rules.

## Import Organization

**Order:**
1. Apple frameworks (`AppKit`, `SwiftUI`, `Foundation`, `AVFoundation`, `Speech`, `ScreenCaptureKit`)
2. Third-party frameworks (`PostHog`, `Sparkle`, `Combine`)
3. Local types in the same module

**Path Aliases:**
- Not detected. Imports use direct module names only.

## Error Handling

**Patterns:**
- Throw typed or domain-tagged errors when API calls fail, usually with `NSError(domain:code:userInfo:)` in `ClaudeAPI.swift`, `OpenAIAPI.swift`, and `ElevenLabsTTSClient.swift`.
- Use `guard` for early exits and precondition checks in permission and window logic, especially in `WindowPositionManager.swift`.
- Prefer silent failure only for non-critical optimizations, such as TLS warmup in `ClaudeAPI.swift` and `OpenAIAPI.swift`.
- Cancellation is handled explicitly where playback or async work can be interrupted, such as `ElevenLabsTTSClient.stopPlayback()` and `Task.checkCancellation()`.

## Logging

**Framework:**
- Primarily `print(...)` for operational diagnostics in `ClaudeAPI.swift`, `OpenAIAPI.swift`, `ElevenLabsTTSClient.swift`, and `GlobalPushToTalkShortcutMonitor.swift`.

**Patterns:**
- Use emoji-prefixed log messages for high-signal runtime events.
- Keep logs short and actionable; avoid verbose narrative logging.

## Comments

**When to Comment:**
- Comment non-obvious AppKit bridging, coordinate conversion, permission behavior, and performance workarounds.
- Use comments to explain why a workaround exists, such as the TLS warmup logic in `ClaudeAPI.swift` or the AX coordinate conversion in `WindowPositionManager.swift`.

**JSDoc/TSDoc:**
- Swift uses doc comments selectively on public or non-obvious APIs.
- Tests use minimal inline comments only when the sample code needs context.

## Function Design

**Size:**
- Functions are generally small and single-purpose when feasible.
- Larger state machines such as `CompanionManager.swift` and `BuddyDictationManager.swift` are organized into sections with helper methods rather than split into many tiny files.

**Parameters:**
- Prefer explicit parameter labels and preserve full semantic names.
- Use tuples for simple structured return values, such as `(text:duration:)` from API calls.

**Return Values:**
- Return optionals for missing configuration or unavailable values, such as `AppBundleConfiguration.stringValue(forKey:)`.
- Return enums for state transitions and permission routing instead of booleans alone.

## Module Design

**Exports:**
- Most modules expose one primary type plus supporting enums or helper structs in the same file.
- Shared helpers live next to their consumers unless they are broad utilities, such as `DesignSystem.swift` and `AppBundleConfiguration.swift`.

**Barrel Files:**
- Not detected.

## SwiftUI and AppKit Conventions

- Use SwiftUI for app surfaces and AppKit only where required for `NSPanel`, `NSStatusItem`, or accessibility APIs, as seen in `MenuBarPanelManager.swift`, `OverlayWindow.swift`, and `WindowPositionManager.swift`.
- Mark UI-driving state with `@Published` and isolate UI mutation to `@MainActor`, especially in `CompanionManager.swift` and `BuddyDictationManager.swift`.
- Keep design tokens in `DesignSystem.swift` and reference them through `DS.Colors`, `DS.CornerRadius`, and related namespaces.

---

*Convention analysis: 2026-04-13*
