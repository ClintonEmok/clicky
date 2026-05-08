---
phase: 04-stay-immersed
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - leanring-buddy/Localizable.xcstrings
  - leanring-buddy/CompanionManager.swift
  - leanring-buddy/CompanionPanelView.swift
  - leanring-buddy/CompanionResponseOverlay.swift
  - leanring-buddy/WritingAssistAnnotationView.swift
autonomous: true
requirements_addressed:
  - IMMR-01
must_haves:
  truths:
    - "User can see the companion panel mostly in their target language"
    - "User can configure which language they are learning"
    - "Strings missing in the target language fall back to English gracefully"
    - "The overlay and annotation views also respect the target language"
  artifacts:
    - path: "leanring-buddy/Localizable.xcstrings"
      provides: "String catalog for target language with English as development language"
      min_lines: 30
    - path: "leanring-buddy/CompanionManager.swift"
      provides: "Target language preference persisted in UserDefaults"
      contains: "targetLanguage"
    - path: "leanring-buddy/CompanionPanelView.swift"
      provides: "Localized panel UI and language picker in settings"
      contains: "LocalizedStringKey"
    - path: "leanring-buddy/CompanionResponseOverlay.swift"
      provides: "Localized overlay response UI"
    - path: "leanring-buddy/WritingAssistAnnotationView.swift"
      provides: "Localized annotation view text"
  key_links:
    - from: "CompanionManager"
      to: "UserDefaults"
      via: "language preference storage"
      pattern: "targetLanguage"
    - from: "CompanionPanelView"
      to: "Localizable.xcstrings"
      via: "Text() localized string lookups"
      pattern: "Text\\(.*\\)"
    - from: "CompanionManager"
      to: "AppleLanguages (UserDefaults override)"
      via: "per-app language override"
      pattern: "AppleLanguages"
---

<objective>
Enable target-language UI throughout the companion app. The companion panel, overlay, and annotation views display mostly in the user's target language with English as fallback. The user can configure their learning language in the panel settings.

Purpose: This is the foundational immersion step — the app itself starts modeling the target language instead of presenting in English.
Output: String catalog, language preference in CompanionManager, localized views, language picker in panel settings.
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
@.planning/phases/01-read-in-place/01-CONTEXT.md
@.planning/codebase/ARCHITECTURE.md
@.planning/codebase/CONVENTIONS.md
@.planning/research/PITFALLS.md
@leanring-buddy/CompanionManager.swift
@leanring-buddy/CompanionPanelView.swift
@leanring-buddy/CompanionResponseOverlay.swift
@leanring-buddy/WritingAssistAnnotationView.swift
@leanring-buddy/DesignSystem.swift
</context>

<tasks>

