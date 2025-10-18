//
//  TutorialView.swift
//  Thai Phonetic Keyboard
//
//  Setup and usage tutorial
//

import SwiftUI

struct TutorialView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // How to Enable section
                VStack(alignment: .leading, spacing: 16) {
                    Text("How to Enable")
                        .font(.title2)
                        .bold()

                    InstructionStep(
                        number: 1,
                        text: "Go to Settings → General → Keyboard → Keyboards"
                    )

                    InstructionStep(
                        number: 2,
                        text: "Tap 'Add New Keyboard...'"
                    )

                    InstructionStep(
                        number: 3,
                        text: "Select 'Thai Phonetic' under Third-Party Keyboards"
                    )

                    InstructionStep(
                        number: 4,
                        text: "Switch to Thai Phonetic keyboard using the 🌐 key"
                    )
                }

                Divider()

                // How to Use section
                VStack(alignment: .leading, spacing: 16) {
                    Text("How to Use")
                        .font(.title2)
                        .bold()

                    UsageExample(
                        romanization: "sawatdi",
                        thai: "สวัสดี",
                        meaning: "(hello)"
                    )

                    VStack(alignment: .leading, spacing: 12) {
                        UsagePoint(text: "Type romanization (e.g., 'sawatdi')")
                        UsagePoint(text: "Thai candidates appear above keyboard")
                        UsagePoint(text: "Tap candidate or press space to select")
                        UsagePoint(text: "Type English normally when not matching Thai")
                        UsagePoint(text: "Press 123 for numbers and punctuation")
                    }
                }

                Divider()

                // Tips section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Tips")
                        .font(.title2)
                        .bold()

                    TipCard(
                        icon: "lightbulb.fill",
                        title: "Flexible Romanization",
                        description: "The keyboard handles multiple romanization styles. Try 'sawatdi', 'sawatdee', 'sawasdee', or 'sawadee' - they all work!"
                    )

                    TipCard(
                        icon: "keyboard",
                        title: "Multi-Word Input",
                        description: "Type multiple words together like 'sabaidemai' to get 'สบายดีไหม' (how are you)."
                    )

                    TipCard(
                        icon: "arrow.uturn.backward",
                        title: "Delete to Edit",
                        description: "Use delete to remove characters from the romanization buffer before committing."
                    )
                }

                Spacer(minLength: 40)
            }
            .padding()
        }
        .navigationTitle("Setup Guide")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct InstructionStep: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.blue)
                .clipShape(Circle())

            Text(text)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct UsageExample: View {
    let romanization: String
    let thai: String
    let meaning: String

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Example:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }

            VStack(spacing: 8) {
                HStack {
                    Text("Type:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(romanization)
                        .font(.body)
                        .fontWeight(.medium)
                    Spacer()
                }

                HStack {
                    Text("Get:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(thai)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text(meaning)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

struct UsagePoint: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.body)
                .foregroundColor(.blue)

            Text(text)
                .font(.body)
        }
    }
}

struct TipCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.orange)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationView {
        TutorialView()
    }
}
