import Foundation

struct Match: Identifiable, Codable, Equatable {
    enum MatchStatus: String, Codable {
        case walkover = "Walkover"
        case retired = "Retired"
        case defaulted = "Default"
    }
    
    var id = UUID()
    var player: String
    var opponent: String
    var score: String
    var result: Result
    var date: Date
    var round: String
    var handedness: String = "Unknown"
    var wtn: Double?
    var ranking: Int?
    var notes: String?
    var status: MatchStatus?
    var county: County?
    
    var playerSets: Int {
        score.components(separatedBy: ",")
            .compactMap { set -> Int? in
                let scores = set.trimmingCharacters(in: .whitespaces)
                    .components(separatedBy: "-")
                    .compactMap(Int.init)
                guard scores.count == 2 else { return nil }
                return scores[0] > scores[1] ? 1 : 0
            }
            .reduce(0, +)
    }
    
    var opponentSets: Int {
        score.components(separatedBy: ",")
            .compactMap { set -> Int? in
                let scores = set.trimmingCharacters(in: .whitespaces)
                    .components(separatedBy: "-")
                    .compactMap(Int.init)
                guard scores.count == 2 else { return nil }
                return scores[1] > scores[0] ? 1 : 0
            }
            .reduce(0, +)
    }
    
    enum Result: String, Codable, CaseIterable, Equatable {
        case win = "Win"
        case loss = "Loss"
        case draw = "Draw"
    }
    
    static func == (lhs: Match, rhs: Match) -> Bool {
        lhs.id == rhs.id &&
        lhs.player == rhs.player &&
        lhs.opponent == rhs.opponent &&
        lhs.score == rhs.score &&
        lhs.result == rhs.result &&
        lhs.date == rhs.date &&
        lhs.round == rhs.round &&
        lhs.handedness == rhs.handedness &&
        lhs.wtn == rhs.wtn &&
        lhs.ranking == rhs.ranking &&
        lhs.notes == rhs.notes &&
        lhs.status == rhs.status &&
        lhs.county == rhs.county
    }
    
    init(id: UUID = UUID(), date: Date, player: String, opponent: String, score: String, result: Result, round: String, notes: String? = nil, status: MatchStatus? = nil, county: County? = nil) {
        self.id = id
        self.date = date
        self.player = player
        self.opponent = opponent
        self.score = score
        self.result = result
        self.round = round
        self.notes = notes
        self.status = status
        self.county = county
    }
} 