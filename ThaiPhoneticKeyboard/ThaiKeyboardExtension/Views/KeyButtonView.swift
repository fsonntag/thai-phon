//
//  KeyButtonView.swift
//  Thai Phonetic Keyboard
//
//  Individual key button component
//

import SwiftUI

struct KeyButtonView: View {
    let label: String
    let key: String
    var style: KeyStyle = .normal
    var width: CGFloat? = nil
    let onTap: (String) -> Void

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    enum KeyStyle {
        case normal
        case system
        case primary
    }

    var body: some View {
        Button(action: {
            onTap(key)
        }) {
            Text(label)
                .font(.system(size: KeyboardConstants.keyFontSize, weight: .regular))
                .foregroundColor(foregroundColor)
                .frame(maxWidth: width == nil ? .infinity : width, maxHeight: .infinity)
                .background(backgroundColor)
                .cornerRadius(KeyboardConstants.keyCornerRadius)
                .shadow(color: .black.opacity(0.1), radius: 1, y: 1)
        }
        .frame(height: keyHeight)
    }

    private var keyHeight: CGFloat {
        horizontalSizeClass == .regular ? KeyboardConstants.keyHeightIPad : KeyboardConstants.keyHeight
    }

    private var backgroundColor: Color {
        switch style {
        case .normal:
            return KeyboardConstants.keyBackground
        case .system:
            return KeyboardConstants.systemKeyBackground
        case .primary:
            return KeyboardConstants.primaryKeyBackground
        }
    }

    private var foregroundColor: Color {
        style == .primary ? .white : .primary
    }
}

#Preview {
    VStack(spacing: 8) {
        KeyButtonView(label: "A", key: "a", style: .normal) { _ in }
        KeyButtonView(label: "⇧", key: "shift", style: .system) { _ in }
        KeyButtonView(label: "return", key: "\n", style: .primary) { _ in }
    }
    .padding()
    .frame(height: 200)
}
