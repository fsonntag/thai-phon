//
//  KeyboardViewController.swift
//  Thai Phonetic Keyboard Extension
//
//  Main keyboard view controller using KeyboardKit 10
//

import KeyboardKit
import SwiftUI
import OSLog

// Global log to test if file is even loaded
private let fileLoadLogger: Void = {
    os_log("🟡 FILE LOADED: KeyboardViewController.swift", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "FileLoad"), type: .fault)
}()

class KeyboardViewController: KeyboardInputViewController {

    // MARK: - Properties

    private var thaiHandler: ThaiActionHandler?

    // MARK: - Initialization

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        os_log("🔴 INIT: KeyboardViewController init(nibName:bundle:)", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "KeyboardViewController"), type: .info)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        os_log("🔴 INIT: After super.init", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "KeyboardViewController"), type: .info)
    }

    required init?(coder: NSCoder) {
        os_log("🔴 INIT: KeyboardViewController init(coder:)", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "KeyboardViewController"), type: .info)
        super.init(coder: coder)
        os_log("🔴 INIT: After super.init(coder)", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "KeyboardViewController"), type: .info)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        os_log("🔵 viewDidLoad: START", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "KeyboardViewController"), type: .info)
        super.viewDidLoad()
        os_log("🔵 viewDidLoad: After super.viewDidLoad", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "KeyboardViewController"), type: .info)
        os_log("KeyboardViewController viewDidLoad with KeyboardKit 10", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "KeyboardViewController"), type: .info)

        // Setup KeyboardKit with our Thai configuration
        setup(for: .thaiPhonetic) { [weak self] result in
            os_log("🔵 KeyboardKit setup result: %{public}@", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "KeyboardViewController"), type: .info, String(describing: result))
            switch result {
            case .success:
                self?.setupThaiServices()
                os_log("🟢 KeyboardKit setup successful!", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "KeyboardViewController"), type: .info)
            case .failure(let error):
                os_log("🔴 KeyboardKit setup failed: %{public}@", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "KeyboardViewController"), type: .error, error.localizedDescription)
            }
        }
    }

    // MARK: - Setup

    private func setupThaiServices() {
        os_log("🔵 Setting up Thai services...", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "KeyboardViewController"), type: .info)

        // Replace the default action handler with our Thai-aware handler
        let handler = ThaiActionHandler(controller: self)
        self.thaiHandler = handler
        services.actionHandler = handler

        os_log("🟢 Thai action handler configured!", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "KeyboardViewController"), type: .info)
    }

    // MARK: - Keyboard View

    override func viewWillSetupKeyboardView() {
        os_log("🔵 Setting up keyboard view", log: OSLog(subsystem: "com.fsonntag.ThaiPhoneticKeyboard.extension", category: "KeyboardViewController"), type: .info)

        // Set up custom keyboard view with Thai candidate bar
        guard let handler = thaiHandler else {
            super.viewWillSetupKeyboardView()
            return
        }

        setupKeyboardView { controller in
            ThaiKeyboardView(
                engine: handler.engine,
                services: controller.services,
                state: controller.state,
                onCandidateSelect: { [weak handler] candidate in
                    handler?.commitCandidate(candidate)
                }
            )
        }
    }
}
