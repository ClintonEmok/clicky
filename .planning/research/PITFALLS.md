# Pitfalls Research

**Domain:** desktop language-learning assistant for expats
**Researched:** 2026-04-13
**Confidence:** MEDIUM

## Critical Pitfalls

### Pitfall 1: Overconfident translation and explanation

**What goes wrong:**
The app presents a single translation, grammar note, or “best next action” as if it were certain when the source text is ambiguous, idiomatic, or context-dependent. Users then learn the wrong meaning or act on bad guidance.

**Why it happens:**
Language models are good at fluent answers, not guaranteed interpretation. Desktop overlays also encourage fast, glanceable responses, which pushes the product toward certainty theater.

**How to avoid:**
Show confidence levels, alternate interpretations, and short “why this might mean X” notes. Prefer ranked options over one answer. Let users tap for deeper explanation instead of forcing it into the overlay.

**Warning signs:**
- Translations look clean but users keep asking follow-up “what does this really mean?”
- The same phrase is translated inconsistently across screens
- Users copy guidance into real-world situations and report embarrassment or confusion

**Phase to address:**
Phase 1 foundation, before any broad assistant rollout.

---

### Pitfall 2: Privacy leakage through screenshots, audio, and analytics

**What goes wrong:**
The app captures or transmits personal data the user did not intend to share: emails, chats, addresses, calendar items, bank pages, workplace dashboards, or private conversations. Analytics can also become a hidden transcript archive.

**Why it happens:**
Desktop assistance works by observing the screen, but that creates a high-risk default. Teams often optimize for model accuracy first and privacy boundaries later.

**How to avoid:**
Minimize capture scope, redact sensitive regions, make capture obvious, and give a strict local-only or private-mode path. Keep telemetry text-free by default. Make data retention explicit and user-controlled.

**Warning signs:**
- Users hesitate before using the app on work accounts
- Support questions mention “did it upload my screen?”
- Internal logs or analytics contain raw text, screenshots, or account identifiers

**Phase to address:**
Phase 1 foundation for consent and data boundaries; Phase 2 for redaction and retention controls.

---

### Pitfall 3: Screen-capture and accessibility failures block the core flow

**What goes wrong:**
The app asks for permissions too late, behaves unpredictably after permission changes, fails on multi-monitor setups, or creates overlays that interfere with screen readers, magnifiers, voice control, or keyboard navigation.

**Why it happens:**
Desktop permissions are brittle and stateful, and macOS accessibility APIs are easy to misuse. Overlay-first products often prioritize visuals over assistive compatibility.

**How to avoid:**
Design the permission journey as part of the product, not a setup afterthought. Test VoiceOver, reduced motion, keyboard-only use, and multi-display scenarios early. Make overlays dismissible and non-blocking.

**Warning signs:**
- Users get stuck on permission prompts
- Capture works once but fails after settings changes or relaunch
- Overlay obscures important UI or steals focus

**Phase to address:**
Phase 1 foundation, with accessibility and permission validation before feature expansion.

---

### Pitfall 4: Latency and resource drain make the assistant feel unreliable

**What goes wrong:**
Transcription, capture, translation, and voice playback lag enough that the app feels “late,” battery-heavy, or noisy. Users stop trusting it because it interrupts flow instead of supporting it.

**Why it happens:**
Vision plus speech plus streaming is expensive. Desktop apps can accidentally re-capture too much, re-encode images, or keep hot loops running in the background.

**How to avoid:**
Set hard latency budgets, degrade gracefully, and prefer incremental/partial responses. Capture the minimum needed, cache aggressively, and throttle background polling.

**Warning signs:**
- The assistant feels slower than just looking things up manually
- Fans spin, battery drops, or CPU spikes during normal use
- Users cancel before responses finish

**Phase to address:**
Phase 2 core experience, before scaling to richer computer-use features.

---

### Pitfall 5: Immersion gets broken by noisy, over-helpful UX

**What goes wrong:**
The app interrupts too often, over-explains, or behaves like a tutor instead of a subtle companion. Instead of supporting language immersion, it pulls users out of the task and into app management.

**Why it happens:**
Teams optimize for “helpfulness” and ship constant nudges, tooltips, and correction prompts. For expats, the product must respect the user’s real task and attention budget.

**How to avoid:**
Make help opt-in, delayed, and context-aware. Use progressive disclosure. Prefer quiet, inline support over modal interruptions. Let users choose immersion mode vs explicit tutoring mode.

