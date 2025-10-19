//
//  ThaiActionHandler.swift
//  Thai Phonetic Keyboard Extension
//
//  Custom action handler to integrate Thai phonetic engine
//

import KeyboardKit
import UIKit
import OSLog

class ThaiActionHandler: KeyboardAction.StandardActionHandler {

    // MARK: - Properties

    // Make engine internal so it can be accessed by autocomplete provider
    lazy var engine: ThaiPhoneticEngine = {
        os_log("🟢 ThaiPhoneticEngine initialized", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "ThaiActionHandler"), type: .info)
        return ThaiPhoneticEngine()
    }()

    private var bufferLength: Int = 0  // Track how many romanization chars are in the document

    // MARK: - Public Methods

    /// Manually commit a specific candidate (called when user taps a candidate)
    func commitCandidate(_ candidate: String) {
        os_log("👆 Manual candidate selection: %{public}@", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "ThaiActionHandler"), type: .info, candidate)

        // Delete the romanization from document
        for _ in 0..<bufferLength {
            keyboardContext.textDocumentProxy.deleteBackward()
        }
        bufferLength = 0

        // Insert the selected candidate
        keyboardContext.textDocumentProxy.insertText(candidate)

        // Clear the engine buffer
        engine.clearBuffer()
    }

    // MARK: - Override Action Handling

    override func action(
        for gesture: Keyboard.Gesture,
        on action: KeyboardAction
    ) -> KeyboardAction.GestureAction? {
        switch action {
        case .character(let char):
            // Intercept character input for Thai conversion
            if gesture == .release {
                return { [weak self] _ in
                    self?.handleCharacter(char)
                }
            }
        case .space:
            // Intercept space to commit Thai text
            if gesture == .release {
                return { [weak self] _ in
                    self?.handleSpace()
                }
            }
        case .backspace:
            // Intercept backspace to delete from buffer if needed
            if gesture == .press || gesture == .release {
                return { [weak self] _ in
                    self?.handleBackspace()
                }
            }
        default:
            break
        }

        // Use standard handling for all other cases
        return super.action(for: gesture, on: action)
    }

    // MARK: - Thai Input Handling

    private func handleCharacter(_ char: String) {
        os_log("🔤 Character input: %{public}@", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "ThaiActionHandler"), type: .debug, char)

        // Check if it's a letter (a-z, A-Z)
        let letters = CharacterSet.letters
        if char.count == 1,
           let scalar = char.unicodeScalars.first,
           letters.contains(scalar),
           scalar.value < 128 { // ASCII letters only

            // Add to Thai phonetic engine (preserving original case)
            engine.appendCharacter(char)
            os_log("📝 Buffer: %{public}@, Candidates: %d", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "ThaiActionHandler"), type: .debug, engine.composedBuffer, engine.currentCandidates.count)

            // Delete existing romanization from document and insert updated buffer
            // This way the user sees the romanization being built up: "P" -> "Po" -> "Pom"
            if bufferLength > 0 {
                for _ in 0..<bufferLength {
                    keyboardContext.textDocumentProxy.deleteBackward()
                }
            }

            // Insert the full romanization buffer (with original case preserved)
            keyboardContext.textDocumentProxy.insertText(engine.composedBuffer)
            bufferLength = engine.composedBuffer.count

        } else {
            // Not a letter - commit any pending Thai text first
            commitPendingThaiText()

            // Then insert the character normally
            keyboardContext.textDocumentProxy.insertText(char)
        }
    }

    private func handleSpace() {
        os_log("⎵ Space pressed, buffer: %{public}@", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "ThaiActionHandler"), type: .debug, engine.composedBuffer)

        if !engine.composedBuffer.isEmpty {
            // Delete the romanization from document
            for _ in 0..<bufferLength {
                keyboardContext.textDocumentProxy.deleteBackward()
            }
            bufferLength = 0

            // Commit first Thai candidate if available
            if let candidate = engine.getFirstCandidate() {
                keyboardContext.textDocumentProxy.insertText(candidate)
                os_log("✅ Committed Thai: %{public}@", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "ThaiActionHandler"), type: .info, candidate)
            } else {
                // No candidates, output romanization as English
                keyboardContext.textDocumentProxy.insertText(engine.composedBuffer)
                os_log("⚠️ No candidates, output romanization: %{public}@", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "ThaiActionHandler"), type: .info, engine.composedBuffer)
            }
            engine.clearBuffer()

            // Insert space
            keyboardContext.textDocumentProxy.insertText(" ")
        } else {
            // Normal space
            keyboardContext.textDocumentProxy.insertText(" ")
        }
    }

    private func handleBackspace() {
        os_log("⌫ Backspace pressed, buffer: %{public}@", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "ThaiActionHandler"), type: .debug, engine.composedBuffer)

        if !engine.composedBuffer.isEmpty {
            // Delete from Thai input buffer
            engine.deleteCharacter()

            // Delete one char from document and re-insert updated buffer
            keyboardContext.textDocumentProxy.deleteBackward()
            bufferLength -= 1

            // If buffer is now empty, we're done
            if engine.composedBuffer.isEmpty {
                bufferLength = 0
            } else {
                // Re-insert the updated buffer
                // First delete all remaining buffer chars
                for _ in 0..<bufferLength {
                    keyboardContext.textDocumentProxy.deleteBackward()
                }

                // Then insert the updated buffer
                keyboardContext.textDocumentProxy.insertText(engine.composedBuffer)
                bufferLength = engine.composedBuffer.count
            }

            os_log("⌫ After delete, buffer: %{public}@, length: %d", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "ThaiActionHandler"), type: .debug, engine.composedBuffer, bufferLength)
        } else {
            // Delete from document normally
            keyboardContext.textDocumentProxy.deleteBackward()
        }
    }

    // MARK: - Helper Methods

    private func commitPendingThaiText() {
        guard !engine.composedBuffer.isEmpty else { return }

        // Delete the romanization
        for _ in 0..<bufferLength {
            keyboardContext.textDocumentProxy.deleteBackward()
        }
        bufferLength = 0

        // Insert Thai or romanization
        if let candidate = engine.getFirstCandidate() {
            keyboardContext.textDocumentProxy.insertText(candidate)
            os_log("✅ Auto-committed Thai: %{public}@", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "ThaiActionHandler"), type: .info, candidate)
        } else {
            keyboardContext.textDocumentProxy.insertText(engine.composedBuffer)
        }

        engine.clearBuffer()
    }
}
