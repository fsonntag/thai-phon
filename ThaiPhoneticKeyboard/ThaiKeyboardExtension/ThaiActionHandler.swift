//
//  ThaiActionHandler.swift
//  Thai Phonetic Keyboard Extension
//
//  Custom action handler to integrate Thai phonetic engine
//

import KeyboardKit
import UIKit

class ThaiActionHandler: KeyboardAction.StandardActionHandler {

    // MARK: - Properties

    // Make engine internal so it can be accessed by autocomplete provider
    lazy var engine: ThaiPhoneticEngine = {
        return ThaiPhoneticEngine()
    }()

    private var bufferLength: Int = 0  // Track how many romanization chars are in the document

    // MARK: - Public Methods

    /// Manually commit a specific candidate (called when user taps a candidate)
    func commitCandidate(_ candidate: String) {
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
            // For other gestures, use standard handling
            return super.action(for: gesture, on: action)

        case .space:
            // Intercept space to commit Thai text
            if gesture == .release {
                return { [weak self] _ in
                    self?.handleSpace()
                }
            }
            // For other gestures, use standard handling
            return super.action(for: gesture, on: action)

        case .backspace:
            // Intercept backspace to manage our buffer
            if gesture == .release {
                return { [weak self] _ in
                    self?.handleBackspace()
                }
            }
            // Use standard handling for other gestures
            return super.action(for: gesture, on: action)

        default:
            // Use standard handling for all other cases
            return super.action(for: gesture, on: action)
        }
    }

    // MARK: - Thai Input Handling

    private func handleCharacter(_ char: String) {
        // Check if it's a letter (a-z, A-Z)
        let letters = CharacterSet.letters
        if char.count == 1,
           let scalar = char.unicodeScalars.first,
           letters.contains(scalar),
           scalar.value < 128 { // ASCII letters only

            // Add to Thai phonetic engine (preserving original case)
            engine.appendCharacter(char)

            // Just insert the new character (engine only appends, doesn't transform existing buffer)
            keyboardContext.textDocumentProxy.insertText(char)
            bufferLength += 1

        } else {
            // Not a letter - commit any pending Thai text first
            commitPendingThaiText()

            // Then insert the character normally
            keyboardContext.textDocumentProxy.insertText(char)
        }
    }

    private func handleSpace() {
        if !engine.composedBuffer.isEmpty {
            // Delete the romanization from document
            for _ in 0..<bufferLength {
                keyboardContext.textDocumentProxy.deleteBackward()
            }
            bufferLength = 0

            // Commit first Thai candidate if available
            if let candidate = engine.getFirstCandidate() {
                keyboardContext.textDocumentProxy.insertText(candidate)
            } else {
                // No candidates, output romanization as English
                keyboardContext.textDocumentProxy.insertText(engine.composedBuffer)
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
        if !engine.composedBuffer.isEmpty {
            // Delete from engine buffer to keep it in sync with document
            engine.deleteCharacter()
            bufferLength -= 1
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
        } else {
            keyboardContext.textDocumentProxy.insertText(engine.composedBuffer)
        }

        engine.clearBuffer()
    }
}
