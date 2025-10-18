// ThaiCandidateWindow.swift
// Custom candidate window for Thai Phonetic Input Method
// Inspired by vChewing's implementation

import Cocoa

class ThaiCandidateWindow: NSWindow {
    // MARK: - Constants
    private static let windowHeight: CGFloat = 32  // Reduced from 40 for more compact appearance

    private var candidates: [String] = []
    private var selectedIndex: Int = 0
    private let stackView = NSStackView()
    private var candidateViews: [NSView] = []

    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: Self.windowHeight),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        setupWindow()
        setupUI()
    }

    private func setupWindow() {
        isOpaque = false
        backgroundColor = NSColor.clear
        // Use .popUpMenu level so candidate window appears above Spotlight and other UI
        // This matches the behavior of system input methods like Pinyin
        level = .popUpMenu
        hasShadow = true
        isMovableByWindowBackground = false
    }

    private func setupUI() {
        // Create container view with background
        let containerView = NSView(frame: contentView!.bounds)
        containerView.autoresizingMask = [.width, .height]
        containerView.wantsLayer = true
        containerView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        containerView.layer?.cornerRadius = 8

        // Setup horizontal stack view for candidates
        stackView.orientation = .horizontal
        stackView.spacing = 4  // Reduced from 12 to 4 for tighter spacing
        stackView.edgeInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)  // No edge insets - handled by containers
        stackView.alignment = .centerY  // Center items vertically
        stackView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(stackView)
        contentView?.addSubview(containerView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
    }

    func updateCandidates(_ newCandidates: [String], selected: Int = 0) {
        candidates = newCandidates
        selectedIndex = selected

        // Store current position to restore after resize
        let currentOrigin = frame.origin

        // Clear existing views
        candidateViews.forEach { $0.removeFromSuperview() }
        candidateViews.removeAll()

        // Create new candidate views
        for (index, candidate) in candidates.enumerated() {
            let candidateView = createCandidateView(
                number: index + 1,
                text: candidate,
                isSelected: index == selectedIndex,
                isFirst: index == 0,
                isLast: index == candidates.count - 1
            )
            stackView.addArrangedSubview(candidateView)
            candidateViews.append(candidateView)
        }

        // Resize window to fit content and restore position
        sizeToFit()
        setFrameOrigin(currentOrigin)
    }

    private func createCandidateView(number: Int, text: String, isSelected: Bool, isFirst: Bool, isLast: Bool) -> NSView {
        // Create container view for the candidate
        let containerView = NSView()
        containerView.wantsLayer = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = false  // Allow background to extend beyond container bounds

        // Create text field first to determine size
        let textField = NSTextField()
        textField.isEditable = false
        textField.isBordered = false
        textField.drawsBackground = false
        textField.backgroundColor = NSColor.clear

        // Create attributed string with different styles for number and text
        let attributedString = NSMutableAttributedString()

        // Number part: smaller, gray
        let numberText = "\(number). "
        let numberAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 11),
            .foregroundColor: isSelected
                ? NSColor.white.withAlphaComponent(0.8)
                : NSColor.secondaryLabelColor
        ]
        attributedString.append(NSAttributedString(string: numberText, attributes: numberAttrs))

        // Thai text part: larger size, prominent
        let textAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 16),  // Increased from 14 to 16
            .foregroundColor: isSelected ? NSColor.white : NSColor.labelColor
        ]
        attributedString.append(NSAttributedString(string: text, attributes: textAttrs))

        textField.attributedStringValue = attributedString
        textField.sizeToFit()

        // Add selection background if selected
        // For first/last items, background extends beyond text to window edge
        if isSelected {
            let backgroundView = NSView()
            backgroundView.wantsLayer = true
            backgroundView.layer?.backgroundColor = NSColor.selectedContentBackgroundColor.cgColor
            backgroundView.layer?.cornerRadius = 5
            backgroundView.translatesAutoresizingMaskIntoConstraints = false

            containerView.addSubview(backgroundView)

            // Background extends to edges for first/last items
            // For leading: negative value extends left, for trailing: positive value extends right
            let backgroundLeftInset: CGFloat = isFirst ? -12 : 0
            let backgroundRightInset: CGFloat = isLast ? 12 : 0  // Positive for trailing anchor

            NSLayoutConstraint.activate([
                backgroundView.topAnchor.constraint(equalTo: containerView.topAnchor),
                backgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                backgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: backgroundLeftInset),
                backgroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: backgroundRightInset)
            ])
        }

        // Add text field on top of background
        // First/last items get 12px padding to create window edge margin
        // Middle items get 8px padding
        let textPadding: CGFloat = 8
        let leftPadding: CGFloat = isFirst ? 12 : textPadding
        let rightPadding: CGFloat = isLast ? 12 : textPadding

        textField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(textField)

        NSLayoutConstraint.activate([
            // Container has fixed height that fills the window
            containerView.heightAnchor.constraint(equalToConstant: Self.windowHeight),
            // Text field is centered vertically in container
            textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            // Text padding - first/last items use only stack edge insets for cleaner look
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: leftPadding),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -rightPadding)
        ])

        return containerView
    }

    func selectCandidate(at index: Int) {
        guard index >= 0 && index < candidates.count else { return }
        selectedIndex = index
        updateCandidates(candidates, selected: selectedIndex)
    }

    func selectNext() {
        if selectedIndex < candidates.count - 1 {
            selectCandidate(at: selectedIndex + 1)
        }
    }

    func selectPrevious() {
        if selectedIndex > 0 {
            selectCandidate(at: selectedIndex - 1)
        }
    }

    func selectedCandidate() -> String? {
        guard selectedIndex >= 0 && selectedIndex < candidates.count else { return nil }
        return candidates[selectedIndex]
    }

    func positionNear(rect: NSRect, screenHeight: CGFloat) {
        // Position window below the cursor/text
        var origin = NSPoint(x: rect.origin.x, y: rect.origin.y - frame.height - 5)

        // Adjust if would go off screen
        if origin.y < 0 {
            origin.y = rect.origin.y + rect.height + 5
        }

        setFrameOrigin(origin)
    }

    private func sizeToFit() {
        // Force layout to get accurate sizes
        stackView.layoutSubtreeIfNeeded()

        // Calculate the fitting size from the stack view
        let fittingSize = stackView.fittingSize

        // The fittingSize includes the content, and we add edge insets
        // However, the first/last item backgrounds extend into the edge inset space,
        // so we don't need to add extra width - the fittingSize already accounts for it
        let totalWidth = fittingSize.width + stackView.edgeInsets.left + stackView.edgeInsets.right

        setFrame(NSRect(x: frame.origin.x, y: frame.origin.y, width: totalWidth, height: Self.windowHeight), display: true)
    }
}