import SwiftUI

struct AddBoxLeagueView: View {
    @ObservedObject var viewModel: MatchTrackerViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var box = ""
    @State private var season = ""
    @State private var showingAddPlayer = false
    @State private var players: [Player]
    
    // Default initializer
    init(viewModel: MatchTrackerViewModel) {
        self.viewModel = viewModel
        _players = State(initialValue: [viewModel.settings.playerProfile])
    }
    
    // Custom initializer with existing players
    init(viewModel: MatchTrackerViewModel, players: [Player]) {
        self.viewModel = viewModel
        _players = State(initialValue: players)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("League Details") {
                    TextField("League Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Box Number/Name", text: $box)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Season", text: $season)
                        .textInputAutocapitalization(.words)
                }
                
                Section("Players") {
                    ForEach(players) { player in
                        VStack(alignment: .leading) {
                            Text(player.name)
                                .font(.headline)
                            HStack {
                                if let wtn = player.wtn {
                                    Text("WTN: \(wtn, specifier: "%.1f")")
                                }
                                if let ranking = player.ranking {
                                    Text("Rank: #\(ranking)")
                                }
                                Text("• \(player.handedness)")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                    
                    Button {
                        showingAddPlayer = true
                    } label: {
                        Label("Add Player", systemImage: "person.badge.plus")
                    }
                }
            }
            .navigationTitle("Add Box League")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let boxLeague = BoxLeague(
                            name: name,
                            box: box,
                            season: season,
                            matches: [],
                            players: players
                        )
                        viewModel.addBoxLeague(boxLeague)
                        dismiss()
                    }
                    .disabled(name.isEmpty || box.isEmpty || season.isEmpty || players.count < 2)
                }
            }
            .sheet(isPresented: $showingAddPlayer) {
                AddPlayerView { player in
                    players.append(player)
                }
            }
        }
    }
}

struct AddPlayerView: View {
    @Environment(\.dismiss) var dismiss
    let onSave: (Player) -> Void
    
    @State private var name = ""
    @State private var wtn = ""
    @State private var ranking = ""
    @State private var handedness = "Right"
    @State private var notes = ""
    
    let handednessOptions = ["Right", "Left", "Unknown"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Player Details") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    Picker("Handedness", selection: $handedness) {
                        ForEach(handednessOptions, id: \.self) { option in
                            Text(option)
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
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Add Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let player = Player(
                            name: name,
                            wtn: Double(wtn),
                            ranking: Int(ranking),
                            handedness: handedness,
                            notes: notes.isEmpty ? nil : notes
                        )
                        onSave(player)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
} 