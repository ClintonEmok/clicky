# Roadmap: Language Learning for Expats

## Overview

This roadmap keeps the product desktop-first and immersion-first: expats should be able to read, write, and stay in the target language while working on their Mac without getting pulled into a lesson app. V1 starts with reading support and API flexibility, then writing help, then immersion controls; speaking stays out of scope for later.

## Phases

- [x] **Phase 1: Read in Place** - Let users understand foreign-language text where they already are.
- [ ] **Phase 2: OpenAPI-Compatible Models and Local TTS** - Let the app use any OpenAI-compatible model and local text-to-speech.
- [ ] **Phase 3: Write with Guidance** - Let users draft and refine target-language messages and forms.
- [ ] **Phase 4: Stay Immersed** - Keep the experience mostly in the target language with minimal interruption.

## Phase Details

### Phase 1: Read in Place
**Goal**: Users can quickly understand selected or visible text and save useful language they encounter.
**Depends on**: Nothing (first phase)
**Requirements**: READ-01, READ-02, READ-03
**Plans**: 3 plans
Plans:
- [x] 01-read-in-place-01-PLAN.md — Core lookup flow and inline translation
- [x] 01-read-in-place-02-PLAN.md — Ambiguous text explanation
- [x] 01-read-in-place-03-PLAN.md — Save vocabulary with source context
**Success Criteria** (what must be TRUE):
  1. User can select or focus text and get a concise translation without leaving the current task.
  2. Ambiguous or idiomatic text surfaces a short explanation instead of a misleading one-line answer.
  3. User can save unknown words or phrases together with the source context they came from.

### Phase 2: OpenAPI-Compatible Models and Local TTS
**Goal**: Users can choose a model through an OpenAI-compatible API and use local TTS for lower-latency speech.
**Depends on**: Phase 1
**Requirements**: TBD
**Plans**: 2 plans
Plans:
- [ ] 02-01-PLAN.md — OpenAI-compatible model support
- [ ] 02-02-PLAN.md — Local TTS integration
**Success Criteria** (what must be TRUE):
  1. The app can talk to an OpenAI-compatible model endpoint.
  2. The app can play responses through a local TTS path.
  3. Model and TTS selection remain configurable without changing the main reading flow.

### Phase 3: Write with Guidance
**Goal**: Users can compose and revise messages in the target language without switching into a separate writing tool.
**Depends on**: Phase 2
**Requirements**: WRITE-01, WRITE-02
**Success Criteria** (what must be TRUE):
  1. User can draft or rewrite text in the target language from within their normal desktop workflow.
  2. User can ask for tone or grammar suggestions and see them applied to the current message or form.
  3. Suggestions appear as part of the writing flow, not as a separate lesson or blocking dialog.

### Phase 4: Stay Immersed
**Goal**: Users can keep the app itself and its assistance mostly in the target language while staying in flow.
**Depends on**: Phase 3
**Requirements**: IMMR-01, IMMR-02
**Success Criteria** (what must be TRUE):
  1. The app can present its interface mostly in the target language with only minimal English fallback.
  2. Help appears inline and contextually instead of forcing modal interruptions.
  3. Users can keep working in their existing app with help staying subtle and non-disruptive.

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Read in Place | 3/3 | Complete | 2026-04-13 |
| 2. OpenAPI-Compatible Models and Local TTS | 0/0 | Not started | - |
| 3. Write with Guidance | 0/0 | Not started | - |
| 4. Stay Immersed | 0/0 | Not started | - |

