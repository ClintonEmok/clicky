# External Integrations

**Analysis Date:** 2026-04-13

## APIs & External Services

**AI/LLM:**
- Anthropic Claude - Vision/chat responses streamed through the Cloudflare Worker in `worker/src/index.ts` (`POST /chat` → `https://api.anthropic.com/v1/messages`).
  - SDK/Client: Direct `fetch` from `worker/src/index.ts`; app client in `leanring-buddy/ClaudeAPI.swift`.
  - Auth: `ANTHROPIC_API_KEY` stored as a Cloudflare secret.

**Speech-to-Text:**
- AssemblyAI - Real-time transcription used by `leanring-buddy/AssemblyAIStreamingTranscriptionProvider.swift`.
  - SDK/Client: Native `URLSession` + WebSocket client in `leanring-buddy/AssemblyAIStreamingTranscriptionProvider.swift`.
  - Auth: `ASSEMBLYAI_API_KEY` stored as a Cloudflare secret and exchanged for a short-lived token via `POST /transcribe-token`.

**Text-to-Speech:**
- ElevenLabs - Audio generation used by `leanring-buddy/ElevenLabsTTSClient.swift`.
  - SDK/Client: Native `URLSession` client in `leanring-buddy/ElevenLabsTTSClient.swift`; proxied through `POST /tts` in `worker/src/index.ts`.
  - Auth: `ELEVENLABS_API_KEY` stored as a Cloudflare secret; `ELEVENLABS_VOICE_ID` stored in `worker/wrangler.toml`.

**Analytics:**
- PostHog - Event analytics in `leanring-buddy/ClickyAnalytics.swift`.
  - SDK/Client: `PostHogSDK` from the `posthog-ios` package.
  - Auth: Embedded project key in `leanring-buddy/ClickyAnalytics.swift`.

**Auto-updates:**
- Sparkle - App update checks and release delivery in `leanring-buddy/leanring_buddyApp.swift`.
  - SDK/Client: `SPUStandardUpdaterController`.
  - Auth: Appcast URL and Ed25519 public key in `leanring-buddy/Info.plist` (`SUFeedURL`, `SUPublicEDKey`).

## Data Storage

**Databases:**
- Not detected - No local or remote database client is present in `leanring-buddy/*.swift` or `worker/src/index.ts`.

**File Storage:**
- Local filesystem only for app resources and bundled configuration; runtime network payloads are not stored persistently in app code.

**Caching:**
- URLSession in several clients uses in-memory/default networking behavior with disk caches disabled in `leanring-buddy/ClaudeAPI.swift` and `leanring-buddy/OpenAIAPI.swift`.

## Authentication & Identity

**Auth Provider:**
- Custom / service-specific auth only.
  - App uses Cloudflare Worker proxy instead of shipping raw API keys.
  - OS-level permissions are used for microphone, screen recording, and accessibility; see `leanring-buddy/Info.plist` and `README.md`.

## Monitoring & Observability

**Error Tracking:**
- Not detected - No Sentry/Datadog/New Relic integration found.

**Logs:**
- `print(...)` logging in `leanring-buddy/ClaudeAPI.swift`, `leanring-buddy/AssemblyAIStreamingTranscriptionProvider.swift`, `leanring-buddy/ElevenLabsTTSClient.swift`, and `leanring-buddy/leanring_buddyApp.swift`.
- Cloudflare Worker errors are written with `console.error(...)` in `worker/src/index.ts`.

## CI/CD & Deployment

**Hosting:**
- macOS app distributed as a signed desktop app; release metadata via `appcast.xml` and Sparkle.
- Cloudflare Workers host the proxy layer defined in `worker/wrangler.toml` and `worker/src/index.ts`.

**CI Pipeline:**
- Not detected.

## Environment Configuration

**Required env vars:**
- `ANTHROPIC_API_KEY` - Cloudflare Worker secret used by `worker/src/index.ts`.
- `ASSEMBLYAI_API_KEY` - Cloudflare Worker secret used by `worker/src/index.ts`.
- `ELEVENLABS_API_KEY` - Cloudflare Worker secret used by `worker/src/index.ts`.
- `ELEVENLABS_VOICE_ID` - Worker variable in `worker/wrangler.toml`.
- `VoiceTranscriptionProvider` - App bundle key in `leanring-buddy/Info.plist`.
- Worker base URL placeholder - Hardcoded proxy URL placeholder is referenced in `leanring-buddy/ClaudeAPI.swift`, `leanring-buddy/ElevenLabsTTSClient.swift`, and `leanring-buddy/AssemblyAIStreamingTranscriptionProvider.swift`.

**Secrets location:**
- Cloudflare Worker secrets for AI credentials.
- Appcast signing public key in `leanring-buddy/Info.plist`.

## Webhooks & Callbacks

**Incoming:**
- Not detected - No webhook receiver endpoints are implemented in `leanring-buddy/*.swift` or `worker/src/index.ts`.

**Outgoing:**
- Cloudflare Worker sends outbound requests to Anthropic, ElevenLabs, and AssemblyAI in `worker/src/index.ts`.
- Sparkle checks the release feed at `https://raw.githubusercontent.com/julianjear/makesomething-mac-app/main/appcast.xml` from `leanring-buddy/Info.plist`.

---

*Integration audit: 2026-04-13*
