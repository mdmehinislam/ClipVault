import AppKit
import SwiftUI
import SwiftData

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var panel: NSPanel?
    private var monitor: ClipboardMonitor?
    private let shortcut = GlobalShortcut()
    private var container: ModelContainer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        container = AppServices.shared.container
        if let container {
            monitor = ClipboardMonitor(container: container)
            monitor?.start()
        }

        shortcut.onShortcut = { [weak self] in self?.togglePopup() }
        shortcut.registerOptionV()
    }

    func togglePopup() {
        guard let container else { return }
        if let panel, panel.isVisible {
            panel.orderOut(nil)
            return
        }

        QuickPasteService.shared.rememberFrontmostApplication()
        if panel == nil {
            let view = ContentView(isPopup: true, onClose: { [weak self] in
                self?.panel?.orderOut(nil)
            })
            let hosting = NSHostingView(rootView: view.modelContainer(container))
            let newPanel = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 440, height: 560),
                                   styleMask: [.titled, .fullSizeContentView, .nonactivatingPanel],
                                   backing: .buffered, defer: false)
            newPanel.title = "ClipVault"
            newPanel.isFloatingPanel = true
            newPanel.level = .floating
            newPanel.center()
            newPanel.contentView = hosting
            newPanel.isReleasedWhenClosed = false
            panel = newPanel
        }

        panel?.center()
        NSApp.activate(ignoringOtherApps: true)
        panel?.makeKeyAndOrderFront(nil)
    }
}
