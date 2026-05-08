---
phase: 04-stay-immersed
plan: 02
type: execute
wave: 2
depends_on:
  - 04-stay-immersed-01
files_modified:
  - leanring-buddy/CompanionManager.swift
  - leanring-buddy/CompanionPanelView.swift
  - leanring-buddy/OverlayWindow.swift
  - leanring-buddy/BuddyDictationManager.swift
autonomous: true
requirements_addressed:
  - IMMR-02
must_haves:
  truths:
    - "Help auto-dismisses after the user finishes reading"
    - "User can configure immersion level (learning / balanced / immersed)"
    - "No help interaction creates a blocking modal"
    - "Help stays visible only while the user is actively interacting"
    - "User can keep working in their source app without interruption"
  artifacts:
    - path: "leanring-buddy/CompanionManager.swift"
      provides: "Immersion level state machine (learning/balanced/immersed) and auto-dismiss timer config"
      contains: "ImmersionLevel"
    - path: "leanring-buddy/CompanionPanelView.swift"
      provides: "Immersion mode toggle in settings section"
      contains: "immersionLevel"
    - path: "leanring-buddy/OverlayWindow.swift"
      provides: "Configurable auto-dismiss timer driven by immersion level"
      contains: "autoDismiss"
    - path: "leanring-buddy/BuddyDictationManager.swift"
      provides: "Non-blocking dictation flow — no modal confirmation dialogs"
      contains: "nonBlocking"
  key_links:
    - from: "OverlayWindow"
      to: "CompanionManager"
      via: "immersion level reading for dismiss timeout"
      pattern: "immersionLevel"
    - from: "CompanionPanelView"
      to: "CompanionManager"
      via: "immersion mode picker binding"
      pattern: "immersionLevel"
---

<objective>
Keep help subtle and non-disruptive with configurable immersion levels. Help auto-dismisses after interaction, never blocks with modals, and adapts its behavior (timeout, verbosity) to the user's immersion preference.

Purpose: The app should stay out of the user's way. After help is consumed, it fades away automatically. The user controls how much English and explanation they see via immersion level.
Output: Immersion level state machine, auto-dismiss logic in overlay, immersion toggle in panel, non-blocking audit of all help flows.
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
@.planning/phases/04-stay-immersed/04-RESEARCH.md
@.planning/phases/04-stay-immersed/04-stay-immersed-01-PLAN.md
@.planning/codebase/ARCHITECTURE.md
@.planning/codebase/CONVENTIONS.md
@.planning/research/PITFALLS.md
@leanring-buddy/CompanionManager.swift
@leanring-buddy/CompanionPanelView.swift
@leanring-buddy/OverlayWindow.swift
@leanring-buddy/BuddyDictationManager.swift
@leanring-buddy/DesignSystem.swift
</context>

<tasks>

