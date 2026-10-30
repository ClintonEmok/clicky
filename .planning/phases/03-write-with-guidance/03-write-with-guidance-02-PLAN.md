---
phase: 02-write-with-guidance
plan: 02
type: execute
wave: 1
depends_on: []
files_modified:
  - leanring-buddy/GlobalPushToTalkShortcutMonitor.swift
  - leanring-buddy/CompanionManager.swift
  - leanring-buddy/OverlayWindow.swift
  - leanring-buddy/WritingAssistAnnotationView.swift
autonomous: true
requirements_addressed:
  - WRITE-01
  - WRITE-02
must_haves:
  truths:
    - "User can trigger writing assist from any app using ctrl+option+W"
    - "User can see annotated suggestions in context within the writing flow"
    - "User can accept or dismiss suggestions individually or as a batch"
  artifacts:
    - path: "leanring-buddy/GlobalPushToTalkShortcutMonitor.swift"
      provides: "Secondary hotkey (ctrl+option+W) for writing assist trigger"
      contains: "writingAssist"
    - path: "leanring-buddy/OverlayWindow.swift"
      provides: "Annotation presentation in overlay context"
      contains: "writingAssistAnnotation"
    - path: "leanring-buddy/WritingAssistAnnotationView.swift"
      provides: "Inline annotation chip with hover/tap interaction"
  key_links:
    - from: "GlobalPushToTalkShortcutMonitor"
      to: "CompanionManager"
      via: "write assist trigger"
      pattern: "startWritingAssist"
    - from: "CompanionPanelView"
      to: "OverlayWindow"
      via: "annotation context display"
      pattern: "WritingAssistAnnotationView"
---

<objective>
Complete the write-with-guidance flow: ctrl+option+W triggers writing assist, annotations appear in context, and users can accept/dismiss suggestions.

Purpose: Wire the hotkey trigger and annotation interaction, making the writing assist feel like a natural extension of the companion's existing interaction model.
Output: Hotkey integration, overlay annotation rendering, and suggestion acceptance flow.
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
@.planning/phases/02-write-with-guidance/02-CONTEXT.md
@.planning/phases/02-write-with-guidance/02-RESEARCH.md
@.planning/phases/02-write-with-guidance/02-write-with-guidance-01-PLAN.md
@.planning/phases/01-read-in-place/01-CONTEXT.md
@.planning/codebase/ARCHITECTURE.md
@.planning/codebase/CONVENTIONS.md
@leanring-buddy/CompanionManager.swift
@leanring-buddy/GlobalPushToTalkShortcutMonitor.swift
@leanring-buddy/OverlayWindow.swift
@leanring-buddy/CompanionPanelView.swift
@leanring-buddy/DesignSystem.swift
</context>

<tasks>

<task type="auto">
  <name>Task 1: Add ctrl+option+W hotkey trigger for writing assist</name>
  <files>leanring-buddy/GlobalPushToTalkShortcutMonitor.swift</files>
  <read_first>
    - leanring-buddy/GlobalPushToTalkShortcutMonitor.swift
    - leanring-buddy/CompanionManager.swift
  </read_first>
  <action>
    Modify `GlobalPushToTalkShortcutMonitor.swift` to support a secondary hotkey for writing assist.

    The existing implementation uses a listen-only CGEvent tap for ctrl+option (voice). We need to add ctrl+option+W (writing).

    Add a second key combination detection in the same tap. When ctrl+option+W is detected:
    1. Post a `writingAssistTriggered` notification or call a delegate method on CompanionManager
    2. CompanionManager's `startWritingAssist()` is called (from Plan 01)
    3. MenuBarPanelManager shows/raises the panel if not visible

    Key code for W: 13 (kCGKeyW)

    The detection should be:
    - Modifier mask: control + option (same as voice)
    - Plus key: W

    Add a new published property to CompanionManager:
    ```swift
    @Published var isWritingAssistHotkeyEnabled: Bool = true
    ```

    If the user disables writing assist hotkey, the ctrl+option+W combination does nothing.

    Keep the existing voice shortcut (ctrl+option) fully functional. These are two independent trigger paths.
  </action>
  <verify>
    grep -n "writingAssist\|ctrl.*option.*W\|writingAssistTriggered" leanring-buddy/GlobalPushToTalkShortcutMonitor.swift
    grep -n "startWritingAssist\|isWritingAssistHotkeyEnabled" leanring-buddy/CompanionManager.swift
  </verify>
  <done>Users can trigger writing assist from any app using ctrl+option+W.</done>
</task>

