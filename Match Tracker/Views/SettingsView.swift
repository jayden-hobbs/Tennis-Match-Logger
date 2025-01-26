import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: MatchTrackerViewModel
    @State private var showingEditProfile = false
    
    var body: some View {
        List {
            Section("Player Profile") {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.settings.playerProfile.name)
                        .font(.headline)
                    
                    HStack {
                        if let wtn = viewModel.settings.playerProfile.wtn {
                            Text("WTN: \(wtn, specifier: "%.1f")")
                        }
                        if let ranking = viewModel.settings.playerProfile.ranking {
                            Text("Rank: #\(ranking)")
                        }
                        Text("• \(viewModel.settings.playerProfile.handedness)")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    showingEditProfile = true
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showingEditProfile) {
            NavigationStack {
                EditProfileView(player: viewModel.settings.playerProfile) { updatedPlayer in
                    viewModel.updatePlayerProfile(updatedPlayer)
                }
            }
        }
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    let player: Player
    let onSave: (Player) -> Void
    
    @State private var name: String
    @State private var wtn: String
    @State private var ranking: String
    @State private var handedness: String
    @State private var notes: String
    
    init(player: Player, onSave: @escaping (Player) -> Void) {
        self.player = player
        self.onSave = onSave
        
        _name = State(initialValue: player.name)
        _wtn = State(initialValue: player.wtn.map { String(format: "%.1f", $0) } ?? "")
        _ranking = State(initialValue: player.ranking.map { String($0) } ?? "")
        _handedness = State(initialValue: player.handedness)
        _notes = State(initialValue: player.notes ?? "")
    }
    
    var body: some View {
        Form {
            Section("Player Details") {
                TextField("Name", text: $name)
                    .textInputAutocapitalization(.words)
                
                Picker("Handedness", selection: $handedness) {
                    ForEach(["Right", "Left", "Unknown"], id: \.self) { option in
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
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    var updatedPlayer = player
                    updatedPlayer.name = name
                    updatedPlayer.wtn = Double(wtn)
                    updatedPlayer.ranking = Int(ranking)
                    updatedPlayer.handedness = handedness
                    updatedPlayer.notes = notes.isEmpty ? nil : notes
                    onSave(updatedPlayer)
                    dismiss()
                }
                .disabled(name.isEmpty)
            }
        }
    }
} 