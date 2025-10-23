package com.fsonntag.thaiphonetic.ime

import android.inputmethodservice.InputMethodService
import android.view.View
import android.view.inputmethod.EditorInfo
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.runtime.mutableStateOf
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.ViewCompositionStrategy
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import androidx.lifecycle.setViewTreeLifecycleOwner
import androidx.savedstate.SavedStateRegistry
import androidx.savedstate.SavedStateRegistryController
import androidx.savedstate.SavedStateRegistryOwner
import androidx.savedstate.setViewTreeSavedStateRegistryOwner
import com.fsonntag.thaiphonetic.engine.ThaiPhoneticEngine
import com.fsonntag.thaiphonetic.ui.CandidateBar
import com.fsonntag.thaiphonetic.ui.KeyboardScreen
import com.fsonntag.thaiphonetic.ui.SymbolKeyboardScreen1
import com.fsonntag.thaiphonetic.ui.SymbolKeyboardScreen2

/**
 * Main Input Method Service for Thai Phonetic Keyboard
 *
 * This is the core of the keyboard implementation. It extends InputMethodService
 * and handles:
 * - Creating keyboard and candidate views
 * - Processing key presses
 * - Managing input state
 * - Coordinating with the Thai phonetic transformation engine
 */
class ThaiPhoneticIME : InputMethodService(), LifecycleOwner, SavedStateRegistryOwner {

    // Phonetic transformation engine (ported from Swift)
    private lateinit var engine: ThaiPhoneticEngine

    // Input buffer (romanization being typed)
    private val inputBuffer = StringBuilder()

    // Compose state for candidates
    private val candidatesState = mutableStateOf<List<String>>(emptyList())

    // Shift state - OFF = lowercase, ONCE = uppercase next only, LOCKED = all uppercase (caps lock)
    enum class ShiftState {
        OFF,      // No shift - lowercase
        ONCE,     // Single tap - uppercase next letter only
        LOCKED    // Long press - caps lock, all uppercase
    }
    private val shiftState = mutableStateOf(ShiftState.OFF)

    // Keyboard mode - switch between letters, symbols layer 1, and symbols layer 2
    enum class KeyboardMode {
        LETTERS,    // Main QWERTY keyboard
        SYMBOLS_1,  // Numbers + common symbols (@#$%...)
        SYMBOLS_2   // Brackets + extended symbols ([]{}<>...)
    }
    private val keyboardModeState = mutableStateOf(KeyboardMode.LETTERS)

    // Lifecycle for Compose
    private val lifecycleRegistry = LifecycleRegistry(this)
    private val savedStateRegistryController = SavedStateRegistryController.create(this)

    override val lifecycle: Lifecycle
        get() = lifecycleRegistry

    override val savedStateRegistry: SavedStateRegistry
        get() = savedStateRegistryController.savedStateRegistry

    override fun onCreate() {
        super.onCreate()        

        // Initialize lifecycle
        savedStateRegistryController.performRestore(null)
        lifecycleRegistry.currentState = Lifecycle.State.CREATED

        // Initialize the phonetic engine
        engine = ThaiPhoneticEngine(this)
        engine.loadDictionary()
        engine.loadNgramFrequencies()
    }

    /**
     * Called when the input view should be created.
     * Returns the keyboard view to be displayed.
     */
    override fun onCreateInputView(): View {

        // Set lifecycle owner on the window's root view to prevent crashes
        window.window?.decorView?.let { decorView ->
            decorView.setViewTreeLifecycleOwner(this)
            decorView.setViewTreeSavedStateRegistryOwner(this)
        }

        // Create the ComposeView and set lifecycle owners BEFORE any composition happens
        val composeView = ComposeView(this)

        // CRITICAL: Set lifecycle owners before the view is attached or composed
        composeView.setViewTreeLifecycleOwner(this@ThaiPhoneticIME)
        composeView.setViewTreeSavedStateRegistryOwner(this@ThaiPhoneticIME)

        // Use DisposeOnDetachedFromWindow strategy
        composeView.setViewCompositionStrategy(ViewCompositionStrategy.DisposeOnDetachedFromWindow)

        composeView.setContent {
            Column(modifier = Modifier.fillMaxWidth()) {
                // Candidate bar at top
                CandidateBar(
                    candidates = candidatesState.value,
                    onCandidateSelected = { candidate ->
                        commitCandidate(candidate)
                    }
                )

                // Keyboard below - switch based on mode
                when (keyboardModeState.value) {
                    KeyboardMode.LETTERS -> KeyboardScreen(
                        shiftState = shiftState.value,
                        onKey = { key -> handleKey(key) },
                        onShiftLongPress = { handleShiftLongPress() },
                        onKeyLongPress = { key, alternate -> handleKeyLongPress(key, alternate) }
                    )
                    KeyboardMode.SYMBOLS_1 -> SymbolKeyboardScreen1(
                        onKey = { key -> handleKey(key) },
                        onKeyLongPress = { key, alternate -> handleKeyLongPress(key, alternate) }
                    )
                    KeyboardMode.SYMBOLS_2 -> SymbolKeyboardScreen2(
                        onKey = { key -> handleKey(key) }
                    )
                }
            }
        }

        return composeView
    }