<task type="auto">
  <name>Task 1: Add immersion level state machine to CompanionManager</name>
  <files>leanring-buddy/CompanionManager.swift</files>
  <read_first>
    - leanring-buddy/CompanionManager.swift
  </read_first>
  <action>
    Add an immersion level state machine to CompanionManager that controls help verbosity, auto-dismiss timeout, and per-app language strictness.

    Add the following enum near the top of the file:

    ```swift
    enum ImmersionLevel: String, CaseIterable, Codable {
        case learning   // More English guidance, slower dismiss, fuller explanations
        case balanced   // Target language UI, moderate dismiss, concise help
        case immersed   // Target language only, fast dismiss, minimal help surface

        var autoDismissTimeout: TimeInterval {
            switch self {
            case .learning: return 8.0
            case .balanced: return 4.0
            case .immersed: return 2.0
            }
        }

        var helpVerbosity: HelpVerbosity {
            switch self {
            case .learning: return .full
            case .balanced: return .concise
            case .immersed: return .minimal
            }
        }

        var displayName: String {
            switch self {
            case .learning: return "Learning"
            case .balanced: return "Balanced"
            case .immersed: return "Immersed"
            }
        }

        var description: String {
            switch self {
            case .learning: return "More English guidance, slower dismiss"
            case .balanced: return "Target language, moderate dismiss"
            case .immersed: return "Minimal English, fast dismiss"
            }
        }
    }

    enum HelpVerbosity {
        case full     // Show full explanations and bilingual labels
        case concise  // Show concise help with target language labels
        case minimal  // Show only essential help, all target language
    }
    ```

    Add published properties:
    ```swift
    @Published var immersionLevel: ImmersionLevel {
        didSet {
            UserDefaults.standard.set(immersionLevel.rawValue, forKey: "immersionLevel")
            applyImmersionLevel()
        }
    }
    ```

    Initialize from UserDefaults:
    ```swift
    let savedLevel = UserDefaults.standard.string(forKey: "immersionLevel")
        .flatMap { ImmersionLevel(rawValue: $0) }
    self.immersionLevel = savedLevel ?? .balanced  // sensible default
    ```

    Add the `applyImmersionLevel()` method:
    ```swift
    private func applyImmersionLevel() {
        // Update overlay auto-dismiss timeout based on immersion level
        overlayAutoDismissTimeout = immersionLevel.autoDismissTimeout
    }
    ```

    Add a published property for the overlay timeout:
    ```swift
    @Published var overlayAutoDismissTimeout: TimeInterval = 4.0
    ```

    Add the `scheduleAutoDismiss()` method for use by OverlayWindow:
    ```swift
    func scheduleAutoDismiss(for interaction: HelpInteractionType) {
        // Cancel any existing auto-dismiss timer
        cancelAutoDismiss()

        autoDismissTask = Task { [weak self] in
            guard let self = self else { return }
            let timeout = self.overlayAutoDismissTimeout
            try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self.dismissHelpInteraction()
            }
        }
    }

    func cancelAutoDismiss() {
        autoDismissTask?.cancel()
        autoDismissTask = nil
    }
    ```

    Add the `dismissHelpInteraction()` method:
    ```swift
    func dismissHelpInteraction() {
        // Dismiss whatever help surface is currently active
        if readingLookupState != .idle {
            readingLookupState = .idle
        }
        if writingAssistState != .idle && writingAssistState != .showingInput {
            writingAssistState = .idle
            latestWritingAssistResult = nil
        }
        overlayAutoDismissTimeout = immersionLevel.autoDismissTimeout
    }
    ```

    Add an enum for help interaction type:
    ```swift
    enum HelpInteractionType {
        case readingLookup
        case writingAssist
        case onboarding
    }
    ```

    Add the stored task reference:
    ```swift
    private var autoDismissTask: Task<Void, Never>?
    ```

    Add a helper to check whether the current immersion level requires bilingual labels:
    ```swift
    var showsBilingualLabels: Bool {
        immersionLevel == .learning
    }
    ```

    Place all new properties and methods in clearly marked `// MARK: - Immersion Mode` sections.

    Preserve ALL existing functionality. This task only adds the immersion mode infrastructure.
  </action>
  <verify>
    grep -n "enum ImmersionLevel\|enum HelpVerbosity" leanring-buddy/CompanionManager.swift
    grep -n "immersionLevel\|overlayAutoDismissTimeout" leanring-buddy/CompanionManager.swift
    grep -n "scheduleAutoDismiss\|cancelAutoDismiss\|dismissHelpInteraction" leanring-buddy/CompanionManager.swift
    grep -n "autoDismissTask" leanring-buddy/CompanionManager.swift
  </verify>
  <acceptance_criteria>
    - ImmersionLevel enum with 3 cases (.learning, .balanced, .immersed) each with autoDismissTimeout
    - HelpVerbosity enum with 3 cases (.full, .concise, .minimal)
    - @Published immersionLevel property persisted in UserDefaults
    - @Published overlayAutoDismissTimeout property updated by applyImmersionLevel()
    - scheduleAutoDismiss() and cancelAutoDismiss() methods exist
    - dismissHelpInteraction() resets active help states
    - autoDismissTask stored property for cancellation
    - showsBilingualLabels computed property returns true only for .learning
  </acceptance_criteria>
  <done>CompanionManager has an immersion level state machine with configurable timeouts and verbosity.</done>
