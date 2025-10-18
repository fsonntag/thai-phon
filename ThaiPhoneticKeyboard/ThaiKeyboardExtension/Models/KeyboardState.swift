//
//  KeyboardState.swift
//  Thai Phonetic Keyboard
//
//  Manages keyboard UI state
//

import Foundation
import Combine

enum KeyboardMode {
    case letters
    case numbers
    case symbols
}

enum ShiftState {
    case off
    case on
    case locked
}

class KeyboardState: ObservableObject {
    @Published var mode: KeyboardMode = .letters
    @Published var shiftState: ShiftState = .off

    var isShifted: Bool {
        shiftState != .off
    }

    func toggleShift() {
        switch shiftState {
        case .off:
            shiftState = .on
        case .on:
            shiftState = .locked
        case .locked:
            shiftState = .off
        }
    }

    func handleKeyPress() {
        // Reset shift to off after typing a character (unless locked)
        if shiftState == .on {
            shiftState = .off
        }
    }

    func toggleMode() {
        mode = mode == .letters ? .numbers : .letters
    }
}
