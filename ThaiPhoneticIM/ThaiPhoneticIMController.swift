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

    // Current candidates for selection
    private var currentCandidates: [String] = []

    // Custom candidate window
    private var candidatesWindow: ThaiCandidateWindow?

    override init!(server: IMKServer!, delegate: Any!, client: Any!) {
        super.init(server: server, delegate: delegate, client: client)
        loadDictionary()

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

        // Try exact match first
        if let candidates = dictionary[composedBuffer] {
            currentCandidates = candidates
            return
        }

        // Try fuzzy matching with vowel variants
        let fuzzyVariants = generateFuzzyVariants(composedBuffer)
        var allCandidates: [String] = []
        var seenWords = Set<String>()

        for variant in fuzzyVariants {
            if let candidates = dictionary[variant] {
                for candidate in candidates {
                    // Avoid duplicates
                    if !seenWords.contains(candidate) {
                        allCandidates.append(candidate)
                        seenWords.insert(candidate)
                    }
                }
            }
        }

        currentCandidates = allCandidates
    }

    // MARK: - Composition and Commit

    private func updateComposition(client sender: Any) {
        guard let client = sender as? IMKTextInput else { return }

        // Create attributed string for the composition
        let attrs: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .markedClauseSegment: 0
        ]

        // Always show romanization while typing (like Pinyin input)
        // Thai text is only committed when user selects a candidate
        let composedString = composedBuffer

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
