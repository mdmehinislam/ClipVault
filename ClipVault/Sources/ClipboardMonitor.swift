import AppKit
import SwiftData

@MainActor
final class ClipboardMonitor {
    private var timer: Timer?
    private var lastChangeCount = NSPasteboard.general.changeCount
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    func start() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 0.65, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.checkClipboard() }
        }
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        guard let text = pasteboard.string(forType: .string) else { return }
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }

        let context = ModelContext(container)
        let descriptor = FetchDescriptor<ClipboardEntry>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let existing = (try? context.fetch(descriptor)) ?? []

        // Avoid consecutive duplicates; move an existing copy to the top.
        if let duplicate = existing.first(where: { $0.text == text }) {
            duplicate.createdAt = .now
            try? context.save()
            return
        }

        context.insert(ClipboardEntry(text: text))
        try? context.save()
        enforceLimit(in: context)
    }

    private func enforceLimit(in context: ModelContext) {
        let descriptor = FetchDescriptor<ClipboardEntry>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let entries = (try? context.fetch(descriptor)) ?? []
        let unpinned = entries.filter { !$0.isPinned }
        if unpinned.count > 500 {
            for entry in unpinned.dropFirst(500) {
                context.delete(entry)
            }
            try? context.save()
        }
    }
}
