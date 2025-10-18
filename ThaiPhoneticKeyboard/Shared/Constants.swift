//
//  Constants.swift
//  Thai Phonetic Keyboard
//
//  Shared constants between app and keyboard extension
//

import Foundation
import SwiftUI

struct AppConstants {
    // Bundle identifiers
    static let appBundleID = "com.fsonntag.ThaiPhoneticKeyboard"
    static let extensionBundleID = "com.fsonntag.ThaiPhoneticKeyboard.extension"

    // App Store
    static let appName = "Thai Phonetic Keyboard"
    static let appDescription = "Type Thai using romanization"

    // Dictionary files
    static let dictionaryFileName = "dictionary"
    static let ngramFileName = "ngram_frequencies"
}

struct KeyboardConstants {
    // Layout dimensions
    static let keyHeight: CGFloat = 42
    static let keyHeightIPad: CGFloat = 50
    static let keySpacing: CGFloat = 6
    static let keyCornerRadius: CGFloat = 5

    static let candidateBarHeight: CGFloat = 44
    static let candidateBarHeightIPad: CGFloat = 50

    // Colors
    static let keyBackground = Color(.systemBackground)
    static let systemKeyBackground = Color(.systemBackground)  // System keys are white like normal keys
    static let primaryKeyBackground = Color(.systemBlue)

    // Typography
    static let keyFontSize: CGFloat = 20
    static let candidateFontSize: CGFloat = 18
    static let numberBadgeFontSize: CGFloat = 11

    // Behavior
    static let maxCandidates = 9
}
