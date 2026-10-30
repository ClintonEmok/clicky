//
//  ReadingVocabularyListView.swift
//  leanring-buddy
//

import SwiftUI

struct ReadingVocabularyListView: View {
    let items: [ReadingVocabularyItem]
    let onClearAll: () -> Void
    let onDeleteItem: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Saved vocabulary")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(DS.Colors.textSecondary)

                Spacer()

                Button(action: onClearAll) {
                    Text("Clear")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(DS.Colors.textTertiary)
                }
                .buttonStyle(.plain)
                .pointerCursor()
                .disabled(items.isEmpty)
            }

            if items.isEmpty {
                Text("Saved words and phrases will appear here.")
                    .font(.system(size: 11))
                    .foregroundColor(DS.Colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: DS.CornerRadius.medium, style: .continuous)
                            .fill(Color.white.opacity(0.04))
                    )
            } else {
                VStack(spacing: 8) {
                    ForEach(items) { item in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.originalText)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(DS.Colors.textPrimary)
                                        .lineLimit(2)

                                    Text(item.translatedText)
                                        .font(.system(size: 11))
                                        .foregroundColor(DS.Colors.textSecondary)
                                        .lineLimit(2)
                                }

                                Spacer()

                                Button(action: { onDeleteItem(item.lookupID) }) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(DS.Colors.textTertiary)
                                }
                                .buttonStyle(.plain)
                                .pointerCursor()
                            }

                            Text(item.sourceAppName)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(DS.Colors.textTertiary)

                            Text(item.sourceContext)
                                .font(.system(size: 10))
                                .foregroundColor(DS.Colors.textTertiary)
                                .lineLimit(2)
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: DS.CornerRadius.medium, style: .continuous)
                                .fill(Color.white.opacity(0.04))
                        )
                    }
                }
            }
        }
    }
}
