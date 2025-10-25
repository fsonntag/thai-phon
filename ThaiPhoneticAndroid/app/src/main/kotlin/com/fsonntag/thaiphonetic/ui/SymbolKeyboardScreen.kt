package com.fsonntag.thaiphonetic.ui

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.zIndex
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Popup
import androidx.compose.ui.window.PopupProperties
import kotlinx.coroutines.delay

/**
 * Symbol Keyboard Screen 1 - Numbers + Common Symbols
 *
 * Layout aligned with letter keyboard:
 * Row 1: 1 2 3 4 5 6 7 8 9 0 (10 keys, aligns with QWERTYUIOP)
 * Row 2: @ # $ % & * ( ) ' (9 keys, aligns with ASDFGHJKL)
 * Row 3: =\< - + = / : ; , . ? ! ⌫ (aligns with SHIFT + ZXCVBNM + BACKSPACE)
 * Row 4: ABC , SPACE . ENTER (aligns with 123 , SPACE . ENTER)
 */
@Composable
fun SymbolKeyboardScreen1(
    onKey: (String) -> Unit,
    onKeyLongPress: (String, String) -> Unit,
    modifier: Modifier = Modifier
) {
    MaterialTheme {
        Column(
            modifier = modifier
                .fillMaxWidth()
                .height(280.dp)
                .background(KeyboardStyle.BACKGROUND_COLOR), // Sleek light gray background
            verticalArrangement = Arrangement.SpaceEvenly
        ) {
            // Row 1: Numbers with Thai numeral long-press (10 keys)
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
                    .padding(horizontal = 4.dp, vertical = 4.dp),
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically
            ) {
                val numbers = listOf("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
                val thaiNumbers = listOf("๑", "๒", "๓", "๔", "๕", "๖", "๗", "๘", "๙", "๐")

                numbers.forEachIndexed { index, number ->
                    LongPressKeyButton(
                        key = number,
                        label = number,
                        onKey = onKey,
                        onLongPress = { onKeyLongPress(number, thaiNumbers[index]) },
                        modifier = Modifier.weight(1f)
                    )
                }
            }

            // Row 2: Common symbols (9 keys to align with row 2 letters)
            SymbolRow(
                keys = listOf("@", "#", "$", "%", "&", "*", "(", ")", "\""),
                onKey = onKey,
                modifier = Modifier.weight(1f)
            )

            // Row 3: =\< (mode) + 7 symbols + BACKSPACE (aligns with SHIFT + 7 letters + BACKSPACE)
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
                    .padding(horizontal = 4.dp, vertical = 4.dp),
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Mode switch button (same position as shift)
                ModeKeyButton(
                    key = "MODE_SYMBOLS2",
                    label = "=\\<",
                    onKey = onKey,
                    modifier = Modifier.weight(1.5f)
                )

                // 7 symbols (aligned with 7 letters z-m)
                LongPressKeyButton(key = "-", label = "-", onKey = onKey, onLongPress = { onKeyLongPress("-", "๏") }, modifier = Modifier.weight(1f))
                SymbolKeyButton(key = "+", label = "+", onKey = onKey, modifier = Modifier.weight(1f))
                SymbolKeyButton(key = "=", label = "=", onKey = onKey, modifier = Modifier.weight(1f))
                SymbolKeyButton(key = "/", label = "/", onKey = onKey, modifier = Modifier.weight(1f))
                SymbolKeyButton(key = "'", label = "'", onKey = onKey, modifier = Modifier.weight(1f))
                SymbolKeyButton(key = ":", label = ":", onKey = onKey, modifier = Modifier.weight(1f))
                SymbolKeyButton(key = ";", label = ";", onKey = onKey, modifier = Modifier.weight(1f))

                // Backspace on right (same position as letter keyboard)
                SymbolKeyButton(
                    key = "BACKSPACE",
                    label = "⌫",
                    onKey = onKey,
                    modifier = Modifier.weight(1.5f)
                )
            }

            // Row 4: ABC, COMMA, SPACE, PERIOD, ENTER (same layout as letters)
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
                    .padding(horizontal = 4.dp, vertical = 4.dp),
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically
            ) {
                ModeKeyButton(
                    key = "MODE_ABC",
                    label = "ABC",
                    onKey = onKey,
                    modifier = Modifier.weight(1.5f)
                )
                LongPressKeyButton(
                    key = ",",
                    label = ",",
                    onKey = onKey,
                    onLongPress = { onKeyLongPress(",", "ๆ") },
                    modifier = Modifier.weight(1f)
                )
                SymbolKeyButton(
                    key = "SPACE",
                    label = "space",
                    onKey = onKey,
                    modifier = Modifier.weight(3f)
                )
                LongPressKeyButton(
                    key = ".",
                    label = ".",
                    onKey = onKey,
                    onLongPress = { onKeyLongPress(".", "ฯ") },
                    modifier = Modifier.weight(1f)
                )
                SymbolKeyButton(
                    key = "ENTER",
                    label = "↵",
                    onKey = onKey,
                    modifier = Modifier.weight(1.5f)
                )
            }
        }
    }
}

