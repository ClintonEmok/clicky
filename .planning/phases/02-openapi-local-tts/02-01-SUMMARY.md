---
phase: "02-openapi-local-tts"
plan: "01"
subsystem: model-configuration
tags: [openai, api, streaming, fallback, user-settings]
dependency-graph:
  requires: []
  provides: [openai-compatible-client, openai-settings-ui, fallback-logic]
  affects: [companion-panel, voice-pipeline]
tech-stack:
  added: []
  patterns:
    - OpenAI Chat Completions API format
    - SSE streaming with fallback
    - UserDefaults-based settings persistence
key-files:
  created:
    - path: leanring-buddy/OpenAICompatibleClient.swift
      provides: OpenAI-compatible API client with streaming
      exports: analyzeText, analyzeTextStreaming
  modified:
    - path: leanring-buddy/CompanionManager.swift
      provides: Model provider selection and fallback logic
      contains: openAIEndpoint, openAIAPIKey, openAIModelName, useOpenAICompatible
    - path: leanring-buddy/CompanionPanelView.swift
      provides: Settings UI for endpoint and model selection
      contains: openAIConfigExpanded, openAISettingsSection
decisions:
  - id: "D-01"
    description: Settings panel in companion menu bar panel for OpenAI-compatible endpoint configuration
  - id: "D-02"
    description: Model selection via configurable endpoint URL, API key, and model name
  - id: "D-03"
    description: Settings persist via UserDefaults
  - id: "D-04"
    description: OpenAI-compatible API format works with any endpoint accepting OpenAI chat completions format
  - id: "D-05"
    description: Works alongside existing Cloudflare Worker proxy - user can switch between the two
  - id: "D-06"
    description: Graceful fallback to Cloudflare Worker if OpenAI-compatible endpoint fails
---

# Phase 2 Plan 1: OpenAI-Compatible Model Support

**User can configure an OpenAI-compatible endpoint, API key, and model name in the companion panel settings. When enabled, the app uses that endpoint instead of Cloudflare Worker. If that endpoint fails, it falls back to Cloudflare Worker automatically.**

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Create OpenAICompatibleClient.swift | eec4e2b | leanring-buddy/OpenAICompatibleClient.swift |
| 2 | Add OpenAI config to CompanionManager | 96d0f40 | leanring-buddy/CompanionManager.swift |
| 3 | Add OpenAI settings UI to CompanionPanelView | 8ed0596 | leanring-buddy/CompanionPanelView.swift |

## Summary

Added OpenAI-compatible model support allowing users to configure any endpoint that speaks the OpenAI Chat Completions API format.

### Task 1: OpenAICompatibleClient (eec4e2b)
- Created new file `leanring-buddy/OpenAICompatibleClient.swift`
- Implements `analyzeText` for simple text-only requests
- Implements `analyzeTextStreaming` with SSE parsing for progressive text display
- Vision support with base64-encoded images in OpenAI format
- Authorization via `Bearer` token in `Authorization` header
- TLS warmup optimization pattern matching ClaudeAPI
- Configurable endpoint URL, API key, and model name

### Task 2: CompanionManager Configuration (96d0f40)
- Added `openAIEndpoint`, `openAIAPIKey`, `openAIModelName`, `useOpenAICompatible` properties
- Properties loaded from UserDefaults on access
- Added `saveOpenAISettings()` and `isOpenAIConfigured` helper
- Implemented fallback logic in `sendTranscriptToClaudeWithScreenshot`:
  - If `useOpenAICompatible` is true and endpoint is configured, try OpenAI-compatible client first
  - On error, automatically fall back to Cloudflare Worker (Claude)

### Task 3: CompanionPanelView Settings UI (8ed0596)
- Added `openAIConfigExpanded` state for DisclosureGroup
- Added `openAISettingsSection` with:
  - TextField for endpoint URL
  - SecureField for API key
  - TextField for model name
  - Toggle to enable OpenAI-compatible endpoint
  - Status text showing current configuration
- All changes persist via `companionManager.saveOpenAISettings()`
- Styled consistently with dark panel aesthetic

## Verification

- [x] OpenAICompatibleClient.swift compiles without errors
- [x] CompanionManager has OpenAI config properties and fallback logic
- [x] CompanionPanelView has settings UI for OpenAI configuration
- [x] Existing Phase 1 flow still works (reading lookup still functions)

## Deviations from Plan

None - plan executed exactly as written.

## Commits

- eec4e2b feat(02-01): add OpenAICompatibleClient with streaming support
- 96d0f40 feat(02-01): add OpenAI-compatible model configuration with fallback
- 8ed0596 feat(02-01): add OpenAI settings UI to companion panel

## Duration

~15 minutes
