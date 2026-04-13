# Language Learning for Expats

## What This Is

A macOS language-learning companion that helps expats use their computer in the language they want to learn. It supports reading and writing in-context with a strong immersion bias, so users can stay in the target language while still getting translation and explanation when they need it.

## Core Value

Help expats keep using their computer in the target language without getting stuck.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Instant lookup for selected or visible text with concise translation and explanation
- [ ] Save unknown words and phrases with source context for later review
- [ ] Writing assist for emails, chats, and forms in the target language
- [ ] Immersion mode that minimizes English and reduces interruption

### Out of Scope

- [ ] Full Duolingo-style course paths — the product is about real computer use, not curriculum delivery
- [ ] Heavy gamification — it distracts from immersion and actual work
- [ ] Auto-translate everything on screen — it breaks immersion

## Context

This is a desktop-first language-learning product for expats. The user wants to work in the language they are learning, with v1 focused on reading and writing support rather than speaking drills.

The existing codebase is a macOS menu bar app with AppKit/SwiftUI, screen capture, accessibility, and external AI services, so the new product should preserve a native desktop workflow and likely reuse the same platform strengths.

## Constraints

- **Platform**: macOS-first — the product depends on native desktop affordances and permissions.
- **Experience**: Immersion-first — help should be subtle, contextual, and not turn into a lesson app.
- **Scope**: Start with reading and writing — voice practice can come later.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Focus v1 on reading and writing assistance | Clear first value for expats using the computer | — Pending |
| Keep immersion mode as the default experience | Reduces interruption and supports learning in context | — Pending |
| Treat translation as contextual help, not a full course | Keeps the product aligned with real-world usage | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-04-13 after initialization*
