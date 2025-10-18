//
//  CandidateBar.swift
//  Thai Phonetic Keyboard
//
//  Horizontal scrolling candidate selection bar
//  Displays Thai candidates as user types romanization
//

import SwiftUI

struct CandidateBar: View {
    let candidates: [String]
    let buffer: String
    let onTap: (String) -> Void

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 0) {
                // Show romanization buffer (like iOS Pinyin keyboard)
                if !buffer.isEmpty {
                    Text(buffer)
                        .font(.system(size: KeyboardConstants.candidateFontSize))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .frame(height: candidateBarHeight)

                    Divider()
                        .frame(height: candidateBarHeight * 0.6)
                }

                // Thai candidates
                ForEach(Array(candidates.enumerated()), id: \.offset) { index, candidate in
                    Button(action: {
                        onTap(candidate)
                    }) {
                        HStack(alignment: .center, spacing: 4) {
                            // Number badge
                            Text("\(index + 1)")
                                .font(.system(size: KeyboardConstants.numberBadgeFontSize))
                                .foregroundColor(.secondary)

                            Text(candidate)
                                .font(.system(size: KeyboardConstants.candidateFontSize))
                                .foregroundColor(.primary)
                        }
                        .frame(height: candidateBarHeight - 8)
                        .padding(.horizontal, 12)
                    }
                    .background(index == 0 ? Color(.systemGray4) : Color.clear)
                    .cornerRadius(6)

                    if index < candidates.count - 1 {
                        Divider()
                            .frame(height: candidateBarHeight * 0.6)
                    }
                }
            }
            .frame(height: candidateBarHeight)
        }
        .frame(height: candidateBarHeight)
    }

    private var candidateBarHeight: CGFloat {
        horizontalSizeClass == .regular ? KeyboardConstants.candidateBarHeightIPad : KeyboardConstants.candidateBarHeight
    }
}

#Preview {
    VStack(spacing: 0) {
        CandidateBar(
            candidates: ["สวัสดี", "สวัสดี", "สวัสดิ์", "สวาสดี"],
            buffer: "sawatdi",
            onTap: { candidate in
                print("Selected: \(candidate)")
            }
        )
        .frame(height: 50)

        Spacer()
    }
    .background(Color(.systemGray6))
}
