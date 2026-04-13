---
phase: 01-read-in-place
plan: 02
type: execute
wave: 2
depends_on:
  - 01-read-in-place-01
files_modified:
  - leanring-buddy/ReadingLookupManager.swift
  - leanring-buddy/CompanionManager.swift
  - leanring-buddy/ReadingLookupResultView.swift
  - leanring-buddy/DesignSystem.swift
autonomous: true
requirements_addressed:
  - READ-02
must_haves:
  truths:
    - "Ambiguous or idiomatic text shows a short explanation instead of a misleading one-line answer"
    - "The translation stays visible even when an explanation is added"
    - "The app avoids overexplaining and keeps help concise"
  artifacts:
    - path: "leanring-buddy/ReadingLookupManager.swift"
      provides: "Ambiguity-aware lookup response shaping"
      contains: "isAmbiguous"
    - path: "leanring-buddy/ReadingLookupResultView.swift"
      provides: "Translation plus short explanation rendering"
      contains: "explanation"
    - path: "leanring-buddy/CompanionManager.swift"
      provides: "State selection for explanation-aware results"
      contains: "confidenceNote"
  key_links:
    - from: "ReadingLookupManager"
      to: "ReadingLookupResultView"
      via: "structured ambiguity fields"
      pattern: "isAmbiguous|explanation|confidenceNote"
    - from: "CompanionManager"
      to: "ReadingLookupManager"
      via: "request type or prompt mode"
      pattern: "ambiguous|idiomatic|explanation"
---

<objective>
Make reading help trustworthy when the source text is idiomatic, ambiguous, or has multiple valid readings.

Purpose: Prevent misleading one-line translations and keep the product aligned with concise, contextual help.
Output: An ambiguity-aware reading result model and a compact explanation callout in the UI.
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
@leanring-buddy/ReadingLookupManager.swift
@leanring-buddy/ReadingLookupResultView.swift
@leanring-buddy/CompanionManager.swift
@leanring-buddy/DesignSystem.swift
</context>

<tasks>

<task type="auto">
  <name>Task 1: Shape lookup output for ambiguity handling</name>
  <files>leanring-buddy/ReadingLookupManager.swift</files>
  <read_first>
    - leanring-buddy/ReadingLookupManager.swift
    - leanring-buddy/ClaudeAPI.swift
    - leanring-buddy/CompanionManager.swift
  </read_first>
  <action>
    Extend the lookup prompt and response model so the service can return a concise translation first, then a short explanation only when the text is idiomatic, ambiguous, slang-heavy, or otherwise likely to mislead a literal translation.

    Add explicit structured fields for isAmbiguous, explanation, and confidenceNote. Keep the explanation short: 1-3 sentences max, and do not turn the result into a lesson.
  </action>
  <acceptance_criteria>
    - `ReadingLookupManager.swift` contains `isAmbiguous`
    - `ReadingLookupManager.swift` contains `explanation`
    - `ReadingLookupManager.swift` contains `confidenceNote`
  </acceptance_criteria>
  <verify>grep -n "isAmbiguous\|explanation\|confidenceNote" leanring-buddy/ReadingLookupManager.swift</verify>
  <done>The lookup service can distinguish between direct translation and short explanation mode.</done>
</task>

<task type="auto">
  <name>Task 2: Render concise explanation copy in the result card</name>
  <files>leanring-buddy/ReadingLookupResultView.swift</files>
  <read_first>
    - leanring-buddy/ReadingLookupResultView.swift
    - leanring-buddy/CompanionManager.swift
    - leanring-buddy/DesignSystem.swift
  </read_first>
  <action>
    Update the result card so it always shows the short translation first and conditionally appends a compact explanation callout when isAmbiguous is true.

    Use careful wording that signals uncertainty when needed, keep the visual treatment subtle, and preserve the source text so users can compare meaning themselves.
  </action>
  <acceptance_criteria>
    - `ReadingLookupResultView.swift` renders a separate explanation block
    - the translation remains visible when explanation mode is active
    - the UI wording includes an uncertainty cue when the lookup is ambiguous
  </acceptance_criteria>
  <verify>grep -n "isAmbiguous\|explanation\|uncertainty\|confidence" leanring-buddy/ReadingLookupResultView.swift</verify>
  <done>Ambiguous text shows a short, non-misleading explanation without hiding the translation.</done>
</task>

</tasks>

<verification>
Confirm the reading result can shift between literal translation and concise explanation while staying compact and readable.
</verification>

<success_criteria>
- Ambiguous text no longer receives a misleading one-line answer.
- The explanation remains brief and secondary to the translation.
- The panel still feels like inline help, not a lesson screen.
</success_criteria>

<output>
After completion, create `.planning/phases/01-read-in-place/01-read-in-place-02-SUMMARY.md`
</output>
