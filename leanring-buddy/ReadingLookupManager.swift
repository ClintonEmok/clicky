//
//  ReadingLookupManager.swift
//  leanring-buddy
//

import CryptoKit
import Foundation

struct ReadingLookupRequest {
    let sourceText: String
    let sourceContext: String
    let sourceAppName: String
}

struct ReadingLookupResult: Identifiable, Codable, Equatable {
    let lookupID: String
    let originalText: String
    let translatedText: String
    let sourceContext: String
    let sourceAppName: String
    let isAmbiguous: Bool
    let explanation: String?
    let confidenceNote: String?

    var id: String { lookupID }
}

@MainActor
final class ReadingLookupManager {
    private let lookupClient: ReadingLookupClient

    init(claudeAPI: ReadingLookupClient) {
        self.lookupClient = claudeAPI
    }

    func lookup(request: ReadingLookupRequest) async throws -> ReadingLookupResult {
        let trimmedSourceText = request.sourceText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard !trimmedSourceText.isEmpty else {
            throw NSError(
                domain: "ReadingLookupManager",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "No text was provided for lookup."]
            )
        }

        let prompt = """
        translate the source text into clear english for reading support.

        return only valid json with these keys:
        - translatedText: a concise translation of the source text
        - isAmbiguous: true only when the source text is idiomatic, slang-heavy, or could mislead a literal translation
        - explanation: a short 1-3 sentence note only when isAmbiguous is true, otherwise null
        - confidenceNote: a brief note about certainty or alternate readings, otherwise null

        keep the translation first and the explanation brief. do not add lesson-style commentary.

        source app: \(request.sourceAppName)
        source context: \(request.sourceContext)
        source text: \(trimmedSourceText)
        """

        let (responseText, _) = try await lookupClient.analyzeText(systemPrompt: Self.systemPrompt, userPrompt: prompt)

        let parsedResponse = Self.parseLookupResponse(responseText) ?? LookupResponsePayload(
            translatedText: responseText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
            isAmbiguous: false,
            explanation: nil,
            confidenceNote: nil
        )

        let translatedText = parsedResponse.translatedText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let sourceContext = request.sourceContext.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let sourceAppName = request.sourceAppName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let lookupID = Self.makeStableLookupIdentifier(
            originalText: trimmedSourceText,
            sourceContext: sourceContext,
            sourceAppName: sourceAppName
        )

        return ReadingLookupResult(
            lookupID: lookupID,
            originalText: trimmedSourceText,
            translatedText: translatedText,
            sourceContext: sourceContext,
            sourceAppName: sourceAppName,
            isAmbiguous: parsedResponse.isAmbiguous ?? false,
            explanation: parsedResponse.explanation?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
            confidenceNote: parsedResponse.confidenceNote?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        )
    }

    private static let systemPrompt = """
    you translate short user-selected or visible text for quick reading help.

    rules:
    - return only valid json.
    - keep the translation concise and literal unless the text is idiomatic or ambiguous.
    - if the text is ambiguous, include a short explanation and a brief confidence note.
    - if the text is not ambiguous, set explanation and confidenceNote to null.
    - do not add markdown, bullets, or extra commentary.
    """

    private struct LookupResponsePayload: Decodable {
        let translatedText: String
        let isAmbiguous: Bool?
        let explanation: String?
        let confidenceNote: String?
    }

    private static func parseLookupResponse(_ responseText: String) -> LookupResponsePayload? {
        let trimmedResponse = responseText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonStartIndex = trimmedResponse.firstIndex(of: "{"),
              let jsonEndIndex = trimmedResponse.lastIndex(of: "}") else {
            return nil
        }

        let jsonSubstring = trimmedResponse[jsonStartIndex...jsonEndIndex]
        guard let jsonData = String(jsonSubstring).data(using: .utf8) else {
            return nil
        }

        return try? JSONDecoder().decode(LookupResponsePayload.self, from: jsonData)
    }

    private static func makeStableLookupIdentifier(
        originalText: String,
        sourceContext: String,
        sourceAppName: String
    ) -> String {
        let identifierSeed = [originalText, sourceContext, sourceAppName].joined(separator: "|")
        let digest = SHA256.hash(data: Data(identifierSeed.utf8))
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
}
