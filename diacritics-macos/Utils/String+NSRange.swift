import Cocoa

extension String {
    subscript(range: NSRange) -> Substring {
        self[
            index(startIndex, offsetBy: range.lowerBound)
            ..<
            index(startIndex, offsetBy: range.upperBound)
        ]
    }

    mutating func removeSubrange(_ range: Range<Int>) {
        removeSubrange(
            index(startIndex, offsetBy: range.lowerBound)
            ..<
            index(startIndex, offsetBy: range.upperBound)
        )
    }
}
