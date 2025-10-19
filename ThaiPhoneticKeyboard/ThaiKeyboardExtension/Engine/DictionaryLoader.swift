//
//  DictionaryLoader.swift
//  Thai Phonetic Keyboard
//
//  Handles loading dictionary and n-gram frequency data
//

import Foundation

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
        // Load main dictionary
        guard let dictionary = loadDictionary() else {
            return nil
        }

        // Load n-gram frequencies
        let (bigrams, trigrams) = loadNgramFrequencies()

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
            return nil
        }

        guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: bundlePath)) else {
            return nil
        }

        guard let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: [String]] else {
            return nil
        }

        return dict
    }

    /// Load n-gram frequencies from JSON
    private func loadNgramFrequencies() -> (bigrams: [String: Int], trigrams: [String: Int]) {
        // Use Bundle(for:) to get the extension's bundle
        let bundle = Bundle(for: DictionaryLoader.self)

        guard let bundlePath = bundle.path(forResource: AppConstants.ngramFileName, ofType: "json"),
              let jsonData = try? Data(contentsOf: URL(fileURLWithPath: bundlePath)),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            return ([:], [:])
        }

        let bigrams = json["bigrams"] as? [String: Int] ?? [:]
        let trigrams = json["trigrams"] as? [String: Int] ?? [:]

        return (bigrams, trigrams)
    }
}
