import Foundation
import SwiftData

final class AppServices {
    static let shared = AppServices()
    var container: ModelContainer?
    private init() {}
}
