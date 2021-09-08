import Cocoa
import Carbon
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    private var window: NSWindow!

    private var popover: NSPopover!
    private var statusBarItem: NSStatusItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        GlobalHotKeyService.installHandler()

        let isInitialRegistrationSuccessful: Bool
        if let initialHotKey = StorageService.hotKey {
            isInitialRegistrationSuccessful = GlobalHotKeyService.registerHotKey(hotKey: initialHotKey)
        } else {
            isInitialRegistrationSuccessful = true
        }

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(
            hotKey: StorageService.hotKey,
            isErrored: !isInitialRegistrationSuccessful
        )

        popover = NSPopover()
        popover.contentSize = NSSize(width: 240, height: 360)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)

        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        constructMenu()

        if let button = statusBarItem.button {
            button.image = NSImage(named: "logo")
            button.image?.size = NSSize(width: 18.0, height: 18.0)
        }
    }

    private func constructMenu() {
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Menu.Diacriticize".localized, action: #selector(AppDelegate.addDiacritics(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Menu.Preferences".localized, action: #selector(AppDelegate.togglePopover(_:)), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Menu.Quit".localized, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusBarItem.menu = menu
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc
    func togglePopover(_ sender: AnyObject?) {
        if let button = statusBarItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                popover.contentViewController?.view.window?.becomeKey()
            }
        }
    }

    @objc
    func addDiacritics(_ sender: AnyObject?) {
        DiacriticsService.addDiacriticsToClipboardText()
    }
}

func hotKeyHandler(nextHandler: EventHandlerCallRef?, eventRef: EventRef?, userData: UnsafeMutableRawPointer?) -> OSStatus {
    DiacriticsService.addDiacriticsToClipboardText()

    return noErr
}
