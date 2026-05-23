import AppKit

@main
struct BarDockMain {
    @MainActor
    private static var delegate: AppDelegate?

    @MainActor
    static func main() {
        let application = NSApplication.shared
        let appDelegate = AppDelegate()

        delegate = appDelegate
        application.delegate = appDelegate
        application.setActivationPolicy(.accessory)
        application.run()
    }
}
