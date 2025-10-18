//
//  KeyboardViewController.swift
//  Thai Phonetic Keyboard Extension
//
//  Main keyboard view controller
//

import UIKit
import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "KeyboardViewController")

class KeyboardViewController: UIInputViewController {

    // MARK: - Properties

    private var engine = ThaiPhoneticEngine()
    private var keyboardState = KeyboardState()
    private var keyboardView: UIHostingController<KeyboardLayoutView>?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        logger.info("KeyboardViewController viewDidLoad")

        // Set the preferred keyboard height
        let keyboardHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 320 : 260

        // This is the key: create a height constraint on the inputView itself
        let heightConstraint = NSLayoutConstraint(
            item: view!,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 0.0,
            constant: keyboardHeight
        )
        heightConstraint.priority = .required
        view.addConstraint(heightConstraint)

        setupKeyboardView()
    }

    // MARK: - Setup

    private func setupKeyboardView() {
        // Create SwiftUI keyboard view
        let keyboardLayout = KeyboardLayoutView(
            engine: engine,
            state: keyboardState,
            onKeyTap: { [weak self] key in
                self?.handleKeyTap(key)
            },
            onCandidateTap: { [weak self] candidate in
                self?.handleCandidateTap(candidate)
            },
            onNextKeyboard: { [weak self] in
                self?.handleNextKeyboard()
            }
        )

        // Wrap in UIHostingController
        let hostingController = UIHostingController(rootView: keyboardLayout)
        keyboardView = hostingController

        // Add as child view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)

        // Use constraints to fill parent view
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        hostingController.didMove(toParent: self)

        logger.info("KeyboardViewController setup complete")
    }

    // MARK: - Input Handling

    private func handleKeyTap(_ key: String) {
        logger.debug("Key tapped: \(key)")

        switch key {
        case "delete":
            handleDelete()
        case "space":
            handleSpace()
        case "return":
            handleReturn()
        case "emoji":
            handleEmojiKey()
        case let letter where letter.count == 1 && letter.rangeOfCharacter(from: .letters) != nil:
            handleLetter(letter)
        default:
            // Numbers, punctuation, etc. - insert directly
            textDocumentProxy.insertText(key)
        }

        // Reset shift state after key press
        keyboardState.handleKeyPress()
    }

    private func handleLetter(_ letter: String) {
        let char = keyboardState.isShifted ? letter.uppercased() : letter.lowercased()

        // Add to Thai input buffer
        engine.appendCharacter(char)

        // Don't auto-commit - let user decide when to commit with space
        // Multi-word segmentation will handle cases like "pomg" → "pom" + "g"
    }

    private func handleSpace() {
        if !engine.composedBuffer.isEmpty {
            // Commit first Thai candidate if available
            if let candidate = engine.getFirstCandidate() {
                textDocumentProxy.insertText(candidate)
                engine.clearBuffer()
            } else {
                // No candidates, output romanization as English
                textDocumentProxy.insertText(engine.composedBuffer)
                engine.clearBuffer()
                textDocumentProxy.insertText(" ")
            }
        } else {
            // Normal space
            textDocumentProxy.insertText(" ")
        }
    }

    private func handleDelete() {
        if !engine.composedBuffer.isEmpty {
            // Delete from Thai input buffer
            engine.deleteCharacter()
        } else {
            // Delete from document
            textDocumentProxy.deleteBackward()
        }
    }

    private func handleReturn() {
        if !engine.composedBuffer.isEmpty {
            // Commit buffer as-is (romanization or first candidate)
            if let candidate = engine.getFirstCandidate() {
                textDocumentProxy.insertText(candidate)
            } else {
                textDocumentProxy.insertText(engine.composedBuffer)
            }
            engine.clearBuffer()
        }
        textDocumentProxy.insertText("\n")
    }

    private func handleCandidateTap(_ candidate: String) {
        logger.debug("Candidate tapped: \(candidate)")

        // Insert Thai text
        textDocumentProxy.insertText(candidate)

        // Clear buffer
        engine.clearBuffer()
    }

    private func handleNextKeyboard() {
        logger.debug("Next keyboard requested")
        advanceToNextInputMode()
    }

    private func handleEmojiKey() {
        logger.debug("Emoji keyboard requested")
        // Cycle to next keyboard (including emoji keyboard)
        // Unfortunately, there's no direct API to jump to emoji keyboard specifically
        // without Full Access permission. This will cycle through available keyboards.
        advanceToNextInputMode()
    }

    // MARK: - UIInputViewController Overrides

    override func textWillChange(_ textInput: UITextInput?) {
        // Called when text will change in the document
    }

    override func textDidChange(_ textInput: UITextInput?) {
        // Called when text changed in the document
    }
}
