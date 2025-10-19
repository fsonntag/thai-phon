//
//  KeyboardApp+Thai.swift
//  Thai Phonetic Keyboard
//
//  KeyboardKit app configuration for Thai Phonetic Keyboard
//

import KeyboardKit

extension KeyboardApp {

    /// Thai Phonetic Keyboard configuration
    static var thaiPhonetic: KeyboardApp {
        .init(
            name: "Thai Phonetic",
            licenseKey: nil,
            appGroupId: nil,
            locales: [Locale(identifier: "en"), Locale(identifier: "th")],
            deepLinks: .init(app: "thaiphonetic://")
        )
    }
}
