//
//  CandidateBarView.swift
//  Thai Phonetic Keyboard Extension
//
//  Displays Thai word candidates above the keyboard
//

import SwiftUI
import KeyboardKit

struct CandidateBarView: View {

    // MARK: - Properties

    let candidates: [String]
    let romanization: String
    let onSelect: (String) -> Void

    // MARK: - Body

    var body: some View {
        if !candidates.isEmpty {
            HStack(spacing: 0) {
                // Show candidates
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(Array(candidates.enumerated()), id: \.offset) { index, candidate in
                            Button {
                                onSelect(candidate)
                            } label: {
                                Text(candidate)
                                    .font(.system(size: 18))
                                    .foregroundColor(index == 0 ? .black : .primary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        index == 0 ? Color.white.opacity(0.9) : Color.clear
                                    )
                                    .cornerRadius(5)
                            }
                            .buttonStyle(.plain)
                            .padding(.leading, index == 0 ? 8 : 0)  // Extra spacing for first candidate

                            if index < candidates.count - 1 {
                                Divider()
                                    .frame(height: 20)
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                    .padding(.leading, 4)  // Move all candidates slightly to the right
                }
            }
            .frame(height: 44)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        CandidateBarView(
            candidates: ["สวัสดี", "สวัส", "สวาท"],
            romanization: "sawatdii",
            onSelect: { _ in }
        )

        Color.gray.frame(height: 200)
    }
}
