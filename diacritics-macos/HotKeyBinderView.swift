import SwiftUI

struct HotKeyBinderView: View {
    @State
    private(set) var hotKey: HotKey?

    @State
    private(set) var isErrored: Bool = false

    @State
    private var isFocused: Bool = false

    var body: some View {
        let cornerRadius: CGFloat = 8

        ZStack {
            // Using space to not let the Text's height shrink when empty.
            Text(hotKey?.description ?? " ")
                .padding(4)
            KeyEventHandling(hotKey: $hotKey, isFocused: $isFocused, isErrored: $isErrored)
            Image(systemName: "xmark")
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 6)
                .background(RoundedCorners(color: .clear, strokeColor: borderColor(), tl: cornerRadius, tr: cornerRadius, bl: cornerRadius, br: cornerRadius))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .onTapGesture {
                    hotKey = nil
                }
        }
        .background(RoundedCorners(color: .white, strokeColor: borderColor(), tl: cornerRadius, tr: cornerRadius, bl: cornerRadius, br: cornerRadius))
        .onChange(of: hotKey, perform: { newHotKey in
            StorageService.hotKey = newHotKey
            if let newHotKey = newHotKey {
                isErrored = !GlobalHotKeyService.registerHotKey(hotKey: newHotKey)
            } else {
                isErrored = !GlobalHotKeyService.unregisterHotKey()
            }
        })
    }

    private func borderColor() -> Color {
        if isErrored {
            return .crimson
        } else if isFocused {
            return .blurple
        } else {
            return .gray
        }
    }
}

private struct KeyEventHandling: NSViewRepresentable {
    private let hotKey: Binding<HotKey?>
    private let isFocused: Binding<Bool>
    private let isErrored: Binding<Bool>

    init(hotKey: Binding<HotKey?>, isFocused: Binding<Bool>, isErrored: Binding<Bool>) {
        self.hotKey = hotKey
        self.isFocused = isFocused
        self.isErrored = isErrored
    }

    func makeNSView(context: Context) -> NSView {
        let view = KeyView()
        view.delegate = context.coordinator
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class KeyView: NSView {
        weak var delegate: KeyViewDelegate?

        override var acceptsFirstResponder: Bool { true }

        override func keyDown(with event: NSEvent) {
            let hotKey = HotKey(
                keyCode: Int(event.keyCode),
                character: event.charactersIgnoringModifiers,
                modifiers: event.modifierFlags
            )
            delegate?.hotKeyChanged(hotKey: hotKey)
        }

        override func becomeFirstResponder() -> Bool {
            let result = super.becomeFirstResponder()
            delegate?.focusChanged(isFocused: true)
            return result
        }

        override func resignFirstResponder() -> Bool {
            let result = super.resignFirstResponder()
            delegate?.focusChanged(isFocused: false)
            return result
        }
    }

    class Coordinator: NSObject, KeyViewDelegate {
        var parent: KeyEventHandling

        init(_ parent: KeyEventHandling) {
            self.parent = parent
        }

        func focusChanged(isFocused: Bool) {
            parent.isFocused.wrappedValue = isFocused
        }

        func hotKeyChanged(hotKey: HotKey) {
            parent.hotKey.wrappedValue = hotKey
        }
    }
}

private protocol KeyViewDelegate: AnyObject {
    func focusChanged(isFocused: Bool)

    func hotKeyChanged(hotKey: HotKey)
}
