# Feature Research

**Domain:** Desktop language-learning assistant for expats / immersion while using the computer
**Researched:** 2026-04-13
**Confidence:** MEDIUM

## Feature Landscape

### Table Stakes (Users Expect These)

Features users assume exist. Missing these = product feels incomplete.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Instant on-screen translation on click/hover | Core “learn while reading” behavior in tools like Readlang and LingQ | MEDIUM | Must work on arbitrary text in browser/apps where possible |
| Save unknown words/phrases to a vocabulary list | Users need a memory loop, not just one-off lookup | MEDIUM | Include word, phrase, translation, and source context |
| Contextual definitions / explanations | Literal translation alone is often insufficient | MEDIUM | Short, plain-language explanations beat long AI essays |
| Reader support for long-form content | Immersive learning depends on reading real content, not drills | MEDIUM | Support articles, docs, emails, messages, and pasted text |
| Quick re-lookup of previously seen vocabulary | Repetition is essential for retention | LOW | Can be from history, sidebar, or command palette |
| Target-language UI affordances | Users need the app itself to model immersion | LOW | Minimal chrome, target-language labels, optional bilingual fallback |

### Differentiators (Competitive Advantage)

Features that set the product apart. Not required, but valuable.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| System-wide reading overlay | Lets users learn from anything already on their computer, not just imported content | HIGH | Strong fit for desktop-only, immersion-first workflow |
| Writing assist in-context | Helps users draft replies, emails, chats, and forms in the target language | HIGH | Can suggest rewrite, tone, and grammar help without replacing user input |
| Progressive immersion mode | Slowly hides translations as proficiency improves | MEDIUM | Reduces dependence on the tool over time |
| One-click capture of unknown phrases from any app | Low-friction vocabulary capture beats copy/paste workflows | HIGH | Especially useful for expats using chat, docs, and OS UI |
| Smart bilingual inline support | Shows just enough translation to keep flow without breaking immersion | HIGH | Better than full-page translation dumps |
| Personalized vocab from the user’s actual life | Focus on apartment hunting, work, groceries, transit, admin tasks | MEDIUM | High relevance for expats; more valuable than generic word lists |

### Anti-Features (Commonly Requested, Often Problematic)

Features that seem good but create problems.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Full Duolingo-style course paths | Feels structured and familiar | Pulls the product away from immersion and adds curriculum overhead | Keep to contextual help and vocabulary capture |
| Heavy gamification / streak economy | Improves short-term engagement | Distracts from real-world language use | Use light progress signals and usage stats only |
| Auto-translate everything on the screen | Feels convenient | Destroys immersion and overwhelms users with noise | Translate on demand, with progressive reveal |
| Large lesson authoring system | Seems like a way to scale content | Content ops burden is high and it duplicates what users already consume | Let users learn from their own apps and text |
| AI-generated long explanations by default | Feels smart | Slows flow and can be inaccurate or verbose | Offer concise translation first, deeper help on request |
| Full-featured grammar tutor | Appears educationally complete | Turns the product into a second language school | Offer targeted rewrite help and minimal grammar hints |

## Feature Dependencies

```
[On-screen lookup]
    └──requires──> [Text detection / selection capture]
                        └──requires──> [Language model or dictionary service]

[Vocabulary save]
    └──requires──> [Lookup history + source context]

[Writing assist]
    └──requires──> [Translation + rewrite primitives]

[Progressive immersion mode] ──enhances──> [On-screen lookup]

[Auto-translate everything] ──conflicts──> [Progressive immersion mode]
```

### Dependency Notes

- **On-screen lookup requires text detection / selection capture:** desktop UX only works if the app can reliably grab text from the active surface.
- **Vocabulary save requires lookup history + source context:** without context, review turns into isolated word memorization.
- **Writing assist requires translation + rewrite primitives:** it is a downstream feature of the core language understanding pipeline.
- **Progressive immersion mode enhances on-screen lookup:** it supports retention by reducing help over time.
- **Auto-translate everything conflicts with progressive immersion mode:** one optimizes convenience, the other optimizes learning.

## MVP Definition

### Launch With (v1)

Minimum viable product — what's needed to validate the concept.

- [ ] Instant lookup for selected text — validates the core immersion workflow
- [ ] Save words/phrases with source context — creates a retention loop
- [ ] Concise translation + short explanation — covers reading and writing basics without overbuilding

### Add After Validation (v1.x)

Features to add once core is working.

- [ ] Writing rewrite suggestions — add after users show they want help composing messages
- [ ] Progress tracking / vocabulary review — add after capture volume proves the loop
- [ ] Progressive immersion mode — add once baseline lookup quality is strong

### Future Consideration (v2+)

Features to defer until product-market fit is established.

- [ ] Personalized expat scenario packs — useful, but only after core immersion is sticky
- [ ] Advanced multi-app capture / OCR everywhere — powerful, but high engineering and permission complexity
- [ ] Deep analytics dashboards — defer until there is enough usage data to justify them

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Instant on-screen lookup | HIGH | MEDIUM | P1 |
| Save words/phrases with context | HIGH | MEDIUM | P1 |
| Concise translation + explanation | HIGH | MEDIUM | P1 |
| Writing assist / rewrite help | HIGH | HIGH | P2 |
| Progressive immersion mode | MEDIUM | MEDIUM | P2 |
| Personal expat scenario packs | MEDIUM | MEDIUM | P3 |
| Full lesson system / curriculum | LOW | HIGH | P3 |

**Priority key:**
- P1: Must have for launch
- P2: Should have, add when possible
- P3: Nice to have, future consideration

## Competitor Feature Analysis

| Feature | Competitor A | Competitor B | Our Approach |
|---------|--------------|--------------|--------------|
| Click-to-translate reading | Readlang emphasizes instant word/phrase translation on any text or website | LingQ emphasizes reading real content with highlighted words | Match this as baseline and optimize for desktop-wide use |
| Vocabulary retention | Readlang saves translated words into flashcards | LingQ tracks known/unknown words and learning stats | Keep simple save/review loop with source context, not a giant curriculum |
| Immersive content import | LingQ importer turns external content into lessons | Language Reactor focuses on subtitles and media immersion | Focus on what users are already doing on their computer instead of content import first |
| Contextual AI help | Readlang offers context-aware explanations | LingQ offers AI tools for transcripts, translations, and audio | Use AI for concise help and rewrite support, but keep it optional and fast |

## Sources

- Readlang features / landing page
- LingQ homepage / method pages
- Language Learning with Netflix / Language Reactor pages

---
*Feature research for: Desktop immersion-first language learning for expats*
*Researched: 2026-04-13*
