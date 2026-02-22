import Cocoa
import WebKit

// MARK: - Draggable borderless window

class FaceWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    private var dragOrigin: NSPoint?

    override func sendEvent(_ event: NSEvent) {
        switch event.type {
        case .leftMouseDown:
            dragOrigin = NSEvent.mouseLocation
        case .leftMouseDragged:
            guard let origin = dragOrigin else { super.sendEvent(event); return }
            let current = NSEvent.mouseLocation
            setFrameOrigin(NSPoint(
                x: frame.origin.x + (current.x - origin.x),
                y: frame.origin.y + (current.y - origin.y)
            ))
            dragOrigin = current
        case .leftMouseUp:
            dragOrigin = nil
        default:
            super.sendEvent(event)
        }
    }
}

// MARK: - App delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: FaceWindow!
    var webView: WKWebView!
    var statusItem: NSStatusItem!
    var currentAvatar = "flubber"
    let baseURL = "http://localhost:3456"
    let avatarNames = ["flubber", "default", "cat", "robot", "ghost", "blob"]
    var widgetSize: CGFloat = 200

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupWindow()
        setupMenuBar()
        loadAvatar(currentAvatar)
    }

    func setupWindow() {
        let screen = NSScreen.main!.visibleFrame
        let origin = NSPoint(x: screen.maxX - widgetSize - 20, y: screen.minY + 20)

        window = FaceWindow(
            contentRect: NSRect(origin: origin, size: NSSize(width: widgetSize, height: widgetSize)),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.isMovableByWindowBackground = true
        window.hasShadow = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]

        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "developerExtrasEnabled")
        webView = WKWebView(frame: NSRect(x: 0, y: 0, width: widgetSize, height: widgetSize), configuration: config)
        webView.setValue(false, forKey: "drawsBackground")

        window.contentView = webView
        window.makeKeyAndOrderFront(nil)

        // Right-click on widget → same menu
        let contextMenu = NSMenu()
        buildMenu(contextMenu)
        webView.menu = contextMenu
    }

    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.title = "🎭"
        }
        let menu = NSMenu()
        buildMenu(menu)
        statusItem.menu = menu
    }

    func buildMenu(_ menu: NSMenu) {
        menu.removeAllItems()

        // Avatar section
        let header = NSMenuItem(title: "Avatar", action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)

        for name in avatarNames {
            let item = NSMenuItem(title: name.capitalized, action: #selector(switchAvatar(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = name
            if name == currentAvatar {
                item.state = .on
            }
            menu.addItem(item)
        }

        menu.addItem(NSMenuItem.separator())

        // Size section
        let sizeHeader = NSMenuItem(title: "Size", action: nil, keyEquivalent: "")
        sizeHeader.isEnabled = false
        menu.addItem(sizeHeader)

        for (label, size) in [("Small", CGFloat(150)), ("Medium", CGFloat(200)), ("Large", CGFloat(300))] {
            let item = NSMenuItem(title: label, action: #selector(changeSize(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = size
            if size == widgetSize {
                item.state = .on
            }
            menu.addItem(item)
        }

        menu.addItem(NSMenuItem.separator())

        // Open in browser
        let browserItem = NSMenuItem(title: "Open Picker in Browser", action: #selector(openBrowser), keyEquivalent: "b")
        browserItem.target = self
        menu.addItem(browserItem)

        menu.addItem(NSMenuItem.separator())

        // Quit
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }

    func loadAvatar(_ name: String) {
        currentAvatar = name
        // Clear old content first to prevent ghosting artifacts on transparent bg
        webView.loadHTMLString("<html><body style='background:transparent'></body></html>", baseURL: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            let url = URL(string: "\(baseURL)/avatar/\(name)?widget")!
            webView.load(URLRequest(url: url))
        }

        // Refresh menus to update checkmarks
        if let menu = statusItem?.menu { buildMenu(menu) }
        if let menu = webView?.menu { buildMenu(menu) }
    }

    @objc func switchAvatar(_ sender: NSMenuItem) {
        guard let name = sender.representedObject as? String else { return }
        loadAvatar(name)
    }

    @objc func changeSize(_ sender: NSMenuItem) {
        guard let size = sender.representedObject as? CGFloat else { return }
        widgetSize = size

        let origin = window.frame.origin
        window.setFrame(NSRect(origin: origin, size: NSSize(width: size, height: size)), display: true, animate: true)
        webView.frame = NSRect(x: 0, y: 0, width: size, height: size)

        // Refresh menus
        if let menu = statusItem?.menu { buildMenu(menu) }
        if let menu = webView?.menu { buildMenu(menu) }
    }

    @objc func openBrowser() {
        NSWorkspace.shared.open(URL(string: baseURL)!)
    }
}

// MARK: - Launch

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
