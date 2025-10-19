//
//  DictionaryLoader.swift
//  Thai Phonetic Keyboard
//
//  Handles loading dictionary and n-gram frequency data
//

import Foundation
import OSLog

struct DictionaryData {
    let dictionary: [String: [String]]
    let bigramFrequencies: [String: Int]
    let trigramFrequencies: [String: Int]
}

class DictionaryLoader {
    static let shared = DictionaryLoader()

    private init() {}

    /// Load dictionary and n-gram data from bundle
    func loadDictionaries() -> DictionaryData? {
        let startTime = Date()

        // Load main dictionary
        guard let dictionary = loadDictionary() else {
            os_log("Failed to load dictionary", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "DictionaryLoader"), type: .error)
            return nil
        }

        // Load n-gram frequencies
        let (bigrams, trigrams) = loadNgramFrequencies()

        let loadTime = Date().timeIntervalSince(startTime)
        os_log("Loaded dictionary: %d entries, %d bigrams, %d trigrams in %.3fs", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "DictionaryLoader"), type: .info, dictionary.count, bigrams.count, trigrams.count, loadTime)

        return DictionaryData(
            dictionary: dictionary,
            bigramFrequencies: bigrams,
            trigramFrequencies: trigrams
        )
    }

    /// Load Thai romanization dictionary from JSON
    private func loadDictionary() -> [String: [String]]? {
        // Use Bundle(for:) to get the extension's bundle, not the main app bundle
        let bundle = Bundle(for: DictionaryLoader.self)

        guard let bundlePath = bundle.path(forResource: AppConstants.dictionaryFileName, ofType: "json") else {
            os_log("❌ Dictionary file not found in bundle", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "DictionaryLoader"), type: .error)
            return nil
        }

        guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: bundlePath)) else {
            os_log("❌ Failed to read dictionary file", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "DictionaryLoader"), type: .error)
            return nil
        }

        guard let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: [String]] else {
            os_log("❌ Failed to parse dictionary JSON", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "DictionaryLoader"), type: .error)
            return nil
        }

        os_log("✅ Dictionary loaded successfully from bundle", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "DictionaryLoader"), type: .info)
        return dict
    }

    /// Load n-gram frequencies from JSON
    private func loadNgramFrequencies() -> (bigrams: [String: Int], trigrams: [String: Int]) {
        // Use Bundle(for:) to get the extension's bundle
        let bundle = Bundle(for: DictionaryLoader.self)

        guard let bundlePath = bundle.path(forResource: AppConstants.ngramFileName, ofType: "json"),
              let jsonData = try? Data(contentsOf: URL(fileURLWithPath: bundlePath)),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            os_log("⚠️ Failed to load n-gram frequencies", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "DictionaryLoader"), type: .default)
            return ([:], [:])
        }

        let bigrams = json["bigrams"] as? [String: Int] ?? [:]
        let trigrams = json["trigrams"] as? [String: Int] ?? [:]

        os_log("✅ N-gram frequencies loaded successfully", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "DictionaryLoader"), type: .info)
        return (bigrams, trigrams)
    }
}
