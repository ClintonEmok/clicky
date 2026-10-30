//
//  ReadingLookupResultView.swift
//  leanring-buddy
//

import SwiftUI

struct ReadingLookupResultView: View {
    let result: ReadingLookupResult
    let isSaved: Bool
    let isSaving: Bool
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Source")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(DS.Colors.textTertiary)

                    Text(result.originalText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DS.Colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Translation")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(DS.Colors.textTertiary)

                    Text(result.translatedText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DS.Colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if let explanation = result.explanation, !explanation.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.isAmbiguous ? "Likely meaning, but not certain" : "Note")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(DS.Colors.textTertiary)

                    Text(explanation)
                        .font(.system(size: 11))
                        .foregroundColor(DS.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: DS.CornerRadius.medium, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                )
            }

            if let confidenceNote = result.confidenceNote, !confidenceNote.isEmpty {
                Text(confidenceNote)
                    .font(.system(size: 10))
                    .foregroundColor(DS.Colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 8) {
                Text(result.sourceAppName)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(DS.Colors.textTertiary)

                Spacer()

                Button(action: onSave) {
                    Text(isSaved ? "Saved" : (isSaving ? "Saving..." : "Save"))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(DS.Colors.textOnAccent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(isSaved ? DS.Colors.success : DS.Colors.accent)
                        )
                }
                .buttonStyle(.plain)
                .pointerCursor()
                .disabled(isSaved || isSaving)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: DS.CornerRadius.large, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DS.CornerRadius.large, style: .continuous)
                .stroke(DS.Colors.borderSubtle, lineWidth: 0.5)
        )
    }
}