    /**
     * Called when input is starting in a new editor field
     */
    override fun onStartInput(attribute: EditorInfo?, restarting: Boolean) {
        super.onStartInput(attribute, restarting)

        // Clear input state when starting fresh
        if (!restarting) {
            inputBuffer.clear()
            updateCandidates()
        }
    }

    /**
     * Called when the input view is being displayed
     */
    override fun onStartInputView(info: EditorInfo?, restarting: Boolean) {
        super.onStartInputView(info, restarting)

        // Update lifecycle state to STARTED when keyboard is shown
        lifecycleRegistry.currentState = Lifecycle.State.STARTED
        lifecycleRegistry.currentState = Lifecycle.State.RESUMED

        // Clear any stale state when keyboard reappears
        if (!restarting) {
            inputBuffer.clear()
            candidatesState.value = emptyList()
        }
    }

    /**
     * Handle key press from keyboard
     */
    private fun handleKey(key: String) {
        when (key) {
            "SHIFT" -> handleShift()
            "BACKSPACE" -> handleBackspace()
            "ENTER" -> handleEnter()
            "SPACE" -> handleSpace()
            "MODE_123" -> switchToSymbols()
            "MODE_ABC" -> switchToLetters()
            "MODE_SYMBOLS2" -> switchToSymbols2()
            else -> {
                // Check if it's a special character (non-letter)
                if (key.length == 1 && !key[0].isLetter()) {
                    handleSpecialCharacter(key)
                } else {
                    handleCharacter(key)
                }
            }
        }
    }

    /**
     * Handle special character input (punctuation, symbols, etc.)
     * Commits any pending Thai text first, then inserts the character
     */
    private fun handleSpecialCharacter(char: String) {
        // Commit any pending Thai text first (like iOS line 100-105)
        if (inputBuffer.isNotEmpty()) {
            val candidates = engine.getCandidates(inputBuffer.toString().lowercase())
            if (candidates.isNotEmpty()) {
                commitCandidate(candidates[0])
            } else {
                // No candidates, commit romanization as-is
                commitText(inputBuffer.toString())
            }
        }

        // Insert the special character
        currentInputConnection?.commitText(char, 1)
    }

    /**
     * Switch keyboard to symbols layer 1 (numbers + common symbols)
     */
    private fun switchToSymbols() {
        keyboardModeState.value = KeyboardMode.SYMBOLS_1
    }

    /**
     * Switch keyboard to symbols layer 2 (brackets + extended symbols)
     */
    private fun switchToSymbols2() {
        keyboardModeState.value = KeyboardMode.SYMBOLS_2
    }

    /**
     * Switch keyboard back to letters
     */
    private fun switchToLetters() {
        keyboardModeState.value = KeyboardMode.LETTERS
    }

    /**
     * Handle shift key tap - cycle through states: OFF -> ONCE -> OFF
     * Long press will be handled separately to set LOCKED state
     */
    private fun handleShift() {
        shiftState.value = when (shiftState.value) {
            ShiftState.OFF -> ShiftState.ONCE    // First tap: uppercase next letter
            ShiftState.ONCE -> ShiftState.OFF    // Second tap: back to lowercase
            ShiftState.LOCKED -> ShiftState.OFF  // Tap while locked: turn off
        }        
    }

    /**
     * Handle shift key long press - enable caps lock
     */
    private fun handleShiftLongPress() {
        shiftState.value = ShiftState.LOCKED        
    }