/**
 * Symbol Keyboard Screen 2 - Brackets + Extended Symbols
 *
 * Layout aligned with letter keyboard:
 * Row 1: [ ] { } < > ^ ~ ` _ (10 keys, aligns with QWERTYUIOP)
 * Row 2: \ | € £ ¥ ₹ ₩ § • (9 keys, aligns with ASDFGHJKL)
 * Row 3: 123 ≠ ≈ ± × ÷ ∞ … ⌫ (aligns with SHIFT + 7 letters + BACKSPACE)
 * Row 4: ABC , SPACE . ENTER (aligns with 123 , SPACE . ENTER)
 */
@Composable
fun SymbolKeyboardScreen2(
    onKey: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    MaterialTheme {
        Column(
            modifier = modifier
                .fillMaxWidth()
                .height(280.dp)
                .background(KeyboardStyle.BACKGROUND_COLOR), // Sleek light gray background
            verticalArrangement = Arrangement.SpaceEvenly
        ) {
            // Row 1: Brackets and special chars (10 keys)
            SymbolRow(
                keys = listOf("[", "]", "{", "}", "<", ">", "^", "~", "`", "_"),
                onKey = onKey,
                modifier = Modifier.weight(1f)
            )

            // Row 2: Currency and symbols (9 keys)
            SymbolRow(
                keys = listOf("\\", "|", "€", "£", "¥", "₹", "₩", "§", "•"),
                onKey = onKey,
                modifier = Modifier.weight(1f)
            )

            // Row 3: 123 (mode) + 7 math symbols + BACKSPACE
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
                    .padding(horizontal = 4.dp, vertical = 4.dp),
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Mode switch button (same position as shift/=\<)
                ModeKeyButton(
                    key = "MODE_123",
                    label = "123",
                    onKey = onKey,
                    modifier = Modifier.weight(1.5f)
                )

                // 7 math symbols (aligned with 7 letters z-m)
                SymbolKeyButton(key = "≠", label = "≠", onKey = onKey, modifier = Modifier.weight(1f))
                SymbolKeyButton(key = "≈", label = "≈", onKey = onKey, modifier = Modifier.weight(1f))
                SymbolKeyButton(key = "±", label = "±", onKey = onKey, modifier = Modifier.weight(1f))
                SymbolKeyButton(key = "×", label = "×", onKey = onKey, modifier = Modifier.weight(1f))
                SymbolKeyButton(key = "÷", label = "÷", onKey = onKey, modifier = Modifier.weight(1f))
                SymbolKeyButton(key = "∞", label = "∞", onKey = onKey, modifier = Modifier.weight(1f))
                SymbolKeyButton(key = "…", label = "…", onKey = onKey, modifier = Modifier.weight(1f))

                // Backspace on right (same position as letter keyboard)
                SymbolKeyButton(
                    key = "BACKSPACE",
                    label = "⌫",
                    onKey = onKey,
                    modifier = Modifier.weight(1.5f)
                )
            }

            // Row 4: ABC, COMMA, SPACE, PERIOD, ENTER (same layout as letters)
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
                    .padding(horizontal = 4.dp, vertical = 4.dp),
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically
            ) {
                ModeKeyButton(
                    key = "MODE_ABC",
                    label = "ABC",
                    onKey = onKey,
                    modifier = Modifier.weight(1.5f)
                )
                SymbolKeyButton(
                    key = ",",
                    label = ",",
                    onKey = onKey,
                    modifier = Modifier.weight(1f)
                )
                SymbolKeyButton(
                    key = "SPACE",
                    label = "space",
                    onKey = onKey,
                    modifier = Modifier.weight(3f)
                )
                SymbolKeyButton(
                    key = ".",
                    label = ".",
                    onKey = onKey,
                    modifier = Modifier.weight(1f)
                )
                SymbolKeyButton(
                    key = "ENTER",
                    label = "↵",
                    onKey = onKey,
                    modifier = Modifier.weight(1.5f)
                )
            }
        }
    }
}

