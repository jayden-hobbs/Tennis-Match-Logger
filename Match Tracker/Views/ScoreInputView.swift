import SwiftUI

struct ScoreInputView: View {
    let player1: Player
    let player2: Player
    let onSave: (String, String, String, Match.MatchStatus?) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var score = ""
    @State private var winner: Player
    @State private var notes = ""
    @State private var status: Match.MatchStatus?
    
    init(player1: Player, player2: Player, onSave: @escaping (String, String, String, Match.MatchStatus?) -> Void) {
        self.player1 = player1
        self.player2 = player2
        self.onSave = onSave
        _winner = State(initialValue: player1)
    }
    
    var body: some View {
        List {
            Section {
                Picker("Winner", selection: $winner) {
                    Text(player1.name).tag(player1)
                    Text(player2.name).tag(player2)
                }
            }
            
            Section {
                Picker("Match Status", selection: $status) {
                    Text("").tag(Optional<Match.MatchStatus>.none)
                    Text("Walkover").tag(Optional<Match.MatchStatus>.some(.walkover))
                    Text("Retired").tag(Optional<Match.MatchStatus>.some(.retired))
                    Text("Default").tag(Optional<Match.MatchStatus>.some(.defaulted))
                }
            } header: {
                Text("Match Status")
            }
            
            Section {
                TextField("e.g., 6-4 6-2", text: $score)
                    .keyboardType(.default)
            } header: {
                Text("Score")
            } footer: {
                Text("Enter sets separated by spaces (e.g., 6-4 6-2)")
            }
            
            Section {
                TextEditor(text: $notes)
                    .frame(minHeight: 100)
            } header: {
                Text("Match Notes")
            } footer: {
                Text("Add any notes about the match")
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
                Button("Save") {
                    onSave(score, winner.name, notes, status)
                    dismiss()
                }
                .disabled(score.isEmpty && status == nil)
            }
        }
    }
} 