---
phase: 01-read-in-place
plan: 03
type: execute
wave: 3
depends_on:
  - 01-read-in-place-01
  - 01-read-in-place-02
files_modified:
  - leanring-buddy/ReadingVocabularyStore.swift
  - leanring-buddy/ReadingVocabularyListView.swift
  - leanring-buddy/CompanionManager.swift
  - leanring-buddy/ReadingLookupResultView.swift
  - leanring-buddy/CompanionPanelView.swift
autonomous: false
requirements_addressed:
  - READ-03
must_haves:
  truths:
    - "User can save unknown words or phrases together with the source context they came from"
    - "Saved items persist across app relaunches"
    - "Users can review saved items from the same panel they use for lookup"
  artifacts:
    - path: "leanring-buddy/ReadingVocabularyStore.swift"
      provides: "Persistent storage for saved reading items"
      exports:
        - "ReadingVocabularyStore"
        - "ReadingVocabularyItem"
    - path: "leanring-buddy/ReadingVocabularyListView.swift"
      provides: "Saved items review list"
      contains: "ReadingVocabularyListView"
    - path: "leanring-buddy/CompanionManager.swift"
      provides: "Save/delete/clear actions for vocabulary items"
      contains: "saveReadingVocabularyItem"
  key_links:
    - from: "ReadingLookupResultView"
      to: "ReadingVocabularyStore"
      via: "save button action"
      pattern: "saveReadingVocabularyItem|ReadingVocabularyStore"
    - from: "CompanionPanelView"
      to: "ReadingVocabularyListView"
      via: "saved items section"
      pattern: "ReadingVocabularyListView"
---

<objective>
Let users save unfamiliar words and phrases with the source context that produced them.

Purpose: Turn one-off reading help into reusable vocabulary without breaking the desktop flow.
Output: Persistent saved-item storage, a save action on the reading card, and a review list in the panel.
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
@.planning/codebase/CONCERNS.md
@.planning/codebase/CONVENTIONS.md
@.planning/codebase/TESTING.md
@leanring-buddy/ReadingLookupResultView.swift
@leanring-buddy/CompanionManager.swift
@leanring-buddy/CompanionPanelView.swift
@leanring-buddy/WindowPositionManager.swift
</context>

<tasks>

<task type="auto">
  <name>Task 1: Add persistent vocabulary storage</name>
  <files>leanring-buddy/ReadingVocabularyStore.swift</files>
  <read_first>
    - leanring-buddy/CompanionManager.swift
    - leanring-buddy/WindowPositionManager.swift
    - leanring-buddy/ReadingLookupResultView.swift
  </read_first>
  <action>
    Create a codable vocabulary store backed by UserDefaults that saves the source text, translation, optional explanation, source app name, source context, and capture timestamp for each saved item.

    Use a stable identifier per item, keep the stored list capped at the newest 100 items, and provide add/remove/clear methods. Do not introduce a database or file-based persistence for this phase.
  </action>
  <acceptance_criteria>
    - `ReadingVocabularyStore.swift` defines `ReadingVocabularyItem`
    - the store persists items through app relaunches
    - the store exposes add, delete, and clear operations
  </acceptance_criteria>
  <verify>grep -n "ReadingVocabularyItem\|UserDefaults\|clear" leanring-buddy/ReadingVocabularyStore.swift</verify>
  <done>Saved vocabulary survives relaunch and keeps source context attached.</done>
</task>

<task type="auto">
  <name>Task 2: Wire save actions and review UI into the panel</name>
  <files>leanring-buddy/ReadingLookupResultView.swift</files>
  <read_first>
    - leanring-buddy/ReadingLookupResultView.swift
    - leanring-buddy/ReadingVocabularyListView.swift
    - leanring-buddy/CompanionPanelView.swift
    - leanring-buddy/CompanionManager.swift
  </read_first>
  <action>
    Add a save button to the reading result card and a saved-items section to the panel that lists each saved word or phrase with its translation, source app, and original context.

    Keep the review UI compact, inline, and easy to clear. Include an empty state when nothing has been saved yet.
  </action>
  <acceptance_criteria>
    - `ReadingLookupResultView.swift` exposes a save action
    - `ReadingVocabularyListView.swift` renders saved items
    - `CompanionPanelView.swift` shows the saved-items section inline
  </acceptance_criteria>
  <verify>grep -n "saveReadingVocabularyItem\|ReadingVocabularyListView\|empty state" leanring-buddy/ReadingLookupResultView.swift leanring-buddy/ReadingVocabularyListView.swift leanring-buddy/CompanionPanelView.swift</verify>
  <done>Users can save a word or phrase from lookup and review it from the same panel.</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>Persistent save flow for unknown words and phrases with source context.</what-built>
  <how-to-verify>
    1. Perform a lookup on a foreign phrase that shows the reading card.
    2. Save the item from the card.
    3. Quit and relaunch the app.
    4. Open the panel again and confirm the saved item still shows the original source text, translation, and source context.
  </how-to-verify>
  <resume-signal>Type "approved" or describe issues</resume-signal>
</task>

</tasks>

<verification>
Confirm saved vocabulary persists, includes source context, and is reviewable from the main panel after relaunch.
</verification>

<success_criteria>
- Unknown words and phrases can be saved from a reading result.
- Saved items remain available after relaunch.
- The panel includes a compact review section for saved vocabulary.
</success_criteria>

<output>
After completion, create `.planning/phases/01-read-in-place/01-read-in-place-03-SUMMARY.md`
</output>
