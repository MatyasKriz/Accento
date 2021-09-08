import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }

    func localized(_ parameters: CVarArg...) -> String {
        String(format: localized, arguments: parameters)
    }
}
