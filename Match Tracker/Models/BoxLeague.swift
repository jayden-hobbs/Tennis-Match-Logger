import Foundation

struct BoxLeague: Identifiable, Codable {
    var id = UUID()
    var name: String
    var box: String
    var season: String
    var matches: [Match]
    var players: [Player]
    var leagueURL: String?
} 