**Warning signs:**
- Users turn off notifications or the overlay
- The app gets ignored during real work
- Conversations become about the app, not the target language task

**Phase to address:**
Phase 2 for interaction design; Phase 3 for personalization and adaptive intervention.

---

## Technical Debt Patterns

Shortcuts that seem reasonable but create long-term problems.

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| One generic “translate/explain” prompt | Fast launch | Bad ambiguity handling and inconsistent guidance | Never for core translation flow |
| Always capture the full screen | Simpler implementation | Privacy risk, slower requests, higher cost | Only in tightly scoped demos |
| Store raw transcripts for analytics | Easy product insight | Sensitive data exposure and trust loss | Never as a default |
| One overlay UI for all users | Less UI work | Bad fit for accessibility and immersion needs | MVP only if fully configurable |

## Integration Gotchas

Common mistakes when connecting to external services.

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| Speech-to-text | Treating partial transcripts as final | Label interim vs finalized text clearly |
| Translation/LLM | Assuming one answer is correct | Return alternatives and confidence cues |
| Screen capture | Capturing too much or too often | Capture only what is needed, only when needed |
| Analytics | Logging full user content | Redact or avoid content payloads entirely |

## Performance Traps

Patterns that work at small scale but fail as usage grows.

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Full-screen multi-monitor capture every turn | Slow responses, battery drain, privacy concern | Scope capture to active display/context | Immediately on privacy-sensitive users |
| Repeated image encoding/upload | High CPU and network usage | Downsample once, reuse payloads, cache where safe | At any non-trivial usage |
| Continuous permission polling | Background churn and UI jank | Event-driven refresh where possible | When app stays open for hours |
| Over-rendered overlay animation | Distracting UI and extra CPU | Keep motion minimal and tied to need | On low-power laptops |

## Security Mistakes

Domain-specific security issues beyond general web security.

| Mistake | Risk | Prevention |
|---------|------|------------|
| Treating workplace screens as safe by default | Leaks confidential information | Default to least-capture and explicit consent |
| Sending raw text to third-party services without disclosure | Trust loss, compliance risk | Explain data flow and retention clearly |
| Storing secrets or identifiers in the client | Abuse and rotation pain | Keep secrets in a proxy or config layer |
| Silent telemetry collection | Perceived surveillance | Make analytics opt-in or heavily minimized |

## UX Pitfalls

Common user experience mistakes in this domain.

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Too much correction | Users feel judged and stop using it | Correct only when asked or when confidence is high |
| Tooltip overload | Interrupts the task | Use progressive disclosure and short summaries |
| Hidden capture state | Users feel spied on | Show a clear recording/capture indicator |
| One-size-fits-all help | Beginners overwhelmed, advanced users annoyed | Offer levels of assistance |

## "Looks Done But Isn't" Checklist

- [ ] **Translation output:** Often missing ambiguity alternatives — verify confidence and examples are shown.
- [ ] **Privacy mode:** Often missing retention controls — verify users can limit capture and storage.
- [ ] **Accessibility:** Often missing keyboard/VoiceOver validation — verify overlay and permissions are operable without a mouse.
- [ ] **Performance:** Often missing realistic hardware tests — verify on battery, multi-monitor, and slower network conditions.

## Recovery Strategies

When pitfalls occur despite prevention, how to recover.

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Wrong translation shown | MEDIUM | Provide correction history, allow user feedback, and avoid repeating the bad interpretation |
| Privacy scare | HIGH | Publish a clear incident explanation, add stronger defaults, and reduce captured content immediately |
| Permission failure | MEDIUM | Re-run guided setup, explain exactly which permission is missing, and preserve user state |
| Performance collapse | MEDIUM | Reduce capture scope, disable nonessential features, and ship a low-power mode |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Overconfident translation | Phase 1 | Ambiguous phrases return multiple interpretations and confidence labels |
| Privacy leakage | Phase 1 | Data flow review and user-facing consent copy exist before beta |
| Accessibility/screen-capture failure | Phase 1 | VoiceOver, keyboard-only, and permission flows pass manual checks |
| Latency/resource drain | Phase 2 | Core assist completes within a usable response budget on target hardware |
| Immersion-breaking UX | Phase 2-3 | Users can keep working without frequent app-managed interruptions |

## Sources

- Existing codebase concerns audit (`.planning/codebase/CONCERNS.md`)
- Product domain inference from greenfield brief and current app architecture

---
*Pitfalls research for: desktop language-learning assistant for expats*
*Researched: 2026-04-13*
