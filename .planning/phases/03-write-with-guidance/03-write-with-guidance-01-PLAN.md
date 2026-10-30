---
phase: 02-write-with-guidance
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - leanring-buddy/WritingAssistManager.swift
  - leanring-buddy/CompanionManager.swift
  - leanring-buddy/CompanionPanelView.swift
  - leanring-buddy/WritingAssistAnnotationView.swift
autonomous: true
requirements_addressed:
  - WRITE-01
  - WRITE-02
must_haves:
  truths:
    - "User can draft or rewrite text in the target language from within their normal desktop workflow"
    - "User can ask for tone or grammar suggestions and see them applied"
    - "Suggestions appear as part of the writing flow, not as a separate lesson or blocking dialog"
  artifacts:
    - path: "leanring-buddy/WritingAssistManager.swift"
      provides: "Writing assist request/result flow with annotated suggestions"
      exports:
        - "WritingAssistManager"
        - "WritingAssistRequest"
        - "WritingAssistResult"
        - "Suggestion"
    - path: "leanring-buddy/CompanionManager.swift"
      provides: "Writing assist state machine and trigger wiring"
      contains: "writingAssist"
    - path: "leanring-buddy/CompanionPanelView.swift"
      provides: "Text input area and annotation display in panel"
      contains: "WritingAssistSection"
    - path: "leanring-buddy/WritingAssistAnnotationView.swift"
      provides: "Individual annotation chip with original→revised text and explanation"
  key_links:
    - from: "CompanionManager"
      to: "WritingAssistManager"
      via: "async assist action and state updates"
      pattern: "writingAssist.*(start|result|error)"
    - from: "WritingAssistManager"
      to: "ClaudeAPI"
      via: "revision request"
      pattern: "ClaudeAPI.*(analyze|stream)"
    - from: "CompanionPanelView"
      to: "WritingAssistAnnotationView"
      via: "inline suggestion rendering"
      pattern: "WritingAssistAnnotationView"
---

<objective>
Enable writing assistance: users can paste target-language text into the panel and receive annotated suggestions that explain tone and grammar changes.

Purpose: Establish the core write-with-guidance flow — user pastes text, gets suggestions back, applies what helps.
Output: Writing assist request/result manager, panel UI with text input and annotation display, state wiring into CompanionManager.
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
@.planning/phases/01-read-in-place/01-CONTEXT.md
@.planning/codebase/ARCHITECTURE.md
@.planning/codebase/CONVENTIONS.md
@.planning/research/PITFALLS.md
@leanring-buddy/CompanionManager.swift
@leanring-buddy/ReadingLookupManager.swift
@leanring-buddy/CompanionPanelView.swift
@leanring-buddy/DesignSystem.swift
</context>

<tasks>

<task type="auto">
  <name>Task 1: Create WritingAssistManager with request/result types</name>
  <files>leanring-buddy/WritingAssistManager.swift</files>
  <read_first>
    - leanring-buddy/ClaudeAPI.swift
    - leanring-buddy/ReadingLookupManager.swift
    - leanring-buddy/DesignSystem.swift
  </read_first>
  <action>
    Create a new @MainActor writing assist service at `leanring-buddy/WritingAssistManager.swift`.

    Define the following types:
    ```swift
    struct WritingAssistRequest {
        let sourceText: String           // The text to be revised
        let targetLanguage: String      // e.g., "Spanish", "French"
        let context: String?             // Optional context (email, chat, form)
    }

    struct Suggestion {
        let originalSegment: String      // Text being changed
        let revisedSegment: String       // Suggested revision
        let explanation: String          // WHY this change helps (learning-focused)
        let startIndex: Int             // Start position in original text
        let endIndex: Int               // End position in original text
        let suggestionType: SuggestionType  // .grammar | .tone | .spelling | .wordChoice
    }

    enum SuggestionType {
        case grammar
        case tone
        case spelling
        case wordChoice
    }

    struct WritingAssistResult {
        let originalText: String
        let suggestions: [Suggestion]
        let toneNote: String?           // e.g., "This reads as informal"
        let revisedFullText: String     // Full text with all accepted suggestions applied
    }
    ```

    The service exposes one async method:
    ```swift
    func getSuggestions(request: WritingAssistRequest) async throws -> WritingAssistResult
    ```

    The prompt to Claude should ask for:
    1. Revised version of the text with inline corrections marked
    2. Annotations next to each change explaining the reason (supports language learning)
    3. A tone assessment (formal/informal/neutral) with adjustment suggestions if needed

    Limit input to 2000 characters. If exceeded, throw `WritingAssistError.inputTooLong(maxLength: 2000)`.

    Reuse `ClaudeAPI` rather than introducing a new network path.
  </action>
  <verify>
    grep -n "WritingAssistRequest\|WritingAssistResult\|Suggestion" leanring-buddy/WritingAssistManager.swift
    grep -n "getSuggestions" leanring-buddy/WritingAssistManager.swift
  </verify>
  <done>Writing assist has typed request/result models and a service that calls Claude for annotated revisions.</done>
</task>

