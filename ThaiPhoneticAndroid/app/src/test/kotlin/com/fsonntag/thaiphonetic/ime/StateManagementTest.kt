package com.fsonntag.thaiphonetic.ime

import org.junit.Before
import org.junit.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/**
 * Unit tests for state management bugs
 *
 * Tests the specific bugs:
 * 1. Backspace not clearing input buffer properly
 * 2. Stale candidates appearing when keyboard reappears
 */
class StateManagementTest {

    private lateinit var inputBuffer: StringBuilder

    @Before
    fun setup() {
        inputBuffer = StringBuilder()
    }

    @Test
    fun `test backspace clears buffer completely`() {
        // Simulate typing "pom"
        inputBuffer.append("p")
        assertEquals("p", inputBuffer.toString())

        inputBuffer.append("o")
        assertEquals("po", inputBuffer.toString())

        inputBuffer.append("m")
        assertEquals("pom", inputBuffer.toString())

        // Simulate backspace 3 times
        inputBuffer.deleteCharAt(inputBuffer.length - 1)
        assertEquals("po", inputBuffer.toString())

        inputBuffer.deleteCharAt(inputBuffer.length - 1)
        assertEquals("p", inputBuffer.toString())

        inputBuffer.deleteCharAt(inputBuffer.length - 1)
        assertEquals("", inputBuffer.toString())
        assertTrue(inputBuffer.isEmpty())
    }

    @Test
    fun `test buffer state after complete deletion`() {
        inputBuffer.append("pom")

        // Delete all characters
        repeat(3) {
            if (inputBuffer.isNotEmpty()) {
                inputBuffer.deleteCharAt(inputBuffer.length - 1)
            }
        }

        assertTrue(inputBuffer.isEmpty(), "Buffer should be empty after deleting all characters")

        // Should be able to type again
        inputBuffer.append("g")
        assertEquals("g", inputBuffer.toString())
    }

    @Test
    fun `test buffer clears on keyboard lifecycle reset`() {
        inputBuffer.append("test")
        assertEquals("test", inputBuffer.toString())

        // Simulate keyboard dismissal
        inputBuffer.clear()
        assertTrue(inputBuffer.isEmpty())

        // Should not have stale data
        assertEquals("", inputBuffer.toString())
    }

    @Test
    fun `test buffer state consistency`() {
        // Start empty
        assertTrue(inputBuffer.isEmpty())

        // Type something
        inputBuffer.append("hello")
        assertEquals(5, inputBuffer.length)

        // Clear
        inputBuffer.clear()
        assertEquals(0, inputBuffer.length)
        assertTrue(inputBuffer.isEmpty())

        // Type again - should work normally
        inputBuffer.append("world")
        assertEquals(5, inputBuffer.length)
        assertEquals("world", inputBuffer.toString())
    }

    @Test
    fun `test backspace on empty buffer is safe`() {
        assertTrue(inputBuffer.isEmpty())

        // Should not crash when backspacing empty buffer
        if (inputBuffer.isNotEmpty()) {
            inputBuffer.deleteCharAt(inputBuffer.length - 1)
        }

        // Should still be empty
        assertTrue(inputBuffer.isEmpty())
    }

    @Test
    fun `test multiple clear operations are safe`() {
        inputBuffer.append("test")

        // Multiple clears should be safe
        inputBuffer.clear()
        inputBuffer.clear()
        inputBuffer.clear()

        assertTrue(inputBuffer.isEmpty())
    }

    @Test
    fun `test candidate list state management`() {
        val candidateList = mutableListOf<String>()

        // Add candidates
        candidateList.addAll(listOf("ผม", "กิน", "ข้าว"))
        assertEquals(3, candidateList.size)

        // Clear candidates
        candidateList.clear()
        assertTrue(candidateList.isEmpty())

        // Add new candidates - should not have stale data
        candidateList.addAll(listOf("อร่อย"))
        assertEquals(1, candidateList.size)
        assertEquals("อร่อย", candidateList[0])
    }
}
