# Architecture Research

**Domain:** Desktop language-learning system for expats
**Researched:** 2026-04-13
**Confidence:** MEDIUM

## Standard Architecture

### System Overview

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                               Presentation Layer                            │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌──────────────────┐   ┌──────────────────┐   ┌─────────────────────────┐  │
│  │ Status bar /     │   │ Lesson / review   │   │ Conversation / overlay  │  │
│  │ floating panel   │   │ dashboard         │   │ coach UI                │  │
│  └─────────┬────────┘   └─────────┬────────┘   └─────────┬───────────────┘  │
│            │                      │                      │                  │
├────────────┴──────────────────────┴──────────────────────┴──────────────────┤
│                           Orchestration / Domain Layer                       │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────────────┐  │
│  │ Session manager   │  │ Language pipeline │  │ Learning memory manager  │  │
│  │ / state machine   │  │ router            │  │ (vocab, SRS, history)    │  │
│  └─────────┬────────┘  └─────────┬────────┘  └─────────┬────────────────┘  │
│            │                     │                     │                   │
├────────────┴─────────────────────┴─────────────────────┴───────────────────┤
│                         Device / Interaction Layer                          │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────────────┐  │
│  │ Accessibility     │  │ Screen capture   │  │ Input capture / hotkeys  │  │
│  │ / window scan     │  │ / OCR / context  │  │ / mic / clipboard        │  │
│  └─────────┬────────┘  └─────────┬────────┘  └─────────┬────────────────┘  │
│            │                     │                     │                   │
├────────────┴─────────────────────┴─────────────────────┴───────────────────┤
│                          AI / Knowledge Services Layer                      │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────────────┐  │
│  │ Translation API   │  │ LLM tutor /      │  │ Retrieval / terminology  │  │
│  │ / glossary        │  │ coach service    │  │ store                    │  │
│  └──────────────────┘  └──────────────────┘  └──────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|------------------------|
| UI shell | Owns navigation, current lesson/session view, notifications, and quick actions | Native desktop app UI (SwiftUI/Electron/Tauri/etc.) with lightweight state bindings |
| Session manager | Coordinates capture → translate → explain → review flow | Single orchestrator with async state machine and cancellation |
| Accessibility / window scan | Detects active app, selected text, UI labels, focused controls | OS accessibility APIs plus permission handling |
| Screen capture / OCR | Captures screenshots, crops regions, extracts visible text and context | OS capture APIs + OCR pipeline, often on-demand rather than continuous |
| Translation service | Produces literal translation, transliteration, and alternative phrasing | External translation API or internal model-backed translator |
| LLM tutor | Explains usage, generates examples, corrects user output, handles dialogue | Hosted LLM with structured prompts and safety/formatting guardrails |
| Learning memory manager | Stores vocab, phrases, user mistakes, spaced repetition queue, and progress | Local DB with syncable user profile and review scheduler |
| Retrieval / terminology store | Supplies prior translations, domain vocabulary, and user-specific context | Indexed embeddings + keyword lookup, or a simpler normalized glossary |
| Input capture | Collects hotkeys, clipboard text, optional mic input, and interaction triggers | Global shortcuts, paste listener, push-to-talk if voice is included |

## Recommended Project Structure

```text
src/
├── app/                  # app shell, bootstrap, routing
├── ui/                   # panels, overlays, dashboard, review screens
├── domain/               # session state, lesson logic, memory models
├── capture/              # accessibility, screen capture, OCR, clipboard
├── ai/                   # translation, LLM tutor, prompt building
├── memory/               # vocab store, review scheduler, retrieval
├── sync/                 # optional cloud sync, auth, backups
└── platform/             # desktop-specific permissions and OS bridges
```

### Structure Rationale

- **`app/`** keeps launch, lifecycle, and composition root separate from product logic.
- **`domain/`** isolates the learning workflow from platform APIs so lesson logic can evolve.
- **`capture/`** is its own boundary because permissions, latency, and failure modes differ from normal app code.
- **`ai/`** should be provider-agnostic to swap translation or LLM vendors later.
- **`memory/`** must stay independent so progress data survives UI and model changes.
- **`platform/`** contains OS-specific code that will vary the most between macOS, Windows, and Linux.

## Architectural Patterns

### Pattern 1: Capture-then-interpret pipeline

**What:** The app first collects raw context from the desktop, then sends a normalized payload to translation/LLM services.
**When to use:** Any time the product reacts to what the user is doing on-screen.
**Trade-offs:**
- Pros: simpler prompts, better debugging, easier replay of sessions
- Cons: permission-heavy, capture latency must be managed carefully

