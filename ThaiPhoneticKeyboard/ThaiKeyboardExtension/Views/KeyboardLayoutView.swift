//
//  KeyboardLayoutView.swift
//  Thai Phonetic Keyboard
//
//  Main keyboard layout with QWERTY keys and candidate bar
//

import SwiftUI

struct KeyboardLayoutView: View {
    @ObservedObject var engine: ThaiPhoneticEngine
    @ObservedObject var state: KeyboardState

    let onKeyTap: (String) -> Void
    let onCandidateTap: (String) -> Void
    let onNextKeyboard: () -> Void

    private var keyboardHeight: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 320 : 260
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar - ALWAYS reserve 44pt (like Pinyin)
            // Shows candidates when typing, gray background when empty
            ZStack {
                // Background always present - exact RGB match for iOS system bar above keyboard
                Color(red: 226/255, green: 227/255, blue: 231/255)

                // Candidates appear on top when available
                if !engine.currentCandidates.isEmpty {
                    CandidateBar(
                        candidates: engine.currentCandidates,
                        buffer: engine.composedBuffer,
                        onTap: onCandidateTap
                    )
                }
            }
            .frame(height: KeyboardConstants.candidateBarHeight)

            // Keyboard layout - fills remaining space
            if state.mode == .letters {
                LetterKeyboardLayout(
                    state: state,
                    onKeyTap: onKeyTap,
                    onNextKeyboard: onNextKeyboard
                )
            } else {
                NumberKeyboardLayout(
                    state: state,
                    onKeyTap: onKeyTap,
                    onNextKeyboard: onNextKeyboard
                )
            }
        }
        .frame(height: keyboardHeight)
    }
}

// MARK: - Letter Keyboard Layout

struct LetterKeyboardLayout: View {
    @ObservedObject var state: KeyboardState
    let onKeyTap: (String) -> Void
    let onNextKeyboard: () -> Void

    var body: some View {
        VStack(spacing: KeyboardConstants.keySpacing) {
            // Row 1: Q W E R T Y U I O P
            KeyRow(
                keys: ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
                state: state,
                onTap: onKeyTap
            )

            // Row 2: A S D F G H J K L
            HStack(spacing: KeyboardConstants.keySpacing) {
                Spacer()
                    .frame(width: 20)

                KeyRow(
                    keys: ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
                    state: state,
                    onTap: onKeyTap
                )

                Spacer()
                    .frame(width: 20)
            }

            // Row 3: Z X C V B N M Delete (centered layout)
            HStack(spacing: KeyboardConstants.keySpacing) {
                Spacer()
                    .frame(width: 46)

                KeyRow(
                    keys: ["z", "x", "c", "v", "b", "n", "m"],
                    state: state,
                    onTap: onKeyTap
                )

                KeyButtonView(
                    label: "⌫",
                    key: "delete",
                    style: .system,
                    width: 46
                ) { _ in
                    onKeyTap("delete")
                }
            }

            // Row 4: 123 Space Return
            HStack(spacing: KeyboardConstants.keySpacing) {
                KeyButtonView(
                    label: "123",
                    key: "numbers",
                    style: .system,
                    width: 80
                ) { _ in
                    state.toggleMode()
                }

                KeyButtonView(
                    label: "space",
                    key: " ",
                    style: .normal
                ) { _ in
                    onKeyTap("space")
                }

                KeyButtonView(
                    label: "return",
                    key: "return",
                    style: .primary,
                    width: 90
                ) { _ in
                    onKeyTap("return")
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
        .padding(.bottom, 2)
        .frame(maxHeight: .infinity)
        .background(Color(red: 226/255, green: 227/255, blue: 231/255))
    }

    private var shiftIcon: String {
        switch state.shiftState {
        case .off:
            return "⇧"
        case .on:
            return "⇧"  // Could use different icon for temporary shift
        case .locked:
            return "⇪"  // Caps lock icon
        }
    }
}

// MARK: - Number Keyboard Layout

struct NumberKeyboardLayout: View {
    @ObservedObject var state: KeyboardState
    let onKeyTap: (String) -> Void
    let onNextKeyboard: () -> Void

    var body: some View {
        VStack(spacing: KeyboardConstants.keySpacing) {
            // Row 1: 1 2 3 4 5 6 7 8 9 0
            KeyRow(
                keys: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
                state: state,
                onTap: onKeyTap
            )

            // Row 2: - / : ; ( ) $ & @ "
            KeyRow(
                keys: ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""],
                state: state,
                onTap: onKeyTap
            )

            // Row 3: #+=  . , ? ! ' Delete
            HStack(spacing: KeyboardConstants.keySpacing) {
                KeyButtonView(
                    label: "#+=",
                    key: "symbols",
                    style: .system,
                    width: 46
                ) { _ in
                    // Could add symbols layer here
                }

                KeyRow(
                    keys: [".", ",", "?", "!", "'"],
                    state: state,
                    onTap: onKeyTap
                )

                KeyButtonView(
                    label: "⌫",
                    key: "delete",
                    style: .system,
                    width: 46
                ) { _ in
                    onKeyTap("delete")
                }
            }

            // Row 4: ABC Space Return
            HStack(spacing: KeyboardConstants.keySpacing) {
                KeyButtonView(
                    label: "ABC",
                    key: "letters",
                    style: .system,
                    width: 80
                ) { _ in
                    state.toggleMode()
                }

                KeyButtonView(
                    label: "space",
                    key: " ",
                    style: .normal
                ) { _ in
                    onKeyTap("space")
                }

                KeyButtonView(
                    label: "return",
                    key: "return",
                    style: .primary,
                    width: 90
                ) { _ in
                    onKeyTap("return")
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
        .padding(.bottom, 2)
        .frame(maxHeight: .infinity)
        .background(Color(red: 226/255, green: 227/255, blue: 231/255))
    }
}

// MARK: - Key Row Helper

struct KeyRow: View {
    let keys: [String]
    @ObservedObject var state: KeyboardState
    let onTap: (String) -> Void

    var body: some View {
        HStack(spacing: KeyboardConstants.keySpacing) {
            ForEach(keys, id: \.self) { key in
                KeyButtonView(
                    label: state.isShifted ? key.uppercased() : key,
                    key: key,
                    style: .normal,
                    onTap: onTap
                )
            }
        }
    }
}

#Preview {
    KeyboardLayoutView(
        engine: ThaiPhoneticEngine(),
        state: KeyboardState(),
        onKeyTap: { key in
            print("Key tapped: \(key)")
        },
        onCandidateTap: { candidate in
            print("Candidate tapped: \(candidate)")
        },
        onNextKeyboard: {
            print("Next keyboard")
        }
    )
    .frame(height: 300)
}
