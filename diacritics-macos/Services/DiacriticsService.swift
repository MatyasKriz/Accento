import Cocoa
import UserNotifications

final class DiacriticsService {
    static func addDiacriticsToClipboardText() {
        guard
            let payload = NSPasteboard.general.string(forType: .string).map(Request.init(text:)),
            let payloadData = try? JSONEncoder().encode(payload) else { return }

        var request = URLRequest(url: URL(string: "https://www.nechybujte.cz/adddiacritics")!)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = payloadData

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let responseString = data.flatMap({ String(data: $0, encoding: .utf8) }) else { return }
            let cleanString = responseString
                .replacingOccurrences(of: "<word>", with: "")
                .replacingOccurrences(of: "</word>", with: "")
            let range = NSRange(location: 0, length: cleanString.utf16.count)
            let regex = try! NSRegularExpression(pattern: "<var .*? data-part=\"(.*?)\">(.*?)</var>")
            let matches = regex.matches(in: cleanString, options: [], range: range)

            var conflicts: [Conflict] = []
            var resultString = cleanString
            for match in matches.reversed() {
                let variantsRange = match.range(at: 1)
                let wordRange = match.range(at: 2)

                conflicts.append(
                    .init(
                        variants: resultString[variantsRange].components(separatedBy: ","),
                        word: String(resultString[wordRange])
                    )
                )

                resultString.removeSubrange(wordRange.upperBound..<match.range.upperBound)
                resultString.removeSubrange(match.range.lowerBound..<wordRange.lowerBound)
            }

            NSPasteboard.general.declareTypes([.string], owner: nil)
            NSPasteboard.general.setString(resultString, forType: .string)

            

            if StorageService.areNotificationsEnabled {
                UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .badge]) { granted, error in
                        let content = UNMutableNotificationContent()
                        content.title = "Notification.Title".localized
                        let conflictsSuffix: String
                        if conflicts.isEmpty {
                            conflictsSuffix = ""
                        } else {
                            conflictsSuffix = "Notification.Subtitle.Uncertainties".localized(String(conflicts.count))
                        }
                        content.subtitle = "Notification.Subtitle.Base".localized(conflictsSuffix)

                        // Define when banner will appear - this is set to 1 second - note you cannot set this to zero.
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false);

                        let notification = UNNotificationRequest(
                            identifier: UUID().uuidString,
                            content: content,
                            trigger: trigger
                        )
                        UNUserNotificationCenter.current().add(notification, withCompletionHandler: nil)
                    }
            }
        }.resume()
    }

    private struct Request: Encodable {
        let text: String
    }

    private struct Conflict {
        let variants: [String]
        let word: String
    }
}