</task>

<task type="auto">
  <name>Task 2: Implement auto-dismiss in OverlayWindow</name>
  <files>leanring-buddy/OverlayWindow.swift</files>
  <read_first>
    - leanring-buddy/OverlayWindow.swift
    - leanring-buddy/CompanionManager.swift
  </read_first>
  <action>
    Add auto-dismiss behavior to the overlay window that triggers after a configurable timeout based on the current immersion level.

    **Part A: Add auto-dismiss scheduling to the overlay lifecycle**

    Find where help interactions begin (where the overlay shows response text or cursor pointing) and call `companionManager.scheduleAutoDismiss(for:)` with the appropriate interaction type.

    In OverlayWindow.swift, locate the method or property that receives new response text or triggers pointing animation. This is likely where `responseText` is set or where cursor animation begins. After that state change, call:

    ```swift
    // Schedule auto-dismiss for the current interaction
    companionManager.scheduleAutoDismiss(for: .readingLookup)
    ```

    **Part B: Add observer for overlay dismissal**

    Add a listener to `companianManager.$readingLookupState` (or equivalent) that hides the overlay content when the interaction state returns to idle. This should already work if the overlay content is driven by state, but ensure:

    ```swift
    // Observe reading/writing assist state changes to hide overlay content
    // When state returns to idle, the overlay content should clear
    ```

    **Part C: Click-outside or interaction-extends-dismiss**

    Ensure that any user interaction with the overlay (hover, looking at content) resets the auto-dismiss timer. Add a method:

    ```swift
    func userDidInteractWithOverlay() {
        // Reset the dismiss timer — user is still engaging
        companionManager.cancelAutoDismiss()
        companionManager.scheduleAutoDismiss(for: .readingLookup)
    }
    ```

    Wire this to overlay touch/hover events if any exist, or ensure that the auto-dismiss timer is long enough that casual reading completes before dismissal.

    **Important:** This is additive. The existing transient cursor mode (1s inactivity fade-out) should remain unchanged — the new auto-dismiss targets the help content (response text, annotations), not the cursor overlay.

    Preserve ALL existing overlay functionality including cursor animation, pointing, onboarding, and transient cursor behavior.
  </action>
  <verify>
    grep -n "scheduleAutoDismiss\|cancelAutoDismiss" leanring-buddy/OverlayWindow.swift
    grep -n "readingLookupState\|writingAssistState" leanring-buddy/OverlayWindow.swift
  </verify>
  <acceptance_criteria>
    - scheduleAutoDismiss(for:) is called when help content appears in the overlay
    - Overlay auto-dismiss timeout is driven by companionManager.overlayAutoDismissTimeout
    - The transient cursor mode (1s inactivity fade-out) is preserved unchanged
    - Existing overlay functionality (cursor animation, pointing, onboarding) is preserved
  </acceptance_criteria>
  <done>OverlayWindow auto-dismisses help content after the immersion-configurable timeout.</done>
</task>

