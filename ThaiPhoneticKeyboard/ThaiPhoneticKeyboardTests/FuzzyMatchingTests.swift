//
//  FuzzyMatchingTests.swift
//  Thai Phonetic Keyboard Tests
//
//  Unit tests for fuzzy matching logic
//

import Testing
import Foundation

@Suite("Fuzzy Matching Tests")
struct FuzzyMatchingTests {

    @Test("krab should generate krap variant for ครับ")
    func krabToKrap() {
        let variants = FuzzyMatching.generateFuzzyVariants("krab")

        #expect(variants.contains("krap"), "Should convert 'b' to 'p' (krab → krap for ครับ)")
        #expect(variants.contains("krab"), "Should keep original 'krab'")
    }

    @Test("krap should generate krab variant")
    func krapToKrab() {
        let variants = FuzzyMatching.generateFuzzyVariants("krap")

        #expect(variants.contains("krab"), "Should convert 'p' to 'b' (krap → krab)")
        #expect(variants.contains("krap"), "Should keep original 'krap'")
    }

    @Test("b to p conversion at word-final")
    func wordFinalBToP() {
        let variants = FuzzyMatching.generateFuzzyVariants("tob")

        #expect(variants.contains("top"), "Should convert word-final 'b' to 'p'")
    }

    @Test("b to p conversion at word-initial")
    func wordInitialBToP() {
        let variants = FuzzyMatching.generateFuzzyVariants("bai")

        #expect(variants.contains("pai"), "Should convert word-initial 'b' to 'p'")
    }

    @Test("Final i to ee conversion")
    func finalIToEE() {
        let variants = FuzzyMatching.generateFuzzyVariants("sawatdi")

        #expect(variants.contains("sawatdee"), "Should convert final 'i' to 'ee'")
    }

    @Test("Final ee to i conversion")
    func finalEEToI() {
        let variants = FuzzyMatching.generateFuzzyVariants("sawatdee")

        #expect(variants.contains("sawatdi"), "Should convert final 'ee' to 'i'")
    }

    @Test("t to s conversion")
    func tToS() {
        let variants = FuzzyMatching.generateFuzzyVariants("sawatdi")

        #expect(variants.contains("sawasdi"), "Should convert 't' to 's'")
    }

    @Test("t to d conversion")
    func tToD() {
        let variants = FuzzyMatching.generateFuzzyVariants("sawatdi")

        #expect(variants.contains("sawaddi"), "Should convert 't' to 'd'")
    }

    @Test("Bidirectional matching")
    func bidirectional() {
        let variants1 = FuzzyMatching.generateFuzzyVariants("sawatdi")
        let variants2 = FuzzyMatching.generateFuzzyVariants("sawatdee")

        let common = Set(variants1).intersection(Set(variants2))

        #expect(!common.isEmpty, "Should have common variants between sawatdi and sawatdee")
    }

    @Test("Minimum length requirement")
    func minimumLength() {
        let variants = FuzzyMatching.generateFuzzyVariants("a")

        #expect(variants.allSatisfy { $0.count >= 2 }, "All variants should have minimum length of 2")
    }
}
