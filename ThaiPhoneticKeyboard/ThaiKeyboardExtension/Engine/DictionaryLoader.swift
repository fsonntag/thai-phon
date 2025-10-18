//
//  DictionaryLoader.swift
//  Thai Phonetic Keyboard
//
//  Handles loading dictionary and n-gram frequency data
//

import Foundation
import OSLog

private let logger = Logger(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "DictionaryLoader")

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
            logger.error("Failed to load dictionary")
            return nil
        }

        // Load n-gram frequencies
        let (bigrams, trigrams) = loadNgramFrequencies()

        let loadTime = Date().timeIntervalSince(startTime)
        logger.info("Loaded dictionary: \(dictionary.count) entries, \(bigrams.count) bigrams, \(trigrams.count) trigrams in \(String(format: "%.3f", loadTime))s")

        return DictionaryData(
            dictionary: dictionary,
            bigramFrequencies: bigrams,
            trigramFrequencies: trigrams
        )
    }

    /// Load Thai romanization dictionary from JSON
    private func loadDictionary() -> [String: [String]]? {
        guard let bundlePath = Bundle.main.path(forResource: AppConstants.dictionaryFileName, ofType: "json"),
              let jsonData = try? Data(contentsOf: URL(fileURLWithPath: bundlePath)),
              let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: [String]] else {
            return nil
        }

        return dict
    }

    /// Load n-gram frequencies from JSON
    private func loadNgramFrequencies() -> (bigrams: [String: Int], trigrams: [String: Int]) {
        guard let bundlePath = Bundle.main.path(forResource: AppConstants.ngramFileName, ofType: "json"),
              let jsonData = try? Data(contentsOf: URL(fileURLWithPath: bundlePath)),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            logger.warning("Failed to load n-gram frequencies")
            return ([:], [:])
        }

        let bigrams = json["bigrams"] as? [String: Int] ?? [:]
        let trigrams = json["trigrams"] as? [String: Int] ?? [:]

        return (bigrams, trigrams)
    }
}
