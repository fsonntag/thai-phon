package com.fsonntag.thaiphonetic.engine

import org.junit.Test
import kotlin.test.assertTrue

/**
 * Unit tests for fuzzy matching logic
 *
 * Tests the fuzzy variant generation without needing Android context
 */
class FuzzyMatchingTest {

    /**
     * Helper function that replicates the fuzzy matching logic
     * This is extracted to be testable without Android dependencies
     */
    private fun generateFuzzyVariants(roman: String): Set<String> {
        val variants = mutableSetOf(roman)

        // Pattern 1: Final 'i' ↔ 'ee'
        if (roman.endsWith("i")) {
            variants.add(roman.dropLast(1) + "ee")
        }
        if (roman.endsWith("ee")) {
            variants.add(roman.dropLast(2) + "i")
        }

        // Pattern 2: Final 'y' ↔ 'i' ↔ 'ee'
        if (roman.endsWith("y")) {
            variants.add(roman.dropLast(1) + "i")
            variants.add(roman.dropLast(1) + "ee")
        }
        if (roman.endsWith("i") && roman.length > 2) {
            variants.add(roman.dropLast(1) + "y")
        }
        if (roman.endsWith("ee") && roman.length > 3) {
            variants.add(roman.dropLast(2) + "y")
        }

        // Pattern 3: 't' ↔ 's'
        if (roman.contains("t")) {
            variants.add(roman.replace("t", "s"))
        }
        if (roman.contains("s")) {
            variants.add(roman.replace("s", "t"))
        }

        // Pattern 4: 't' ↔ 'd'
        if (roman.contains("t")) {
            variants.add(roman.replace("t", "d"))
        }
        if (roman.contains("d")) {
            variants.add(roman.replace("d", "t"))
        }

        // Pattern 8: b ↔ p (common phonetic confusion, especially word-final)
        // Examples: krab ↔ krap (ครับ), tob ↔ top
        if (roman.contains("b")) {
            variants.add(roman.replace("b", "p"))
        }
        if (roman.contains("p")) {
            variants.add(roman.replace("p", "b"))
        }

        return variants.filter { it.length >= 2 }.toSet()
    }

    @Test
    fun `test final i to ee conversion`() {
        val variants = generateFuzzyVariants("sawatdi")

        assertTrue(variants.contains("sawatdee"), "Should convert final 'i' to 'ee'")
    }

    @Test
    fun `test final ee to i conversion`() {
        val variants = generateFuzzyVariants("sawatdee")

        assertTrue(variants.contains("sawatdi"), "Should convert final 'ee' to 'i'")
    }

    @Test
    fun `test y to i conversion`() {
        val variants = generateFuzzyVariants("aroy")

        assertTrue(variants.contains("aroi"), "Should convert final 'y' to 'i'")
        assertTrue(variants.contains("aroee"), "Should convert final 'y' to 'ee'")
    }

    @Test
    fun `test t to s conversion`() {
        val variants = generateFuzzyVariants("sawatdi")

        assertTrue(variants.contains("sawasdi"), "Should convert 't' to 's'")
    }

    @Test
    fun `test s to t conversion`() {
        val variants = generateFuzzyVariants("sawasdi")

        // When "sawasdi" has replace("s", "t"), it replaces ALL 's' chars to 't'
        // So we get "tawatdi" not "sawatdi"
        assertTrue(variants.contains("tawatdi"), "Should convert 's' to 't'")
    }

    @Test
    fun `test t to d conversion`() {
        val variants = generateFuzzyVariants("sawatdi")

        assertTrue(variants.contains("sawaddi"), "Should convert 't' to 'd'")
    }

    @Test
    fun `test combined transformations`() {
        val variants = generateFuzzyVariants("sawatdi")

        // Should have multiple variants
        assertTrue(variants.size > 1, "Should generate multiple fuzzy variants")

        // Check for specific expected variants
        assertTrue(
            variants.contains("sawatdee") ||
                    variants.contains("sawasdi") ||
                    variants.contains("sawaddi"),
            "Should contain at least one fuzzy variant"
        )
    }

    @Test
    fun `test bidirectional matching`() {
        val variants1 = generateFuzzyVariants("sawatdi")
        val variants2 = generateFuzzyVariants("sawatdee")

        // Both should generate "sawatdi" and "sawatdee"
        val common = variants1.intersect(variants2)

        assertTrue(common.isNotEmpty(), "Should have common variants between sawatdi and sawatdee")
    }

    @Test
    fun `test minimum length requirement`() {
        val variants = generateFuzzyVariants("a")

        // Single character should not generate variants (minimum length is 2)
        assertTrue(variants.all { it.length >= 2 }, "All variants should have minimum length of 2")
    }

    @Test
    fun `test b to p conversion for krab`() {
        val variants = generateFuzzyVariants("krab")

        assertTrue(variants.contains("krap"), "Should convert 'b' to 'p' (krab → krap for ครับ)")
        assertTrue(variants.contains("krab"), "Should keep original 'krab'")
    }

    @Test
    fun `test p to b conversion for krap`() {
        val variants = generateFuzzyVariants("krap")

        assertTrue(variants.contains("krab"), "Should convert 'p' to 'b' (krap → krab)")
        assertTrue(variants.contains("krap"), "Should keep original 'krap'")
    }

    @Test
    fun `test b to p word-final`() {
        val variants = generateFuzzyVariants("tob")

        assertTrue(variants.contains("top"), "Should convert word-final 'b' to 'p'")
    }

    @Test
    fun `test b to p word-initial`() {
        val variants = generateFuzzyVariants("bai")

        assertTrue(variants.contains("pai"), "Should convert word-initial 'b' to 'p'")
    }
}