**Example:**
```ts
captureActiveWindow() -> extractTextAndRegions() -> buildContextPacket() -> callTutor()
```

### Pattern 2: Stateful session orchestrator

**What:** One coordinator owns the active learning session and advances through states like idle, observing, explaining, practicing, and reviewing.
**When to use:** When multiple async services must stay in sync.
**Trade-offs:**
- Pros: clear cancellation, fewer race conditions, easier UI binding
- Cons: can become a god object if domain boundaries are weak

**Example:**
```ts
switch (session.state) {
  case "observing":
    await contextService.capture()
    break
}
```

### Pattern 3: Memory as a first-class service

**What:** Vocab, phrases, corrections, and review intervals are stored independently of the session UI.
**When to use:** If the product promises retention and repeat practice.
**Trade-offs:**
- Pros: supports SRS, progress tracking, personalized feedback
- Cons: data model design matters early; migration pain if schema is sloppy

## Data Flow

### Request Flow

```text
User action
  ↓
UI / hotkey / selection event
  ↓
Capture layer (accessibility, screenshot, clipboard, OCR)
  ↓
Session manager normalizes context
  ↓
Translation service + LLM tutor
  ↓
Learning memory manager stores artifacts
  ↓
UI renders explanation, correction, and review prompt
```

### State Management

```text
Learning store
  ↓ subscribe
Session manager ↔ UI components
  ↓ mutate
Memory records / review queue / session history
```

### Key Data Flows

1. **Active context capture:** selected text, nearby UI text, screenshot region, and app/window metadata move from OS APIs into a normalized context packet.
2. **Interpretation:** the packet is routed to translation first, then to the LLM for explanation, examples, and correction.
3. **Retention:** new words/phrases/errors are written to memory with metadata such as source app, language, difficulty, and next-review time.
4. **Practice loop:** review queue items are surfaced back into the UI as flashcards, micro-lessons, or one-tap recall prompts.

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| 0-1k users | Monolith is fine; local-first memory with one external AI gateway |
| 1k-100k users | Add sync, encryption, analytics, and provider abstraction; isolate capture permissions carefully |
| 100k+ users | Split AI proxy, memory sync, and analytics into separate services if needed |

### Scaling Priorities

1. **First bottleneck:** permission/capture reliability. If screenshots or accessibility fail, the product feels broken immediately.
2. **Second bottleneck:** memory consistency. Review scheduling and vocabulary history must remain correct across devices.

## Anti-Patterns

### Anti-Pattern 1: Sending raw screenshots to the LLM for everything

**What people do:** use the model as the entire system, with no preprocessing or structure.
**Why it's wrong:** expensive, hard to debug, and brittle when OCR or layout matters.
**Do this instead:** extract structured context first, then let the LLM reason over it.

### Anti-Pattern 2: Mixing session logic with persistence

**What people do:** store vocabulary, UI state, and API responses in the same view model.
**Why it's wrong:** hard to test and impossible to evolve the review engine independently.
**Do this instead:** keep session orchestration separate from memory/storage services.

### Anti-Pattern 3: Treating accessibility as optional

**What people do:** build the core learning loop around manual text entry only.
**Why it's wrong:** expat users need low-friction capture from whatever app they are already using.
**Do this instead:** make accessibility/window context a core input, with fallback manual entry.

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| Translation API | Request/response or streaming text endpoint | Use for literal translations and language metadata |
| LLM provider | Prompted tutoring with structured output | Needs strict JSON or tagged output for UI rendering |
| OCR engine | On-device or OS-assisted extraction | Prefer local processing when possible for privacy/latency |
| Cloud sync | Authenticated profile sync | Optional for MVP, but important for multi-device progress |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| UI ↔ session manager | Published state / events | UI should never directly call translation vendors |
| session manager ↔ capture layer | async service calls | Capture returns normalized context, not raw OS objects |
| session manager ↔ ai layer | typed request objects | Keeps prompts and provider switching contained |
| session manager ↔ memory store | repository interface | Enables local DB now, sync later |

## Sources

- `/.planning/codebase/ARCHITECTURE.md` — existing desktop app constraints and AppKit/SwiftUI orchestration patterns
- Domain inference from the project brief: desktop language-learning workflow for expats

---
*Architecture research for: desktop language-learning system for expats*
*Researched: 2026-04-13*
