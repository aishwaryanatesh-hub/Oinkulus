import SwiftUI

@main
struct OverlayApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // We use a menu bar app with no main window.
        // The overlay window is managed by AppDelegate.
        Settings {
            EmptyView()
        }
    }
}
