//
//  Extensions.swift
//  Thai Phonetic Keyboard
//
//  Utility extensions shared between app and keyboard extension
//

import Foundation
import SwiftUI

// MARK: - String Extensions

extension String {
    /// Check if string contains only Latin letters (a-z, A-Z)
    var isLatinLetters: Bool {
        let regex = try? NSRegularExpression(pattern: "^[a-zA-Z]+$")
        let range = NSRange(location: 0, length: utf16.count)
        return regex?.firstMatch(in: self, options: [], range: range) != nil
    }

    /// Convert to lowercase for consistent matching
    var normalized: String {
        lowercased().trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - View Extensions

extension View {
    /// Apply conditional modifiers
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Environment Values

extension EnvironmentValues {
    var isIPad: Bool {
        #if targetEnvironment(macCatalyst)
        return true
        #else
        return UIDevice.current.userInterfaceIdiom == .pad
        #endif
    }
}
