//
//  ReadingLookupClient.swift
//  leanring-buddy
//

import Foundation

protocol ReadingLookupClient {
    func analyzeText(
        systemPrompt: String,
        userPrompt: String
    ) async throws -> (text: String, duration: TimeInterval)
}
