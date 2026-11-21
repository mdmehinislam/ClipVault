import AppKit
import ApplicationServices
import CoreGraphics

@MainActor
final class QuickPasteService {
    static let shared = QuickPasteService()
    private weak var previousApplication: NSRunningApplication?

    func rememberFrontmostApplication() {
        let current = NSWorkspace.shared.frontmostApplication
        if current?.bundleIdentifier != Bundle.main.bundleIdentifier {
            previousApplication = current
        }
    }

    func paste(_ text: String, closePopup: @escaping () -> Void) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        closePopup()

        guard let target = previousApplication else {
            NSSound.beep()
            return
        }

        target.activate(options: [.activateIgnoringOtherApps])
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            guard AXIsProcessTrusted() else {
                NSSound.beep()
                return
            }
            let source = CGEventSource(stateID: .hidSystemState)
            let down = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: true)
            let up = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: false)
            down?.flags = .maskCommand
            up?.flags = .maskCommand
            down?.post(tap: .cghidEventTap)
            up?.post(tap: .cghidEventTap)
        }
    }
}
