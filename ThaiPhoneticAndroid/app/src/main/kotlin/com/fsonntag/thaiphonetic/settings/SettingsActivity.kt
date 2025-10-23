package com.fsonntag.thaiphonetic.settings

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import android.view.inputmethod.InputMethodManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * Settings Activity - launcher activity for the keyboard app
 *
 * Modern Jetpack Compose implementation providing:
 * - Test input field for keyboard testing
 * - Example words to try
 * - Instructions for enabling the keyboard
 * - Button to open system keyboard settings
 */
class SettingsActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            ThaiPhoneticTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    SettingsScreen()
                }
            }
        }
    }
}

@Composable
fun ThaiPhoneticTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = lightColorScheme(),
        content = content
    )
}

@Composable
fun SettingsScreen() {
    val context = LocalContext.current
    val view = LocalView.current
    var testText by remember { mutableStateOf("") }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Title
        Text(
            text = "Thai Phonetic Keyboard",
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(bottom = 32.dp)
        )

        // Test Input Section
        Text(
            text = "Test Input",
            fontSize = 18.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 8.dp)
        )

        OutlinedTextField(
            value = testText,
            onValueChange = { testText = it },
            placeholder = { Text("Tap here to test the keyboard...") },
            modifier = Modifier
                .fillMaxWidth()
                .height(140.dp),
            textStyle = MaterialTheme.typography.bodyLarge
        )

        Spacer(modifier = Modifier.height(16.dp))

        // Button to force show software keyboard (for hardware keyboard mode)
        Button(
            onClick = {
                val imm = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                imm.toggleSoftInput(InputMethodManager.SHOW_FORCED, 0)
            },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Show Software Keyboard")
        }

        Spacer(modifier = Modifier.height(8.dp))

        // Keyboard switcher button (for emulators with hardware keyboard mode)
        OutlinedButton(
            onClick = {
                val imm = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                imm.showInputMethodPicker()
            },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Select Keyboard (Switch IME)")
        }

        Spacer(modifier = Modifier.height(8.dp))

        // Example words
        Text(
            text = "Try typing these examples:",
            fontSize = 16.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 8.dp)
        )

        ExamplesList()

        Spacer(modifier = Modifier.height(24.dp))

        HorizontalDivider()

        Spacer(modifier = Modifier.height(24.dp))

        // Setup Instructions
        Text(
            text = "Setup Instructions",
            fontSize = 18.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 8.dp)
        )

        Text(
            text = "1. Tap the button below to open keyboard settings\n" +
                   "2. Enable 'Thai Phonetic Keyboard'\n" +
                   "3. Return here and tap the test field\n" +
                   "4. Select Thai Phonetic from the keyboard picker",
            fontSize = 15.sp,
            lineHeight = 22.sp,
            modifier = Modifier.fillMaxWidth()
        )

        Spacer(modifier = Modifier.height(16.dp))

        Button(
            onClick = {
                val intent = Intent(Settings.ACTION_INPUT_METHOD_SETTINGS)
                context.startActivity(intent)
            },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(
                text = "Open Keyboard Settings",
                fontSize = 16.sp,
                modifier = Modifier.padding(8.dp)
            )
        }

        Spacer(modifier = Modifier.height(32.dp))

        // Version info
        Text(
            text = "Version 1.0.0\n\nA phonetic Thai keyboard inspired by Pinyin input.\nType romanization to get Thai script.",
            fontSize = 13.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center,
            lineHeight = 18.sp,
            modifier = Modifier.fillMaxWidth()
        )
    }
}

@Composable
fun ExamplesList() {
    Column(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        ExampleItem("pom", "ผม", "I/me")
        ExampleItem("gin", "กิน", "eat")
        ExampleItem("kao", "เข้า, ข้าว", "enter, rice")
        ExampleItem("aroy", "อร่อย", "delicious")
        ExampleItem("sawatdee", "สวัสดี", "hello")
    }
}

@Composable
fun ExampleItem(romanization: String, thai: String, meaning: String) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.Start
    ) {
        Text(text = "• ", fontSize = 15.sp)
        Text(
            text = "$romanization → $thai ",
            fontSize = 15.sp,
            fontWeight = FontWeight.Medium
        )
        Text(
            text = "($meaning)",
            fontSize = 15.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}
