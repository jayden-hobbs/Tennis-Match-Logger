import Foundation

struct League: Identifiable, Codable {
    var id = UUID()
    var name: String
    var division: String
    var season: String
    var matches: [Match]
    var leagueURL: String?
} 