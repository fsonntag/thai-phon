package com.fsonntag.thaiphonetic.ui

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.zIndex
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Popup
import androidx.compose.ui.window.PopupProperties
import com.fsonntag.thaiphonetic.ime.ThaiPhoneticIME
import kotlinx.coroutines.delay

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
                .background(Color(0xFFD3D8DE)), // Sleek light gray background
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
    var isPressed by remember { mutableStateOf(false) }
    val scale by animateFloatAsState(
        targetValue = if (isPressed) 0.95f else 1f,
        animationSpec = tween(durationMillis = 100),
        label = "keyPressScale"
    )

    Surface(
        onClick = { onKey(key) },
        modifier = modifier
            .fillMaxHeight()
            .padding(2.dp)
            .scale(scale)
            .pointerInput(Unit) {
                detectTapGestures(
                    onPress = {
                        isPressed = true
                        tryAwaitRelease()
                        isPressed = false
                    }
                )
            },
        shape = RoundedCornerShape(6.dp), // Sleeker, slightly smaller radius
        color = when {
            isActive -> Color(0xFF4A90E2) // Sleek blue for active
            isSpecial -> Color(0xFFADB5BD) // Subtle gray for special keys
            else -> Color(0xFFFFFFFF) // Clean white for regular keys
        },
        tonalElevation = 0.dp, // Flat design
        shadowElevation = if (isPressed) 0.dp else 1.dp // Subtle shadow only when not pressed
    ) {
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier.fillMaxSize()
        ) {
            Text(
                text = label,
                fontSize = 20.sp, // Slightly larger for better readability
                textAlign = TextAlign.Center,
                color = when {
                    isActive -> Color.White
                    isSpecial -> Color(0xFF212529) // Dark gray text
                    else -> Color(0xFF212529) // Dark gray text
                },
                style = MaterialTheme.typography.bodyLarge
            )
        }
    }
}