<task type="auto">
  <name>Task 3: Add immersion mode toggle to panel and audit for blocking interactions</name>
  <files>leanring-buddy/CompanionPanelView.swift, leanring-buddy/BuddyDictationManager.swift</files>
  <read_first>
    - leanring-buddy/CompanionPanelView.swift
    - leanring-buddy/CompanionManager.swift
    - leanring-buddy/BuddyDictationManager.swift
    - leanring-buddy/DesignSystem.swift
  </read_first>
  <action>
    Add an immersion mode picker in the panel settings and audit all help flows for blocking interactions.

    **Part A: Add immersion level picker to CompanionPanelView**

    In the settings section of the panel, add an immersion level picker below the language picker:

    ```swift
    Picker("Mode", selection: $companionManager.immersionLevel) {
        ForEach(ImmersionLevel.allCases, id: \.self) { level in
            VStack(alignment: .leading, spacing: 2) {
                Text(level.displayName)
                    .foregroundColor(DS.Colors.textPrimary)
                Text(level.description)
                    .font(DS.Typography.caption)
                    .foregroundColor(DS.Colors.textSecondary)
            }
            .tag(level)
        }
    }
    .pickerStyle(.radioGroup)
    ```

    Style the picker with:
    - Background: `DS.Colors.surfaceSecondary`
    - Corner radius: `DS.CornerRadius.input`
    - Section label: "Mode" using Text("Mode") (should be in String Catalog — add if missing)

    **Part B: Audit BuddyDictationManager for blocking interactions**

    Review BuddyDictationManager.swift for any modal confirmations, blocking alerts, or required-interaction dialogs during the dictation flow. Specifically check:

    1. Permission requests — do they use the system permission prompt (non-blocking) or a custom blocking alert?
    2. Error states — does a dictation error show a blocking dialog or just update state?
    3. Microphone access — is there any "allow microphone" dialog that stops the user's workflow?

    For each blocking pattern found, replace with a state-driven non-blocking alternative:
    - Instead of `NSAlert.runModal()`, update a published error state and let the panel display it inline
    - Instead of requiring button tap to dismiss an error, auto-dismiss after 4 seconds
    - Instead of blocking permission dialogs from app code, use the system's async permission prompts (AVAudioSession.requestRecordPermission already returns async)

    **Part C: Wire immersion level to dictation behavior**

    In BuddyDictationManager, if there's any place where verbosity or timeout is fixed, connect it to the immersion level:

    - No changes needed if dictation behavior is already non-blocking
    - If there are fixed timeout values (e.g., silence detection timeout), consider whether they should vary by immersion level

    **Important:** Do NOT change the core dictation flow (capture, transcription, finalization). Only audit for blocking patterns and wire immersion settings where appropriate.
  </action>
  <verify>
    grep -n "immersionLevel\|ImmersionLevel" leanring-buddy/CompanionPanelView.swift
    grep -n "NSAlert\|runModal\|blocking" leanring-buddy/BuddyDictationManager.swift; echo "EXIT: $?"  # non-zero is OK (no blocking patterns found)
  </verify>
  <acceptance_criteria>
    - CompanionPanelView has an immersion mode picker with displayName and description for each level
    - Picker uses .radioGroup style for clear visual selection
    - BuddyDictationManager has no NSAlert.runModal() or blocking dialog patterns
    - All error states in dictation flow are non-blocking (state-driven, auto-dismiss)
    - Existing dictation flow (capture, transcription, finalization) is unchanged
  </acceptance_criteria>
  <done>Users can configure immersion level, and all help flows are non-blocking with state-driven error handling.</done>
</task>

</tasks>

<verification>
Verify the immersion mode and subtle help infrastructure:

1. CompanionManager has ImmersionLevel enum with 3 levels, each with appropriate autoDismissTimeout
2. OverlayWindow calls scheduleAutoDismiss when help content appears
3. CompanionPanelView has an immersion level picker in settings
4. BuddyDictationManager has no blocking NSAlert.runModal() patterns
5. Existing overlay functionality (cursor, pointing, transient mode) is preserved

Note: Functional verification (auto-dismiss timing, immersion level behavior) requires running the app — handled by the execute phase's checkpoint step.
</verification>

<success_criteria>
- Immersion level state machine with 3 levels (learning/balanced/immersed)
- Auto-dismiss timeout configurable per immersion level (8s / 4s / 2s)
- Help content auto-dismisses after timeout when no user interaction
- No blocking modal dialogs in any help flow
- Immersion level picker visible and functional in panel settings
- Existing overlay, cursor, and dictation functionality preserved
</success_criteria>

<output>
After completion, create `.planning/phases/04-stay-immersed/04-stay-immersed-02-SUMMARY.md`
</output>
