import Cocoa
import InputMethodKit

// IMK constants not automatically bridged to Swift
private let kIMKBaseline = NSAttributedString.Key("IMKBaseline")

@objc(ThaiPhoneticIMController)
class ThaiPhoneticIMController: IMKInputController {

    // Current input buffer (romanization being typed)
    private var composedBuffer = ""

    // Thai dictionary: romanization -> [Thai words]
    private var dictionary: [String: [String]] = [:]

    // N-gram frequencies for multi-word ranking
    private var wordFrequencies: [String: Int] = [:]  // From tnc_freq.txt
    private var bigramFrequencies: [String: Int] = [:] // word1|word2 -> frequency
    private var trigramFrequencies: [String: Int] = [:]  // word1|word2|word3 -> frequency

    // Current candidates for selection
    private var currentCandidates: [String] = []

    // Custom candidate window
    private var candidatesWindow: ThaiCandidateWindow?

    override init!(server: IMKServer!, delegate: Any!, client: Any!) {
        super.init(server: server, delegate: delegate, client: client)
        loadDictionary()
        loadNgramFrequencies()

        // Initialize our custom candidate window
        candidatesWindow = ThaiCandidateWindow()
    }

    // MARK: - Dictionary Loading

    private func loadDictionary() {
        // Load the dictionary from the embedded JSON file
        guard let bundlePath = Bundle.main.path(forResource: "dictionary", ofType: "json"),
              let jsonData = try? Data(contentsOf: URL(fileURLWithPath: bundlePath)),
              let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: [String]] else {
            NSLog("Failed to load dictionary")
            return
        }

