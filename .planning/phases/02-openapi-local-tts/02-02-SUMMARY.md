---
phase: 02-openapi-local-tts
plan: 02
subsystem: tts
tags: [avspeechsynthesizer, elevenlabs, tts, speech-synthesis]

# Dependency graph
requires:
  - phase: 01-read-in-place
    provides: CompanionManager state machine, TTS client interface
provides:
  - Local TTS using AVSpeechSynthesizer with ElevenLabs-compatible interface
  - TTS provider selection in companion panel UI
  - Automatic fallback from local TTS to ElevenLabs on failure
affects:
  - Phase 3 (Write with Guidance) - will use whichever TTS provider is configured
  - Any phase using voice output

# Tech tracking
tech-stack:
  added: [AVSpeechSynthesizer, LocalTTSClient]
  patterns: [TTS provider abstraction, fallback pattern]

key-files:
  created:
    - leanring-buddy/LocalTTSClient.swift
  modified:
    - leanring-buddy/CompanionManager.swift
    - leanring-buddy/CompanionPanelView.swift

key-decisions:
  - "LocalTTSClient inherits NSObject for AVSpeechSynthesizerDelegate conformance"
  - "TTS provider selected via segmented button style matching model picker"

patterns-established:
  - "Provider selection pattern: enum + @Published property + UserDefaults persistence"
  - "Fallback pattern: try selected provider, catch and fallback to default"

requirements-completed: []

# Metrics
duration: ~3min
completed: 2026-04-13
---

# Phase 2: Plan 02 - Local TTS Support Summary

**Local TTS using AVSpeechSynthesizer with ElevenLabs fallback and companion panel selection UI**

## Performance

- **Duration:** ~3 min
- **Tasks:** 3
- **Files modified:** 3

## Accomplishments
- Created LocalTTSClient.swift using macOS AVSpeechSynthesizer with ElevenLabs-compatible interface
- Added TTSProvider enum and ttsProvider property to CompanionManager with UserDefaults persistence
- Added activeTTSClient() method returning selected provider's client
- Added speakWithFallback() that tries selected provider then falls back to ElevenLabs
- Added TTS provider picker UI in companion panel with segmented button style

## Task Commits

Each task was committed atomically:

1. **Task 1: Create LocalTTSClient.swift** - `d8a39a1` (feat)
2. **Task 2: Add TTS provider selection to CompanionManager** - `44d368d` (feat)
3. **Task 3: Add TTS selection UI to CompanionPanelView** - `0d0a7ac` (feat)

## Files Created/Modified
- `leanring-buddy/LocalTTSClient.swift` - Local TTS using AVSpeechSynthesizer
- `leanring-buddy/CompanionManager.swift` - TTSProvider enum, ttsProvider, activeTTSClient(), speakWithFallback()
- `leanring-buddy/CompanionPanelView.swift` - TTS picker row with segmented buttons

## Decisions Made
- LocalTTSClient inherits NSObject for AVSpeechSynthesizerDelegate conformance (required by protocol)
- Used segmented button style matching existing model picker for UI consistency
- TTSProvider enum has two cases: elevenlabs and local (system was deferred)

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
- Initial LocalTTSClient had LSP error: "Cannot declare conformance to 'NSObjectProtocol' in Swift" - fixed by making class inherit NSObject instead of just conforming to AVSpeechSynthesizerDelegate

## Next Phase Readiness
- Local TTS fully integrated with fallback to ElevenLabs
- TTS provider selection available in companion panel
- Ready for Phase 3 (Write with Guidance) which will use whichever TTS is configured

---
*Phase: 02-openapi-local-tts - Plan 02*
*Completed: 2026-04-13*
