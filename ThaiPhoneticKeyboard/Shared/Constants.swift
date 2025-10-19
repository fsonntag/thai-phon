//
//  Constants.swift
//  Thai Phonetic Keyboard
//
//  Shared constants between app and keyboard extension
//

import Foundation
import UIKit

struct AppConstants {
    // Dictionary files
    static let dictionaryFileName = "dictionary"
    static let ngramFileName = "ngram_frequencies"

    // Keyboard behavior - adaptive based on device
    static var maxCandidates: Int {
        // Show more candidates on iPad (more screen space)
        return UIDevice.current.userInterfaceIdiom == .pad ? 14 : 9
    }
}
