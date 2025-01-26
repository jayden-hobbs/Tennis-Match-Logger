import SwiftUI

struct AddMatchView: View {
    @Environment(\.dismiss) var dismiss
    let viewModel: MatchTrackerViewModel
    let tournament: Tournament?
    let event: Tournament.Event?
    let onSave: (Match) -> Void
    
    @State private var player = ""
    @State private var opponent = ""
    @State private var score = ""
    @State private var result = Match.Result.win
    @State private var date = Date()
    @State private var round = ""
    @State private var handedness = "Right"
    @State private var wtn = ""
    @State private var ranking = ""
    @State private var notes = ""
    @State private var county: County = .surrey
    
    let handednessOptions = ["Right", "Left", "Unknown"]
    let roundOptions = ["R128", "R64", "R32", "R16", "QF", "SF", "F"]
    
    var isValidMatch: Bool {
        !opponent.isEmpty && !score.isEmpty
    }
    
    private var matchDetails: some View {
        Section("Match Details") {
            TextField("Opponent Name", text: $opponent)
                .textInputAutocapitalization(.words)
            
            TextField("Score (e.g. 6-4, 6-3)", text: $score)
                .textInputAutocapitalization(.none)
            
            Picker(selection: $round, label: Text("Round")) {
                ForEach(roundOptions, id: \.self) { round in
                    Text(round).tag(round)
                }
            }
            
            DatePicker("Date", selection: $date, displayedComponents: [.date])
            
            Picker(selection: $result, label: Text("Result")) {
                ForEach(Match.Result.allCases, id: \.self) { result in
                    Text(result.rawValue).tag(result)
                }
            }
        }
    }
    
    private var playerInfoSection: some View {
        Section("Player Info") {
            HStack {
                Text("WTN")
                    .foregroundStyle(.secondary)
                TextField("0.0", text: $wtn)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
            
            HStack {
                Text("Ranking")
                    .foregroundStyle(.secondary)
                TextField("#", text: $ranking)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
            }
            
            Picker("County", selection: $county) {
                ForEach(County.allCases, id: \.self) { county in
                    Text(county.rawValue).tag(county)
                }
            }
        }
    }
    
    private var opponentDetails: some View {
        Section("Opponent Details") {
            Picker(selection: $handedness, label: Text("Handedness")) {
                ForEach(handednessOptions, id: \.self) { option in
                    Text(option).tag(option)
                }
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
            player: player,
            opponent: opponent,
            score: score,
            result: result,
            round: round,
            notes: notes.isEmpty ? nil : notes,
            status: nil,
            county: county
        )
        onSave(match)
        dismiss()
    }
    
    var body: some View {
        Form {
            matchDetails
            playerInfoSection
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
                    Text("Add")
                }
                .disabled(!isValidMatch)
            }
        })
    }
} 