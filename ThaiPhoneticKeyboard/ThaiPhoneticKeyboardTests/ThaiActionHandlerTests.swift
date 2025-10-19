//
//  ThaiActionHandlerTests.swift
//  Thai Phonetic Keyboard Tests
//
//  Integration tests for Thai action handler with document proxy
//

import Testing
import Foundation
import UIKit

// Mock text document proxy for testing
class MockTextDocumentProxy: NSObject, UITextDocumentProxy {
    var documentText = ""

    // UITextDocumentProxy properties
    var documentContextBeforeInput: String? {
        return documentText.isEmpty ? nil : documentText
    }

    var documentContextAfterInput: String? {
        return nil
    }

    var selectedText: String? {
        return nil
    }

    var documentInputMode: UITextInputMode? {
        return nil
    }

    var documentIdentifier: UUID {
        return UUID()
    }

    // UIKeyInput protocol requirements
    var hasText: Bool {
        return !documentText.isEmpty
    }

    var autocapitalizationType: UITextAutocapitalizationType {
        get { return .none }
        set {}
    }

    var autocorrectionType: UITextAutocorrectionType {
        get { return .no }
        set {}
    }

    var keyboardType: UIKeyboardType {
        get { return .default }
        set {}
    }

    var keyboardAppearance: UIKeyboardAppearance {
        get { return .default }
        set {}
    }

    var returnKeyType: UIReturnKeyType {
        get { return .default }
        set {}
    }

    var enablesReturnKeyAutomatically: Bool {
        get { return false }
        set {}
    }

    var isSecureTextEntry: Bool {
        get { return false }
        set {}
    }

    var textContentType: UITextContentType! {
        get { return nil }
        set {}
    }

    // UITextDocumentProxy methods
    func adjustTextPosition(byCharacterOffset offset: Int) {}

    func setMarkedText(_ markedText: String, selectedRange: NSRange) {}

    func unmarkText() {}

    // UIKeyInput methods
    func insertText(_ text: String) {
        documentText.append(text)
    }

    func deleteBackward() {
        if !documentText.isEmpty {
            documentText.removeLast()
        }
    }
}

@Suite("Thai Action Handler Integration Tests")
struct ThaiActionHandlerTests {

    // Helper to simulate typing and verify buffer/document sync
    func simulateTyping(_ text: String, engine: ThaiPhoneticEngine, proxy: MockTextDocumentProxy, bufferLength: inout Int) {
        for char in text {
            engine.appendCharacter(String(char))
            proxy.insertText(String(char))
            bufferLength += 1
        }
    }

    // Helper to simulate backspace and verify buffer/document sync
    func simulateBackspace(engine: ThaiPhoneticEngine, proxy: MockTextDocumentProxy, bufferLength: inout Int) {
        if !engine.composedBuffer.isEmpty {
            engine.deleteCharacter()
            proxy.deleteBackward()
            bufferLength -= 1
        }
    }

    @Test("Typing characters keeps buffer and document in sync")
    func typingKeepsBufferAndDocumentInSync() async throws {
        let engine = ThaiPhoneticEngine()
        let proxy = MockTextDocumentProxy()
        var bufferLength = 0

        try await Task.sleep(for: .milliseconds(500))

        // When: User types "por"
        simulateTyping("por", engine: engine, proxy: proxy, bufferLength: &bufferLength)

        // Then: Engine buffer should match document
        #expect(engine.composedBuffer == "por", "Engine buffer should be 'por'")
        #expect(proxy.documentText == "por", "Document should contain 'por'")
        #expect(bufferLength == 3, "Buffer length should be 3")
    }

    @Test("Single backspace removes one character from buffer and document")
    func singleBackspaceRemovesOneCharacter() async throws {
        let engine = ThaiPhoneticEngine()
        let proxy = MockTextDocumentProxy()
        var bufferLength = 0

        try await Task.sleep(for: .milliseconds(500))

        // Given: User has typed "por"
        simulateTyping("por", engine: engine, proxy: proxy, bufferLength: &bufferLength)

        #expect(engine.composedBuffer == "por")
        #expect(proxy.documentText == "por")
        #expect(bufferLength == 3)

        // When: User presses backspace once
        simulateBackspace(engine: engine, proxy: proxy, bufferLength: &bufferLength)

        // Then: Both should have "po"
        #expect(engine.composedBuffer == "po", "Engine buffer should be 'po' after backspace")
        #expect(proxy.documentText == "po", "Document should contain 'po' after backspace")
        #expect(bufferLength == 2, "Buffer length should be 2")
    }

