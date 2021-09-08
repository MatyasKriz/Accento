import Foundation
import Carbon

final class StorageService {
    private static let hotKeyKey = "hotKey"
    private static let notificationsEnabledKey = "notificationsEnabled"

    static var hotKey: HotKey? {
        get {
            UserDefaults.standard.data(forKey: Self.hotKeyKey).map { try! JSONDecoder().decode(HotKey.self, from: $0) }
                ?? HotKey(keyCode: kVK_ANSI_D, character: "D", modifiers: [.control, .option, .command])
        }
        set {
            if let newHotKey = newValue {
                UserDefaults.standard.setValue(try! JSONEncoder().encode(newHotKey), forKey: Self.hotKeyKey)
            } else {
                UserDefaults.standard.removeObject(forKey: Self.hotKeyKey)
            }
        }
    }

    static var areNotificationsEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: Self.notificationsEnabledKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.notificationsEnabledKey)
        }
    }
}
