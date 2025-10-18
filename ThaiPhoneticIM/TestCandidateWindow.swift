// TestCandidateWindow.swift
// Standalone test app for the candidate window
// Build with: swiftc TestCandidateWindow.swift ThaiCandidateWindow.swift -o TestCandidateWindow -framework Cocoa
// Run with: ./TestCandidateWindow

import Cocoa

class TestAppDelegate: NSObject, NSApplicationDelegate {
    var window: ThaiCandidateWindow!
    var currentIndex = 0

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the candidate window
        window = ThaiCandidateWindow()

        // Test with sample Thai candidates (single word)
        let candidates = ["ฟ้า", "ฝา", "ผา", "ฝ่า", "ฟา", "ฟะ", "ฟ่า", "ฟาร์", "ฟาห์"]
        window.updateCandidates(candidates, selected: 0)

        // Position in the center of the screen
        if let screen = NSScreen.main {
            let screenFrame = screen.frame
            let windowX = screenFrame.midX - window.frame.width / 2
            let windowY = screenFrame.midY
            window.setFrameOrigin(NSPoint(x: windowX, y: windowY))
        }

        // Show the window
        window.orderFront(nil)
        window.makeKey()

        print("Candidate Window Test App")
        print("=========================")
        print("Commands:")
        print("  Left/Right Arrow - Navigate candidates")
        print("  1-9 - Select candidate by number")
        print("  S - Single-word candidates (short)")
        print("  M - Multi-word candidates (longer phrases)")
        print("  L - Long multi-word candidates")
        print("  Q - Quit")
        print("")
        print("Current: Single-word candidates")

        // Set up event monitor for keyboard input
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
            return nil
        }
    }

    func handleKeyEvent(_ event: NSEvent) {
        guard let characters = event.characters else { return }

        switch characters.lowercased() {
        case "q":
            NSApplication.shared.terminate(nil)

        case "s":
            // Single-word candidates (short)
            let singleWord = ["ฟ้า", "ฝา", "ผา", "ฝ่า", "ฟา", "ฟะ", "ฟ่า", "ฟาร์", "ฟาห์"]
            window.updateCandidates(singleWord, selected: 0)
            currentIndex = 0
            print("→ Single-word candidates (9 words)")

        case "m":
            // Multi-word candidates (2-3 words joined)
            // Simulating "pom gin kao" → "ผมกินข้าว" type results
            let multiWord = [
                "ผมกินข้าว",      // pom gin kao (I eat rice)
                "ผมกินเก่า",      // variant
                "ผมคิดข้าว",      // pom kin kao variant
                "พมกินข้าว",      // pom variant + gin kao
                "ผมกิ่นข้าว",     // pom + gin variant + kao
                "ผมกินข่าว"       // pom gin khao variant (news)
            ]
            window.updateCandidates(multiWord, selected: 0)
            currentIndex = 0
            print("→ Multi-word candidates (6 combinations)")
            print("  Simulating: pom gin kao → ผมกินข้าว")

        case "l":
            // Long multi-word candidates (3-4 words)
            let longMultiWord = [
                "ผมกินข้าวเย็น",        // pom gin kao yen (I eat dinner)
                "ผมกินข้าวเช้า",        // pom gin kao chao (I eat breakfast)
                "ผมอยากกินข้าว",        // pom yaak gin kao (I want to eat rice)
                "ผมไม่กินข้าว",         // pom mai gin kao (I don't eat rice)
                "ผมชอบกินข้าว",         // pom chop gin kao (I like to eat rice)
                "ผมต้องกินข้าว"          // pom tong gin kao (I must eat rice)
            ]
            window.updateCandidates(longMultiWord, selected: 0)
            currentIndex = 0
            print("→ Long multi-word candidates (6 phrases)")
            print("  Simulating: pom yaak gin kao → ผมอยากกินข้าว")

        case _ where characters == String(UnicodeScalar(NSRightArrowFunctionKey)!):
            window.selectNext()
            print("Selected next candidate")

        case _ where characters == String(UnicodeScalar(NSLeftArrowFunctionKey)!):
            window.selectPrevious()
            print("Selected previous candidate")

        case let num where num.count == 1 && Int(num) != nil:
            if let index = Int(num), index >= 1 && index <= 9 {
                window.selectCandidate(at: index - 1)
                print("Selected candidate \(index)")
            }

        default:
            break
        }
    }
}

// Main entry point
@main
struct TestCandidateWindowApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = TestAppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.regular)
        app.activate(ignoringOtherApps: true)
        app.run()
    }
}
