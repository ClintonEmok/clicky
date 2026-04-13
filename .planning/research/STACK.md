# Stack Research

**Domain:** macOS language-learning assistant for expats
**Researched:** 2026-04-13
**Confidence:** MEDIUM

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| Swift | 6.x | Primary app language | Best fit for a native macOS companion app; strong concurrency model and direct access to Apple frameworks. |
| SwiftUI | macOS 15 / 2025-era | Main UI layer | Fastest path for polished settings, onboarding, and content views; works well with AppKit bridging for custom desktop chrome. |
| AppKit | Native macOS | Status bar item, floating panel, overlay windows, event handling | Still the standard for menu-bar-only apps, borderless panels, global event monitoring, and always-on-top behavior. |
| ScreenCaptureKit | macOS 12.3+ | Capture screen/window content for reading help and context-aware assistance | Current Apple framework for high-performance desktop capture; better choice than legacy capture APIs. |
| Accessibility (AXUIElement / AX APIs) | Native macOS | Detect UI elements, read labels, support pointer/selection workflows | Required for truly useful “help me use this app” assistance, especially when screenshots alone are not enough. |
| Vision | macOS-native | OCR and visual parsing of screen content | Useful for extracting text from screenshots and turning foreign-language UI into actionable language assistance. |
| AVFoundation | Native macOS | Microphone capture and audio playback | Core for speech input, pronunciation practice, and TTS playback. |
| Speech | Native macOS | On-device / Apple speech recognition fallback | Good fallback path, but not strong enough alone for a premium language app. |
| ServiceManagement | Native macOS | Login item / launch-at-login | Standard for always-available menu bar utilities. |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Anthropic Claude API | Current | High-quality multilingual tutoring, rewriting, explanation, and screenshot reasoning | Best when you need nuanced language help, translation explanations, or contextual UI guidance. |
| OpenAI API | Current | Multimodal assistance, transcription, structured language tools | Good secondary provider for vision + speech workflows and fallback routing. |
| DeepL API | Current | High-quality translation | Strong choice for direct translations and tone-sensitive text rewriting. |
| Google Cloud Translation | Current | Broad language coverage | Use when coverage and scale matter more than stylistic nuance. |
| Azure AI Speech | Current | STT, TTS, pronunciation assessment, speech translation | Best all-in-one speech stack if you want language-learning features beyond basic dictation. |
| ElevenLabs | Current | Natural TTS voices | Good for immersion playback and spoken examples, especially when voice quality matters. |
| PostHog | Current | Product analytics | Helpful for measuring which language-learning flows users actually use. |

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| Xcode | Build and ship macOS app | Use native signing, entitlements, and permission prompts correctly. |
| Swift Package Manager | Dependency management | Keep Apple frameworks native; add only a few focused third-party packages. |
| Cloudflare Worker | API proxy and secret isolation | Keep third-party API keys off the client app. |

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| SwiftUI + AppKit | Electron | Only if the product becomes web-first; otherwise Electron adds overhead and weakens native overlay/accessibility behavior. |
| ScreenCaptureKit | Legacy screen capture APIs | Only for older macOS support; ScreenCaptureKit is the current default for modern Mac apps. |
| Accessibility APIs | Image-only OCR | OCR alone is not enough for controls, labels, or workflow guidance. |
| Azure Speech | Apple Speech only | Use Apple Speech only as a fallback; Azure gives stronger end-to-end speech features for learning apps. |
| DeepL / Google / Azure translation APIs | Apple Translation framework | Use cloud translation when language coverage, quality, or consistency matters more than local-only operation. |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| Electron for the main app shell | Harder to make a convincing native overlay, weaker accessibility integration, more latency for desktop interactions | SwiftUI + AppKit |
| Polling screenshots as the primary context source | Wasteful, brittle, and misses interactive UI state | ScreenCaptureKit + Accessibility APIs |
| OCR-only UI understanding | Text extraction without control metadata leads to poor guidance | OCR + AXUIElement + vision model reasoning |
| Shipping API keys in the app bundle | Easy to extract and impossible to rotate safely | Cloudflare Worker or equivalent proxy |
| Depending only on Apple Speech | Great fallback, but not enough accuracy/consistency for a language-learning product | Azure Speech / Whisper-class STT with fallback routing |
| Depending only on Apple Translation | Coverage and behavior may be too limited for broad expat workflows | DeepL, Google Cloud Translation, Azure Translation, or hybrid routing |
| Building custom accessibility scraping before basic UX is stable | Accessibility work is high-friction and can consume the roadmap | Start with screenshot + OCR + selective AX expansion |

## Stack Patterns by Variant

**If the app is mostly passive immersion:**
- Use SwiftUI + AppKit, ScreenCaptureKit, Vision, and a cloud LLM.
- Keep speech optional and lightweight.

**If the app includes real-time speaking practice:**
- Add Azure Speech or another robust STT/TTS provider.
- Add pronunciation assessment early.

**If the app must translate arbitrary desktop UI text:**
- Add Accessibility APIs and OCR together.
- Use translation APIs with a fallback LLM for explanation, not just literal translation.

## Version Compatibility

| Package A | Compatible With | Notes |
|-----------|-----------------|-------|
| ScreenCaptureKit | macOS 12.3+ | Good baseline for modern screen capture. |
| SwiftUI floating-window conveniences | macOS 15+ | Useful, but AppKit `NSPanel` still matters for broader support. |
| Azure Speech / OpenAI / Anthropic / DeepL | Server-side proxy | Keep secrets server-side; do not call directly from the Mac app. |

## Sources

- Apple ScreenCaptureKit docs — capture desktop/window content, `SCShareableContent`, `SCContentFilter`.
- Apple SwiftUI/AppKit integration docs — window bridging, hosting, and custom macOS scenes.
- Anthropic vision docs — image input handling, limits, and desktop/screenshot reasoning caveats.
- OpenAI vision docs — multimodal image analysis and detail-level guidance for computer-use style workflows.
- Microsoft Azure Speech overview — STT, TTS, speech translation, and pronunciation assessment.

---
*Stack research for: macOS language-learning app for expats*
*Researched: 2026-04-13*
