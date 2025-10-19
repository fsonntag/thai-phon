//
//  ThaiPhoneticKeyboardApp.swift
//  Thai Phonetic Keyboard
//
//  Main app entry point
//

import SwiftUI
import KeyboardKit

@main
struct ThaiPhoneticKeyboardApp: App {

    init() {
        // Setup KeyboardKit with App Group for settings sync
        _ = KeyboardSettings.setupStore(forAppGroup: KeyboardApp.thaiPhonetic.appGroupId ?? "")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
