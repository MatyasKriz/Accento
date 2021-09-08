import Cocoa
import Carbon

// Source: https://stackoverflow.com/a/58225397/11558478
final class GlobalHotKeyService {
    private static var hotKeyRef: EventHotKeyRef?

    static func installHandler() {
        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyReleased)

        // Install handler.
        InstallEventHandler(GetApplicationEventTarget(), hotKeyHandler(nextHandler:eventRef:userData:), 1, &eventType, nil, nil)
    }

    @discardableResult
    static func registerHotKey(hotKey: HotKey) -> Bool {
        // Unregister old hotKey.
        unregisterHotKey()

        let hotKeyId = EventHotKeyID(
            signature: OSType("swat".fourCharCodeValue),
            id: UInt32(hotKey.keyCode)
        )

        // Register hotkey.
        let status = RegisterEventHotKey(
            hotKeyId.id,
            hotKey.modifiers.carbonFlags,
            hotKeyId,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        if status == noErr {
            print("Successfully registered hot key '\(hotKey)'.")
        } else {
            print("Failed to register hot key '\(hotKey)', error: '\(status)'.")
        }

        return status == noErr
    }

    @discardableResult
    static func unregisterHotKey() -> Bool {
        if let hotKeyRef = hotKeyRef {
            let status = UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
            return status == noErr
        } else {
            return true
        }
    }
}

private extension String {
    /// This converts string to UInt as a fourCharCode
    var fourCharCodeValue: Int {
        var result: Int = 0
        if let data = self.data(using: String.Encoding.macOSRoman) {
            data.withUnsafeBytes({ (rawBytes) in
                let bytes = rawBytes.bindMemory(to: UInt8.self)
                for i in 0 ..< data.count {
                    result = result << 8 + Int(bytes[i])
                }
            })
        }
        return result
    }
}

private extension NSEvent.ModifierFlags {
    var carbonFlags: UInt32 {
        let flags = rawValue
        var newFlags: Int = 0

        if ((flags & NSEvent.ModifierFlags.control.rawValue) > 0) {
            newFlags |= controlKey
        }

        if ((flags & NSEvent.ModifierFlags.command.rawValue) > 0) {
            newFlags |= cmdKey
        }

        if ((flags & NSEvent.ModifierFlags.shift.rawValue) > 0) {
            newFlags |= shiftKey;
        }

        if ((flags & NSEvent.ModifierFlags.option.rawValue) > 0) {
            newFlags |= optionKey
        }

        if ((flags & NSEvent.ModifierFlags.capsLock.rawValue) > 0) {
            newFlags |= alphaLock
        }

        return UInt32(newFlags)
    }
}
