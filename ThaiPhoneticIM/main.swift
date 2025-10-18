import Cocoa
import InputMethodKit

// Find the bundle identifier
guard let mainBundle = Bundle.main.bundleIdentifier else {
    NSLog("Failed to get bundle identifier")
    exit(1)
}

// Connection name from Info.plist
guard let connectionName = Bundle.main.infoDictionary?["InputMethodConnectionName"] as? String else {
    NSLog("Failed to get InputMethodConnectionName from Info.plist")
    exit(1)
}

NSLog("Initializing IMKServer with connection: \(connectionName), bundle: \(mainBundle)")

// Initialize the input method server
guard let server = IMKServer(name: connectionName, bundleIdentifier: mainBundle) else {
    NSLog("Failed to initialize input method server")
    exit(1)
}

NSLog("IMKServer initialized successfully")

// Load and run the application
NSApplication.shared.run()
