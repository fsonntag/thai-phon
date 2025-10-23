package com.fsonntag.thaiphonetic.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * Candidate Bar - Displays Thai word suggestions above keyboard with Material Design 3
 *
 * Shows horizontally scrollable candidates that user can tap to select.
 * Each candidate shows a number badge (1-9) for quick selection.
 * Maintains fixed height to prevent keyboard jumping.
 */
@Composable
fun CandidateBar(
    candidates: List<String>,
    onCandidateSelected: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    MaterialTheme {
        Row(
            modifier = modifier
                .fillMaxWidth()
                .height(56.dp)
                .background(MaterialTheme.colorScheme.surfaceContainer) // Material Design 3 surface container
                .horizontalScroll(rememberScrollState())
                .padding(horizontal = 8.dp, vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.Start
        ) {
            if (candidates.isEmpty()) {
                // Invisible placeholder to maintain height and prevent jumping
                Spacer(modifier = Modifier.width(1.dp).fillMaxHeight())
            } else {
                candidates.forEachIndexed { index, candidate ->
                    CandidateButton(
                        candidate = candidate,
                        number = index + 1,
                        onClick = { onCandidateSelected(candidate) }
                    )
                }
            }
        }
    }
}

@Composable
private fun CandidateButton(
    candidate: String,
    number: Int,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Surface(
        onClick = onClick,
        modifier = modifier
            .padding(horizontal = 4.dp)
            .height(40.dp),
        shape = RoundedCornerShape(20.dp), // Pill shape for Material Design 3
        color = MaterialTheme.colorScheme.primaryContainer,
        tonalElevation = 1.dp,
        shadowElevation = 1.dp
    ) {
        Row(
            modifier = Modifier
                .padding(horizontal = 16.dp, vertical = 8.dp),
            horizontalArrangement = Arrangement.Center,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Number badge
            Text(
                text = "$number",
                fontSize = 14.sp,
                color = MaterialTheme.colorScheme.onPrimaryContainer,
                style = MaterialTheme.typography.labelMedium,
                modifier = Modifier.padding(end = 8.dp)
            )
            // Candidate text
            Text(
                text = candidate,
                fontSize = 18.sp,
                color = MaterialTheme.colorScheme.onPrimaryContainer,
                style = MaterialTheme.typography.bodyLarge,
                textAlign = TextAlign.Center
            )
        }
    }
}
