import Cocoa

struct HotKey: Equatable {
    let keyCode: Int
    let character: String?
    private let modifiersRawValue: UInt

    var modifiers: NSEvent.ModifierFlags {
        return .init(rawValue: modifiersRawValue)
    }

    init(keyCode: Int, character: String?, modifiers: NSEvent.ModifierFlags) {
        self.keyCode = keyCode
        self.character = character
        self.modifiersRawValue = modifiers.rawValue
    }
}

extension HotKey: Codable {}

extension HotKey: CustomStringConvertible {
    var description: String {
        var stringBuilder = ""
        if modifiers.contains(.function) {
            stringBuilder += "fn"
        }
        if modifiers.contains(.control) {
            stringBuilder += "⌃"
        }
        if modifiers.contains(.option) {
            stringBuilder += "⌥"
        }
        if modifiers.contains(.command) {
            stringBuilder += "⌘"
        }
        if modifiers.contains(.shift) {
            stringBuilder += "⇧"
        }
        if modifiers.contains(.capsLock) {
            stringBuilder += "⇪"
        }
        if let character = character {
            stringBuilder += character.uppercased()
        }
        return stringBuilder
    }
}
