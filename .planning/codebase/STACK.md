# Technology Stack

**Analysis Date:** 2026-04-13

## Languages

**Primary:**
- Swift 5.0 - App target and test targets in `leanring-buddy.xcodeproj/project.pbxproj`, source files under `leanring-buddy/*.swift`.

**Secondary:**
- TypeScript - Cloudflare Worker in `worker/src/index.ts`.
- JSON / XML / TOML - Config files in `leanring-buddy/Info.plist`, `leanring-buddy.xcodeproj/project.pbxproj`, and `worker/wrangler.toml`.

## Runtime

**Environment:**
- macOS 14.2+ - App deployment target in `leanring-buddy.xcodeproj/project.pbxproj` and documented in `README.md`.
- Cloudflare Workers runtime - Worker configured in `worker/wrangler.toml` with `compatibility_date = "2024-01-01"`.

**Package Manager:**
- Swift Package Manager via Xcode - Remote packages listed in `leanring-buddy.xcodeproj/project.pbxproj` and locked in `leanring-buddy.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`.
- npm - Worker tooling in `worker/package.json`.
- Lockfile: present (`worker/package-lock.json`, `leanring-buddy.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`).

## Frameworks

**Core:**
- SwiftUI - App shell and UI in `leanring-buddy/leanring_buddyApp.swift` and companion views.
- AppKit - Menu bar panel, windows, and system integration in files like `leanring-buddy/MenuBarPanelManager.swift`, `leanring-buddy/OverlayWindow.swift`, and `leanring-buddy/WindowPositionManager.swift`.
- AVFoundation - Audio capture/playback in `leanring-buddy/BuddyDictationManager.swift`, `leanring-buddy/AssemblyAIStreamingTranscriptionProvider.swift`, and `leanring-buddy/ElevenLabsTTSClient.swift`.
- Speech - Local fallback transcription in `leanring-buddy/AppleSpeechTranscriptionProvider.swift`.
- ScreenCaptureKit - Screen capture pipeline in `leanring-buddy/CompanionScreenCaptureUtility.swift` and `leanring-buddy/WindowPositionManager.swift`.
- ServiceManagement - Login item registration in `leanring-buddy/leanring_buddyApp.swift`.

**Testing:**
- XCTest - Unit and UI test targets in `leanring-buddyTests/` and `leanring-buddyUITests/`.

**Build/Dev:**
- Sparkle 2.9.0 - Auto-update framework wired into `leanring-buddy/leanring_buddyApp.swift` and declared in `leanring-buddy.xcodeproj/project.pbxproj`.
- PostHog 3.47.0 - Analytics SDK used in `leanring-buddy/ClickyAnalytics.swift`.
- Cloudflare Wrangler 3.x - Worker dev/deploy scripts in `worker/package.json`.

## Key Dependencies

**Critical:**
- Sparkle 2.9.0 - App update flow and appcast-based releases; referenced in `leanring-buddy/leanring_buddyApp.swift` and `leanring-buddy/Info.plist` (`SUFeedURL`, `SUPublicEDKey`).
- PostHog 3.47.0 - Event tracking in `leanring-buddy/ClickyAnalytics.swift`.
- `wrangler` ^3.0.0 - Builds and deploys `worker/src/index.ts`.

**Infrastructure:**
- `plcrashreporter` 1.12.2 - Present in `leanring-buddy.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved` as a resolved package dependency.

## Configuration

**Environment:**
- App runtime behavior is configured from `leanring-buddy/Info.plist` and read through `leanring-buddy/AppBundleConfiguration.swift`.
- Worker secrets are stored in Cloudflare as secrets; `worker/src/index.ts` expects `ANTHROPIC_API_KEY`, `ASSEMBLYAI_API_KEY`, and `ELEVENLABS_API_KEY`.
- Worker non-secret config uses `ELEVENLABS_VOICE_ID` in `worker/wrangler.toml`.
- Transcription provider selection uses `VoiceTranscriptionProvider` from `leanring-buddy/Info.plist`.

**Build:**
- App build configuration lives in `leanring-buddy.xcodeproj/project.pbxproj`.
- Worker build/deploy configuration lives in `worker/wrangler.toml` and `worker/package.json`.
- App permissions and usage strings are declared in `leanring-buddy/Info.plist`.

## Platform Requirements

**Development:**
- Xcode 15+ - Documented in `README.md`.
- macOS 14.2+ - Required for ScreenCaptureKit and the app target in `leanring-buddy.xcodeproj/project.pbxproj`.
- Node.js 18+ - Required for `worker/` per `README.md`.

**Production:**
- macOS menu bar app signed with hardened runtime and outgoing network access enabled in `leanring-buddy.xcodeproj/project.pbxproj`.
- Cloudflare Worker proxy for all external API traffic in `worker/src/index.ts`.

---

*Stack analysis: 2026-04-13*
