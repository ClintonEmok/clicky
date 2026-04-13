# Testing Patterns

**Analysis Date:** 2026-04-13

## Test Framework

**Runner:**
- Swift Testing in `leanring-buddyTests/leanring_buddyTests.swift`
- XCTest in `leanring-buddyUITests/leanring_buddyUITests.swift` and `leanring-buddyUITests/leanring_buddyUITestsLaunchTests.swift`

**Assertion Library:**
- Swift Testing uses `#expect(...)`
- UI tests rely on XCTest assertions and metrics APIs

**Run Commands:**
```bash
open leanring-buddy.xcodeproj   # Run test targets from Xcode
```

## Test File Organization

**Location:**
- Unit tests live in `leanring-buddyTests/`.
- UI tests live in `leanring-buddyUITests/`.

**Naming:**
- Test files mirror the target/module name rather than the feature name.
- Test methods use long, behavior-focused names such as `firstPermissionRequestUsesSystemPromptOnly()`.

**Structure:**
```
leanring-buddyTests/
  leanring_buddyTests.swift
leanring-buddyUITests/
  leanring_buddyUITests.swift
  leanring_buddyUITestsLaunchTests.swift
```

## Test Structure

**Suite Organization:**
```swift
import Testing
@testable import leanring_buddy

struct leanring_buddyTests {

    @Test func firstPermissionRequestUsesSystemPromptOnly() async throws {
        let presentationDestination = WindowPositionManager.permissionRequestPresentationDestination(
            hasPermissionNow: false,
            hasAttemptedSystemPrompt: false
        )

        #expect(presentationDestination == .systemPrompt)
    }
}
```

**Patterns:**
- Unit tests are small, direct, and behavior-specific.
- Setup is minimal; tests construct input inline and assert a single outcome.
- UI tests launch the app through `XCUIApplication()` and use launch/performance measurements.

## Mocking

**Framework:**
- Not detected.

**Patterns:**
```swift
let presentationDestination = WindowPositionManager.permissionRequestPresentationDestination(
    hasPermissionNow: false,
    hasAttemptedSystemPrompt: true
)

#expect(presentationDestination == .systemSettings)
```

**What to Mock:**
- No mocking framework or shared fixture layer is present.
- Favor pure helper functions and deterministic branches where possible, as in `WindowPositionManager.swift`.

**What NOT to Mock:**
- Do not mock simple static decision helpers that can be tested directly.

## Fixtures and Factories

**Test Data:**
- No fixture directory is detected.
- Tests currently inline all inputs instead of using factory helpers.

**Location:**
- Not applicable.

## Coverage

**Requirements:**
- No enforced coverage threshold is detected.

**View Coverage:**
```bash
open leanring-buddy.xcodeproj   # Inspect coverage in Xcode
```

## Test Types

**Unit Tests:**
- Focus on small decision functions and permission routing.
- Current example coverage is in `WindowPositionManager.swift` behavior.

**Integration Tests:**
- Not detected.

**E2E Tests:**
- XCTest UI launch tests exist, but they are template-level and not app-flow specific.

## Common Patterns

**Async Testing:**
```swift
@Test func knownGrantedScreenRecordingPermissionSkipsTheGate() async throws {
    let shouldTreatPermissionAsGranted = WindowPositionManager.shouldTreatScreenRecordingPermissionAsGrantedForSessionLaunch(
        hasScreenRecordingPermissionNow: false,
        hasPreviouslyConfirmedScreenRecordingPermission: true
    )

    #expect(shouldTreatPermissionAsGranted)
}
```

**Error Testing:**
```swift
// Not detected in current tests.
```

## Current Test Gaps

- `leanring-buddyTests/leanring_buddyTests.swift` covers only three permission-related branches in `WindowPositionManager.swift`.
- `leanring-buddyUITests/leanring_buddyUITests.swift` and `leanring-buddyUITests/leanring_buddyUITestsLaunchTests.swift` are template-shaped and do not exercise the app’s real menu-bar flow.
- No mocking, fixture, or coverage tooling is detected in the repository.

---

*Testing analysis: 2026-04-13*