    @Test("Multiple backspaces keep buffer and document in sync")
    func multipleBackspacesKeepInSync() async throws {
        let engine = ThaiPhoneticEngine()
        let proxy = MockTextDocumentProxy()
        var bufferLength = 0

        try await Task.sleep(for: .milliseconds(500))

        // Given: User has typed "sawat"
        simulateTyping("sawat", engine: engine, proxy: proxy, bufferLength: &bufferLength)

        #expect(engine.composedBuffer == "sawat")
        #expect(proxy.documentText == "sawat")

        // When: User presses backspace twice
        simulateBackspace(engine: engine, proxy: proxy, bufferLength: &bufferLength)

        #expect(engine.composedBuffer == "sawa", "Buffer should be 'sawa' after first backspace")
        #expect(proxy.documentText == "sawa", "Document should be 'sawa' after first backspace")

        simulateBackspace(engine: engine, proxy: proxy, bufferLength: &bufferLength)

        // Then: Both should have "saw"
        #expect(engine.composedBuffer == "saw", "Buffer should be 'saw' after second backspace")
        #expect(proxy.documentText == "saw", "Document should be 'saw' after second backspace")
        #expect(bufferLength == 3, "Buffer length should be 3")
    }

    @Test("Backspace until empty clears both buffer and document")
    func backspaceUntilEmptyClearsBoth() async throws {
        let engine = ThaiPhoneticEngine()
        let proxy = MockTextDocumentProxy()
        var bufferLength = 0

        try await Task.sleep(for: .milliseconds(500))

        // Given: User has typed "hi"
        simulateTyping("hi", engine: engine, proxy: proxy, bufferLength: &bufferLength)

        #expect(engine.composedBuffer == "hi")
        #expect(proxy.documentText == "hi")

        // When: User deletes all characters
        simulateBackspace(engine: engine, proxy: proxy, bufferLength: &bufferLength)
        simulateBackspace(engine: engine, proxy: proxy, bufferLength: &bufferLength)

        // Then: Both should be empty
        #expect(engine.composedBuffer.isEmpty, "Engine buffer should be empty")
        #expect(proxy.documentText.isEmpty, "Document should be empty")
        #expect(bufferLength == 0, "Buffer length should be 0")
    }

    @Test("Mixed typing and backspace maintains sync")
    func mixedTypingAndBackspaceMaintainsSync() async throws {
        let engine = ThaiPhoneticEngine()
        let proxy = MockTextDocumentProxy()
        var bufferLength = 0

        try await Task.sleep(for: .milliseconds(500))

        // Type "abc"
        simulateTyping("abc", engine: engine, proxy: proxy, bufferLength: &bufferLength)
        #expect(engine.composedBuffer == "abc")
        #expect(proxy.documentText == "abc")

        // Delete one
        simulateBackspace(engine: engine, proxy: proxy, bufferLength: &bufferLength)
        #expect(engine.composedBuffer == "ab")
        #expect(proxy.documentText == "ab")

        // Type "cd"
        simulateTyping("cd", engine: engine, proxy: proxy, bufferLength: &bufferLength)
        #expect(engine.composedBuffer == "abcd")
        #expect(proxy.documentText == "abcd")

        // Delete two
        simulateBackspace(engine: engine, proxy: proxy, bufferLength: &bufferLength)
        simulateBackspace(engine: engine, proxy: proxy, bufferLength: &bufferLength)
        #expect(engine.composedBuffer == "ab")
        #expect(proxy.documentText == "ab")
        #expect(bufferLength == 2)
    }

    @Test("Buffer length tracking remains accurate")
    func bufferLengthTrackingIsAccurate() async throws {
        let engine = ThaiPhoneticEngine()
        let proxy = MockTextDocumentProxy()
        var bufferLength = 0

        try await Task.sleep(for: .milliseconds(500))

        // Type some characters
        simulateTyping("test", engine: engine, proxy: proxy, bufferLength: &bufferLength)
        #expect(bufferLength == engine.composedBuffer.count, "Buffer length should match buffer count")
        #expect(bufferLength == proxy.documentText.count, "Buffer length should match document length")

        // Delete some
        simulateBackspace(engine: engine, proxy: proxy, bufferLength: &bufferLength)
        simulateBackspace(engine: engine, proxy: proxy, bufferLength: &bufferLength)
        #expect(bufferLength == engine.composedBuffer.count, "Buffer length should match buffer count after deletion")
        #expect(bufferLength == proxy.documentText.count, "Buffer length should match document length after deletion")

        // Type more
        simulateTyping("ing", engine: engine, proxy: proxy, bufferLength: &bufferLength)
        #expect(bufferLength == engine.composedBuffer.count, "Buffer length should match buffer count after more typing")
        #expect(bufferLength == proxy.documentText.count, "Buffer length should match document length after more typing")
    }

