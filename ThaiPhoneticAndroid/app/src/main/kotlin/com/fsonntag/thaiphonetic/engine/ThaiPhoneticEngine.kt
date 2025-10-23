package com.fsonntag.thaiphonetic.engine

import android.content.Context
import android.util.Log
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonPrimitive
import java.io.BufferedReader
import java.io.InputStreamReader

/**
 * Thai Phonetic Transformation Engine
 *
 * Ported from Swift implementation (ThaiPhoneticIMController.swift).
 * Handles:
 * - Loading dictionary (romanization → Thai words)
 * - Loading n-gram frequencies (bigrams, trigrams)
 * - Fuzzy matching (vowel/consonant variants)
 * - Multi-word segmentation
 * - Candidate generation and ranking
 */
class ThaiPhoneticEngine(private val context: Context) {

    companion object {
        private const val TAG = "ThaiPhoneticEngine"
        private const val MAX_WORD_LENGTH = 15
        private const val MAX_PER_POSITION = 3
        private const val MAX_COMBINATIONS = 50
    }

    // Dictionary: romanization -> list of Thai words
    private val dictionary = mutableMapOf<String, List<String>>()

    // N-gram frequencies for ranking
    private val bigramFrequencies = mutableMapOf<String, Int>()
    private val trigramFrequencies = mutableMapOf<String, Int>()

    /**
     * Load dictionary from assets/dictionary.json
     * Format: { "romanization": ["thai_word1", "thai_word2", ...], ... }
     */
    fun loadDictionary() {
        try {
            val inputStream = context.assets.open("dictionary.json")
            val reader = BufferedReader(InputStreamReader(inputStream))
            val jsonString = reader.readText()
            reader.close()

            // Parse JSON
            val json = Json.parseToJsonElement(jsonString).jsonObject

            json.forEach { (key, value) ->
                val candidates = value.jsonArray.map { it.jsonPrimitive.content }
                dictionary[key] = candidates
            }

            Log.d(TAG, "Loaded dictionary with ${dictionary.size} entries")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to load dictionary", e)
        }
    }

    /**
     * Load n-gram frequencies from assets/ngram_frequencies.json
     * Format: { "bigrams": {...}, "trigrams": {...} }
     */
    fun loadNgramFrequencies() {
        try {
            val inputStream = context.assets.open("ngram_frequencies.json")
            val reader = BufferedReader(InputStreamReader(inputStream))
            val jsonString = reader.readText()
            reader.close()

            // Parse JSON
            val json = Json.parseToJsonElement(jsonString).jsonObject

            // Load bigrams
            json["bigrams"]?.jsonObject?.forEach { (key, value) ->
                bigramFrequencies[key] = value.jsonPrimitive.content.toInt()
            }

            // Load trigrams
            json["trigrams"]?.jsonObject?.forEach { (key, value) ->
                trigramFrequencies[key] = value.jsonPrimitive.content.toInt()
            }

            Log.d(TAG, "Loaded ${bigramFrequencies.size} bigrams, ${trigramFrequencies.size} trigrams")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to load n-gram frequencies", e)
        }
    }

    /**
     * Get Thai candidates for a given romanization input
     *
     * Main entry point called by the IME.
     * Returns a list of Thai word candidates, ranked by relevance.
     *
     * Ported from Swift ThaiPhoneticIMController.swift:486-531
     */
    fun getCandidates(input: String): List<String> {
        if (input.isEmpty()) {
            return emptyList()
        }

        val lowercaseInput = input.lowercase()

        // Try single-word lookup first (exact match)
        dictionary[lowercaseInput]?.let { candidates ->
            return candidates
        }

        // Try single-word fuzzy matching
        val fuzzyVariants = generateFuzzyVariants(lowercaseInput)
        val singleWordCandidates = mutableListOf<String>()
        val seenWords = mutableSetOf<String>()

        for (variant in fuzzyVariants) {
            dictionary[variant]?.let { candidates ->
                for (candidate in candidates) {
                    if (!seenWords.contains(candidate)) {
                        singleWordCandidates.add(candidate)
                        seenWords.add(candidate)
                    }
                }
            }
        }

        // If single-word lookup found results, use them
        if (singleWordCandidates.isNotEmpty()) {
            return singleWordCandidates
        }

        // Try multi-word segmentation
        greedySegment(lowercaseInput)?.let { segments ->
            val multiWordCandidates = generateMultiWordCandidates(segments)
            if (multiWordCandidates.isNotEmpty()) {
                return multiWordCandidates.take(6) // Max 6 for multi-word
            }
        }

        // No matches found
        return emptyList()
    }

