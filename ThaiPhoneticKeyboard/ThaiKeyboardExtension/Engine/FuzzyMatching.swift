//
//  FuzzyMatching.swift
//  Thai Phonetic Keyboard
//
//  Fuzzy matching logic for Thai romanization variants
//  Ported from macOS implementation
//

import Foundation

struct FuzzyMatching {
    /// Generate common vowel variations for a romanization at runtime.
    /// This replicates the Python logic from vowel_variants_backup.py
    ///
    /// Examples:
    ///     - sawatdi → sawatdee, sawasdee, sawasdi, sawadee
    ///     - aroi → aloi, aroy
    static func generateFuzzyVariants(_ roman: String) -> [String] {
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

        // Pattern 8: b ↔ p (common phonetic confusion, especially word-final)
        // Examples: krab ↔ krap (ครับ), tob ↔ top
        // This handles cases where users type phonetically vs. spelling-based romanization
        if roman.contains("b") {
            variants.insert(roman.replacingOccurrences(of: "b", with: "p"))
        }
        if roman.contains("p") {
            variants.insert(roman.replacingOccurrences(of: "p", with: "b"))
        }

        // Remove any empty or single-char variants
        return Array(variants.filter { $0.count >= 2 })
    }
}
