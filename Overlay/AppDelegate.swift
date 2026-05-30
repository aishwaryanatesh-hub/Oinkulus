import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var overlayWindow: NSWindow?
    var statusItem: NSStatusItem?
    var overlayState = OverlayState()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon — menu bar only
        NSApp.setActivationPolicy(.accessory)

        setupMenuBar()
        createOverlayWindow()
        updateMenuBarIcon()   // reflect the default-active state
    }

    // MARK: - Menu Bar

    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = nil
            button.title = "🐷"
        }

        let menu = NSMenu()

        let toggleItem = NSMenuItem(title: "Toggle Oinkulus", action: #selector(toggleOverlay), keyEquivalent: "e")
        toggleItem.keyEquivalentModifierMask = [.command, .shift]
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        // Speed submenu
        let speedMenu = NSMenu()
        for speed in [("Fast (0.3 Hz)", 0.3), ("Medium (0.2 Hz)", 0.2), ("Slow (0.1 Hz)", 0.1)] {
            let item = NSMenuItem(title: speed.0, action: #selector(setSpeed(_:)), keyEquivalent: "")
            item.tag = Int(speed.1 * 100)
            item.representedObject = speed.1
            speedMenu.addItem(item)
        }
        let speedItem = NSMenuItem(title: "Speed", action: nil, keyEquivalent: "")
        speedItem.submenu = speedMenu
        menu.addItem(speedItem)

        // Shape submenu
        let shapeMenu = NSMenu()
        for shape in ["Triangle", "Circle", "Diamond", "Pig"] {
            let item = NSMenuItem(title: shape, action: #selector(setShape(_:)), keyEquivalent: "")
            item.representedObject = shape.lowercased()
            shapeMenu.addItem(item)
        }
        let shapeItem = NSMenuItem(title: "Shape", action: nil, keyEquivalent: "")
        shapeItem.submenu = shapeMenu
        menu.addItem(shapeItem)

        // Letters toggle
        let lettersItem = NSMenuItem(title: "Side Letters", action: #selector(toggleLetters), keyEquivalent: "")
        menu.addItem(lettersItem)

        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))

        statusItem?.menu = menu

        // Update checkmarks
        menu.delegate = self
    }

    // MARK: - Overlay Window

    func createOverlayWindow() {
        guard let screen = NSScreen.main else { return }

        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window.level = .statusBar + 1    // above almost everything
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = true  // click-through
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]

        let overlayView = OverlayView(state: overlayState)
        window.contentView = NSHostingView(rootView: overlayView)
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.backgroundColor = .clear

        window.setFrame(screen.frame, display: true)
        window.orderFront(nil)

        self.overlayWindow = window

        // Watch for screen changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    @objc func screenChanged() {
        guard let screen = NSScreen.main, let window = overlayWindow else { return }
        window.setFrame(screen.frame, display: true)
    }

    // MARK: - Actions

    @objc func toggleOverlay() {
        overlayState.isActive.toggle()
        updateMenuBarIcon()
    }

    @objc func setSpeed(_ sender: NSMenuItem) {
        if let speed = sender.representedObject as? Double {
            overlayState.speed = speed
        }
    }

    @objc func setShape(_ sender: NSMenuItem) {
        if let shape = sender.representedObject as? String {
            overlayState.shape = shape
        }
    }

    @objc func toggleLetters() {
        overlayState.lettersEnabled.toggle()
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }

    func updateMenuBarIcon() {
        if let button = statusItem?.button {
            button.image = nil
            // Pig flies when active, sleeps when paused.
            button.title = overlayState.isActive ? "🐷" : "💤"
        }
    }
}

// MARK: - Menu Delegate

extension AppDelegate: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        // Update toggle item title
        if let toggleItem = menu.items.first(where: { $0.action == #selector(toggleOverlay) }) {
            toggleItem.title = overlayState.isActive ? "⏸ Pause Oinkulus" : "▶ Start Oinkulus"
        }

        // Update letters checkmark
        if let lettersItem = menu.items.first(where: { $0.action == #selector(toggleLetters) }) {
            lettersItem.state = overlayState.lettersEnabled ? .on : .off
        }

        // Update speed checkmarks
        if let speedItem = menu.items.first(where: { $0.title == "Speed" }),
           let speedMenu = speedItem.submenu {
            for item in speedMenu.items {
                if let val = item.representedObject as? Double {
                    item.state = abs(val - overlayState.speed) < 0.01 ? .on : .off
                }
            }
        }

        // Update shape checkmarks
        if let shapeItem = menu.items.first(where: { $0.title == "Shape" }),
           let shapeMenu = shapeItem.submenu {
            for item in shapeMenu.items {
                if let val = item.representedObject as? String {
                    item.state = val == overlayState.shape ? .on : .off
                }
            }
        }
    }
}
