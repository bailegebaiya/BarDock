import AppKit
import Combine
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let store = BarDockStore()
    private var panel: NSPanel?
    private var boundaryItem: NSStatusItem?
    private var controlItem: NSStatusItem?
    private var cancellables = Set<AnyCancellable>()

    private let shownLength: CGFloat = 18
    private let hiddenLength: CGFloat = 10_000

    func applicationDidFinishLaunching(_ notification: Notification) {
        configureStatusItems()
        configurePanel()
        observeStore()
        applyState()

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(250))
            showPanel()
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showPanel()
        return true
    }

    private func configureStatusItems() {
        controlItem = makeStatusItem(name: "local.bardock.dozer.control.v2")
        boundaryItem = makeStatusItem(name: "local.bardock.dozer.boundary.v2")
    }

    private func makeStatusItem(name: String) -> NSStatusItem {
        let item = NSStatusBar.system.statusItem(withLength: shownLength)
        item.autosaveName = name

        if let button = item.button {
            button.alignment = .center
            button.sendAction(on: [.leftMouseDown, .rightMouseDown])
            button.action = #selector(statusIconClicked(_:))
            button.target = self
        }

        return item
    }

    private func configurePanel() {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 212),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.isOpaque = false
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.hidesOnDeactivate = true
        panel.contentView = NSHostingView(
            rootView: BarDockPanel(
                store: store,
                onToggle: { [weak self] in self?.toggleCollapsed() }
            )
            .frame(width: 300, height: 212)
        )
        self.panel = panel
    }

    private func observeStore() {
        store.$isCollapsed
            .sink { [weak self] _ in self?.applyState() }
            .store(in: &cancellables)
    }

    @objc private func statusIconClicked(_ sender: NSStatusBarButton) {
        switch NSApp.currentEvent?.type {
        case .rightMouseDown:
            showPanel()
        case .leftMouseDown:
            toggleCollapsed()
        default:
            break
        }
    }

    private func toggleCollapsed() {
        store.isCollapsed.toggle()
    }

    private func applyState() {
        boundaryItem?.length = store.isCollapsed ? hiddenLength : shownLength
        controlItem?.length = shownLength

        if let button = boundaryItem?.button {
            button.image = nil
            button.title = store.isCollapsed ? "" : "·"
            button.font = .systemFont(ofSize: 16, weight: .semibold)
            button.alphaValue = store.isCollapsed ? 0.01 : 0.42
            button.toolTip = "BarDock 边界：按住 Command 拖动到要隐藏的图标右侧"
        }

        if let button = controlItem?.button {
            button.image = nil
            button.title = store.isCollapsed ? "‹" : "›"
            button.font = .systemFont(ofSize: 16, weight: .semibold)
            button.alphaValue = 1
            button.toolTip = store.isCollapsed ? "显示隐藏图标" : "隐藏左侧图标"
        }
    }

    private func showPanel() {
        guard let button = controlItem?.button else { return }
        showPanel(anchoredTo: button)
    }

    private func showPanel(anchoredTo button: NSStatusBarButton) {
        guard let panel, let buttonWindow = button.window else { return }

        let buttonRectInWindow = button.convert(button.bounds, to: nil)
        let buttonRectOnScreen = buttonWindow.convertToScreen(buttonRectInWindow)
        let panelSize = panel.frame.size
        let screenFrame = buttonWindow.screen?.visibleFrame ?? NSScreen.main?.visibleFrame ?? .zero

        let idealX = buttonRectOnScreen.midX - panelSize.width / 2
        let x = min(max(idealX, screenFrame.minX + 8), screenFrame.maxX - panelSize.width - 8)
        let y = buttonRectOnScreen.minY - panelSize.height - 8

        panel.setFrameOrigin(NSPoint(x: x, y: y))
        panel.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }
}