    /**
     * Handle long press on a key - insert alternate character
     * Used for Thai special characters and symbol variants
     */
    fun handleKeyLongPress(key: String, alternateChar: String) {
        // Commit any pending text first
        if (inputBuffer.isNotEmpty()) {
            val candidates = engine.getCandidates(inputBuffer.toString().lowercase())
            if (candidates.isNotEmpty()) {
                commitCandidate(candidates[0])
            } else {
                commitText(inputBuffer.toString())
            }
        }

        // Insert the alternate character
        currentInputConnection?.commitText(alternateChar, 1)
    }

    /**
     * Handle regular character input (a-z, A-Z)
     * Preserves original case in buffer and display.
     * Thai suggestions work on lowercase version of input.
     */
    private fun handleCharacter(char: String) {
        // Apply case based on shift state
        val actualChar = when (shiftState.value) {
            ShiftState.OFF -> char.lowercase()
            ShiftState.ONCE -> {
                // Uppercase this letter, then turn off shift
                val result = char.uppercase()
                shiftState.value = ShiftState.OFF
                result
            }
            ShiftState.LOCKED -> char.uppercase()
        }

        // Add to buffer preserving case (like iOS does)
        inputBuffer.append(actualChar)

        // Update candidates and composing text
        updateCandidates()
        updateComposingText()
    }

    /**
     * Handle backspace key
     */
    private fun handleBackspace() {
        if (inputBuffer.isNotEmpty()) {
            inputBuffer.deleteCharAt(inputBuffer.length - 1)

            if (inputBuffer.isEmpty()) {
                // Buffer is now empty - clear everything completely
                currentInputConnection?.setComposingText("", 1)
                currentInputConnection?.finishComposingText()
                updateCandidates() // This will clear the candidate bar
            } else {
                // Still have input - update normally
                updateComposingText()
                updateCandidates()
            }
        } else {
            // Send backspace to app if buffer is empty
            currentInputConnection?.deleteSurroundingText(1, 0)
        }
    }

    /**
     * Handle space bar - commit first candidate
     */
    private fun handleSpace() {
        if (inputBuffer.isNotEmpty()) {
            val candidates = engine.getCandidates(inputBuffer.toString())
            if (candidates.isNotEmpty()) {
                commitCandidate(candidates[0])
            } else {
                // No candidates, just commit the romanization
                commitText(inputBuffer.toString())
            }
        } else {
            // No input, just insert space
            currentInputConnection?.commitText(" ", 1)
        }
    }

    /**
     * Handle enter key - commit current buffer as-is
     */
    private fun handleEnter() {
        if (inputBuffer.isNotEmpty()) {
            commitText(inputBuffer.toString())
        } else {
            // Send enter to app if buffer is empty
            currentInputConnection?.performEditorAction(EditorInfo.IME_ACTION_DONE)
        }
    }

    /**
     * Update candidates based on current input buffer
     */
    private fun updateCandidates() {
        if (inputBuffer.isEmpty()) {
            candidatesState.value = emptyList()
            return
        }

        // Get Thai candidates from engine using lowercase version (engine works with lowercase)
        val thaiCandidates = engine.getCandidates(inputBuffer.toString().lowercase())

        // Add English romanization as the last candidate (preserving original case, like iOS)
        val allCandidates = if (thaiCandidates.isNotEmpty()) {
            thaiCandidates + inputBuffer.toString()
        } else {
            listOf(inputBuffer.toString())
        }

        candidatesState.value = allCandidates
    }

    /**
     * Update the composing text (underlined text showing current input)
     */
    private fun updateComposingText() {
        val displayText = inputBuffer.toString()
        currentInputConnection?.setComposingText(displayText, 1)
    }

    /**
     * Commit a candidate to the text field
     */
    private fun commitCandidate(candidate: String) {
        commitText(candidate)
    }

    /**
     * Commit text and clear input state
     */
    private fun commitText(text: String) {
        currentInputConnection?.commitText(text, 1)
        inputBuffer.clear()
        updateCandidates()
    }

    override fun onFinishInput() {
        super.onFinishInput()

        // Clear state when finishing input
        inputBuffer.clear()
        candidatesState.value = emptyList()
    }

    override fun onDestroy() {
        super.onDestroy()
        // Resources will be cleaned up automatically by Compose
    }
}