    /**
     * Generate fuzzy variants of a romanization
     *
     * Ported from Swift ThaiPhoneticIMController.swift:373-484
     *
     * Examples:
     *   - sawatdi → sawatdee, sawasdee, sawasdi, sawadee
     *   - aroi → aloi, aroy
     */
    private fun generateFuzzyVariants(roman: String): Set<String> {
        val variants = mutableSetOf(roman)

        // Pattern 1: Final 'i' ↔ 'ee' (sawatdi ↔ sawatdee)
        if (roman.endsWith("i")) {
            variants.add(roman.dropLast(1) + "ee")
        }
        if (roman.endsWith("ee")) {
            variants.add(roman.dropLast(2) + "i")
        }

        // Pattern 2: Final 'y' ↔ 'i' ↔ 'ee' (aroy, aroi, aroee)
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

        // Pattern 3: 't' ↔ 's' (common confusion: sawatdi ↔ sawasdi)
        if (roman.contains("t")) {
            variants.add(roman.replace("t", "s"))
        }
        if (roman.contains("s")) {
            variants.add(roman.replace("s", "t"))
        }

        // Pattern 4: 't' ↔ 'd' (common confusion: sawatdi ↔ sawaddi)
        if (roman.contains("t")) {
            variants.add(roman.replace("t", "d"))
        }
        if (roman.contains("d")) {
            variants.add(roman.replace("d", "t"))
        }

        // Pattern 5: Long vowel doubling - BIDIRECTIONAL (aa ↔ a, oo ↔ o, ee ↔ e)
        // This is critical for cases like "yaak" → "yak" (อยาก)

        // a ↔ aa
        if (roman.contains("aa")) {
            variants.add(roman.replace("aa", "a"))
        } else if (roman.contains("a")) {
            variants.add(roman.replaceFirst("a", "aa"))
        }

        // o ↔ oo
        if (roman.contains("oo")) {
            variants.add(roman.replace("oo", "o"))
        } else if (roman.contains("o")) {
            variants.add(roman.replaceFirst("o", "oo"))
        }

        // e ↔ ee (in addition to i ↔ ee from Pattern 1)
        if (roman.contains("ee") && !roman.endsWith("ee")) {
            variants.add(roman.replace("ee", "e"))
        } else if (roman.contains("e") && !roman.contains("ee")) {
            variants.add(roman.replaceFirst("e", "ee"))
        }

        // Pattern 6: Combined transformations for common cases
        val combinedVariants = variants.flatMap { v ->
            val combined = mutableListOf<String>()
            if (v.endsWith("i")) {
                combined.add(v.dropLast(1) + "ee")
            }
            if (v.endsWith("ee")) {
                combined.add(v.dropLast(2) + "i")
            }
            combined
        }
        variants.addAll(combinedVariants)

        // Pattern 7: Remove 't' before final vowel (sawatdi → sawadi, sawatdee → sawadee)
        val tRemoved = mutableListOf<String>()
        if (roman.contains("tdi")) {
            tRemoved.add(roman.replace("tdi", "di"))
            tRemoved.add(roman.replace("tdi", "dee"))
        }
        if (roman.contains("tdee")) {
            tRemoved.add(roman.replace("tdee", "dee"))
            tRemoved.add(roman.replace("tdee", "di"))
        }
        if (roman.contains("ti") && roman.length > 3) {
            tRemoved.add(roman.replace("ti", "i"))
            tRemoved.add(roman.replace("ti", "ee"))
        }
        if (roman.contains("tee") && roman.length > 4) {
            tRemoved.add(roman.replace("tee", "ee"))
            tRemoved.add(roman.replace("tee", "i"))
        }
        variants.addAll(tRemoved)

        // Remove any empty or single-char variants
        return variants.filter { it.length >= 2 }.toSet()
    }

    /**
     * Segment input into multiple words using greedy longest-match
     *
     * Ported from Swift ThaiPhoneticIMController.swift:200-243
     * Returns array of romanization segments, or null if segmentation fails
     */
    private fun greedySegment(input: String): List<String>? {
        val result = mutableListOf<String>()
        var remaining = input

        while (remaining.isNotEmpty()) {
            var matched = false

            // Try longest matches first
            for (length in minOf(remaining.length, MAX_WORD_LENGTH) downTo 1) {
                val prefix = remaining.substring(0, length)

                // Try exact match first
                if (dictionary.containsKey(prefix)) {
                    result.add(prefix)
                    remaining = remaining.substring(length)
                    matched = true
                    break
                }

                // Try fuzzy match
                val fuzzyVariants = generateFuzzyVariants(prefix)
                for (variant in fuzzyVariants) {
                    if (dictionary.containsKey(variant)) {
                        result.add(prefix) // Store original input, not variant
                        remaining = remaining.substring(length)
                        matched = true
                        break
                    }
                }
                if (matched) break
            }

            // If no match found, segmentation failed
            if (!matched) {
                return null
            }
        }

        return result
    }

