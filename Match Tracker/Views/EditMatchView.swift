import SwiftUI

struct EditMatchView: View {
    @Environment(\.dismiss) var dismiss
    let match: Match
    let player: String
    let onSave: (Match) -> Void
    
    @State private var opponent: String
    @State private var score: String
    @State private var result: Match.Result
    @State private var date: Date
    @State private var round: String
    @State private var handedness: String
    @State private var wtn: String
    @State private var ranking: String
    @State private var notes: String
    
    init(match: Match, player: String, onSave: @escaping (Match) -> Void) {
        self.match = match
        self.player = player
        self.onSave = onSave
        
        _opponent = State(initialValue: match.opponent)
        _score = State(initialValue: match.score)
        _result = State(initialValue: match.result)
        _date = State(initialValue: match.date)
        _round = State(initialValue: match.round)
        _handedness = State(initialValue: match.handedness)
        _wtn = State(initialValue: match.wtn.map { String($0) } ?? "")
        _ranking = State(initialValue: match.ranking.map { String($0) } ?? "")
        _notes = State(initialValue: match.notes ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Match Details") {
                    TextField("Opponent Name", text: $opponent)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Score (e.g. 6-4, 6-3)", text: $score)
                        .textInputAutocapitalization(.none)
                    
                    Picker("Round", selection: $round) {
                        ForEach(["R128", "R64", "R32", "R16", "QF", "SF", "F"], id: \.self) { round in
                            Text(round)
                        }
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: [.date])
                    
                    Picker("Result", selection: $result) {
                        ForEach(Match.Result.allCases, id: \.self) { result in
                            Text(result.rawValue)
                        }
                    }
                }
                
                Section("Ratings") {
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
                }
                
                Section("Opponent Details") {
                    Picker("Handedness", selection: $handedness) {
                        ForEach(["Right", "Left", "Unknown"], id: \.self) { option in
                            Text(option)
                        }
                    }
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Edit Match")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updatedMatch = match
                        updatedMatch.opponent = opponent
                        updatedMatch.score = score
                        updatedMatch.result = result
                        updatedMatch.date = date
                        updatedMatch.round = round
                        updatedMatch.handedness = handedness
                        updatedMatch.wtn = Double(wtn)
                        updatedMatch.ranking = Int(ranking)
                        updatedMatch.notes = notes.isEmpty ? nil : notes
                        onSave(updatedMatch)
                        dismiss()
                    }
                }
            }
        }
    }
} 