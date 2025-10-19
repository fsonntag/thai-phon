//
//  SettingsView.swift
//  Thai Phonetic Keyboard
//
//  Settings screen for keyboard preferences
//

import SwiftUI
import KeyboardKit

struct SettingsView: View {
    @State private var isAudioFeedbackEnabled: Bool = false
    @State private var isHapticFeedbackEnabled: Bool = false

    var body: some View {
        Form {
            Section {
                Toggle("Audio Feedback", isOn: Binding(
                    get: { isAudioFeedbackEnabled },
                    set: { newValue in
                        isAudioFeedbackEnabled = newValue
                        var settings = FeedbackSettings()
                        settings.isAudioFeedbackEnabled = newValue
                    }
                ))
                Toggle("Haptic Feedback", isOn: Binding(
                    get: { isHapticFeedbackEnabled },
                    set: { newValue in
                        isHapticFeedbackEnabled = newValue
                        var settings = FeedbackSettings()
                        settings.isHapticFeedbackEnabled = newValue
                    }
                ))
            } header: {
                Text("Feedback")
            } footer: {
                Text("Enable or disable sound and haptic feedback when typing.")
            }
            .onAppear {
                // Load current settings when view appears
                let settings = FeedbackSettings()
                isAudioFeedbackEnabled = settings.isAudioFeedbackEnabled
                isHapticFeedbackEnabled = settings.isHapticFeedbackEnabled
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("How to Enable the Keyboard")
                        .font(.headline)
                    Text("1. Open Settings app")
                    Text("2. Go to General → Keyboard → Keyboards")
                    Text("3. Tap 'Add New Keyboard'")
                    Text("4. Select 'Thai Phonetic'")
                    Text("5. Enable 'Allow Full Access' (required for typing)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            } header: {
                Text("Setup Instructions")
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