<task type="auto">
  <name>Task 1: Create String Catalog and extract localized strings</name>
  <files>leanring-buddy/Localizable.xcstrings</files>
  <read_first>
    - leanring-buddy/CompanionPanelView.swift
    - leanring-buddy/CompanionResponseOverlay.swift
    - leanring-buddy/WritingAssistAnnotationView.swift
    - leanring-buddy/CompanionManager.swift
  </read_first>
  <action>
    Create `leanring-buddy/Localizable.xcstrings` — a String Catalog in the modern .xcstrings JSON format.

    The catalog MUST use English as the development language (no translation needed for English — it IS the source) and define keys for ALL user-facing strings extracted from the three main view files and CompanionManager.

    Extract these strings from the source files and add them as keys:

    **From CompanionPanelView.swift:**
    - "Companion" (panel title)
    - "Press %@ to ask a question" (push-to-talk instruction, format specifier for hotkey name)
    - "Release to send" (dictation state)
    - "Listening…" (recording state)
    - "Thinking…" (processing state)
    - "Model" (model picker label)
    - "Sonnet" (model option)
    - "Opus" (model option)
    - "Permissions" (permissions section header)
    - "Microphone" (microphone permission label)
    - "Screen Recording" (screen recording permission label)
    - "Accessibility" (accessibility permission label)
    - "Settings" (settings section header)
    - "Language" (language picker label)
    - "Learning Language…" (language picker placeholder)
    - "Send Feedback" (feedback button)
    - "Quit" (quit button)
    - "Select a language" (language picker header)
    - "Show Clicky" (cursor visibility toggle label)

    **From CompanionResponseOverlay.swift:**
    - "Copied!" (copy confirmation toast)
    - (response text is dynamic — no localization needed)

    **From WritingAssistAnnotationView.swift:**
    - "Why?" (explanation toggle button)
    - "Suggestions" (section header)
    - "Get Suggestions" (submit button)
    - "Paste or type text to get suggestions…" (placeholder text)
    - "Getting suggestions…" (processing state)
    - "Apply All" (bulk apply button)
    - "Copy Revised" (copy revised text button)
    - "Start Over" (reset button)
    - "Dismiss" (dismiss button)
    - "%d suggestion(s)" (suggestion count, plural rule)
    - "Try Again" (error retry button)
    - "Input too long. Maximum %d characters." (error message, format specifier for max length)

    **From CompanionManager.swift (user-facing strings):**
    - "Error" (generic error prefix)
    - "Voice" (voice mode label)
    - "Write" (writing mode label)

    Format: Use the Xcode 15+ String Catalog JSON format:

    ```json
    {
      "sourceLanguage" : "en",
      "strings" : {
        "Companion" : {
          "extractionState" : "manual",
          "localizations" : {
            "en" : {
              "stringUnit" : {
                "state" : "translated",
                "value" : "Companion"
              }
            }
          }
        },
        ...
      },
      "version" : "1.0"
    }
    ```

    For EVERY key, add an English `"translated"` entry with the exact string value from the source code. This ensures Xcode's String Catalog tooling works correctly — English is the development language and also has explicit entries.

    Include ALL the strings listed above. The catalog should have at minimum 35 string entries.

    After creating the file, add it to the Xcode project using `ruby` or `python3` to modify `leanring-buddy.xcodeproj/project.pbxproj` — add a reference for `Localizable.xcstrings` in the `PBXFileReference` section and include it in the `leanring-buddy` target's `PBXBuildFile`/`PBXSourcesBuildPhase` sections.
  </action>
  <verify>
    test -f leanring-buddy/Localizable.xcstrings && echo "EXISTS"
    python3 -c "import json; c=json.load(open('leanring-buddy/Localizable.xcstrings')); print(f'{len(c[\"strings\"])} strings')"
    grep -q "Localizable.xcstrings" leanring-buddy.xcodeproj/project.pbxproj && echo "IN_PROJECT" || echo "NOT_IN_PROJECT"
  </verify>
  <acceptance_criteria>
    - leanring-buddy/Localizable.xcstrings exists
    - JSON is valid (python3 json.load succeeds)
    - At least 35 string entries in the catalog
    - English entries exist as "translated" with the correct source values
    - The xcstrings file is referenced in the Xcode project file
  </acceptance_criteria>
  <done>The String Catalog exists with all user-facing string keys and English translations.</done>
</task>

