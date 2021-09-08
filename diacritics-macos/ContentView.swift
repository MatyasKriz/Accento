import SwiftUI
import LaunchAtLogin

struct ContentView: View {
    private(set) var hotKey: HotKey?
    private(set) var isErrored: Bool

    @State
    private var areNotificationsEnabled = StorageService.areNotificationsEnabled

    @ObservedObject
    private var launchAtLogin = LaunchAtLogin.observable

    private static let columns = Array(repeating: GridItem(.flexible(), alignment: .leading), count: 2)

    var body: some View {
        VStack {
            HStack {
                Text("Preferences.HotKey")
                HotKeyBinderView(
                    hotKey: hotKey,
                    isErrored: isErrored
                )
                .frame(maxWidth: 128, maxHeight: 26)
            }
            .frame(maxWidth: .infinity)

            Toggle("Preferences.LaunchAtLogin", isOn: $launchAtLogin.isEnabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)

            Toggle("Preferences.Notification", isOn: $areNotificationsEnabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
                .onChange(of: areNotificationsEnabled, perform: {
                    StorageService.areNotificationsEnabled = $0
                })

            HStack {
                Text("Preferences.PoweredBy")
                Link(destination: URL(string: "https://www.nechybujte.cz/nastroje")!) {
                    Image("lingea")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
                        .foregroundColor(Color.primary)
                }
                .onHover { isInside in
                    if isInside {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top)
        }
        .padding()
    }
}
