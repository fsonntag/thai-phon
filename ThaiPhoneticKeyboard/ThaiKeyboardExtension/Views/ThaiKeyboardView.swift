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

    @State private var showLanguageLabel = true

    // MARK: - Body

    var body: some View {
        // Standard KeyboardKit keyboard view
        KeyboardView(
            layout: nil,  // Use default layout
            services: services,
           buttonContent: { params in
               // Customize space key to show language identifier
               if case .space = params.item.action {
                   ZStack {
                       // Main language label that fades out
                       if showLanguageLabel {
                           Text("Thai - Phonetic")
                               .font(.system(size: 15))
                               .frame(maxWidth: .infinity, maxHeight: .infinity)
                               .transition(.opacity)
                       }

                       // Small Thai character indicator - fixed at bottom-right
                       Text("ส")
                           .font(.system(size: 12))
                           .foregroundColor(.secondary)
                           .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                           .padding(.trailing, 8)
                           .padding(.bottom, 6)
                   }
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
        .onAppear {
            // Fade out language label after 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showLanguageLabel = false
                }
            }
        }
    }
}
