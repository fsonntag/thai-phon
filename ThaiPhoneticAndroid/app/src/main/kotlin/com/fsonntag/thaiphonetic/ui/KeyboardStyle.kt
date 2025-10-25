package com.fsonntag.thaiphonetic.ui

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * Shared UI Constants for keyboard styling across all keyboard screens
 */
object KeyboardStyle {
    // Spacing and dimensions
    val KEY_PADDING = 3.5.dp
    val KEY_CORNER_RADIUS = 5.dp
    val KEY_SHADOW_ELEVATION = 0.dp // Flat design

    // Font sizes
    val KEY_FONT_SIZE = 19.sp
    val MODE_KEY_FONT_SIZE = 15.sp
    val HINT_FONT_SIZE = 11.sp

    // Colors
    val BACKGROUND_COLOR = Color(0xFFD3D8DE)
    val KEY_COLOR = Color(0xFFFFFFFF)
    val SPECIAL_KEY_COLOR = Color(0xFFADB5BD)
    val TEXT_COLOR = Color(0xFF212529)
    val HINT_COLOR = Color(0xFF6C757D)
    val ACTIVE_COLOR = Color(0xFF4A90E2)
    val POPUP_COLOR = Color(0xFF4A90E2)
}
