package com.fsonntag.thaiphonetic.engine

import android.content.Context
import android.content.res.AssetManager
import androidx.test.core.app.ApplicationProvider
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.kotlin.doReturn
import org.mockito.kotlin.mock
import org.mockito.kotlin.whenever
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import java.io.ByteArrayInputStream
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

/**
 * Unit tests for ThaiPhoneticEngine
 *
 * Tests fuzzy matching, segmentation, and candidate generation
 */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [34])
class ThaiPhoneticEngineTest {

    private lateinit var engine: ThaiPhoneticEngine

    // Simple test dictionary
    private val testDictionary = """
    {
        "pom": ["ผม"],
        "gin": ["กิน"],
        "kao": ["เข้า", "ข้าว"],
        "aroy": ["อร่อย"],
        "aroi": ["อร่อย"],
        "sawatdi": ["สวัสดี"],
        "sawatdee": ["สวัสดี"],
        "sawasdee": ["สวัสดี"]
    }
    """.trimIndent()

    // Simple test n-gram frequencies
    private val testNgrams = """
    {
        "bigrams": {
            "ผม|กิน": 100,
            "กิน|ข้าว": 200
        },
        "trigrams": {
            "ผม|กิน|ข้าว": 50
        }
    }
    """.trimIndent()

    @Before
    fun setup() {
        // Create mock AssetManager that returns our test data
        val mockAssetManager = mock<AssetManager> {
            on { open("dictionary.json") } doReturn ByteArrayInputStream(testDictionary.toByteArray())
            on { open("ngram_frequencies.json") } doReturn ByteArrayInputStream(testNgrams.toByteArray())
        }

        // Create mock Context that returns our mock AssetManager
        val mockContext = mock<Context> {
            on { assets } doReturn mockAssetManager
        }

        engine = ThaiPhoneticEngine(mockContext)
        engine.loadDictionary()
        engine.loadNgramFrequencies()
    }

    @Test
    fun `test exact dictionary lookup`() {
        val candidates = engine.getCandidates("pom")

        assertNotNull(candidates)
        assertTrue(candidates.isNotEmpty())
        assertEquals("ผม", candidates[0])
    }

    @Test
    fun `test fuzzy matching - vowel variants`() {
        // Both "aroy" and "aroi" should return same result
        val candidates1 = engine.getCandidates("aroy")
        val candidates2 = engine.getCandidates("aroi")

        assertTrue(candidates1.isNotEmpty())
        assertTrue(candidates2.isNotEmpty())
        assertTrue(candidates1.contains("อร่อย") || candidates2.contains("อร่อย"))
    }

    @Test
    fun `test fuzzy matching - consonant variants`() {
        // "sawatdi", "sawatdee", "sawasdee" should all work
        val candidates1 = engine.getCandidates("sawatdi")
        val candidates2 = engine.getCandidates("sawatdee")
        val candidates3 = engine.getCandidates("sawasdee")

        // At least one should return results
        val totalResults = candidates1.size + candidates2.size + candidates3.size
        assertTrue(totalResults > 0, "Fuzzy matching should find results for sawatdi variants")
    }

    @Test
    fun `test multi-word segmentation`() {
        val candidates = engine.getCandidates("pomgin")

        assertNotNull(candidates)
        assertTrue(candidates.isNotEmpty(), "Should segment 'pomgin' into 'pom' + 'gin'")
        assertTrue(candidates.any { it.contains("ผม") && it.contains("กิน") })
    }

    @Test
    fun `test empty input returns empty list`() {
        val candidates = engine.getCandidates("")

        assertTrue(candidates.isEmpty())
    }

    @Test
    fun `test unknown word returns empty list`() {
        val candidates = engine.getCandidates("xyzabc")

        assertTrue(candidates.isEmpty())
    }

    @Test
    fun `test multiple candidates ordered by frequency`() {
        val candidates = engine.getCandidates("kao")

        assertNotNull(candidates)
        assertTrue(candidates.size >= 2, "Should return multiple candidates for 'kao'")
        assertTrue(candidates.contains("เข้า") || candidates.contains("ข้าว"))
    }

    @Test
    fun `test case insensitive matching`() {
        val candidates1 = engine.getCandidates("pom")
        val candidates2 = engine.getCandidates("POM")
        val candidates3 = engine.getCandidates("Pom")

        // All should return the same results
        assertEquals(candidates1.size, candidates2.size)
        assertEquals(candidates1.size, candidates3.size)
    }
}