    /**
     * Lookup a single segment, trying exact then fuzzy matching
     *
     * Ported from Swift ThaiPhoneticIMController.swift:245-262
     */
    private fun lookupSegment(segment: String): List<String> {
        // Try exact match first
        dictionary[segment]?.let { return it }

        // Try fuzzy matching
        val fuzzyVariants = generateFuzzyVariants(segment)
        for (variant in fuzzyVariants) {
            dictionary[variant]?.let { return it }
        }

        return emptyList()
    }

    /**
     * Score a phrase using n-gram frequencies
     *
     * Ported from Swift ThaiPhoneticIMController.swift:264-301
     * Higher score = more likely phrase
     */
    private fun scorePhrase(words: List<String>): Double {
        if (words.isEmpty()) {
            return 0.0
        }

        if (words.size == 1) {
            // Single word: base score
            return 1000.0
        }

        var score = 1.0

        // Add bigram scores
        for (i in 0 until words.size - 1) {
            val bigramKey = "${words[i]}|${words[i + 1]}"
            val bigramFreq = bigramFrequencies[bigramKey]
            if (bigramFreq != null) {
                score *= bigramFreq.toDouble()
            } else {
                // No bigram data: penalize but don't eliminate
                score *= 0.01
            }
        }

        // Add trigram scores (if available)
        for (i in 0 until words.size - 2) {
            val trigramKey = "${words[i]}|${words[i + 1]}|${words[i + 2]}"
            val trigramFreq = trigramFrequencies[trigramKey]
            if (trigramFreq != null) {
                // Trigrams are less common, so boost them more
                score *= trigramFreq.toDouble() * 10.0
            }
        }

        return score
    }

    /**
     * Generate Thai candidates by joining top matches from each segment
     *
     * Ported from Swift ThaiPhoneticIMController.swift:303-369
     * Returns up to 6 candidates, sorted by n-gram frequency scores
     */
    private fun generateMultiWordCandidates(segments: List<String>): List<String> {
        val candidateSets = mutableListOf<List<String>>()

        // Lookup each segment
        for (segment in segments) {
            val candidates = lookupSegment(segment)
            if (candidates.isEmpty()) {
                return emptyList() // If any segment has no matches, fail
            }
            candidateSets.add(candidates)
        }

        if (candidateSets.size == 1) {
            // Single word, return top candidates
            return candidateSets[0].take(6)
        }

        // Multi-word: generate combinations and score them
        data class ScoredCombination(val phrase: String, val words: List<String>, val score: Double)
        val scoredCombinations = mutableListOf<ScoredCombination>()

        // Generate combinations
        fun generateCombinations(position: Int, currentWords: List<String>, currentPhrase: String) {
            if (position >= candidateSets.size) {
                // Complete combination
                val score = scorePhrase(currentWords)
                scoredCombinations.add(ScoredCombination(currentPhrase, currentWords, score))
                return
            }

            // Try top N candidates for this position
            val candidates = candidateSets[position].take(MAX_PER_POSITION)
            for (candidate in candidates) {
                generateCombinations(
                    position + 1,
                    currentWords + candidate,
                    currentPhrase + candidate
                )

                // Limit total combinations to avoid explosion
                if (scoredCombinations.size >= MAX_COMBINATIONS) {
                    return
                }
            }
        }

        generateCombinations(0, emptyList(), "")

        // Sort by score (descending) and return top 6
        scoredCombinations.sortByDescending { it.score }

        val topCandidates = scoredCombinations.take(6).map { it.phrase }

        // Debug: log scores for top candidates
        if (topCandidates.isNotEmpty()) {
            Log.d(TAG, "Multi-word candidates for ${segments.joinToString("+")}:")
            for ((i, scored) in scoredCombinations.take(6).withIndex()) {
                Log.d(TAG, "  ${i + 1}. ${scored.phrase} [${scored.words.joinToString(" ")}] score: ${scored.score}")
            }
        }

        return topCandidates
    }
}
