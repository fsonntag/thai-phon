//
//  ThaiPhoneticEngineTests.swift
//  Thai Phonetic Keyboard Tests
//
//  Unit tests for Thai phonetic input engine using Swift Testing
//

import Testing
import Foundation

// Note: The keyboard extension source files need to be added to the test target.
// This is the standard approach for testing app extensions in Swift.
// Alternative: Create a shared framework, but that adds unnecessary complexity for this project.

@Suite("Thai Phonetic Engine Tests")
struct ThaiPhoneticEngineTests {

    // MARK: - Backspace Tests

    @Test("Backspace deletes single character from buffer")
    func backspaceDeletesSingleCharacter() async throws {
        let engine = ThaiPhoneticEngine()

        // Give dictionary time to load
        try await Task.sleep(for: .milliseconds(500))

        // Given: User types "por"
        engine.appendCharacter("p")
        engine.appendCharacter("o")
        engine.appendCharacter("r")

        #expect(engine.composedBuffer == "por", "Buffer should contain 'por'")

        // When: User presses backspace once
        engine.deleteCharacter()

        // Then: Only 'r' should be deleted
        #expect(engine.composedBuffer == "po", "Buffer should contain 'po' after one backspace")
    }

    @Test("Backspace works correctly multiple times in sequence")
    func backspaceMultipleTimes() async throws {
        let engine = ThaiPhoneticEngine()
        try await Task.sleep(for: .milliseconds(500))

        // Given: User types "sawat"
        engine.appendCharacter("s")
        engine.appendCharacter("a")
        engine.appendCharacter("w")
        engine.appendCharacter("a")
        engine.appendCharacter("t")

        #expect(engine.composedBuffer == "sawat")

        // When: User presses backspace twice
        engine.deleteCharacter()
        #expect(engine.composedBuffer == "sawa", "First backspace should leave 'sawa'")

        engine.deleteCharacter()
        #expect(engine.composedBuffer == "saw", "Second backspace should leave 'saw'")
    }

    @Test("Backspace on empty buffer does nothing")
    func backspaceOnEmptyBuffer() {
        let engine = ThaiPhoneticEngine()

        // Given: Empty buffer
        #expect(engine.composedBuffer.isEmpty)

        // When: User presses backspace
        engine.deleteCharacter()

        // Then: Buffer remains empty
        #expect(engine.composedBuffer.isEmpty, "Backspace on empty buffer should do nothing")
    }

    @Test("Backspace can delete all characters until buffer is empty")
    func backspaceUntilEmpty() {
        let engine = ThaiPhoneticEngine()

        // Given: User types "hi"
        engine.appendCharacter("h")
        engine.appendCharacter("i")

        // When: User presses backspace twice
        engine.deleteCharacter()
        engine.deleteCharacter()

        // Then: Buffer should be empty
        #expect(engine.composedBuffer.isEmpty, "Buffer should be empty after deleting all characters")
    }

    // MARK: - Character Input Tests

    @Test("Single character can be appended to buffer")
    func appendCharacter() {
        let engine = ThaiPhoneticEngine()

        // Given: Empty buffer
        #expect(engine.composedBuffer.isEmpty)

        // When: User types "p"
        engine.appendCharacter("p")

        // Then: Buffer contains "p"
        #expect(engine.composedBuffer == "p")
    }

    @Test("Multiple characters can be appended in sequence")
    func appendMultipleCharacters() {
        let engine = ThaiPhoneticEngine()

        // When: User types "pom"
        engine.appendCharacter("p")
        engine.appendCharacter("o")
        engine.appendCharacter("m")

        // Then: Buffer contains "pom"
        #expect(engine.composedBuffer == "pom")
    }

    @Test("Case is preserved when typing uppercase letters")
    func caseSensitiveInput() {
        let engine = ThaiPhoneticEngine()

        // When: User types "Pom" with capital P
        engine.appendCharacter("P")
        engine.appendCharacter("o")
        engine.appendCharacter("m")

        // Then: Buffer preserves case
        #expect(engine.composedBuffer == "Pom", "Buffer should preserve original case")
    }

    // MARK: - Candidate Tests

    @Test("Candidates are generated for valid Thai romanization")
    func candidatesGeneratedForValidInput() async throws {
        let engine = ThaiPhoneticEngine()
        try await Task.sleep(for: .milliseconds(500))

        // When: User types "pom"
        engine.appendCharacter("p")
        engine.appendCharacter("o")
        engine.appendCharacter("m")

        // Then: Candidates should be generated
        #expect(!engine.currentCandidates.isEmpty, "Candidates should be generated for 'pom'")

        // And: Last candidate should be the romanization
        #expect(engine.currentCandidates.last == "pom", "Last candidate should be the romanization")
    }

    @Test("Romanization is always included as last candidate")
    func candidatesIncludeRomanizationAsLastOption() {
        let engine = ThaiPhoneticEngine()

        // When: User types "xyz" (unlikely to have Thai matches)
        engine.appendCharacter("x")
        engine.appendCharacter("y")
        engine.appendCharacter("z")

        // Then: At least the romanization should be available
        #expect(!engine.currentCandidates.isEmpty)
        #expect(engine.currentCandidates.last == "xyz", "Romanization should always be last candidate")
    }

    @Test("Candidates are cleared when buffer is cleared")
    func candidatesClearedAfterClearBuffer() async throws {
        let engine = ThaiPhoneticEngine()
        try await Task.sleep(for: .milliseconds(500))

        // Given: User has typed something
        engine.appendCharacter("p")
        engine.appendCharacter("o")
        engine.appendCharacter("m")
        #expect(!engine.currentCandidates.isEmpty)

        // When: Buffer is cleared
        engine.clearBuffer()

        // Then: Candidates should also be cleared
        #expect(engine.currentCandidates.isEmpty, "Candidates should be cleared with buffer")
        #expect(engine.composedBuffer.isEmpty, "Buffer should be empty")
    }

    // MARK: - First Candidate Tests

    @Test("First candidate is returned correctly")
    func getFirstCandidateReturnsFirstItem() async throws {
        let engine = ThaiPhoneticEngine()
        try await Task.sleep(for: .milliseconds(500))

        // Given: User types "pom"
        engine.appendCharacter("p")
        engine.appendCharacter("o")
        engine.appendCharacter("m")

        // When: Getting first candidate
        let firstCandidate = engine.getFirstCandidate()

        // Then: Should return the first item
        #expect(firstCandidate != nil)
        #expect(firstCandidate == engine.currentCandidates.first)
    }

    @Test("First candidate returns nil for empty buffer")
    func getFirstCandidateReturnsNilForEmptyBuffer() {
        let engine = ThaiPhoneticEngine()

        // Given: Empty buffer
        #expect(engine.composedBuffer.isEmpty)

        // When: Getting first candidate
        let firstCandidate = engine.getFirstCandidate()

        // Then: Should return nil
        #expect(firstCandidate == nil, "First candidate should be nil for empty buffer")
    }
}
