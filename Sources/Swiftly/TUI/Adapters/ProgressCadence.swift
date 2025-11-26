import Foundation

enum ProgressCadence {
    static func isCadenceValid(updates: [Date], maxInterval: TimeInterval = 5.0) -> Bool {
        guard updates.count > 1 else { return true }
        let pairs = zip(updates, updates.dropFirst())
        return pairs.allSatisfy { (lhs, rhs) in rhs.timeIntervalSince(lhs) <= maxInterval }
    }
}
