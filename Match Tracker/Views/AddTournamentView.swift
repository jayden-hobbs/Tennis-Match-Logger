import SwiftUI

struct AddTournamentView: View {
    @ObservedObject var viewModel: MatchTrackerViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var code = ""
    @State private var emoji = "🎾"
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var location = ""
    @State private var surface = Tournament.Surface.hardcourt
    @State private var environment = Tournament.Environment.outdoor
    @State private var satisfaction = Tournament.Satisfaction.neutral
    @State private var tournamentURL = ""
    @State private var showingEmojiPicker = false
    
    var isValidTournament: Bool {
        !name.isEmpty && !code.isEmpty && !location.isEmpty && !emoji.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        TextField("Tournament Name", text: $name)
                        Button {
                            showingEmojiPicker = true
                        } label: {
                            Text(emoji)
                                .font(.title2)
                        }
                        .buttonStyle(.plain)
                        .popover(isPresented: $showingEmojiPicker) {
                            EmojiPicker(selectedEmoji: $emoji)
                        }
                    }
                    
                    HStack {
                        Text("Code")
                            .foregroundStyle(.secondary)
                        TextField("ABC23", text: $code)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    TextField("Location", text: $location)
                } header: {
                    Text("Basic Info")
                }
                
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Surface")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Picker("", selection: $surface) {
                                ForEach(Tournament.Surface.allCases, id: \.self) { surface in
                                    Text(surface.rawValue).tag(surface)
                                }
                            }
                            .labelsHidden()
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text("Environment")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Picker("", selection: $environment) {
                                ForEach(Tournament.Environment.allCases, id: \.self) { env in
                                    Text(env.rawValue).tag(env)
                                }
                            }
                            .labelsHidden()
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Court Details")
                }
                
                Section {
                    DatePicker("Start", selection: $startDate, displayedComponents: [.date])
                    DatePicker("End", selection: $endDate, displayedComponents: [.date])
                }
                
                Section {
                    Picker("How did it go?", selection: $satisfaction) {
                        ForEach(Tournament.Satisfaction.allCases, id: \.self) { satisfaction in
                            Label {
                                Text(satisfaction.rawValue)
                            } icon: {
                                Image(systemName: satisfaction.icon)
                                    .foregroundStyle(satisfaction.color)
                            }
                            .tag(satisfaction)
                        }
                    }
                }
                
                Section {
                    TextField("Tournament URL (Optional)", text: $tournamentURL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } header: {
                    Text("Additional Info")
                } footer: {
                    Text("Add a link to the tournament website or draw")
                }
            }
            .navigationTitle("Add Tournament")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let tournament = Tournament(
                            name: name,
                            code: code,
                            emoji: emoji,
                            startDate: startDate,
                            endDate: endDate,
                            location: location,
                            surface: surface,
                            environment: environment,
                            satisfaction: satisfaction,
                            events: [],
                            tournamentURL: tournamentURL.isEmpty ? nil : tournamentURL
                        )
                        viewModel.addTournament(tournament)
                        dismiss()
                    }
                    .disabled(!isValidTournament)
                }
            }
        }
    }
}

// Add a simple emoji picker view
struct EmojiPicker: View {
    @Binding var selectedEmoji: String
    @Environment(\.dismiss) var dismiss
    
    let commonEmojis = ["🎾", "🏆", "🏅", "🥇", "🥈", "🥉", "⭐️", "🌟", "🔥", "💪", "👊", "🎯", "🎪", "🎨", "🎭", "🎪"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 44))
                ], spacing: 10) {
                    ForEach(commonEmojis, id: \.self) { emoji in
                        Button {
                            selectedEmoji = emoji
                            dismiss()
                        } label: {
                            Text(emoji)
                                .font(.title)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Select Emoji")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
} 