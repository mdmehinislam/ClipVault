import Foundation
import SwiftData

@Model
final class ClipboardEntry {
    var id: UUID
    var text: String
    var createdAt: Date
    var isPinned: Bool

    init(text: String, createdAt: Date = .now, isPinned: Bool = false) {
        self.id = UUID()
        self.text = text
        self.createdAt = createdAt
        self.isPinned = isPinned
    }
}