/**
 * Letter key button with long-press support and visual hint
 * Shows the alternate character in top-right corner with lighter font
 * Displays popup on long-press for visual confirmation
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
    var isPressed by remember { mutableStateOf(false) }
    var showPopup by remember { mutableStateOf(false) }
    var popupChar by remember { mutableStateOf("") }
    var isLongPress by remember { mutableStateOf(false) }

    val scale by animateFloatAsState(
        targetValue = if (isPressed) 0.95f else 1f,
        animationSpec = tween(durationMillis = 100),
        label = "keyPressScale"
    )

    Box(modifier = modifier.fillMaxHeight()) {
        // Popup ABOVE button - connected design like iOS
        if (showPopup) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .fillMaxHeight()
                    .align(Alignment.TopCenter)
                    .offset(y = (-50).dp) // Closer to button
                    .zIndex(100f)
            ) {
                Box(
                    modifier = Modifier
                        .align(Alignment.Center)
                        .size(width = 60.dp, height = 70.dp) // Taller to connect better
                        .background(
                            color = Color(0xFF4A90E2),
                            shape = RoundedCornerShape(8.dp)
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    // Draw text directly on Canvas
                    androidx.compose.foundation.Canvas(
                        modifier = Modifier.fillMaxSize()
                    ) {
                        val textPaint = android.graphics.Paint().apply {
                            color = android.graphics.Color.WHITE
                            textSize = 24.sp.toPx() // Same as regular key text (20sp + bold looks like 24sp)
                            textAlign = android.graphics.Paint.Align.CENTER
                            isAntiAlias = true
                            typeface = android.graphics.Typeface.DEFAULT_BOLD
                        }
                        drawContext.canvas.nativeCanvas.drawText(
                            popupChar,
                            size.width / 2,
                            size.height / 2 + (textPaint.textSize / 3),
                            textPaint
                        )
                    }
                }
            }
        }

        Surface(
            modifier = Modifier
                .fillMaxHeight()
                .padding(2.dp)
                .scale(scale)
                .pointerInput(Unit) {
                    detectTapGestures(
                        onLongPress = {
                            isLongPress = true
                            popupChar = alternateChar
                            showPopup = true
                            onLongPress()
                        },
                        onPress = {
                            isPressed = true
                            isLongPress = false
                            popupChar = label
                            showPopup = true

                            val released = tryAwaitRelease()

                            showPopup = false
                            isPressed = false

                            // If it was a tap (not long press), trigger onKey
                            if (released && !isLongPress) {
                                onKey(key)
                            }
                        }
                    )
                },
            shape = RoundedCornerShape(6.dp),
            color = Color(0xFFFFFFFF), // White key
            tonalElevation = 0.dp,
            shadowElevation = if (isPressed) 0.dp else 1.dp
        ) {
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier.fillMaxSize()
            ) {
                // Main label (centered)
                Text(
                    text = label,
                    fontSize = 20.sp,
                    textAlign = TextAlign.Center,
                    color = Color(0xFF212529),
                    style = MaterialTheme.typography.bodyLarge
                )

                // Alternate character hint (top-right corner)
                Text(
                    text = alternateChar,
                    fontSize = 11.sp,
                    color = Color(0xFF6C757D), // Medium gray
                    style = MaterialTheme.typography.labelSmall,
                    modifier = Modifier
                        .align(Alignment.TopEnd)
                        .padding(top = 3.dp, end = 3.dp)
                )
            }
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
    var isPressed by remember { mutableStateOf(false) }
    val isActive = shiftState != ThaiPhoneticIME.ShiftState.OFF
    val isLocked = shiftState == ThaiPhoneticIME.ShiftState.LOCKED

    val scale by animateFloatAsState(
        targetValue = if (isPressed) 0.95f else 1f,
        animationSpec = tween(durationMillis = 100),
        label = "shiftPressScale"
    )

    Surface(
        modifier = modifier
            .fillMaxHeight()
            .padding(2.dp)
            .scale(scale)
            .pointerInput(Unit) {
                detectTapGestures(
                    onTap = { onKey("SHIFT") },
                    onLongPress = { onLongPress() },
                    onPress = {
                        isPressed = true
                        tryAwaitRelease()
                        isPressed = false
                    }
                )
            },
        shape = RoundedCornerShape(6.dp),
        color = Color(0xFFADB5BD), // Subtle gray - same as other special keys
        tonalElevation = 0.dp,
        shadowElevation = if (isPressed) 0.dp else 1.dp
    ) {
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier.fillMaxSize()
        ) {
            // Custom wide arrow drawn with Canvas
            // OFF state: outlined arrow, Active states: filled arrow
            val arrowColor = Color(0xFF212529) // Dark gray for all states
            val isActive = shiftState != ThaiPhoneticIME.ShiftState.OFF

            androidx.compose.foundation.Canvas(
                modifier = Modifier.size(34.dp)
            ) {
                val strokeWidth = 2.5f.dp.toPx() // Thinner stroke

                val paint = android.graphics.Paint().apply {
                    color = arrowColor.toArgb()
                    isAntiAlias = true
                    style = if (isActive) {
                        android.graphics.Paint.Style.FILL_AND_STROKE // Fill with stroke to match outline size
                    } else {
                        android.graphics.Paint.Style.STROKE // Outlined when off
                    }
                    this.strokeWidth = strokeWidth
                    strokeJoin = android.graphics.Paint.Join.MITER // Sharp corners
                    strokeMiter = 10f // Ensure sharp corners don't get clipped
                }

                val width = size.width
                val height = size.height
                val centerX = width / 2

                // Draw a balanced arrow: proportional triangle + stem
                val path = android.graphics.Path().apply {
                    // Arrow head (balanced triangle - 60% width)
                    moveTo(centerX, height * 0.20f) // Top point (lower to reduce height)
                    lineTo(width * 0.80f, height * 0.48f) // Right point
                    lineTo(width * 0.675f, height * 0.48f) // Right inner
                    lineTo(width * 0.675f, height * 0.80f) // Right stem bottom (higher to reduce height)
                    lineTo(width * 0.325f, height * 0.80f) // Left stem bottom
                    lineTo(width * 0.325f, height * 0.48f) // Left inner
                    lineTo(width * 0.20f, height * 0.48f) // Left point
                    close()
                }

                drawContext.canvas.nativeCanvas.drawPath(path, paint)
            }
        }
    }
}
