import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
}

extension GameRecord: Comparable {
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        lhs.correct < rhs.correct
    }
}

extension GameRecord: CustomStringConvertible {
    var description: String {
        return "\(correct)/\(total) (\(date.dateTimeString))"
    }
}
