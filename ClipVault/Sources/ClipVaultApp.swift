import SwiftUI
import SwiftData

@main
struct ClipVaultApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: ClipboardEntry.self)
            AppServices.shared.container = container
        } catch {
            fatalError("Could not initialize ClipVault database: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .frame(minWidth: 720, minHeight: 520)
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}
