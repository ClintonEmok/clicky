# Phase 2 Research: OpenAPI-Compatible Models and Local TTS

**Research Date:** 2026-04-13
**Phase:** 2 — OpenAPI-Compatible Models and Local TTS
**Status:** Complete

---

## Research Questions

1. How to implement an OpenAI-compatible API client abstraction in Swift?
2. What local TTS options exist on macOS and how to integrate them?
3. How to design the provider abstraction layer for model and TTS selection?
4. What configuration/settings patterns should be used?

---

## Domain Analysis

### OpenAI-Compatible API Integration

**What "OpenAI-compatible" means:**
- Any endpoint that accepts the same request/response format as OpenAI's Chat Completions API
- `/v1/chat/completions` endpoint with `messages`, `model`, and streaming support
- Standard SSE streaming for progressive responses

**Key considerations:**
- Request format: `{ "model": "...", "messages": [...], "stream": true }`
- Streaming response: `data: {...}` SSE events with `content_block_delta` type
- Authentication: typically API key in `Authorization: Bearer <key>` header
- Error response: non-2xx with JSON error body

**Existing pattern:** `ClaudeAPI.swift` already has streaming SSE parsing. The OpenAI-compatible client would follow the same pattern but with different:
- URL endpoint
- Request body structure
- Auth header format

### Local TTS Options on macOS

**Option 1: AVSpeechUtterance (built-in)**
- Native iOS/macOS speech synthesis
- No network required, zero latency
- Quality varies — decent for English, may be poor for other languages
- Free, built into the platform

**Option 2: Local TTS Server**
- Run a local model like Coqui TTS, Piper, or Ollama TTS
- HTTP API similar to OpenAI TTS format
- Higher quality, more language options
- Requires background service running

**Option 3: System-level TTS**
- macOS has `say` command and `NSSpeechSynthesizer`
- Similar quality to AVSpeechUtterance
- No configuration needed

**Decision from CONTEXT (D-07, D-08, D-09):**
- Local TTS runs alongside ElevenLabs
- User chooses which to use in settings
- If local TTS fails, fallback to ElevenLabs automatically

### Provider Abstraction Design

**Model Provider Pattern:**
```swift
protocol ModelClient {
    func analyzeText(systemPrompt: String, userPrompt: String) async throws -> (text: String, duration: TimeInterval)
    func analyzeTextStreaming(images: [...], systemPrompt: String, userPrompt: String, onTextChunk: ...) async throws -> (text: String, duration: TimeInterval)
}

class OpenAIClient: ModelClient { ... }
class ClaudeClient: ModelClient { ... }  // existing
```

**TTS Provider Pattern:**
```swift
protocol TTSClient {
    func speakText(_ text: String) async throws
    func stopPlayback()
    var isPlaying: Bool { get }
}

class ElevenLabsTTSClient: TTSClient { ... }  // existing
class LocalTTSClient: TTSClient { ... }
class SystemTTSClient: TTSClient { ... }
```

### Configuration/Settings Design

**From CONTEXT (D-01, D-02, D-03):**
- Settings panel in the companion menu bar panel
- Model selection dropdown in the same settings panel
- Both settings persist via UserDefaults or AppBundleConfiguration

**Settings to persist:**
- `openai_endpoint_url`: String — custom OpenAI-compatible endpoint
- `openai_api_key`: String — API key for the endpoint
- `openai_model_name`: String — model to use (e.g., "gpt-4o-mini")
- `tts_provider`: String — "elevenlabs" | "local" | "system"
- `tts_fallback_enabled`: Bool — fallback to ElevenLabs if local fails

### Fallback Behavior Design

**From CONTEXT (D-10, D-11, D-12):**
- If OpenAI-compatible model API fails → fallback to Cloudflare Worker (Claude)
- If local TTS fails → fallback to ElevenLabs
- Failures are silent to user — phase 1 workflow continues uninterrupted

**Implementation approach:**
- Wrap API calls in `do/catch` with fallback logic
- Use `selectedModel` / `selectedTTSProvider` in `CompanionManager` to determine active providers
- Retry count: 1 attempt per provider before falling back

