//
//  KeyboardViewController.swift
//  Thai Phonetic Keyboard Extension
//
//  Main keyboard view controller using KeyboardKit 10
//

import KeyboardKit
import SwiftUI

class KeyboardViewController: KeyboardInputViewController {

    // MARK: - Properties

    private var thaiHandler: ThaiActionHandler?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup KeyboardKit with our Thai configuration
        setup(for: .thaiPhonetic) { [weak self] result in
            switch result {
            case .success:
                self?.setupThaiServices()
            case .failure:
                break
            }
        }
    }

    // MARK: - Setup

    private func setupThaiServices() {
        // Replace the default action handler with our Thai-aware handler
        let handler = ThaiActionHandler(controller: self)
        self.thaiHandler = handler
        services.actionHandler = handler
    }

    // MARK: - Keyboard View

    override func viewWillSetupKeyboardView() {
        // Set up custom keyboard view with Thai candidate bar
        guard let handler = thaiHandler else {
            super.viewWillSetupKeyboardView()
            return
        }

        setupKeyboardView { controller in
            ThaiKeyboardView(
                engine: handler.engine,
                services: controller.services,
                onCandidateSelect: { [weak handler] candidate in
                    handler?.commitCandidate(candidate)
                }
            )
        }
    }
}