<task type="auto">
  <name>Task 2: Create WritingAssistAnnotationView for inline annotations</name>
  <files>leanring-buddy/WritingAssistAnnotationView.swift</files>
  <read_first>
    - leanring-buddy/DesignSystem.swift
    - leanring-buddy/CompanionPanelView.swift
    - leanring-buddy/WritingAssistManager.swift
  </read_first>
  <action>
    Create `leanring-buddy/WritingAssistAnnotationView.swift` — a SwiftUI view for a single annotation chip.

    The chip shows:
    1. Original text (crossed out or with strikethrough, color: `DS.Colors.textSecondary`)
    2. Arrow (→) in `DS.Colors.accent`
    3. Revised text (color: `DS.Colors.textPrimary`)
    4. A small "why" indicator icon

    On tap/hover (expand):
    - A tooltip/popover appears with the `explanation` text
    - Background: `DS.Colors.surfaceSecondary`
    - Corner radius: `DS.CornerRadius.chip`

    Design:
    ```swift
    struct WritingAssistAnnotationView: View {
        let suggestion: Suggestion
        var onAccept: () -> Void
        var onDismiss: () -> Void

        @State private var isExpanded: Bool = false

        var body: some View {
            HStack(spacing: DS.Spacing.xs) {
                // Original text with strikethrough
                Text(suggestion.originalSegment)
                    .strikethrough(true, color: DS.Colors.textSecondary)
                    .foregroundColor(DS.Colors.textSecondary)

                // Arrow
                Text("→")
                    .foregroundColor(DS.Colors.accent)

                // Revised text
                Text(suggestion.revisedSegment)
                    .foregroundColor(DS.Colors.textPrimary)

                Spacer()

                // "Why" button
                Button {
                    isExpanded.toggle()
                } label: {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(DS.Colors.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(DS.Spacing.sm)
            .background(DS.Colors.surface)
            .cornerRadius(DS.CornerRadius.chip)
            .overlay(
                isExpanded ?
                Text(suggestion.explanation)
                    .font(DS.Typography.caption)
                    .foregroundColor(DS.Colors.textPrimary)
                    .padding(DS.Spacing.sm)
                    .background(DS.Colors.surfaceSecondary)
                    .cornerRadius(DS.CornerRadius.tooltip)
                : nil
            )
        }
    }
    ```

    Keep animations subtle (200ms ease-in-out max). No jarring transitions.
  </action>
  <verify>
    grep -n "WritingAssistAnnotationView" leanring-buddy/WritingAssistAnnotationView.swift
  </verify>
  <done>Annotations display as compact chips with original→revised text and expandable explanations.</done>
</task>

<task type="auto">
  <name>Task 3: Wire suggestion acceptance and dismiss flow</name>
  <files>leanring-buddy/CompanionPanelView.swift</files>
  <read_first>
    - leanring-buddy/CompanionPanelView.swift
    - leanring-buddy/CompanionManager.swift
    - leanring-buddy/WritingAssistAnnotationView.swift
  </read_first>
  <action>
    Add suggestion acceptance actions to CompanionPanelView's WritingAssistSection.

    In the suggestionsReady state, add action buttons:

    1. **"Apply All" button**:
       - Takes all suggestions where `suggestionType == .grammar` or `.spelling` (safe changes)
       - For `.tone` and `.wordChoice` suggestions, show a confirmation ("Apply tone suggestion?")
       - When applied: copies `result.revisedFullText` to clipboard, shows brief "Copied!" confirmation
       - Dismisses the writing assist state after copy

    2. **Individual accept/dismiss on each annotation**:
       - Each `WritingAssistAnnotationView` has onAccept/onDismiss closures
       - When accepted: removes that suggestion from the list, updates revisedFullText
       - When dismissed: removes that suggestion from the list

    3. **"Copy Revised" button** (secondary action):
       - Always visible in suggestionsReady state
       - Copies `result.revisedFullText` to clipboard without applying any filtering
       - Shows brief "Copied!" confirmation

    4. **"Start Over" button**:
       - Resets to showingInput state with original text preserved (user can edit and resubmit)

    5. **"Dismiss" button**:
       - Calls `CompanionManager.dismissWritingSuggestions()` to exit writing assist entirely

    All button styles should match the design system: primary buttons for Apply All and Copy Revised, secondary/destructive for Dismiss and Start Over.
  </action>
  <verify>
    grep -n "Apply All\|Copy Revised\|dismissWritingSuggestions\|onAccept\|onDismiss" leanring-buddy/CompanionPanelView.swift
  </verify>
  <done>Users can accept individual suggestions, apply all, copy revised text, or dismiss the flow entirely.</done>
</task>

</tasks>

<verification>
Confirm the write-with-guidance flow is complete:

1. ctrl+option+W triggers writing assist from any app
2. WritingAssistAnnotationView renders individual suggestions with expandable explanations
3. Users can accept/dismiss individual suggestions or apply all/copy revised
4. The full flow is non-blocking and dismissible at any point
</verification>

<success_criteria>
- Hotkey (ctrl+option+W) triggers writing assist while voice (ctrl+option) remains functional
- Annotations display inline and explain WHY changes help
- Users can accept individual suggestions, apply all, or dismiss entirely
- "Copy Revised" provides a frictionless path to use the revised text in the source app
</success_criteria>

<output>
After completion, create `.planning/phases/02-write-with-guidance/02-write-with-guidance-02-SUMMARY.md`
</output>