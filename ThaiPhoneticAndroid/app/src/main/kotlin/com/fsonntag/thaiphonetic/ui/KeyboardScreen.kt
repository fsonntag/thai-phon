package com.fsonntag.thaiphonetic.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.fsonntag.thaiphonetic.ime.ThaiPhoneticIME

/**
 * Key to alternate character mappings for long-press
 */
private val keyAlternates = mapOf(
    "q" to "1", "w" to "2", "e" to "3", "r" to "4", "t" to "5",
    "y" to "6", "u" to "7", "i" to "8", "o" to "9", "p" to "0",
    "a" to "@", "s" to "#", "d" to "$", "f" to "/", "g" to "(",
    "h" to ")", "j" to "-", "k" to "+", "l" to "=",
    "z" to "*", "x" to "\"", "c" to "'", "v" to ":", "b" to ";",
    "n" to "!", "m" to "?",
    "," to "ๆ", "." to "ฯ"
)

/**
 * Keyboard Screen - Main QWERTY keyboard layout with Material Design 3
 *
 * Displays a 4-row QWERTY keyboard with:
 * - Row 1: Q W E R T Y U I O P
 * - Row 2: A S D F G H J K L
 * - Row 3: SHIFT Z X C V B N M BACKSPACE
 * - Row 4: SPACE ENTER
 *
 * Shift key toggles between Thai phonetic and English input.
 * Fixed height of 280dp to prevent jumping.
 */
@Composable
fun KeyboardScreen(
    shiftState: ThaiPhoneticIME.ShiftState,
    onKey: (String) -> Unit,
    onShiftLongPress: () -> Unit,
    onKeyLongPress: ((String, String) -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    val isShiftEnabled = shiftState != ThaiPhoneticIME.ShiftState.OFF
    MaterialTheme {
        Column(
            modifier = modifier
                .fillMaxWidth()
                .height(280.dp)
                .background(MaterialTheme.colorScheme.surface), // Material Design 3 surface
            verticalArrangement = Arrangement.SpaceEvenly
        ) {
            // Row 1: QWERTY
            KeyRow(
                keys = listOf("q", "w", "e", "r", "t", "y", "u", "i", "o", "p"),
                isShiftEnabled = isShiftEnabled,
                onKey = onKey,
                onKeyLongPress = onKeyLongPress,
                modifier = Modifier.weight(1f)
            )

            // Row 2: ASDFGH
            KeyRow(
                keys = listOf("a", "s", "d", "f", "g", "h", "j", "k", "l"),
                isShiftEnabled = isShiftEnabled,
                onKey = onKey,
                onKeyLongPress = onKeyLongPress,
                modifier = Modifier.weight(1f)
            )

            // Row 3: SHIFT + ZXCVBN + BACKSPACE
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
                    .padding(horizontal = 4.dp, vertical = 4.dp),
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Shift key on left
                ShiftKeyButton(
                    shiftState = shiftState,
                    onKey = onKey,
                    onLongPress = onShiftLongPress,
                    modifier = Modifier.weight(1.5f)
                )

                // Letter keys
                listOf("z", "x", "c", "v", "b", "n", "m").forEach { key ->
                    val alternate = keyAlternates[key]
                    if (alternate != null && onKeyLongPress != null) {
                        LongPressLetterKeyButton(
                            key = key,
                            label = if (isShiftEnabled) key.uppercase() else key,
                            alternateChar = alternate,
                            onKey = onKey,
                            onLongPress = { onKeyLongPress(key, alternate) },
                            modifier = Modifier.weight(1f)
                        )
                    } else {
                        KeyButton(
                            key = key,
                            label = if (isShiftEnabled) key.uppercase() else key,
                            onKey = onKey,
                            modifier = Modifier.weight(1f)
                        )
                    }
                }

                // Backspace on right
                KeyButton(
                    key = "BACKSPACE",
                    label = "⌫",
                    onKey = onKey,
                    modifier = Modifier.weight(1.5f),
                    isSpecial = true
                )
            }

            // Row 4: 123, COMMA, SPACE, PERIOD, ENTER
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
                    .padding(horizontal = 4.dp, vertical = 4.dp),
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically
            ) {
                KeyButton(
                    key = "MODE_123",
                    label = "123",
                    onKey = onKey,
                    modifier = Modifier.weight(1.5f),
                    isSpecial = true
                )
                // Comma with long-press for ๆ
                if (onKeyLongPress != null) {
                    LongPressLetterKeyButton(
                        key = ",",
                        label = ",",
                        alternateChar = "ๆ",
                        onKey = onKey,
                        onLongPress = { onKeyLongPress(",", "ๆ") },
                        modifier = Modifier.weight(1f)
                    )
                } else {
                    KeyButton(
                        key = ",",
                        label = ",",
                        onKey = onKey,
                        modifier = Modifier.weight(1f),
                        isSpecial = false
                    )
                }
                KeyButton(
                    key = "SPACE",
                    label = "space",
                    onKey = onKey,
                    modifier = Modifier.weight(3f),
                    isSpecial = true
                )
                // Period with long-press for ฯ
                if (onKeyLongPress != null) {
                    LongPressLetterKeyButton(
                        key = ".",
                        label = ".",
                        alternateChar = "ฯ",
                        onKey = onKey,
                        onLongPress = { onKeyLongPress(".", "ฯ") },
                        modifier = Modifier.weight(1f)
                    )
                } else {
                    KeyButton(
                        key = ".",
                        label = ".",
                        onKey = onKey,
                        modifier = Modifier.weight(1f),
                        isSpecial = false
                    )
                }
                KeyButton(
                    key = "ENTER",
                    label = "↵",
                    onKey = onKey,
                    modifier = Modifier.weight(1.5f),
                    isSpecial = true
                )
            }
        }
    }
}