    @Test("Typing with existing document content maintains correct buffer tracking")
    func typingWithExistingDocumentContent() async throws {
        let engine = ThaiPhoneticEngine()
        let proxy = MockTextDocumentProxy()
        var bufferLength = 0

        try await Task.sleep(for: .milliseconds(500))

        // Given: Document already has "P" (from previous input)
        proxy.documentText = "P"

        // When: User types "por" (so document becomes "Ppor")
        simulateTyping("por", engine: engine, proxy: proxy, bufferLength: &bufferLength)

        // Then: Engine buffer should only have "por"
        #expect(engine.composedBuffer == "por", "Engine buffer should be 'por'")

        // And: Document should have "Ppor"
        #expect(proxy.documentText == "Ppor", "Document should contain 'Ppor'")

        // And: Buffer length should only track the romanization ("por" = 3)
        #expect(bufferLength == 3, "Buffer length should be 3 (only tracking 'por')")

        // And: Buffer length should NOT equal document length
        #expect(bufferLength != proxy.documentText.count, "Buffer length should not equal document length when there's existing text")
    }

    @Test("Backspace with existing document content only deletes from buffer")
    func backspaceWithExistingDocumentContent() async throws {
        let engine = ThaiPhoneticEngine()
        let proxy = MockTextDocumentProxy()
        var bufferLength = 0

        try await Task.sleep(for: .milliseconds(500))

        // Given: Document has "P", then user types "por"
        proxy.documentText = "P"
        simulateTyping("por", engine: engine, proxy: proxy, bufferLength: &bufferLength)

        #expect(engine.composedBuffer == "por")
        #expect(proxy.documentText == "Ppor")
        #expect(bufferLength == 3)

        // When: User presses backspace once
        simulateBackspace(engine: engine, proxy: proxy, bufferLength: &bufferLength)

        // Then: Engine buffer should have "po"
        #expect(engine.composedBuffer == "po", "Engine buffer should be 'po'")

        // And: Document should have "Ppo" (only deleted from the romanization part)
        #expect(proxy.documentText == "Ppo", "Document should be 'Ppo'")

        // And: Buffer length should be 2
        #expect(bufferLength == 2, "Buffer length should be 2")

        // When: User deletes all romanization
        simulateBackspace(engine: engine, proxy: proxy, bufferLength: &bufferLength)
        simulateBackspace(engine: engine, proxy: proxy, bufferLength: &bufferLength)

        // Then: Engine buffer should be empty
        #expect(engine.composedBuffer.isEmpty, "Engine buffer should be empty")

        // And: Document should still have "P" (the original text)
        #expect(proxy.documentText == "P", "Document should still have 'P'")

        // And: Buffer length should be 0
        #expect(bufferLength == 0, "Buffer length should be 0")
    }

    @Test("Complex scenario: existing text, typing, backspace, more typing")
    func complexScenarioWithExistingText() async throws {
        let engine = ThaiPhoneticEngine()
        let proxy = MockTextDocumentProxy()
        var bufferLength = 0

        try await Task.sleep(for: .milliseconds(500))

        // Start with "Hello " in document
        proxy.documentText = "Hello "

        // Type "sa"
        simulateTyping("sa", engine: engine, proxy: proxy, bufferLength: &bufferLength)
        #expect(engine.composedBuffer == "sa")
        #expect(proxy.documentText == "Hello sa")
        #expect(bufferLength == 2)

        // Delete one
        simulateBackspace(engine: engine, proxy: proxy, bufferLength: &bufferLength)
        #expect(engine.composedBuffer == "s")
        #expect(proxy.documentText == "Hello s")
        #expect(bufferLength == 1)

        // Type "awat"
        simulateTyping("awat", engine: engine, proxy: proxy, bufferLength: &bufferLength)
        #expect(engine.composedBuffer == "sawat")
        #expect(proxy.documentText == "Hello sawat")
        #expect(bufferLength == 5)

        // Delete all romanization
        for _ in 0..<5 {
            simulateBackspace(engine: engine, proxy: proxy, bufferLength: &bufferLength)
        }
        #expect(engine.composedBuffer.isEmpty)
        #expect(proxy.documentText == "Hello ")
        #expect(bufferLength == 0)
    }
}
