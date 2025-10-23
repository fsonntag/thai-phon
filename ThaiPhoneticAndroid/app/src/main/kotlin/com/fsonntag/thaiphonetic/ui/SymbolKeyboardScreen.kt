package com.fsonntag.thaiphonetic.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * Symbol Keyboard Screen 1 - Numbers + Common Symbols
 *
 * Layout:
 * Row 1: 1 2 3 4 5 6 7 8 9 0
 * Row 2: @ # $ % & * ( ) ' "
 * Row 3: - + = / : ; , . ? !
 * Row 4: =\< (mode) - ABC - SPACE - ENTER
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
                .background(MaterialTheme.colorScheme.surface),
            verticalArrangement = Arrangement.SpaceEvenly
        ) {
            // Row 1: Numbers with Thai numeral long-press
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

            // Row 2: Common symbols
            SymbolRow(
                keys = listOf("@", "#", "$", "%", "&", "*", "(", ")", "'", "\""),
                onKey = onKey,
                modifier = Modifier.weight(1f)
            )

            // Row 3: Punctuation with Thai special character long-press
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
                    .padding(horizontal = 4.dp, vertical = 4.dp),
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically
            ) {
                LongPressKeyButton(key = "-", label = "-", onKey = onKey, onLongPress = { onKeyLongPress("-", "๏") }, modifier = Modifier.weight(1f))
                SymbolKeyButton(key = "+", label = "+", onKey = onKey, modifier = Modifier.weight(1f))
                SymbolKeyButton(key = "=", label = "=", onKey = onKey, modifier = Modifier.weight(1f))
                SymbolKeyButton(key = "/", label = "/", onKey = onKey, modifier = Modifier.weight(1f))
                SymbolKeyButton(key = ":", label = ":", onKey = onKey, modifier = Modifier.weight(1f))
                SymbolKeyButton(key = ";", label = ";", onKey = onKey, modifier = Modifier.weight(1f))
                LongPressKeyButton(key = ",", label = ",", onKey = onKey, onLongPress = { onKeyLongPress(",", "ๆ") }, modifier = Modifier.weight(1f))
                LongPressKeyButton(key = ".", label = ".", onKey = onKey, onLongPress = { onKeyLongPress(".", "ฯ") }, modifier = Modifier.weight(1f))
                SymbolKeyButton(key = "?", label = "?", onKey = onKey, modifier = Modifier.weight(1f))
                SymbolKeyButton(key = "!", label = "!", onKey = onKey, modifier = Modifier.weight(1f))
            }

            // Row 4: Mode switch buttons (ABC in same position as 123)
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
                ModeKeyButton(
                    key = "MODE_SYMBOLS2",
                    label = "=\\<",
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
 * Symbol Keyboard Screen 2 - Brackets + Extended Symbols
 *
 * Layout:
 * Row 1: [ ] { } < > ^ ~ ` _
 * Row 2: \ | € £ ¥ ₹ ₩ § • °
 * Row 3: ≠ ≈ ± × ÷ ∞ … ¶ † ‡
 * Row 4: 123 - ABC - SPACE - ENTER
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
                .background(MaterialTheme.colorScheme.surface),
            verticalArrangement = Arrangement.SpaceEvenly
        ) {
            // Row 1: Brackets and special chars
            SymbolRow(
                keys = listOf("[", "]", "{", "}", "<", ">", "^", "~", "`", "_"),
                onKey = onKey,
                modifier = Modifier.weight(1f)
            )

            // Row 2: Currency and symbols
            SymbolRow(
                keys = listOf("\\", "|", "€", "£", "¥", "₹", "₩", "§", "•", "°"),
                onKey = onKey,
                modifier = Modifier.weight(1f)
            )

            // Row 3: Math symbols
            SymbolRow(
                keys = listOf("≠", "≈", "±", "×", "÷", "∞", "…", "¶", "†", "‡"),
                onKey = onKey,
                modifier = Modifier.weight(1f)
            )

            // Row 4: Mode switch buttons (ABC in same position as on symbol layer 1)
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
                ModeKeyButton(
                    key = "MODE_123",
                    label = "123",
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
 * Standard symbol key button
 */
@Composable
private fun SymbolKeyButton(
    key: String,
    label: String,
    onKey: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    Surface(
        onClick = { onKey(key) },
        modifier = modifier
            .fillMaxHeight()
            .padding(3.dp),
        shape = RoundedCornerShape(8.dp),
        color = MaterialTheme.colorScheme.surfaceVariant,
        tonalElevation = 1.dp,
        shadowElevation = 2.dp
    ) {
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier.fillMaxSize()
        ) {
            Text(
                text = label,
                fontSize = 18.sp,
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                style = MaterialTheme.typography.bodyLarge
            )
        }
    }
}

/**
 * Mode switch button (123, ABC, =\<)
 */
@Composable
private fun ModeKeyButton(
    key: String,
    label: String,
    onKey: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    Surface(
        onClick = { onKey(key) },
        modifier = modifier
            .fillMaxHeight()
            .padding(3.dp),
        shape = RoundedCornerShape(8.dp),
        color = MaterialTheme.colorScheme.tertiaryContainer,
        tonalElevation = 1.dp,
        shadowElevation = 2.dp
    ) {
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier.fillMaxSize()
        ) {
            Text(
                text = label,
                fontSize = 16.sp,
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.onTertiaryContainer,
                style = MaterialTheme.typography.labelLarge
            )
        }
    }
}

/**
 * Long-press key button with alternate character support
 */
@Composable
private fun LongPressKeyButton(
    key: String,
    label: String,
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
            Text(
                text = label,
                fontSize = 18.sp,
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                style = MaterialTheme.typography.bodyLarge
            )
        }
    }
}
