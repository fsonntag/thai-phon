#!/bin/bash

# Quick test script for the candidate window
# Builds and runs the test app without needing to install the input method

set -e

echo "Building Candidate Window Test App..."

# Compile the test app
swiftc -O \
    TestCandidateWindow.swift \
    ThaiCandidateWindow.swift \
    -o test_candidate_window \
    -framework Cocoa

echo "✓ Build complete!"
echo ""
echo "Starting test app..."
echo ""

# Run the test app
./test_candidate_window
