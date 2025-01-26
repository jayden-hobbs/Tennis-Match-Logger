import SwiftUI

struct EditTournamentView: View {
    @Environment(\.dismiss) var dismiss
    let tournament: Tournament
    let onSave: (Tournament) -> Void
    
    @State private var name: String
    @State private var code: String
    @State private var emoji: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var location: String
    @State private var surface: Tournament.Surface
    @State private var environment: Tournament.Environment
    @State private var satisfaction: Tournament.Satisfaction
    @State private var tournamentURL: String
    
    init(tournament: Tournament, onSave: @escaping (Tournament) -> Void) {
        self.tournament = tournament
        self.onSave = onSave
        
        _name = State(initialValue: tournament.name)
        _code = State(initialValue: tournament.code)
        _emoji = State(initialValue: tournament.emoji)
        _startDate = State(initialValue: tournament.startDate)
        _endDate = State(initialValue: tournament.endDate)
        _location = State(initialValue: tournament.location)
        _surface = State(initialValue: tournament.surface)
        _environment = State(initialValue: tournament.environment)
        _satisfaction = State(initialValue: tournament.satisfaction)
        _tournamentURL = State(initialValue: tournament.tournamentURL ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Tournament Details") {
                    TextField("Name", text: $name)
                    TextField("Code", text: $code)
                    TextField("Emoji", text: $emoji)
                    
                    Picker("Surface", selection: $surface) {
                        ForEach(Tournament.Surface.allCases, id: \.self) { surface in
                            Text(surface.rawValue)
                        }
                    }
                    
                    Picker("Environment", selection: $environment) {
                        ForEach(Tournament.Environment.allCases, id: \.self) { env in
                            Text(env.rawValue)
                        }
                    }
                }
                
                Section("Dates") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
                
                Section("Tournament URL (Optional)") {
                    TextField("URL", text: $tournamentURL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                Section("Satisfaction") {
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
            }
            .navigationTitle("Edit Tournament")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let updatedTournament = Tournament(
                            id: tournament.id,
                            name: name,
                            code: code,
                            emoji: emoji,
                            startDate: startDate,
                            endDate: endDate,
                            location: location,
                            surface: surface,
                            environment: environment,
                            satisfaction: satisfaction,
                            events: tournament.events,
                            tournamentURL: tournamentURL.isEmpty ? nil : tournamentURL
                        )
                        onSave(updatedTournament)
                        dismiss()
                    }
                    .disabled(name.isEmpty || code.isEmpty || location.isEmpty || emoji.isEmpty)
                }
            }
        }
    }
} 