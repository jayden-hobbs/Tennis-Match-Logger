import SwiftUI

struct EditBoxLeagueView: View {
    @Environment(\.dismiss) var dismiss
    let boxLeague: BoxLeague
    let viewModel: MatchTrackerViewModel
    
    @State private var name: String
    @State private var box: String
    @State private var season: String
    @State private var players: [Player]
    @State private var showingAddPlayer = false
    
    init(boxLeague: BoxLeague, viewModel: MatchTrackerViewModel) {
        self.boxLeague = boxLeague
        self.viewModel = viewModel
        
        _name = State(initialValue: boxLeague.name)
        _box = State(initialValue: boxLeague.box)
        _season = State(initialValue: boxLeague.season)
        _players = State(initialValue: boxLeague.players)
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
                    .onDelete { indexSet in
                        players.remove(atOffsets: indexSet)
                    }
                    
                    Button {
                        showingAddPlayer = true
                    } label: {
                        Label("Add Player", systemImage: "person.badge.plus")
                    }
                }
                
                if !boxLeague.matches.isEmpty {
                    Section {
                        Text("⚠️ Modifying players will not affect existing matches")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Edit Box League")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updatedBoxLeague = boxLeague
                        updatedBoxLeague.name = name
                        updatedBoxLeague.box = box
                        updatedBoxLeague.season = season
                        updatedBoxLeague.players = players
                        viewModel.updateBoxLeague(updatedBoxLeague)
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