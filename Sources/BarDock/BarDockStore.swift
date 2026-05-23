import Foundation

@MainActor
final class BarDockStore: ObservableObject {
    @Published var isCollapsed: Bool {
        didSet { save() }
    }

    private let collapsedKey = "BarDock.lite.isCollapsed"

    init() {
        isCollapsed = false
    }

    func toggleCollapsed() {
        isCollapsed.toggle()
    }

    private func save() {
        UserDefaults.standard.set(isCollapsed, forKey: collapsedKey)
    }
}
