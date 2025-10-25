import Foundation

// MARK: - Copy of generateFuzzyVariants for testing
// This should match the implementation in ThaiPhoneticIMController.swift

func generateFuzzyVariants(_ roman: String) -> [String] {
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
    return variants.filter { $0.count >= 2 }
}

// MARK: - Test Cases

struct TestCase {
    let input: String
    let expectedContains: [String]
    let description: String
}

let testCases = [
    // Long vowel tests (critical for Thai phonetics)
    TestCase(input: "yaak", expectedContains: ["yak", "yaak"], description: "Long vowel aa → a (อยาก)"),
    TestCase(input: "yak", expectedContains: ["yak", "yaak"], description: "Short vowel a → aa"),
    TestCase(input: "aroi", expectedContains: ["aroi", "aroy", "aroee"], description: "Final i/y variants (อร่อย)"),
    TestCase(input: "pood", expectedContains: ["pood", "pod"], description: "Long vowel oo → o (พูด)"),
    TestCase(input: "koon", expectedContains: ["koon", "kon"], description: "Long vowel oo → o (คุณ)"),

    // Paiboon variants
    TestCase(input: "gin", expectedContains: ["gin"], description: "Paiboon gin (กิน)"),
    TestCase(input: "pom", expectedContains: ["pom"], description: "Paiboon pom (ผม)"),

    // Vowel ending variants
    // Note: Fuzzy matching generates variants within one step, not full combinatorial
    TestCase(input: "sawasdee", expectedContains: ["sawasdee", "sawasdi"], description: "สวัสดี s-variants"),
    TestCase(input: "sawatdee", expectedContains: ["sawatdee", "sawatdi", "sawadee", "sawadi"], description: "สวัสดี t-variants"),
    TestCase(input: "sawadee", expectedContains: ["sawadee", "sawadi"], description: "สวัสดี d-variants"),

    // t/d confusion
    TestCase(input: "tid", expectedContains: ["tid", "sid", "did"], description: "t/s/d confusion"),

    // NEW: b/p confusion (Pattern 8)
    TestCase(input: "krab", expectedContains: ["krab", "krap"], description: "b→p phonetic variant (ครับ)"),
    TestCase(input: "krap", expectedContains: ["krap", "krab"], description: "p→b phonetic variant"),
    TestCase(input: "tob", expectedContains: ["tob", "top"], description: "b→p word-final"),
    TestCase(input: "bai", expectedContains: ["bai", "pai"], description: "b→p word-initial"),
]

// MARK: - Run Tests

print("Running Fuzzy Matching Tests")
print(String(repeating: "=", count: 60))

var passed = 0
var failed = 0

for testCase in testCases {
    let variants = generateFuzzyVariants(testCase.input)
    var allFound = true
    var missing: [String] = []

    for expected in testCase.expectedContains {
        if !variants.contains(expected) {
            allFound = false
            missing.append(expected)
        }
    }

    if allFound {
        print("✓ PASS: \(testCase.description)")
        print("  Input: \(testCase.input)")
        print("  Generated: \(variants.sorted())")
        passed += 1
    } else {
        print("✗ FAIL: \(testCase.description)")
        print("  Input: \(testCase.input)")
        print("  Expected to contain: \(testCase.expectedContains)")
        print("  Missing: \(missing)")
        print("  Generated: \(variants.sorted())")
        failed += 1
    }
    print("")
}

print(String(repeating: "=", count: 60))
print("Results: \(passed) passed, \(failed) failed")

if failed > 0 {
    exit(1)
}
