//
//  ContentView.swift
//  Thai Phonetic Keyboard
//
//  Main app view with setup instructions
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // App icon/logo
                    Image("AppIconDisplay")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .cornerRadius(22.5)
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                        .padding(.top, 40)

                    Text("Thai Phonetic Keyboard")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)

                    Text("Type Thai using romanization")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    // Feature highlights
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(
                            icon: "keyboard",
                            title: "Pinyin-Style Input",
                            description: "Type romanization and select Thai text"
                        )

                        FeatureRow(
                            icon: "abc",
                            title: "Smart Matching",
                            description: "Handles multiple romanization variants"
                        )

                        FeatureRow(
                            icon: "text.word.spacing",
                            title: "Multi-Word Support",
                            description: "Automatically segments longer phrases"
                        )

                        FeatureRow(
                            icon: "globe",
                            title: "Seamless English",
                            description: "Type English alongside Thai effortlessly"
                        )
                    }
                    .padding(.horizontal)

                    Divider()
                        .padding(.vertical, 8)

                    // Action buttons
                    VStack(spacing: 12) {
                        NavigationLink(destination: TutorialView()) {
                            Label("Setup Instructions", systemImage: "questionmark.circle.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }

                        NavigationLink(destination: SettingsView()) {
                            Label("Keyboard Settings", systemImage: "slider.horizontal.3")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                        }

                        Button(action: openSettings) {
                            Label("Open iOS Settings", systemImage: "gear")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)

                    Spacer()

                    // Footer
                    Text("Version 1.0")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 20)
                }
            }
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    ContentView()
}
