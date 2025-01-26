import SwiftUI

struct AddBoxMatchView: View {
    @Environment(\.dismiss) var dismiss
    let viewModel: MatchTrackerViewModel
    let boxLeague: BoxLeague
    let player1: Player
    let player2: Player
    
    @State private var score = ""
    @State private var result = Match.Result.win
    @State private var date = Date()
    @State private var notes = ""
    
    private var matchDetails: some View {
        Section("Match Details") {
            HStack {
                Text("Opponent")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(player2.name)
                    .foregroundStyle(.primary)
            }
            
            TextField("Score (e.g. 6-4, 6-3)", text: $score)
                .textInputAutocapitalization(.none)
            
            DatePicker("Date", selection: $date, displayedComponents: [.date])
            
            Picker(selection: $result, label: Text("Result")) {
                ForEach(Match.Result.allCases, id: \.self) { result in
                    Text(result.rawValue).tag(result)
                }
            }
        }
    }
    
    private var opponentDetails: some View {
        Section("Opponent Details") {
            if let wtn = player2.wtn {
                HStack {
                    Text("WTN")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(String(format: "%.1f", wtn))
                }
            }
            
            if let ranking = player2.ranking {
                HStack {
                    Text("Ranking")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("#\(ranking)")
                }
            }
            
            HStack {
                Text("Handedness")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(player2.handedness)
            }
        }
    }
    
    private var notesSection: some View {
        Section("Notes (Optional)") {
            TextEditor(text: $notes)
                .frame(minHeight: 100)
        }
    }
    
    private func saveMatch() {
        let match = Match(
            id: UUID(),
            date: date,
            player: player1.name,
            opponent: player2.name,
            score: score,
            result: result,
            round: "Box League",
            notes: notes.isEmpty ? nil : notes,
            status: nil
        )
        viewModel.addMatch(match, toBoxLeague: boxLeague)
        dismiss()
    }
    
    var body: some View {
        Form {
            matchDetails
            opponentDetails
            notesSection
        }
        .navigationTitle("Add Match")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: { dismiss() }) {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(action: saveMatch) {
                    Text("Save")
                }
                .disabled(score.isEmpty)
            }
        })
    }
} 