---

## Technical Implementation Approach

### Task 1: Create OpenAI-Compatible API Client

**File:** `leanring-buddy/OpenAICompatibleClient.swift` (new)

**Key implementation:**
1. URLSession with streaming SSE parsing (reuse pattern from `ClaudeAPI.swift`)
2. Build messages array in OpenAI format
3. Handle streaming `data: {...}` events with `content_block_delta`
4. API key authentication via `Authorization` header
5. Error handling for non-2xx responses

**Reference:** `ClaudeAPI.swift` lines 145-259 for SSE streaming pattern

### Task 2: Create TTS Provider Abstraction

**File:** `leanring-buddy/TTSClient.swift` (protocol) + `leanring-buddy/LocalTTSClient.swift` (implementation)

**Key implementation:**
1. `LocalTTSClient` using `AVSpeechSynthesizer` or local HTTP client
2. `SystemTTSClient` using `NSSpeechSynthesizer`
3. Factory pattern to select provider based on settings
4. Shared interface with `ElevenLabsTTSClient`

**Reference:** `ElevenLabsTTSClient.swift` for the interface pattern

### Task 3: Settings Integration

**File:** Modify `leanring-buddy/CompanionPanelView.swift` and `leanring-buddy/CompanionManager.swift`

**Key implementation:**
1. Add model/TTS selection UI to the panel
2. Store settings in UserDefaults
3. Read settings on startup and configure active providers

**Reference:** `CompanionPanelView.swift` for existing panel UI patterns

---

## Dependencies and Risks

### Dependencies
- Phase 1 completion (Read in Place) — already done
- Cloudflare Worker proxy — already exists at `worker/src/index.ts`

### Risks

1. **API compatibility variance:** Not all OpenAI-compatible endpoints behave identically. Some may lack streaming, have different error formats, or require different auth. Mitigation: Start with a known-compatible endpoint (e.g., OpenAI itself, Azure OpenAI, or local Ollama).

2. **Local TTS quality:** System TTS quality varies significantly by language. Mitigation: Make it configurable with fallback to ElevenLabs.

3. **Security for API keys:** Storing API keys in UserDefaults is not ideal. Mitigation: Use macOS Keychain for sensitive credentials in a follow-up.

4. **Concurrent providers:** Adding OpenAI-compatible alongside Claude means more code paths to test. Mitigation: Existing streaming patterns in ClaudeAPI.swift reduce risk.

---

## Recommendations

1. **Start with Ollama as test target:** Ollama exposes an OpenAI-compatible `/v1/chat/completions` endpoint locally. This enables offline testing and reduces external dependencies during development.

2. **Implement LocalTTSClient with AVSpeechUtterance first:** It's the simplest integration, requires no external service, and can be enhanced later with a local TTS server option.

3. **Keep the abstraction thin:** Model clients should expose the same interface so `CompanionManager` switches providers without knowing which one is active.

4. **Add fallback at the orchestrator level:** Rather than每个 client handling fallback, let `CompanionManager` catch failures and retry with the next provider.

---

## Files to Create/Modify

**Create:**
- `leanring-buddy/OpenAICompatibleClient.swift` — OpenAI-compatible API client
- `leanring-buddy/LocalTTSClient.swift` — Local TTS implementation (AVSpeechUtterance)
- `leanring-buddy/SystemTTSClient.swift` — System TTS implementation

**Modify:**
- `leanring-buddy/TTSClient.swift` (if exists) or create protocol — Add `LocalTTSClient` to factory
- `leanring-buddy/CompanionManager.swift` — Add model/TTS provider selection and fallback logic
- `leanring-buddy/CompanionPanelView.swift` — Add settings UI for model/TTS selection

**Reference for implementation:**
- `leanring-buddy/ClaudeAPI.swift` — SSE streaming pattern
- `leanring-buddy/ElevenLabsTTSClient.swift` — TTS client interface
- `leanring-buddy/CompanionPanelView.swift` — Existing settings panel patterns

---

*Research complete — ready for planning*