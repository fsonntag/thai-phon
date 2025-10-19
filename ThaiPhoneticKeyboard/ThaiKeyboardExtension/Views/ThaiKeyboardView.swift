//
//  ThaiKeyboardView.swift
//  Thai Phonetic Keyboard Extension
//
//  Main keyboard view with Thai candidate bar
//

import SwiftUI
import KeyboardKit

struct ThaiKeyboardView: View {

    // MARK: - Properties

    @ObservedObject var engine: ThaiPhoneticEngine
    let services: Keyboard.Services
    let onCandidateSelect: (String) -> Void

    // MARK: - Body

    var body: some View {
        // Standard KeyboardKit keyboard view
        KeyboardView(
            layout: nil,  // Use default layout
            services: services,
           buttonContent: { params in
               // Customize space key to remove text
               if case .space = params.item.action {
                   Text("")  // Empty text for space key
                       .frame(maxWidth: .infinity)
               } else {
                   params.view  // Default view for other keys
               }
           },
           buttonView: { $0.view },
           collapsedView: { $0.view },
           emojiKeyboard: { $0.view },
           toolbar: { $0.view }
        )
        .overlay(alignment: .top) {
            // Thai candidate bar overlaid on top
            CandidateBarView(
                candidates: engine.currentCandidates,
                romanization: engine.composedBuffer,
                onSelect: onCandidateSelect
            )
        }
    }
}
