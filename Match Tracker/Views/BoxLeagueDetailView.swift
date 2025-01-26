import SwiftUI

// Add this if your ViewModel is in a separate module
// import ViewModels

// If you have a separate Models module or file, import it
// import Models  // Uncomment if needed

// New helper struct to track matches
struct BoxMatch: Identifiable {
    let id = UUID()
    let player1: Player
    let player2: Player
    let isPlayed: Bool
    let match: Match?
    
    var versusText: String {
        "\(player1.name) vs \(player2.name)"
    }
}

struct PlayerStanding: Identifiable {
    let id = UUID()
    let name: String
    let played: Int
    let wins: Int
    let losses: Int
    let setsWon: Int
    let setsLost: Int
    let player: Player
    
    var points: Int {
        wins * 2
    }
    
    var setRatio: Double {
        guard setsLost > 0 else { return Double(setsWon) }  // Handle division by zero
        return Double(setsWon) / Double(setsLost)
    }
}

struct BoxMatchResult {
    let score: String
    let winner: String
}

struct ResultCell: View {
    let result: BoxMatchResult?
    
    var body: some View {
        Group {
            if let result = result {
                VStack(spacing: 2) {
                    Text(result.score)
                        .font(.caption2)
                    Text(result.winner)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "plus.circle")
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

struct BoxLeagueDetailView: View {
    @ObservedObject var viewModel: MatchTrackerViewModel
    let boxLeague: BoxLeague
    @Environment(\.dismiss) var dismiss
    @State private var showingEditBoxLeague = false
    @State private var showingDeleteConfirmation = false
    @State private var selectedMatch: BoxMatch?

    var allPossibleMatches: [BoxMatch] {
        var matches: [BoxMatch] = []
        let players = boxLeague.players
        
        // Generate all possible combinations where each player plays against every other player once
        for i in 0..<players.count {
            let player1 = players[i]
            
            for j in (i + 1)..<players.count {
                let player2 = players[j]
                
                // Check if this match exists with player1 as player
                let existingMatch1 = boxLeague.matches.first { match in
                    match.player == player1.name && match.opponent == player2.name
                }
                
                // Check if this match exists with player1 as opponent
                let existingMatch2 = boxLeague.matches.first { match in
                    match.player == player2.name && match.opponent == player1.name
                }
                
                // Use the first match found, if any
                let existingMatch = existingMatch1 ?? existingMatch2
                
                let boxMatch = BoxMatch(
                    player1: player1,
                    player2: player2,
                    isPlayed: existingMatch != nil,
                    match: existingMatch
                )
                
                matches.append(boxMatch)
            }
        }
        
        return matches
    }

    var standingsSection: some View {
        Section("Standings") {
            VStack(spacing: 0) {
                StandingsHeaderRow()
                ForEach(standings) { standing in
                    StandingsRow(standing: standing)
                }
            }
        }
    }
    
    var matchesSection: some View {
        Section("All Matches") {
            let matches = Array(zip(allPossibleMatches.indices, allPossibleMatches))
            ForEach(matches, id: \.0) { index, boxMatch in
                MatchRow(boxMatch: boxMatch, viewModel: viewModel, boxLeague: boxLeague)
            }
        }
    }

    var body: some View {
        List {
            standingsSection
            matchesSection
        }
        .listStyle(.insetGrouped)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(boxLeague.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    Image(systemName: "trash")
                }
            }
        }
        .alert("Delete Box League?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                viewModel.deleteBoxLeague(boxLeague)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showingEditBoxLeague) {
            EditBoxLeagueView(boxLeague: boxLeague, viewModel: viewModel)
        }
        .onAppear {
            print("Box League Detail View appeared for: \(boxLeague.name)")
            print("All Possible Matches: \(allPossibleMatches)")
        }
    }
    
    // Helper function to count wins for a player
    private func countWins(for player: Player, in matches: [Match]) -> Int {
        matches.filter { match in
            (match.player == player.name && match.result == .win) ||
            (match.opponent == player.name && match.result == .loss)
        }.count
    }
    
    // Helper function to count losses for a player
    private func countLosses(for player: Player, in matches: [Match]) -> Int {
        matches.filter { match in
            (match.player == player.name && match.result == .loss) ||
            (match.opponent == player.name && match.result == .win)
        }.count
    }
    
    // Helper function to calculate sets for a player
    private func calculateSets(for player: Player, in matches: [Match]) -> (won: Int, lost: Int) {
        var setsWon = 0
        var setsLost = 0
        
        for match in matches {
            // Split by spaces instead of commas
            let sets = match.score.split(separator: " ")
            
            for setScore in sets {
                guard setScore.contains("-") else { continue }
                
                let scores = setScore.components(separatedBy: "-")
                guard scores.count == 2,
                      let score1 = Int(scores[0].trimmingCharacters(in: .whitespaces)),
                      let score2 = Int(scores[1].trimmingCharacters(in: .whitespaces)) else { continue }
                
                if match.player == player.name {
                    if score1 > score2 {
                        setsWon += 1
                    } else if score2 > score1 {
                        setsLost += 1
                    }
                } else {
                    if score1 > score2 {
                        setsLost += 1
                    } else if score2 > score1 {
                        setsWon += 1
                    }
                }
            }
        }
        
        print("Sets for \(player.name): Won \(setsWon), Lost \(setsLost)")  // Add debug print
        return (setsWon, setsLost)
    }
    
    // Calculate standings based on matches
    var standings: [PlayerStanding] {
        boxLeague.players.map { player in
            let matches = boxLeague.matches.filter { 
                $0.opponent == player.name || $0.player == player.name 
            }
            
            let wins = countWins(for: player, in: matches)
            let losses = countLosses(for: player, in: matches)
            let sets = calculateSets(for: player, in: matches)
            
            return PlayerStanding(
                name: player.name,
                played: matches.count,
                wins: wins,
                losses: losses,
                setsWon: sets.won,
                setsLost: sets.lost,
                player: player
            )
        }.sorted { s1, s2 in
            if s1.points == s2.points {
                return s1.setRatio > s2.setRatio  // If points are equal, sort by set ratio
            }
            return s1.points > s2.points  // Otherwise sort by points
        }
    }
    
    func findMatchResult(player1: Player, player2: Player) -> BoxMatchResult? {
        if let match = boxLeague.matches.first(where: { 
            ($0.player == player1.name && $0.opponent == player2.name) ||
            ($0.player == player2.name && $0.opponent == player1.name)
        }) {
            return BoxMatchResult(
                score: match.score,
                winner: match.result == .win ? match.player : match.opponent
            )
        }
        return nil
    }
    
    func validateScore(score: String, status: Match.MatchStatus?) -> Bool {
        // If there's a special status, the score is valid
        if let status = status {
            switch status {
            case .retired, .walkover:
                return true
            default:
                break
            }
        }
        
        // Split the score into sets using space
        let sets = score.split(separator: " ").map(String.init)
        var player1Sets = 0
        var player2Sets = 0
        
        // Count sets won by each player
        for setScore in sets {
            let scores = setScore.components(separatedBy: "-")
            if scores.count == 2,
               let score1 = Int(scores[0]),
               let score2 = Int(scores[1]) {
                if score1 > score2 {
                    player1Sets += 1
                } else if score2 > score1 {
                    player2Sets += 1
                }
            }
        }
        
        // Check if either player has won 2 sets
        return player1Sets == 2 || player2Sets == 2
    }
    
    // Break out the match row into its own view
    struct MatchRow: View {
        let boxMatch: BoxMatch
        let viewModel: MatchTrackerViewModel
        let boxLeague: BoxLeague
        
        var body: some View {
            NavigationLink {
                ScoreInputView(
                    player1: boxMatch.player1,
                    player2: boxMatch.player2
                ) { score, winner, notes, status in
                    // If this is an edit (match exists), remove the old match first
                    if let existingMatch = boxMatch.match {
                        viewModel.removeMatch(existingMatch, fromBoxLeague: boxLeague)
                    }
                    
                    let newMatch = Match(
                        id: UUID(),
                        date: Date(),
                        player: boxMatch.player1.name,
                        opponent: boxMatch.player2.name,
                        score: score,
                        result: winner == boxMatch.player1.name ? .win : .loss,
                        round: "1",
                        notes: notes,
                        status: status
                    )
                    viewModel.addMatch(newMatch, toBoxLeague: boxLeague)
                }
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(boxMatch.versusText)
                        if boxMatch.isPlayed, let match = boxMatch.match {
                            HStack {
                                Text(match.score)
                                if let status = match.status {
                                    Text("(\(status.rawValue))")
                                }
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            if let notes = match.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    Spacer()
                    if !boxMatch.isPlayed {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
    }
}

// Helper Views
struct StandingsHeaderRow: View {
    var body: some View {
        HStack {
            Text("Player")
                .frame(width: 100, alignment: .leading)
            Spacer()
            Text("P")
                .frame(width: 30)
            Text("W")
                .frame(width: 30)
            Text("L")
                .frame(width: 30)
            Text("Sets")
                .frame(width: 50)
            Text("Pts")
                .frame(width: 40)
        }
        .font(.caption.bold())
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(Color(UIColor.secondarySystemBackground))
    }
}

struct StandingsRow: View {
    let standing: PlayerStanding
    
    var body: some View {
        HStack {
            Text(standing.name)
                .frame(width: 100, alignment: .leading)
            Spacer()
            Text("\(standing.played)")
                .frame(width: 30)
            Text("\(standing.wins)")
                .frame(width: 30)
            Text("\(standing.losses)")
                .frame(width: 30)
            Text("\(standing.setsWon)-\(standing.setsLost)")
                .frame(width: 50)
            Text("\(standing.points)")
                .frame(width: 40)
        }
        .font(.callout)
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
    }
}