/**
 * Helper: Symbol row - renders a row of symbol keys
 */
@Composable
private fun SymbolRow(
    keys: List<String>,
    onKey: (String) -> Unit,
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
            SymbolKeyButton(
                key = key,
                label = key,
                onKey = onKey,
                modifier = Modifier.weight(1f)
            )
        }
    }
}

/**
 * Standard symbol key button with sleek design
 */
@Composable
private fun SymbolKeyButton(
    key: String,
    label: String,
    onKey: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    var isPressed by remember { mutableStateOf(false) }
    val scale by animateFloatAsState(
        targetValue = if (isPressed) 0.95f else 1f,
        animationSpec = tween(durationMillis = 100),
        label = "symbolKeyPressScale"
    )

    Surface(
        onClick = { onKey(key) },
        modifier = modifier
            .fillMaxHeight()
            .padding(KeyboardStyle.KEY_PADDING)
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
        shape = RoundedCornerShape(KeyboardStyle.KEY_CORNER_RADIUS),
        color = KeyboardStyle.KEY_COLOR, // Clean white
        tonalElevation = 0.dp,
        shadowElevation = KeyboardStyle.KEY_SHADOW_ELEVATION
    ) {
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier.fillMaxSize()
        ) {
            Text(
                text = label,
                fontSize = KeyboardStyle.KEY_FONT_SIZE,
                textAlign = TextAlign.Center,
                color = KeyboardStyle.TEXT_COLOR, // Dark gray text
                style = MaterialTheme.typography.bodyLarge
            )
        }
    }
}

/**
 * Mode switch button (123, ABC, =\<) with sleek design
 */
@Composable
private fun ModeKeyButton(
    key: String,
    label: String,
    onKey: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    var isPressed by remember { mutableStateOf(false) }
    val scale by animateFloatAsState(
        targetValue = if (isPressed) 0.95f else 1f,
        animationSpec = tween(durationMillis = 100),
        label = "modePressScale"
    )

    Surface(
        onClick = { onKey(key) },
        modifier = modifier
            .fillMaxHeight()
            .padding(KeyboardStyle.KEY_PADDING)
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
        shape = RoundedCornerShape(KeyboardStyle.KEY_CORNER_RADIUS),
        color = KeyboardStyle.SPECIAL_KEY_COLOR, // Subtle gray for mode switches
        tonalElevation = 0.dp,
        shadowElevation = KeyboardStyle.KEY_SHADOW_ELEVATION
    ) {
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier.fillMaxSize()
        ) {
            Text(
                text = label,
                fontSize = KeyboardStyle.MODE_KEY_FONT_SIZE,
                textAlign = TextAlign.Center,
                color = KeyboardStyle.TEXT_COLOR, // Dark gray text
                style = MaterialTheme.typography.labelLarge
            )
        }
    }
}

/**
 * Long-press key button with alternate character support and popup animation
 */
@Composable
private fun LongPressKeyButton(
    key: String,
    label: String,
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
        label = "longPressScale"
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
                            color = KeyboardStyle.POPUP_COLOR,
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
                            textSize = 24.sp.toPx() // Same as regular key text
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
                .padding(KeyboardStyle.KEY_PADDING)
                .scale(scale)
                .pointerInput(Unit) {
                    detectTapGestures(
                        onLongPress = {
                            isLongPress = true
                            // Get the alternate character
                            popupChar = when {
                                key.toIntOrNull() != null -> {
                                    // Convert number to Thai numeral
                                    val thaiNumerals = listOf("๐", "๑", "๒", "๓", "๔", "๕", "๖", "๗", "๘", "๙")
                                    val num = key.toInt()
                                    thaiNumerals.getOrNull(num) ?: label
                                }
                                key == "," -> "ๆ"
                                key == "." -> "ฯ"
                                key == "-" -> "๏"
                                else -> label
                            }
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
            shape = RoundedCornerShape(KeyboardStyle.KEY_CORNER_RADIUS),
            color = KeyboardStyle.KEY_COLOR, // White key
            tonalElevation = 0.dp,
            shadowElevation = KeyboardStyle.KEY_SHADOW_ELEVATION
        ) {
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier.fillMaxSize()
            ) {
                // Main label
                Text(
                    text = label,
                    fontSize = KeyboardStyle.KEY_FONT_SIZE,
                    textAlign = TextAlign.Center,
                    color = KeyboardStyle.TEXT_COLOR,
                    style = MaterialTheme.typography.bodyLarge
                )
            }
        }
    }
}
