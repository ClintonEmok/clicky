---
phase: 01-read-in-place
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - leanring-buddy/ReadingLookupManager.swift
  - leanring-buddy/CompanionManager.swift
  - leanring-buddy/ClaudeAPI.swift
  - leanring-buddy/CompanionPanelView.swift
  - leanring-buddy/ReadingLookupResultView.swift
autonomous: true
requirements_addressed:
  - READ-01
must_haves:
  truths:
    - "User can select or focus text and get a concise translation without leaving the current task"
    - "Lookup requests preserve the source text and current app context"
    - "The app shows clear loading, success, and error states for reading lookup"
  artifacts:
    - path: "leanring-buddy/ReadingLookupManager.swift"
      provides: "Lookup request/result flow for selected or visible text"
      exports:
        - "ReadingLookupManager"
        - "ReadingLookupRequest"
        - "ReadingLookupResult"
    - path: "leanring-buddy/CompanionManager.swift"
      provides: "App state and trigger wiring for reading lookup"
      contains: "readingLookup"
    - path: "leanring-buddy/ReadingLookupResultView.swift"
      provides: "Inline translation result presentation"
  key_links:
    - from: "CompanionManager"
      to: "ReadingLookupManager"
      via: "async lookup action and state updates"
      pattern: "readingLookup.*(start|result|error)"
    - from: "ReadingLookupManager"
      to: "ClaudeAPI"
      via: "translation request"
      pattern: "ClaudeAPI.*(analyze|stream)"
    - from: "CompanionPanelView"
      to: "ReadingLookupResultView"
      via: "inline panel section"
      pattern: "ReadingLookupResultView"
---

<objective>
Enable the first reading interaction: users can pick up visible or selected text and get a concise translation without leaving the current desktop task.

Purpose: Establish the core read-in-place loop before adding nuance or vocabulary management.
Output: Lookup data flow, app state wiring, and an inline result card in the menu bar panel.
</objective>

<execution_context>
@~/.config/opencode/get-shit-done/workflows/execute-plan.md
@~/.config/opencode/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/STATE.md
@.planning/REQUIREMENTS.md
@.planning/codebase/ARCHITECTURE.md
@.planning/codebase/CONVENTIONS.md
@.planning/codebase/CONCERNS.md
@leanring-buddy/CompanionManager.swift
@leanring-buddy/ClaudeAPI.swift
@leanring-buddy/CompanionPanelView.swift
@leanring-buddy/DesignSystem.swift
</context>

<tasks>

<task type="auto">
  <name>Task 1: Add reading lookup domain types and service</name>
  <files>leanring-buddy/ReadingLookupManager.swift</files>
  <read_first>
    - leanring-buddy/ClaudeAPI.swift
    - leanring-buddy/CompanionManager.swift
    - leanring-buddy/DesignSystem.swift
  </read_first>
  <action>
    Create a new @MainActor lookup service that accepts either selected text or visible text plus source context, sends one concise-translation request through ClaudeAPI, and returns a typed result with originalText, translatedText, sourceContext, sourceAppName, and a stable lookup ID.

    Keep the prompt narrowly scoped to direct translation for now. Do not add explanation logic, vocabulary saving, or a second API client in this task.
  </action>
  <acceptance_criteria>
    - `ReadingLookupManager.swift` defines `ReadingLookupRequest` and `ReadingLookupResult`
    - the service exposes one async lookup method that accepts source text plus context
    - the implementation reuses `ClaudeAPI` rather than introducing a new network path
  </acceptance_criteria>
  <verify>grep -n "ReadingLookupRequest\|ReadingLookupResult\|lookup" leanring-buddy/ReadingLookupManager.swift</verify>
  <done>The app has a typed core lookup flow for concise translation.</done>
</task>

<task type="auto">
  <name>Task 2: Wire lookup state into the app orchestrator</name>
  <files>leanring-buddy/CompanionManager.swift</files>
  <read_first>
    - leanring-buddy/CompanionManager.swift
    - leanring-buddy/ReadingLookupManager.swift
    - leanring-buddy/MenuBarPanelManager.swift
  </read_first>
  <action>
    Add a dedicated reading lookup state machine to CompanionManager with idle/loading/success/error states, a trigger for starting a lookup from either selected text or visible text, and reset behavior when a new lookup begins.

    Preserve the existing voice pipeline. This task should only add reading-mode orchestration, context capture, and state publishing for the panel/UI layer.
  </action>
  <acceptance_criteria>
    - `CompanionManager.swift` contains a reading lookup state property
    - `CompanionManager.swift` exposes a start-reading-lookup method
    - the new code stores the latest successful translation and latest lookup error separately
  </acceptance_criteria>
  <verify>grep -n "readingLookup\|startReadingLookup\|lookupError" leanring-buddy/CompanionManager.swift</verify>
  <done>The app can launch and track a reading lookup without disturbing voice mode.</done>
</task>

<task type="auto">
  <name>Task 3: Render the inline reading result card</name>
  <files>leanring-buddy/CompanionPanelView.swift</files>
  <read_first>
    - leanring-buddy/CompanionPanelView.swift
    - leanring-buddy/ReadingLookupResultView.swift
    - leanring-buddy/DesignSystem.swift
    - leanring-buddy/CompanionManager.swift
  </read_first>
  <action>
    Add a reading section to the menu bar panel with a lookup trigger, loading indicator, empty state, and an inline translation card that shows the source text and translated text side by side.

    Keep the result display non-modal and compact. Do not add saving, explanation, or review history in this task.
  </action>
  <acceptance_criteria>
    - `CompanionPanelView.swift` conditionally renders a reading result section
    - `ReadingLookupResultView.swift` exists and is used by the panel
    - the UI has explicit loading, success, and error branches for lookup state
  </acceptance_criteria>
  <verify>grep -n "ReadingLookupResultView\|reading lookup\|loading" leanring-buddy/CompanionPanelView.swift</verify>
  <done>Users can see a concise translation result inline in the panel.</done>
</task>

</tasks>

<verification>
Confirm the reading lookup flow is wired end to end:

1. The new lookup service exists and returns typed results.
2. The app state can start a lookup and expose loading/success/error transitions.
3. The panel shows the result inline instead of forcing a modal flow.
</verification>

<success_criteria>
- Concise translations for selected or visible text are available from the current task flow.
- The lookup result includes source context and app context.
- The panel shows a compact non-modal reading result card.
</success_criteria>

<output>
After completion, create `.planning/phases/01-read-in-place/01-read-in-place-01-SUMMARY.md`
</output>