<task type="auto">
  <name>Task 2: Add target language preference to CompanionManager</name>
  <files>leanring-buddy/CompanionManager.swift</files>
  <read_first>
    - leanring-buddy/CompanionManager.swift
    - leanring-buddy/AppBundleConfiguration.swift
  </read_first>
  <action>
    Add a target language preference to CompanionManager that persists in UserDefaults and overrides the app's locale.

    Add the following enum and published properties:

    ```swift
    enum LearningLanguage: String, CaseIterable, Codable {
        case spanish = "es"
        case french = "fr"
        case german = "de"
        case italian = "it"
        case portuguese = "pt"
        case dutch = "nl"
        case japanese = "ja"
        case korean = "ko"
        case chineseSimplified = "zh-Hans"
        case chineseTraditional = "zh-Hant"

        var displayName: String {
            switch self {
            case .spanish: return "Español"
            case .french: return "Français"
            case .german: return "Deutsch"
            case .italian: return "Italiano"
            case .portuguese: return "Português"
            case .dutch: return "Nederlands"
            case .japanese: return "日本語"
            case .korean: return "한국어"
            case .chineseSimplified: return "简体中文"
            case .chineseTraditional: return "繁體中文"
            }
        }

        var localeIdentifier: String { rawValue }
    }
    ```

    Add published properties:
    ```swift
    @Published var learningLanguage: LearningLanguage {
        didSet {
            UserDefaults.standard.set(learningLanguage.rawValue, forKey: "learningLanguage")
            applyLanguageOverride()
        }
    }
    ```

    Initialize from UserDefaults in `init()`:
    ```swift
    let savedLanguage = UserDefaults.standard.string(forKey: "learningLanguage")
        .flatMap { LearningLanguage(rawValue: $0) }
    self.learningLanguage = savedLanguage ?? .spanish  // sensible default
    ```

    Add the `applyLanguageOverride()` method:
    ```swift
    private func applyLanguageOverride() {
        // Override the app's language to the target language.
        // Missing strings fall back to English (development language).
        UserDefaults.standard.set([learningLanguage.localeIdentifier], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
    ```

    Add a `currentTargetLanguageCode` computed property:
    ```swift
    var currentTargetLanguageCode: String {
        learningLanguage.localeIdentifier
    }
    ```

    **Important:** Call `applyLanguageOverride()` once at startup (after `init()`) to ensure the language override is active. The override takes effect on next launch for system-level strings, but in-app localized strings update immediately via ObservableObject re-render.

    Preserve ALL existing functionality. This task only adds the language preference infrastructure.
  </action>
  <verify>
    grep -n "enum LearningLanguage" leanring-buddy/CompanionManager.swift
    grep -n "learningLanguage" leanring-buddy/CompanionManager.swift
    grep -n "applyLanguageOverride\|AppleLanguages" leanring-buddy/CompanionManager.swift
  </verify>
  <acceptance_criteria>
    - LearningLanguage enum exists with 10 language cases (.spanish through .chineseTraditional)
    - Each case has the correct localeIdentifier and displayName in the target language
    - @Published learningLanguage property exists, persisted to UserDefaults
    - applyLanguageOverride() method sets AppleLanguages UserDefaults key
    - currentTargetLanguageCode computed property returns the locale identifier
  </acceptance_criteria>
  <done>CompanionManager stores a target language preference and applies it as the per-app language override.</done>
</task>

<task type="auto">
  <name>Task 3: Localize CompanionPanelView and add language picker</name>
  <files>leanring-buddy/CompanionPanelView.swift</files>
  <read_first>
    - leanring-buddy/CompanionPanelView.swift
    - leanring-buddy/CompanionManager.swift
    - leanring-buddy/DesignSystem.swift
  </read_first>
  <action>
    Update CompanionPanelView to use localized strings from the String Catalog and add a language picker in the settings section.

    **Part A: Replace hardcoded English strings with Text() lookups**
    
    Find every user-facing string in CompanionPanelView and replace it with a `Text("key")` call where "key" matches a key in the String Catalog. For strings with format specifiers, use `Text("key \(value)")` or `String(format: NSLocalizedString("key", comment: ""), value)`.

    Example replacements:
    - `Text("Model")` stays as `Text("Model")` (SwiftUI auto-localizes)
    - `Text("Press \(hotkeyName) to ask a question")` → `Text("Press \(hotkeyName) to ask a question")` — the format specifier is already in the catalog
    - Buttons: `Button("Send Feedback")` stays as `Button("Send Feedback")` — SwiftUI auto-localizes button labels too

    **Part B: Add language picker to the settings section**

    In the settings section of the panel, add a language picker:

    ```swift
    Picker("Language", selection: $companionManager.learningLanguage) {
        ForEach(LearningLanguage.allCases, id: \.self) { language in
            HStack {
                Text(language.displayName)
                    .foregroundColor(DS.Colors.textPrimary)
            }
            .tag(language)
        }
    }
    .pickerStyle(.menu)
    ```

    Place this picker between the model picker (if any) and the "Send Feedback" button.

    Style the picker using DS tokens:
    - Background: `DS.Colors.surfaceSecondary`
    - Corner radius: `DS.CornerRadius.input`
    - Text color: `DS.Colors.textPrimary`

    **Part C: Ensure dynamic language switching**

    When the user changes the language picker, the panel should immediately reflect the new localized strings. This happens naturally because:
    1. `learningLanguage` is `@Published` → SwiftUI re-renders views
    2. Text("key") lookups use the current effective language
    3. `applyLanguageOverride()` sets `AppleLanguages` for next-launch consistency

    No additional wiring needed — just make sure the picker binds to `$companionManager.learningLanguage`.

    Preserve ALL existing UI elements, layout, and behavior. This task only localizes strings and adds the picker.
  </action>
  <verify>
    grep -n "Text(\"Companion\")\|Text(\"Model\")\|Text(\"Language\")\|Text(\"Permissions\")" leanring-buddy/CompanionPanelView.swift
    grep -n "LearningLanguage.allCases\|learningLanguage" leanring-buddy/CompanionPanelView.swift
  </verify>
  <acceptance_criteria>
    - All user-facing strings in CompanionPanelView use Text() auto-localization
    - A language Picker exists bound to companionManager.learningLanguage
    - The picker shows all LearningLanguage cases with their displayName
    - Picker styling uses DS.Colors and DS.CornerRadius tokens
    - Changing the picker value updates the language override
  </acceptance_criteria>
  <done>CompanionPanelView displays in the target language with a language picker in settings.</done>
