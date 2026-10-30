//
//  AccessibilitySelectionReader.swift
//  leanring-buddy
//

import AppKit
import ApplicationServices
import Foundation

enum AccessibilitySelectionReader {
    static func selectedText() -> String? {
        guard AXIsProcessTrusted() else { return nil }
        guard let frontmostApplication = NSWorkspace.shared.frontmostApplication else { return nil }

        let applicationElement = AXUIElementCreateApplication(frontmostApplication.processIdentifier)

        var focusedElementValue: AnyObject?
        guard AXUIElementCopyAttributeValue(applicationElement, kAXFocusedUIElementAttribute as CFString, &focusedElementValue) == .success,
              let focusedElement = focusedElementValue else {
            return nil
        }

        var selectedTextValue: AnyObject?
        guard AXUIElementCopyAttributeValue(focusedElement as! AXUIElement, kAXSelectedTextAttribute as CFString, &selectedTextValue) == .success,
              let selectedText = selectedTextValue as? String else {
            return nil
        }

        let trimmedText = selectedText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedText.isEmpty ? nil : trimmedText
    }
}