<task type="auto">
  <name>Task 2: Wire writing assist state into CompanionManager</name>
  <files>leanring-buddy/CompanionManager.swift</files>
  <read_first>
    - leanring-buddy/CompanionManager.swift
    - leanring-buddy/WritingAssistManager.swift
    - leanring-buddy/MenuBarPanelManager.swift
  </read_first>
  <action>
    Add to CompanionManager.swift a dedicated writing assist state machine and manager instance.

    Add the following enum (place near ReadingLookupState):
    ```swift
    enum WritingAssistState: Equatable {
        case idle
        case showingInput
        case processing
        case suggestionsReady
        case error(String)
    }
    ```

    Add the following published properties:
    ```swift
    @Published private(set) var writingAssistState: WritingAssistState = .idle
    @Published private(set) var latestWritingAssistResult: WritingAssistResult?
    @Published private(set) var latestWritingAssistError: String?
    @Published var writingAssistInputText: String = ""
    ```

    Add a lazy property:
    ```swift
    private lazy var writingAssistManager: WritingAssistManager = {
        return WritingAssistManager(claudeAPI: claudeAPI)
    }()
    ```

    Add a method to trigger writing assist:
    ```swift
    func startWritingAssist() {
        writingAssistState = .showingInput
        writingAssistInputText = ""
        latestWritingAssistResult = nil
        latestWritingAssistError = nil
    }

    func submitWritingAssist() async {
        guard !writingAssistInputText.isEmpty else { return }
        writingAssistState = .processing
        do {
            let request = WritingAssistRequest(
                sourceText: writingAssistInputText,
                targetLanguage: "target language from settings", // TODO: wire to settings
                context: nil
            )
            let result = try await writingAssistManager.getSuggestions(request: request)
            latestWritingAssistResult = result
            writingAssistState = .suggestionsReady
        } catch {
            latestWritingAssistError = error.localizedDescription
            writingAssistState = .error(error.localizedDescription)
        }
    }

    func dismissWritingSuggestions() {
        writingAssistState = .idle
        latestWritingAssistResult = nil
    }
    ```

    Preserve the existing voice pipeline. This task only adds writing-mode orchestration and state publishing.
  </action>
  <verify>
    grep -n "WritingAssistState\|writingAssist" leanring-buddy/CompanionManager.swift
    grep -n "startWritingAssist\|submitWritingAssist" leanring-buddy/CompanionManager.swift
  </verify>
  <done>CompanionManager can launch and track a writing assist session without disturbing voice mode.</done>
</task>

<task type="auto">
  <name>Task 3: Build the WritingAssistSection in CompanionPanelView</name>
  <files>leanring-buddy/CompanionPanelView.swift</files>
  <read_first>
    - leanring-buddy/CompanionPanelView.swift
    - leanring-buddy/ReadingLookupResultView.swift
    - leanring-buddy/DesignSystem.swift
    - leanring-buddy/CompanionManager.swift
  </read_first>
  <action>
    Add to CompanionPanelView.swift a `WritingAssistSection` that renders when `writingAssistState != .idle`.

    The section has three visual states:

    1. **Input state** (`writingAssistState == .showingInput`):
       - A dark-themed `TextEditor` (background: `DS.Colors.surfaceSecondary`, text: `DS.Colors.textPrimary`, corner radius: `DS.CornerRadius.input`)
       - Placeholder text: "Paste or type text to get suggestions..."
       - A "Get Suggestions" button (primary style, pointer cursor on hover)
       - Character count display (e.g., "42 / 2000")

    2. **Processing state** (`writingAssistState == .processing`):
       - Centered `ProgressView` with label "Getting suggestions..."
       - The input text remains visible but is not editable

    3. **Suggestions state** (`writingAssistState == .suggestionsReady`):
       - Collapsed input area (shows original text in a collapsed view)
       - "Suggestions" header with count (e.g., "3 suggestions")
       - List of `WritingAssistAnnotationView` chips for each suggestion
       - If `result.toneNote` exists, show a tone indicator chip at the top
       - "Apply All" button and "Dismiss" button at the bottom

    4. **Error state** (`writingAssistState == .error(let message)`):
       - Red-tinted alert box with the error message
       - "Try Again" button that returns to showingInput state

    Design tokens to use:
    - `DS.Colors.background` for section background
    - `DS.Colors.surfaceSecondary` for text input background
    - `DS.Colors.textPrimary`, `DS.Colors.textSecondary`
    - `DS.CornerRadius.input` for text editor, `DS.CornerRadius.chip` for annotation chips
    - `DS.Spacing.*` for padding and margins

    Keep the section compact (max 400pt height when suggestions are shown). Use scroll view if many suggestions.
  </action>
  <verify>
    grep -n "WritingAssistSection\|writingAssistState" leanring-buddy/CompanionPanelView.swift
    grep -n "Get Suggestions\|submitWritingAssist" leanring-buddy/CompanionPanelView.swift
  </verify>
  <done>Users can paste text, get suggestions, and see annotated feedback inline in the panel.</done>
</task>

</tasks>

<verification>
Verify the writing assist flow end-to-end:

1. WritingAssistManager exists with typed request/result and async getSuggestions method
2. CompanionManager has WritingAssistState tracking and can be triggered/submitted/dismissed
3. CompanionPanelView renders all four states (input, processing, suggestions, error)
4. Annotations display original→revised text with explanation
</verification>

<success_criteria>
- User can paste target-language text and receive annotated suggestions within the panel
- Suggestions include tone/grammar notes with explanations
- The flow is non-blocking — user can dismiss and continue without applying changes
- Annotations explain WHY changes help (supports language learning, not just correction)
</success_criteria>

<output>
After completion, create `.planning/phases/02-write-with-guidance/02-write-with-guidance-01-SUMMARY.md`
</output>