</task>

<task type="auto">
  <name>Task 4: Localize overlay and annotation views</name>
  <files>leanring-buddy/CompanionResponseOverlay.swift, leanring-buddy/WritingAssistAnnotationView.swift</files>
  <read_first>
    - leanring-buddy/CompanionResponseOverlay.swift
    - leanring-buddy/WritingAssistAnnotationView.swift
    - leanring-buddy/Localizable.xcstrings
    - leanring-buddy/DesignSystem.swift
  </read_first>
  <action>
    Update CompanionResponseOverlay.swift and WritingAssistAnnotationView.swift to use localized strings from the String Catalog.

    **CompanionResponseOverlay.swift:**
    - Find any hardcoded English user-facing strings and replace with Text("key")
    - The "Copied!" toast string should use localizable Text("Copied!")
    - Dynamic content (Claude responses) is NOT localized — it is the assistant's reply text

    **WritingAssistAnnotationView.swift:**
    - Replace all hardcoded English strings:
      - `"Why?"` → `Text("Why?")`
      - `"Suggestions"` → `Text("Suggestions")` (if used as section header)
      - "Apply All" button label → `Button("Apply All")`
      - "Copy Revised" button → `Button("Copy Revised")`
      - "Start Over" button → `Button("Start Over")`
      - "Dismiss" button → `Button("Dismiss")`
      - placeholder text → should already be `Text` with the placeholder key
    - The suggestion content (originalSegment, revisedSegment, explanation) is user/API-provided content — NOT localized

    For both files, verify that ALL static strings match keys that exist in the String Catalog. If any string is not in the catalog, add it.

    Preserve ALL existing functionality, layout, animations, and DS token references.
  </action>
  <verify>
    grep -n "Text(\"Copied\")\|Text(\"Why\")\|Text(\"Suggestions\")\|Text(\"Apply All\")\|Text(\"Copy Revised\")\|Text(\"Start Over\")\|Text(\"Dismiss\")" leanring-buddy/CompanionResponseOverlay.swift leanring-buddy/WritingAssistAnnotationView.swift
  </verify>
  <acceptance_criteria>
    - CompanionResponseOverlay.swift: "Copied!" uses localizable Text("Copied!")
    - WritingAssistAnnotationView.swift: all static button/label strings (Why?, Suggestions, Apply All, Copy Revised, Start Over, Dismiss) use localizable Text()
    - All used string keys exist in Localizable.xcstrings
    - Dynamic/API content is NOT localized
  </acceptance_criteria>
  <done>Overlay and annotation views display static UI text in the target language.</done>
</task>

</tasks>

<verification>
Verify the localization infrastructure end-to-end:

1. Localizable.xcstrings exists with at least 35 English string entries and valid JSON
2. The xcstrings file is referenced in the Xcode project
3. CompanionManager has LearningLanguage enum (10 cases) with persisted preference
4. CompanionPanelView has a language picker bound to learningLanguage
5. All three view files use Text() for static UI strings instead of hardcoded English

Note: Full visual verification (target language rendering in the panel) requires building and running the app — handled by the execute phase's checkpoint step.
</verification>

<success_criteria>
- String catalog contains all user-facing strings (35+ entries)
- Language picker allows selecting from 10 common learning languages
- Target language preference persists across app launches
- Static panel UI renders in target language when language is changed
- Missing string keys gracefully fall back to English
- Overlay and annotation views also respect the target language
</success_criteria>

<output>
After completion, create `.planning/phases/04-stay-immersed/04-stay-immersed-01-SUMMARY.md`
</output>
