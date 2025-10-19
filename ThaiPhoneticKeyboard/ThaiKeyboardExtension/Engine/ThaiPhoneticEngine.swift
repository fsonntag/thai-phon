//
//  ThaiPhoneticEngine.swift
//  Thai Phonetic Keyboard
//
//  Core Thai phonetic input engine
//  Ported from macOS ThaiPhoneticIMController.swift
//

import Foundation
import Combine
import OSLog

class ThaiPhoneticEngine: ObservableObject {
    // MARK: - Published Properties

    /// Current input buffer (romanization being typed)
    @Published var composedBuffer: String = ""

    /// Current candidates for selection
    @Published var currentCandidates: [String] = []

    /// Loading state
    @Published var isLoaded: Bool = false

    // MARK: - Private Properties

    /// Thai dictionary: romanization -> [Thai words]
    private var dictionary: [String: [String]] = [:]

    /// N-gram frequencies for multi-word ranking
    private var bigramFrequencies: [String: Int] = [:]
    private var trigramFrequencies: [String: Int] = [:]

    // MARK: - Initialization

    init() {
        loadDictionaries()
    }

    // MARK: - Dictionary Loading

    func loadDictionaries() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let data = DictionaryLoader.shared.loadDictionaries() else {
                os_log("Failed to load dictionaries", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "Engine"), type: .error)
                return
            }

            DispatchQueue.main.async {
                self?.dictionary = data.dictionary
                self?.bigramFrequencies = data.bigramFrequencies
                self?.trigramFrequencies = data.trigramFrequencies
                self?.isLoaded = true
                os_log("Dictionary loaded successfully", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "Engine"), type: .info)
            }
        }
    }

    // MARK: - Input Handling

    func appendCharacter(_ char: String) {
        // Preserve original case in buffer for display
        composedBuffer.append(char)
        updateCandidates()
    }

    func deleteCharacter() {
        guard !composedBuffer.isEmpty else { return }
        composedBuffer.removeLast()
        updateCandidates()
    }

    func clearBuffer() {
        composedBuffer = ""
        currentCandidates = []
    }

    func getFirstCandidate() -> String? {
        currentCandidates.first
    }

    // MARK: - Multi-word Segmentation

    /// Greedy longest-match segmentation
    /// Returns array of romanization segments, or nil if segmentation fails
    private func greedySegment(_ input: String) -> [String]? {
        var result: [String] = []
        var remaining = input
        let maxWordLength = 15  // Reasonable max for Thai words

        while !remaining.isEmpty {
            var matched = false

            // Try longest matches first
            for length in stride(from: min(remaining.count, maxWordLength), through: 1, by: -1) {
                let prefix = String(remaining.prefix(length))

                // Try exact match first
                if dictionary[prefix] != nil {
                    result.append(prefix)
                    remaining = String(remaining.dropFirst(length))
                    matched = true
                    break
                }

                // Try fuzzy match
                let fuzzyVariants = FuzzyMatching.generateFuzzyVariants(prefix)
                for variant in fuzzyVariants {
                    if dictionary[variant] != nil {
                        result.append(prefix)  // Store original input, not variant
                        remaining = String(remaining.dropFirst(length))
                        matched = true
                        break
                    }
                }
                if matched { break }
            }

            // If no match found, segmentation failed
            if !matched {
                return nil
            }
        }

        return result
    }

    /// Lookup a single segment, trying exact then fuzzy matching
    private func lookupSegment(_ segment: String) -> [String] {
        // Try exact match first
        if let candidates = dictionary[segment] {
            return candidates
        }

        // Try fuzzy matching
        let fuzzyVariants = FuzzyMatching.generateFuzzyVariants(segment)
        for variant in fuzzyVariants {
            if let candidates = dictionary[variant] {
                return candidates
            }
        }

        return []
    }

    /// Score a phrase using n-gram frequencies
    /// Higher score = more likely phrase
    private func scorePhrase(_ words: [String]) -> Double {
        if words.isEmpty {
            return 0.0
        }

        if words.count == 1 {
            // Single word: use position in dictionary as proxy for frequency
            // (dictionary is already sorted by frequency)
            return 1000.0  // Base score for single words
        }

        var score = 1.0

        // Add bigram scores
        for i in 0..<words.count - 1 {
            let bigramKey = "\(words[i])|\(words[i+1])"
            if let bigramFreq = bigramFrequencies[bigramKey] {
                score *= Double(bigramFreq)
            } else {
                // No bigram data: penalize but don't eliminate
                score *= 0.01  // Small penalty
            }
        }

        // Add trigram scores (if available)
        for i in 0..<words.count - 2 {
            let trigramKey = "\(words[i])|\(words[i+1])|\(words[i+2])"
            if let trigramFreq = trigramFrequencies[trigramKey] {
                // Trigrams are less common, so boost them more
                score *= Double(trigramFreq) * 10.0
            }
        }

        return score
    }

    /// Generate Thai candidates by joining top matches from each segment
    /// Returns up to 6 candidates, sorted by n-gram frequency scores
    private func generateMultiWordCandidates(_ segments: [String]) -> [String] {
        var candidateSets: [[String]] = []

        // Lookup each segment
        for segment in segments {
            let candidates = lookupSegment(segment)
            if candidates.isEmpty {
                return []  // If any segment has no matches, fail
            }
            candidateSets.append(candidates)
        }

        if candidateSets.count == 1 {
            // Single word, return top candidates
            return Array(candidateSets[0].prefix(6))
        }

        // Multi-word: generate combinations and score them
        var scoredCombinations: [(phrase: String, words: [String], score: Double)] = []

        // Generate combinations (more exhaustive now that we have scoring)
        let maxPerPosition = 3  // Try top 3 from each position

        func generateCombinations(position: Int, currentWords: [String], currentPhrase: String) {
            if position >= candidateSets.count {
                // Complete combination
                let score = scorePhrase(currentWords)
                scoredCombinations.append((currentPhrase, currentWords, score))
                return
            }

            // Try top N candidates for this position
            let candidates = Array(candidateSets[position].prefix(maxPerPosition))
            for candidate in candidates {
                generateCombinations(
                    position: position + 1,
                    currentWords: currentWords + [candidate],
                    currentPhrase: currentPhrase + candidate
                )

                // Limit total combinations to avoid explosion
                if scoredCombinations.count >= 50 {
                    return
                }
            }
        }

        generateCombinations(position: 0, currentWords: [], currentPhrase: "")

        // Sort by score (descending) and return top 6
        scoredCombinations.sort { $0.score > $1.score }

        let topCandidates = scoredCombinations.prefix(6).map { $0.phrase }

        return Array(topCandidates)
    }

    // MARK: - Candidate Management

    func updateCandidates() {
        guard !composedBuffer.isEmpty else {
            currentCandidates = []
            return
        }

        var candidates: [String] = []

        // Use lowercase version for all dictionary lookups
        let lookupBuffer = composedBuffer.lowercased()

        // Try single-word lookup first (exact match)
        if let exactMatches = dictionary[lookupBuffer] {
            candidates = Array(exactMatches.prefix(AppConstants.maxCandidates - 1))
        } else {
            // Try single-word fuzzy matching
            let fuzzyVariants = FuzzyMatching.generateFuzzyVariants(lookupBuffer)
            var singleWordCandidates: [String] = []
            var seenWords = Set<String>()

            for variant in fuzzyVariants {
                if let matches = dictionary[variant] {
                    for candidate in matches {
                        if !seenWords.contains(candidate) {
                            singleWordCandidates.append(candidate)
                            seenWords.insert(candidate)
                        }
                    }
                }
            }

            // If single-word lookup found results, use them
            if !singleWordCandidates.isEmpty {
                candidates = Array(singleWordCandidates.prefix(AppConstants.maxCandidates - 1))
            } else {
                // Try multi-word segmentation
                if let segments = greedySegment(lookupBuffer) {
                    let multiWordCandidates = generateMultiWordCandidates(segments)
                    if !multiWordCandidates.isEmpty {
                        candidates = Array(multiWordCandidates.prefix(5))  // Max 5 to leave room for romanization
                    }
                }
            }
        }

        // Always add the English romanization (original case) as the last candidate
        if !candidates.isEmpty {
            candidates.append(composedBuffer)
        } else {
            // If no Thai candidates, just show the romanization (original case)
            candidates = [composedBuffer]
        }

        currentCandidates = candidates
    }
}
