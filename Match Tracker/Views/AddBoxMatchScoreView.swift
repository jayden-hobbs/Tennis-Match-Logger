import SwiftUI

struct ScoreInputRow: View {
    let setNumber: Int
    let player1Name: String
    let player2Name: String
    @Binding var player1Score: String
    @Binding var player2Score: String
    
    var body: some View {
        HStack {
            Text("Set \(setNumber)")
            Spacer()
            TextField("0", text: $player1Score)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 40)
            Text("-")
            TextField("0", text: $player2Score)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.leading)
                .frame(width: 40)
        }
    }
}

struct AddBoxMatchScoreView: View {
    @Environment(\.dismiss) var dismiss
    let viewModel: MatchTrackerViewModel
    let boxLeague: BoxLeague
    let player1: Player
    let player2: Player
    
    @State private var player1Set1 = ""
    @State private var player1Set2 = ""
    @State private var player1Set3 = ""
    @State private var player2Set1 = ""
    @State private var player2Set2 = ""
    @State private var player2Set3 = ""
    @State private var status: Match.MatchStatus?
    @State private var selectedWinner: Player?
    var editingMatch: Match?
    
    init(viewModel: MatchTrackerViewModel, boxLeague: BoxLeague, player1: Player, player2: Player) {
        self.viewModel = viewModel
        self.boxLeague = boxLeague
        self.player1 = player1
        self.player2 = player2
        
        print("Initialized with: \(player1.name) vs \(player2.name)")
    }
    
    var setsWon: (player1: Int, player2: Int) {
        var p1Sets = 0
        var p2Sets = 0
        
        if let s1 = Int(player1Set1), let s2 = Int(player2Set1) {
            if s1 > s2 { p1Sets += 1 } else if s2 > s1 { p2Sets += 1 }
        }
        if let s1 = Int(player1Set2), let s2 = Int(player2Set2) {
            if s1 > s2 { p1Sets += 1 } else if s2 > s1 { p2Sets += 1 }
        }
        if let s1 = Int(player1Set3), let s2 = Int(player2Set3) {
            if s1 > s2 { p1Sets += 1 } else if s2 > s1 { p2Sets += 1 }
        }
        
        return (p1Sets, p2Sets)
    }
    
    private var set1Valid: Bool {
        guard let s1 = Int(player1Set1), let s2 = Int(player2Set1) else { return false }
        return isValidSetScore(s1, s2)
    }
    
    private var set2Valid: Bool {
        guard let s1 = Int(player1Set2), let s2 = Int(player2Set2) else { return false }
        return isValidSetScore(s1, s2)
    }
    
    private var set3Valid: Bool {
        guard let s1 = Int(player1Set3), let s2 = Int(player2Set3) else { return false }
        return isValidSetScore(s1, s2)
    }
    
    private func isValidSetScore(_ score1: Int, _ score2: Int) -> Bool {
        if score1 == score2 { return false }
        if score1 < 6 && score2 < 6 { return false }
        if max(score1, score2) < 7 && abs(score1 - score2) < 2 { return false }
        return true
    }
    
    var isValidScore: Bool {
        // For walkover or defaulted, no score needed
        if status == .walkover || status == .defaulted {
            return true
        }
        
        // For retired, need at least one completed set
        if status == .retired {
            return selectedWinner != nil && (setsWon.player1 > 0 || setsWon.player2 > 0)
        }
        
        // For completed match, need valid sets and two sets won by same player
        let hasValidSets = set1Valid || set2Valid || set3Valid
        return hasValidSets && (setsWon.player1 == 2 || setsWon.player2 == 2)
    }
    
    private func getSetScore(_ player1Score: String, _ player2Score: String) -> String? {
        guard let s1 = Int(player1Score), let s2 = Int(player2Score) else { return nil }
        return "\(s1)-\(s2)"
    }
    
    private func getMatchScore() -> [String] {
        var sets: [String] = []
        
        if let set1 = getSetScore(player1Set1, player2Set1) {
            sets.append(set1)
        }
        if let set2 = getSetScore(player1Set2, player2Set2) {
            sets.append(set2)
        }
        if let set3 = getSetScore(player1Set3, player2Set3) {
            sets.append(set3)
        }
        
        return sets
    }
    
    var scoreText: String {
        if status == .walkover {
            return "w/o"
        }
        if status == .defaulted {
            return "def."
        }
        
        let sets = getMatchScore()
        var text = sets.joined(separator: ", ")
        
        if status == .retired {
            text += " ret."
        }
        
        return text
    }
    
    var winner: Player {
        if status == .walkover || status == .defaulted {
            return player1  // First player gets the win
        }
        
        return setsWon.player1 > setsWon.player2 ? player1 : player2
    }
    
    private func createMatch() -> Match {
        let matchWinner: Player
        if status == .retired {
            matchWinner = selectedWinner ?? player1
        } else if status == .walkover || status == .defaulted {
            matchWinner = player1
        } else {
            matchWinner = setsWon.player1 > setsWon.player2 ? player1 : player2
        }
        
        return Match(
            id: editingMatch?.id ?? UUID(),
            date: editingMatch?.date ?? Date(),
            player: matchWinner.name,
            opponent: (matchWinner.id == player1.id ? player2 : player1).name,
            score: scoreText,
            result: .win,
            round: "Box League",
            notes: nil,
            status: status
        )
    }
    
    private func saveMatch() {
        let match = createMatch()
        viewModel.addMatch(match, toBoxLeague: boxLeague)
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Match Details")) {
                    HStack {
                        Text(player1.name)
                        Spacer()
                        Text("vs")
                        Spacer()
                        Text(player2.name)
                    }
                }
                
                Section(header: Text("Score")) {
                    ScoreInputRow(
                        setNumber: 1,
                        player1Name: player1.name,
                        player2Name: player2.name,
                        player1Score: $player1Set1,
                        player2Score: $player2Set1
                    )
                    
                    ScoreInputRow(
                        setNumber: 2,
                        player1Name: player1.name,
                        player2Name: player2.name,
                        player1Score: $player1Set2,
                        player2Score: $player2Set2
                    )
                    
                    ScoreInputRow(
                        setNumber: 3,
                        player1Name: player1.name,
                        player2Name: player2.name,
                        player1Score: $player1Set3,
                        player2Score: $player2Set3
                    )
                }
                
                Section {
                    Picker("Match Status", selection: $status) {
                        Text("Normal").tag(Optional<Match.MatchStatus>.none)
                        Text("Walkover").tag(Optional<Match.MatchStatus>.some(.walkover))
                        Text("Retired").tag(Optional<Match.MatchStatus>.some(.retired))
                        Text("Default").tag(Optional<Match.MatchStatus>.some(.defaulted))
                    }
                    
                    if status == .retired {
                        Picker("Winner", selection: $selectedWinner) {
                            Text(player1.name).tag(player1 as Player?)
                            Text(player2.name).tag(player2 as Player?)
                        }
                    }
                }
            }
            .navigationTitle("Enter Score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveMatch)
                        .disabled(!isValidScore)
                }
            }
            .onAppear {
                selectedWinner = player1
            }
        }
    }
} 