        dictionary = dict
        NSLog("Loaded dictionary with \(dictionary.count) entries")
    }

    private func loadNgramFrequencies() {
        // Load n-gram frequencies from embedded JSON file
        guard let bundlePath = Bundle.main.path(forResource: "ngram_frequencies", ofType: "json"),
              let jsonData = try? Data(contentsOf: URL(fileURLWithPath: bundlePath)),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            NSLog("Failed to load n-gram frequencies")
            return
        }

        // Load bigrams
        if let bigrams = json["bigrams"] as? [String: Int] {
            bigramFrequencies = bigrams
            NSLog("Loaded \(bigramFrequencies.count) bigrams")
        }

        // Load trigrams
        if let trigrams = json["trigrams"] as? [String: Int] {
            trigramFrequencies = trigrams
            NSLog("Loaded \(trigramFrequencies.count) trigrams")
        }

        // Also load word frequencies from tnc_freq.txt (already embedded in dictionary ordering)
        // For now, we'll infer word frequency from position in dictionary
        // Later we can load tnc_freq.txt separately if needed
    }

    // MARK: - Input Handling

    override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
        guard let event = event else { return false }

        // Only handle keyDown events
        guard event.type == .keyDown else { return false }

        // IMPORTANT: Let modifier key combinations through (CMD+W, CMD+S, etc.)
        let modifiers = event.modifierFlags
        if modifiers.contains(.command) || modifiers.contains(.control) || modifiers.contains(.option) {
            // Let app handle shortcuts
            return false
        }

        let keyCode = event.keyCode
        let characters = event.characters ?? ""

        // Handle special keys only if we have input
        if keyCode == 51 { // Delete/Backspace
            return handleDelete(client: sender)
        }

        if keyCode == 36 || keyCode == 76 { // Return/Enter
            return handleEnter(client: sender)
        }

        if keyCode == 53 { // Escape
            return handleEscape(client: sender)
        }

        if keyCode == 49 { // Space
            return handleSpace(client: sender)
        }

        // Handle number keys for candidate selection (only if we have candidates)
        if !composedBuffer.isEmpty && !currentCandidates.isEmpty {
            if characters.count == 1, let num = Int(characters), num >= 1 && num <= 9 {
                return handleNumberSelection(num, client: sender)
            }
        }

        // Handle regular character input (a-z)
        if characters.count == 1 {
            let char = characters.lowercased()
            if char.rangeOfCharacter(from: CharacterSet.lowercaseLetters) != nil {
                return handleCharacter(char, client: sender)
            }
        }

        return false
    }

    private func handleCharacter(_ char: String, client sender: Any) -> Bool {
        composedBuffer += char
        updateCandidates()
        updateComposition(client: sender)
        return true
    }

    private func handleDelete(client sender: Any) -> Bool {
        if composedBuffer.isEmpty {
            return false
        }
        composedBuffer.removeLast()
        updateCandidates()
        updateComposition(client: sender)
        return true
    }

    private func handleSpace(client sender: Any) -> Bool {
        if composedBuffer.isEmpty {
            return false
        }

        // Commit the first candidate if available
        if !currentCandidates.isEmpty {
            commitCandidate(currentCandidates[0], client: sender)
        } else {
            // No candidates, just output the romanization
            commitText(composedBuffer, client: sender)
        }
        return true
    }

    private func handleEnter(client sender: Any) -> Bool {
        if composedBuffer.isEmpty {
            return false
        }

        // Commit the current buffer as-is
        commitText(composedBuffer, client: sender)
        return true
    }

    private func handleEscape(client sender: Any) -> Bool {
        if composedBuffer.isEmpty {
            return false
        }

        // Cancel input
        composedBuffer = ""
        currentCandidates = []
        updateComposition(client: sender)
        return true
    }

    private func handleNumberSelection(_ num: Int, client sender: Any) -> Bool {
        if composedBuffer.isEmpty || currentCandidates.isEmpty {
            return false
        }

        let index = num - 1
        if index < currentCandidates.count {
            commitCandidate(currentCandidates[index], client: sender)
            return true
        }

        return false
    }

    // MARK: - Multi-word Segmentation

    private func greedySegment(_ input: String) -> [String]? {
        // Greedy longest-match segmentation
        // Returns array of romanization segments, or nil if segmentation fails

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
                let fuzzyVariants = generateFuzzyVariants(prefix)
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

    private func lookupSegment(_ segment: String) -> [String] {
        // Lookup a single segment, trying exact then fuzzy matching

        // Try exact match first
        if let candidates = dictionary[segment] {
            return candidates
        }

        // Try fuzzy matching
        let fuzzyVariants = generateFuzzyVariants(segment)
        for variant in fuzzyVariants {
            if let candidates = dictionary[variant] {
                return candidates
            }
        }

        return []
    }

    private func scorePhrase(_ words: [String]) -> Double {
        // Score a phrase using n-gram frequencies
        // Higher score = more likely phrase

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

    private func generateMultiWordCandidates(_ segments: [String]) -> [String] {
        // Generate Thai candidates by joining top matches from each segment
        // Returns up to 6 candidates, sorted by n-gram frequency scores

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

        // Debug: log scores for top candidates
        if !topCandidates.isEmpty {
            NSLog("Multi-word candidates for \(segments.joined(separator: "+")):")
            for (i, scored) in scoredCombinations.prefix(6).enumerated() {
                NSLog("  \(i+1). \(scored.phrase) [\(scored.words.joined(separator: " "))] score: \(scored.score)")
            }
        }

        return Array(topCandidates)
    }

    // MARK: - Candidate Management

    private func generateFuzzyVariants(_ roman: String) -> [String] {
        // Generate common vowel variations for a romanization at runtime.
        // This replicates the Python logic from vowel_variants_backup.py
        //
        // Examples:
        //     - sawatdi → sawatdee, sawasdee, sawasdi, sawadee
        //     - aroi → aloi, aroy

        var variants = Set<String>([roman])

        // Pattern 1: Final 'i' ↔ 'ee' (sawatdi ↔ sawatdee)
        if roman.hasSuffix("i") {
            variants.insert(String(roman.dropLast()) + "ee")
        }
        if roman.hasSuffix("ee") {
            variants.insert(String(roman.dropLast(2)) + "i")
        }

        // Pattern 2: Final 'y' ↔ 'i' ↔ 'ee' (aroy, aroi, aroee)
        if roman.hasSuffix("y") {
            variants.insert(String(roman.dropLast()) + "i")
            variants.insert(String(roman.dropLast()) + "ee")
        }
        if roman.hasSuffix("i") && roman.count > 2 {
            variants.insert(String(roman.dropLast()) + "y")
        }
        if roman.hasSuffix("ee") && roman.count > 3 {
            variants.insert(String(roman.dropLast(2)) + "y")
        }

        // Pattern 3: 't' ↔ 's' (common confusion: sawatdi ↔ sawasdi)
        if roman.contains("t") {
            variants.insert(roman.replacingOccurrences(of: "t", with: "s"))
        }
        if roman.contains("s") {
            variants.insert(roman.replacingOccurrences(of: "s", with: "t"))
        }

        // Pattern 4: 't' ↔ 'd' (common confusion: sawatdi ↔ sawaddi)
        if roman.contains("t") {
            variants.insert(roman.replacingOccurrences(of: "t", with: "d"))
        }
        if roman.contains("d") {
            variants.insert(roman.replacingOccurrences(of: "d", with: "t"))
        }

        // Pattern 5: Long vowel doubling - BIDIRECTIONAL (aa ↔ a, oo ↔ o, ee ↔ e)
        // This is critical for cases like "yaak" → "yak" (อยาก)

        // a ↔ aa
        if roman.contains("aa") {
            variants.insert(roman.replacingOccurrences(of: "aa", with: "a"))
        } else if roman.contains("a") {
            if let range = roman.range(of: "a") {
                variants.insert(roman.replacingCharacters(in: range, with: "aa"))
            }
        }

        // o ↔ oo
        if roman.contains("oo") {
            variants.insert(roman.replacingOccurrences(of: "oo", with: "o"))
        } else if roman.contains("o") {
            if let range = roman.range(of: "o") {
                variants.insert(roman.replacingCharacters(in: range, with: "oo"))
            }
        }

        // e ↔ ee (in addition to i ↔ ee from Pattern 1)
        if roman.contains("ee") && !roman.hasSuffix("ee") {
            variants.insert(roman.replacingOccurrences(of: "ee", with: "e"))
        } else if roman.contains("e") && !roman.contains("ee") {
            if let range = roman.range(of: "e") {
                variants.insert(roman.replacingCharacters(in: range, with: "ee"))
            }
        }

        // Pattern 6: Combined transformations for common cases
        let combinedVariants = variants.flatMap { v -> [String] in
            var combined: [String] = []
            if v.hasSuffix("i") {
                combined.append(String(v.dropLast()) + "ee")
            }
            if v.hasSuffix("ee") {
                combined.append(String(v.dropLast(2)) + "i")
            }
            return combined
        }
        variants.formUnion(combinedVariants)

        // Pattern 7: Remove 't' before final vowel (sawatdi → sawadi, sawatdee → sawadee)
        var tRemoved: [String] = []
        if roman.contains("tdi") {
            tRemoved.append(roman.replacingOccurrences(of: "tdi", with: "di"))
            tRemoved.append(roman.replacingOccurrences(of: "tdi", with: "dee"))
        }
        if roman.contains("tdee") {
            tRemoved.append(roman.replacingOccurrences(of: "tdee", with: "dee"))
            tRemoved.append(roman.replacingOccurrences(of: "tdee", with: "di"))
        }
        if roman.contains("ti") && roman.count > 3 {
            tRemoved.append(roman.replacingOccurrences(of: "ti", with: "i"))
            tRemoved.append(roman.replacingOccurrences(of: "ti", with: "ee"))
        }
        if roman.contains("tee") && roman.count > 4 {
            tRemoved.append(roman.replacingOccurrences(of: "tee", with: "ee"))
            tRemoved.append(roman.replacingOccurrences(of: "tee", with: "i"))
        }
        variants.formUnion(tRemoved)

        // Remove any empty or single-char variants
        return variants.filter { $0.count >= 2 }
    }

    private func updateCandidates() {
        guard !composedBuffer.isEmpty else {
            currentCandidates = []
            return
        }

        // Try single-word lookup first (exact match)
        if let candidates = dictionary[composedBuffer] {
            currentCandidates = candidates
            return
        }

        // Try single-word fuzzy matching
        let fuzzyVariants = generateFuzzyVariants(composedBuffer)
        var singleWordCandidates: [String] = []
        var seenWords = Set<String>()

        for variant in fuzzyVariants {
            if let candidates = dictionary[variant] {
                for candidate in candidates {
                    if !seenWords.contains(candidate) {
                        singleWordCandidates.append(candidate)
                        seenWords.insert(candidate)
                    }
                }
            }
        }

        // If single-word lookup found results, use them
        if !singleWordCandidates.isEmpty {
            currentCandidates = singleWordCandidates
            return
        }

        // Try multi-word segmentation
        if let segments = greedySegment(composedBuffer) {
            let multiWordCandidates = generateMultiWordCandidates(segments)
            if !multiWordCandidates.isEmpty {
                currentCandidates = Array(multiWordCandidates.prefix(6))  // Max 6 for multi-word
                return
            }
        }

        // No matches found
        currentCandidates = []
    }

    // MARK: - Composition and Commit

    private func updateComposition(client sender: Any) {
        guard let client = sender as? IMKTextInput else { return }

        // Create attributed string for the composition
        let attrs: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .markedClauseSegment: 0
        ]

        // Show romanization while typing (like Pinyin input)
        // For multi-word, show segmentation with spaces
        var composedString = composedBuffer

        // Try to segment the input to show word boundaries visually
        if let segments = greedySegment(composedBuffer), segments.count > 1 {
            // Multi-word detected: show with spaces between segments
            composedString = segments.joined(separator: " ")
        }

        let attributedString = NSAttributedString(
            string: composedString,
            attributes: attrs
        )

        // Calculate proper cursor position at the end of the string
        // Use UTF-16 count for NSRange to handle Thai multi-byte characters correctly
        let utf16Length = (composedString as NSString).length

        client.setMarkedText(
            attributedString,
            selectionRange: NSRange(location: utf16Length, length: 0),
            replacementRange: NSRange(location: NSNotFound, length: 0)
        )

        // Show candidates window if we have candidates
        if !currentCandidates.isEmpty {
            showCandidates(client: sender)
        } else {
            hideCandidates()
        }
    }

    private func showCandidates(client sender: Any) {
        guard let candidatesWindow = candidatesWindow,
              let client = sender as? IMKTextInput else { return }

        // Update candidates in our custom window
        candidatesWindow.updateCandidates(currentCandidates, selected: 0)

        // Get cursor position from client
        var cursorRect = NSRect.zero
        let _ = client.attributes(forCharacterIndex: 0, lineHeightRectangle: &cursorRect)

        // Position window below the cursor
        if cursorRect != NSRect.zero {
            let screenHeight = NSScreen.main?.frame.height ?? 1000
            candidatesWindow.positionNear(rect: cursorRect, screenHeight: screenHeight)
        } else {
            // Fallback: center on screen if we can't get cursor position
            let screenFrame = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080)
            let windowX = screenFrame.midX - candidatesWindow.frame.width / 2
            let windowY = screenFrame.midY
            candidatesWindow.setFrameOrigin(NSPoint(x: windowX, y: windowY))
        }

        // Show the window
        candidatesWindow.orderFront(self)
    }

    private func hideCandidates() {
        candidatesWindow?.orderOut(self)
    }

    private func commitCandidate(_ candidate: String, client sender: Any) {
        commitText(candidate, client: sender)
    }

    private func commitText(_ text: String, client sender: Any) {
        guard let client = sender as? IMKTextInput else { return }

        client.insertText(
            text,
            replacementRange: NSRange(location: NSNotFound, length: 0)
        )

        // Clear the buffer
        composedBuffer = ""
        currentCandidates = []
        hideCandidates()
    }

    // MARK: - Overrides

    override func activateServer(_ sender: Any!) {
        super.activateServer(sender)
        composedBuffer = ""
        currentCandidates = []
        hideCandidates()
    }

    override func deactivateServer(_ sender: Any!) {
        super.deactivateServer(sender)
        composedBuffer = ""
        currentCandidates = []
        hideCandidates()
    }
}
