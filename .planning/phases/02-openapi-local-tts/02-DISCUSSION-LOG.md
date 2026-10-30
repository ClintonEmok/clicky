# Phase 2: OpenAPI-Compatible Models and Local TTS - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-13
**Phase:** 02-openapi-local-tts
**Areas discussed:** API configuration, Model selection, Local TTS integration, Fallback behavior

---

## API configuration

| Option | Description | Selected |
|--------|-------------|----------|
| Companion menu bar panel | Settings in the existing panel | ✓ (recommended) |
| Separate settings window | Dedicated settings window | |
| Config file | JSON/plist config file | |
| Command line | CLI flags or arguments | |

**[auto] Selected:** Companion menu bar panel — reuses existing UI patterns

---

## Model selection

| Option | Description | Selected |
|--------|-------------|----------|
| OpenAI-compatible format | Any endpoint accepting OpenAI chat completions format | ✓ (recommended) |
| Provider-specific SDKs | Per-provider implementation | |
| Custom abstraction layer | Abstract interface over multiple providers | |

**[auto] Selected:** OpenAI-compatible format — flexible, aligns with existing proxy URL pattern

---

## Local TTS integration

| Option | Description | Selected |
|--------|-------------|----------|
| Runs alongside ElevenLabs | User chooses which to use in settings | ✓ (recommended) |
| Replaces ElevenLabs entirely | Local TTS only | |
| Progressive enhancement | Use local if available, else ElevenLabs | |

**[auto] Selected:** Runs alongside ElevenLabs — user has the choice

---

## Fallback behavior

| Option | Description | Selected |
|--------|-------------|----------|
| Silent fallback to existing service | Claude Worker if OpenAI fails, ElevenLabs if local TTS fails | ✓ (recommended) |
| User notification on fallback | Tell the user when fallback kicks in | |
| Fail fast | Stop and show error if primary unavailable | |

**[auto] Selected:** Silent fallback — Phase 1 workflow continues uninterrupted

---

*Phase: 02-openapi-local-tts*
*Discussion date: 2026-04-13*
