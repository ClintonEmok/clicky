# Codebase Structure

**Analysis Date:** 2026-04-13

## Directory Layout

```text
clever-jackal/
├── leanring-buddy/              # Main macOS app target source, assets, and bundled media
├── leanring-buddyTests/         # Unit tests
├── leanring-buddyUITests/       # UI tests
├── worker/                      # Cloudflare Worker proxy for external APIs
├── scripts/                     # Release and deployment automation
├── leanring-buddy.xcodeproj/    # Xcode project and shared workspace metadata
├── README.md                    # User-facing setup and project overview
├── AGENTS.md                    # Codebase instructions for agents
├── CLAUDE.md                    # Detailed architecture guidance
└── appcast.xml                  # Sparkle update feed
```

## Directory Purposes

**`leanring-buddy/`:**
- Purpose: Main application source for the menu bar app.
- Contains: Swift source files, `Info.plist`, entitlements, bundled images, bundled audio, asset catalog.
- Key files: `leanring-buddy/leanring_buddyApp.swift`, `leanring-buddy/CompanionManager.swift`, `leanring-buddy/MenuBarPanelManager.swift`, `leanring-buddy/OverlayWindow.swift`, `leanring-buddy/ClaudeAPI.swift`, `leanring-buddy/BuddyDictationManager.swift`, `leanring-buddy/DesignSystem.swift`.

**`leanring-buddy/Assets.xcassets/`:**
- Purpose: Xcode asset catalog for icons and UI art.
- Contains: app icon sets, accent color, onboarding/help imagery.
- Key files: `leanring-buddy/Assets.xcassets/AppIcon.appiconset/Contents.json`, `leanring-buddy/Assets.xcassets/AccentColor.colorset/Contents.json`.

**`leanring-buddyTests/`:**
- Purpose: Swift Testing unit tests.
- Contains: focused logic tests.
- Key files: `leanring-buddyTests/leanring_buddyTests.swift`.

**`leanring-buddyUITests/`:**
- Purpose: XCTest UI scaffolding and launch performance checks.
- Contains: app launch tests, screenshot capture scaffolding.
- Key files: `leanring-buddyUITests/leanring_buddyUITests.swift`, `leanring-buddyUITests/leanring_buddyUITestsLaunchTests.swift`.

**`worker/`:**
- Purpose: Cloudflare Worker proxy and its Node/Wrangler configuration.
- Contains: TypeScript entrypoint, `package.json`, `wrangler.toml`, lockfile.
- Key files: `worker/src/index.ts`, `worker/wrangler.toml`, `worker/package.json`.

**`scripts/`:**
- Purpose: Release automation.
- Contains: shell scripts and release notes.
- Key files: `scripts/release.sh`, `scripts/README.md`.

**`leanring-buddy.xcodeproj/`:**
- Purpose: Xcode target graph and workspace metadata.
- Contains: `project.pbxproj`, shared package resolution, user scheme state.
- Key files: `leanring-buddy.xcodeproj/project.pbxproj`, `leanring-buddy.xcodeproj/project.xcworkspace/contents.xcworkspacedata`.

## Key File Locations

**Entry Points:**
- `leanring-buddy/leanring_buddyApp.swift`: App launch, delegate setup, login item registration.
- `worker/src/index.ts`: Worker HTTP routing for `/chat`, `/tts`, `/transcribe-token`.

**Configuration:**
- `leanring-buddy/Info.plist`: `LSUIElement`, permissions strings, transcription provider selection.
- `leanring-buddy/leanring-buddy.entitlements`: App sandbox / capability configuration.
- `worker/wrangler.toml`: Worker name, main entrypoint, compatibility date, voice ID var.
- `leanring-buddy.xcodeproj/project.pbxproj`: Target definitions and package dependencies.

**Core Logic:**
- `leanring-buddy/CompanionManager.swift`: Central state machine and orchestration.
- `leanring-buddy/BuddyDictationManager.swift`: Push-to-talk recording and transcription session management.
- `leanring-buddy/OverlayWindow.swift`: Overlay window and blue cursor animation.
- `leanring-buddy/MenuBarPanelManager.swift`: Status item and floating panel controller.
- `leanring-buddy/ClaudeAPI.swift`: Claude vision client.
- `leanring-buddy/ElevenLabsTTSClient.swift`: TTS playback client.

**Testing:**
- `leanring-buddyTests/leanring_buddyTests.swift`: Unit coverage for permission helper logic.
- `leanring-buddyUITests/leanring_buddyUITests.swift`: Basic UI launch scaffolding.
- `leanring-buddyUITests/leanring_buddyUITestsLaunchTests.swift`: Launch screenshot harness.

## Naming Conventions

**Files:**
- Swift source files use feature names with type suffixes: `CompanionManager.swift`, `ClaudeAPI.swift`, `GlobalPushToTalkShortcutMonitor.swift`.
- Test files mirror the target name and append `Tests` / `UITests`: `leanring_buddyTests.swift`, `leanring_buddyUITests.swift`.
- Worker source follows standard package layout: `worker/src/index.ts`.

**Directories:**
- Main feature code stays in `leanring-buddy/`.
- Tests stay in dedicated target folders, not mixed into the app target.
- Generated Xcode data remains under `leanring-buddy.xcodeproj/`.

## Where to Add New Code

**New Feature:**
- Primary code: `leanring-buddy/`.
- Tests: `leanring-buddyTests/` for pure logic, `leanring-buddyUITests/` for UI behavior.

**New SwiftUI Component:**
- Implementation: `leanring-buddy/` alongside the related feature file.
- Example placement: overlay-related views next to `leanring-buddy/OverlayWindow.swift`.

**New macOS Integration / System Helper:**
- Implementation: `leanring-buddy/` next to the existing platform helper.
- Example placement: accessibility or screen capture work near `leanring-buddy/WindowPositionManager.swift` or `leanring-buddy/CompanionScreenCaptureUtility.swift`.

**New API Client / External Service Wrapper:**
- Implementation: `leanring-buddy/` near `ClaudeAPI.swift`, `OpenAIAPI.swift`, or `ElevenLabsTTSClient.swift`.
- Worker-side request handling belongs in `worker/src/index.ts`.

**New Release Automation:**
- Implementation: `scripts/`.
- Keep shell-based release logic in `scripts/release.sh` and document it in `scripts/README.md`.

## Special Directories

**`leanring-buddy/Assets.xcassets/`:**
- Purpose: Image and color assets consumed by Xcode.
- Generated: No.
- Committed: Yes.

**`leanring-buddy.xcodeproj/`:**
- Purpose: Build graph, targets, package references, and schemes.
- Generated: No.
- Committed: Yes.

**`worker/node_modules/`:**
- Purpose: Installed Node dependencies for the Worker.
- Generated: Yes.
- Committed: No.

**`worker/.dev.vars`:**
- Purpose: Local secret injection for Wrangler development.
- Generated: No, but local-only.
- Committed: No.

## Practical Placement Rules

- Put shared orchestration in `leanring-buddy/CompanionManager.swift`, not inside views.
- Put AppKit-only window or event tap code in focused helper files such as `leanring-buddy/MenuBarPanelManager.swift` or `leanring-buddy/GlobalPushToTalkShortcutMonitor.swift`.
- Keep API-specific logic in dedicated client files rather than mixing it into view code.
- Keep worker proxy logic in `worker/src/index.ts` so secrets never move into the app bundle.

---

*Structure analysis: 2026-04-13*