@Composable
private fun KeyRow(
    keys: List<String>,
    isShiftEnabled: Boolean,
    onKey: (String) -> Unit,
    onKeyLongPress: ((String, String) -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 4.dp, vertical = 4.dp),
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically
    ) {
        keys.forEach { key ->
            val alternate = keyAlternates[key]
            if (alternate != null && onKeyLongPress != null) {
                LongPressLetterKeyButton(
                    key = key,
                    label = if (isShiftEnabled) key.uppercase() else key,
                    alternateChar = alternate,
                    onKey = onKey,
                    onLongPress = { onKeyLongPress(key, alternate) },
                    modifier = Modifier.weight(1f)
                )
            } else {
                KeyButton(
                    key = key,
                    label = if (isShiftEnabled) key.uppercase() else key,
                    onKey = onKey,
                    modifier = Modifier.weight(1f)
                )
            }
        }
    }
}

@Composable
private fun KeyButton(
    key: String,
    label: String,
    onKey: (String) -> Unit,
    modifier: Modifier = Modifier,
    isSpecial: Boolean = false,
    isActive: Boolean = false
) {
    Surface(
        onClick = { onKey(key) },
        modifier = modifier
            .fillMaxHeight()
            .padding(3.dp),
        shape = RoundedCornerShape(8.dp), // Material Design 3 rounded corners
        color = when {
            isActive -> MaterialTheme.colorScheme.primary // Active state (shift enabled)
            isSpecial -> MaterialTheme.colorScheme.secondaryContainer // Special keys
            else -> MaterialTheme.colorScheme.surfaceVariant // Regular keys
        },
        tonalElevation = if (isActive) 3.dp else 1.dp,
        shadowElevation = if (isActive) 4.dp else 2.dp
    ) {
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier.fillMaxSize()
        ) {
            Text(
                text = label,
                fontSize = 18.sp,
                textAlign = TextAlign.Center,
                color = when {
                    isActive -> MaterialTheme.colorScheme.onPrimary
                    isSpecial -> MaterialTheme.colorScheme.onSecondaryContainer
                    else -> MaterialTheme.colorScheme.onSurfaceVariant
                },
                style = MaterialTheme.typography.bodyLarge
            )
        }
    }
}

/**
 * Letter key button with long-press support and visual hint
 * Shows the alternate character in top-right corner with lighter font
 */
@Composable
private fun LongPressLetterKeyButton(
    key: String,
    label: String,
    alternateChar: String,
    onKey: (String) -> Unit,
    onLongPress: () -> Unit,
    modifier: Modifier = Modifier
) {
    Surface(
        modifier = modifier
            .fillMaxHeight()
            .padding(3.dp)
            .pointerInput(Unit) {
                detectTapGestures(
                    onTap = { onKey(key) },
                    onLongPress = { onLongPress() }
                )
            },
        shape = RoundedCornerShape(8.dp),
        color = MaterialTheme.colorScheme.surfaceVariant,
        tonalElevation = 1.dp,
        shadowElevation = 2.dp
    ) {
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier.fillMaxSize()
        ) {
            // Main label (centered)
            Text(
                text = label,
                fontSize = 18.sp,
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                style = MaterialTheme.typography.bodyLarge
            )

            // Alternate character hint (top-right corner)
            Text(
                text = alternateChar,
                fontSize = 12.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f),
                style = MaterialTheme.typography.labelSmall,
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(top = 4.dp, end = 4.dp)
            )
        }
    }
}

/**
 * Special shift key button with long press support
 * - Single tap: Toggle shift (OFF -> ONCE -> OFF)
 * - Long press: Enable caps lock (LOCKED state)
 */
@Composable
private fun ShiftKeyButton(
    shiftState: ThaiPhoneticIME.ShiftState,
    onKey: (String) -> Unit,
    onLongPress: () -> Unit,
    modifier: Modifier = Modifier
) {
    val isActive = shiftState != ThaiPhoneticIME.ShiftState.OFF
    val isLocked = shiftState == ThaiPhoneticIME.ShiftState.LOCKED

    Surface(
        modifier = modifier
            .fillMaxHeight()
            .padding(3.dp)
            .pointerInput(Unit) {
                detectTapGestures(
                    onTap = { onKey("SHIFT") },
                    onLongPress = { onLongPress() }
                )
            },
        shape = RoundedCornerShape(8.dp),
        color = when (shiftState) {
            ThaiPhoneticIME.ShiftState.LOCKED -> MaterialTheme.colorScheme.primary
            ThaiPhoneticIME.ShiftState.ONCE -> MaterialTheme.colorScheme.primaryContainer
            ThaiPhoneticIME.ShiftState.OFF -> MaterialTheme.colorScheme.secondaryContainer
        },
        tonalElevation = if (isActive) 3.dp else 1.dp,
        shadowElevation = if (isActive) 4.dp else 2.dp
    ) {
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier.fillMaxSize()
        ) {
            Text(
                text = if (isLocked) "⇪" else "⇧", // Different icon for caps lock
                fontSize = 18.sp,
                textAlign = TextAlign.Center,
                color = when (shiftState) {
                    ThaiPhoneticIME.ShiftState.LOCKED -> MaterialTheme.colorScheme.onPrimary
                    ThaiPhoneticIME.ShiftState.ONCE -> MaterialTheme.colorScheme.onPrimaryContainer
                    ThaiPhoneticIME.ShiftState.OFF -> MaterialTheme.colorScheme.onSecondaryContainer
                },
                style = MaterialTheme.typography.bodyLarge
            )
        }
    }
}
