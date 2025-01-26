import Foundation

@MainActor
class MatchTrackerViewModel: ObservableObject {
    @Published var tournaments: [Tournament] = []
    @Published var leagues: [League] = []
    @Published var boxLeagues: [BoxLeague] = []
    @Published var friendlies: [Match] = []
    @Published var settings: Settings
    
    private let saveKey = "MatchTrackerData"
    private let settingsKey = "MatchTrackerSettings"
    
    init() {
        // Initialize settings first
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(Settings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = Settings.default
        }
        
        // Then load the rest of the data
        loadData()
    }
    
    func updatePlayerProfile(_ player: Player) {
        settings.playerProfile = player
        saveSettings()
    }
    
    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }
    
    func addTournament(_ tournament: Tournament) {
        tournaments.append(tournament)
        saveData()
    }
    
    func addLeague(_ league: League) {
        leagues.append(league)
        saveData()
    }
    
    func updateMatch(_ updatedMatch: Match, inLeague league: League) {
        guard let leagueIndex = leagues.firstIndex(where: { $0.id == league.id }),
              let matchIndex = leagues[leagueIndex].matches.firstIndex(where: { $0.id == updatedMatch.id }) else {
            return
        }
        leagues[leagueIndex].matches[matchIndex] = updatedMatch
        saveData()
    }
    
    func updateTournament(_ tournament: Tournament) {
        if let index = tournaments.firstIndex(where: { $0.id == tournament.id }) {
            tournaments[index] = tournament
            saveData()
        }
    }
    
    func updateLeague(_ league: League) {
        if let index = leagues.firstIndex(where: { $0.id == league.id }) {
            leagues[index] = league
            saveData()
        }
    }
    
    func addEvent(_ event: Tournament.Event, toTournament tournament: Tournament) {
        if let index = tournaments.firstIndex(where: { $0.id == tournament.id }) {
            var updatedTournament = tournament
            updatedTournament.events.append(event)
            tournaments[index] = updatedTournament
            saveData()
        }
    }
    
    func updateMatch(_ updatedMatch: Match, inTournament tournament: Tournament, eventId: UUID) {
        guard let tournamentIndex = tournaments.firstIndex(where: { $0.id == tournament.id }),
              let eventIndex = tournaments[tournamentIndex].events.firstIndex(where: { $0.id == eventId }),
              let matchIndex = tournaments[tournamentIndex].events[eventIndex].matches.firstIndex(where: { $0.id == updatedMatch.id }) else {
            return
        }
        tournaments[tournamentIndex].events[eventIndex].matches[matchIndex] = updatedMatch
        saveData()
    }
    
    func addMatch(_ match: Match, toLeague league: League) {
        if let index = leagues.firstIndex(where: { $0.id == league.id }) {
            leagues[index].matches.append(match)
            saveData()
        }
    }
    
    func addMatch(_ match: Match, toTournament tournament: Tournament, eventId: UUID) {
        if let tournamentIndex = tournaments.firstIndex(where: { $0.id == tournament.id }),
           let eventIndex = tournaments[tournamentIndex].events.firstIndex(where: { $0.id == eventId }) {
            tournaments[tournamentIndex].events[eventIndex].matches.append(match)
            saveData()
        }
    }
    
    func addFriendly(_ match: Match) {
        friendlies.append(match)
        saveData()
    }
    
    func deleteTournament(_ tournament: Tournament) {
        tournaments.removeAll { $0.id == tournament.id }
        saveData()
    }
    
    func addBoxLeague(_ boxLeague: BoxLeague) {
        boxLeagues.append(boxLeague)
        saveData()
    }
    
    func addMatch(_ match: Match, toBoxLeague boxLeague: BoxLeague) {
        if let index = boxLeagues.firstIndex(where: { $0.id == boxLeague.id }) {
            boxLeagues[index].matches.append(match)
            saveData()
        }
    }
    
    func updateBoxLeague(_ boxLeague: BoxLeague) {
        if let index = boxLeagues.firstIndex(where: { $0.id == boxLeague.id }) {
            boxLeagues[index] = boxLeague
            saveData()
        }
    }
    
    func updateMatch(_ updatedMatch: Match, inBoxLeague boxLeague: BoxLeague) {
        if let boxLeagueIndex = boxLeagues.firstIndex(where: { $0.id == boxLeague.id }),
           let matchIndex = boxLeagues[boxLeagueIndex].matches.firstIndex(where: { $0.id == updatedMatch.id }) {
            boxLeagues[boxLeagueIndex].matches[matchIndex] = updatedMatch
            saveData()
        }
    }
    
    func deleteBoxLeague(_ boxLeague: BoxLeague) {
        boxLeagues.removeAll { $0.id == boxLeague.id }
        saveData()
    }
    
    func removeMatch(_ match: Match, fromBoxLeague boxLeague: BoxLeague) {
        if let boxLeagueIndex = boxLeagues.firstIndex(where: { $0.id == boxLeague.id }) {
            boxLeagues[boxLeagueIndex].matches.removeAll { $0.id == match.id }
            saveData()
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode(SavedData.self, from: data) {
            self.tournaments = decoded.tournaments
            self.leagues = decoded.leagues
            self.boxLeagues = decoded.boxLeagues
            self.friendlies = decoded.friendlies
        }
    }
    
    private func saveData() {
        let savedData = SavedData(
            tournaments: tournaments,
            leagues: leagues,
            boxLeagues: boxLeagues,
            friendlies: friendlies
        )
        
        do {
            let encoded = try JSONEncoder().encode(savedData)
            UserDefaults.standard.set(encoded, forKey: saveKey)
        } catch {
            print("Failed to save data: \(error.localizedDescription)")
        }
    }
}

private struct SavedData: Codable {
    let tournaments: [Tournament]
    let leagues: [League]
    let boxLeagues: [BoxLeague]
    let friendlies: [Match]
} 