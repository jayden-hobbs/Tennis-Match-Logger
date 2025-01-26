import SwiftUI

struct EventDetailView: View {
    @ObservedObject var viewModel: MatchTrackerViewModel
    @State private var tournament: Tournament
    @State private var event: Tournament.Event
    @State private var showingAddMatch = false
    @State private var showingEditEvent = false
    @State private var selectedMatch: Match?
    
    init(viewModel: MatchTrackerViewModel, tournament: Tournament, event: Tournament.Event) {
        self.viewModel = viewModel
        _tournament = State(initialValue: tournament)
        _event = State(initialValue: event)
    }
    
    private var eventHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Text(event.name)
                    .font(.title2.bold())
                Spacer()
                Text("G\(event.grade)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Label("\(event.type.rawValue)", systemImage: "figure.tennis")
                Spacer()
                if let points = event.rankingPoints {
                    Label("\(points) pts", systemImage: "star.fill")
                }
            }
            .foregroundStyle(.secondary)
            
            Text(event.placement.rawValue)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(placementColor(event.placement).opacity(0.1))
                .foregroundStyle(placementColor(event.placement))
                .clipShape(Capsule())
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var matchesList: some View {
        Group {
            if event.matches.isEmpty {
                Text("No matches recorded")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(event.matches) { match in
                    MatchRow(match: match)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedMatch = match
                        }
                }
            }
        }
    }
    
    private func updateEventAndTournament() {
        if let updatedTournament = viewModel.tournaments.first(where: { $0.id == tournament.id }),
           let updatedEvent = updatedTournament.events.first(where: { $0.id == event.id }) {
            tournament = updatedTournament
            event = updatedEvent
        }
    }
    
    var body: some View {
        List {
            Section {
                eventHeader
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            
            Section("Matches") {
                matchesList
            }
        }
        .navigationTitle("Event Details")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { showingEditEvent = true }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddMatch = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title3.bold())
                }
            }
        }
        .sheet(isPresented: $showingEditEvent) {
            EditEventView(event: event) { updatedEvent in
                var updatedTournament = tournament
                if let eventIndex = updatedTournament.events.firstIndex(where: { $0.id == event.id }) {
                    updatedTournament.events[eventIndex] = updatedEvent
                    viewModel.updateTournament(updatedTournament)
                    updateEventAndTournament()
                }
            }
        }
        .sheet(isPresented: $showingAddMatch) {
            NavigationStack {
                AddMatchView(
                    viewModel: viewModel,
                    tournament: tournament,
                    event: event,
                    onSave: { match in
                        viewModel.addMatch(match, toTournament: tournament, eventId: event.id)
                        updateEventAndTournament()
                    }
                )
            }
        }
        .sheet(item: $selectedMatch) { match in
            NavigationStack {
                EditMatchView(match: match, player: "Jayden") { updatedMatch in
                    viewModel.updateMatch(updatedMatch, inTournament: tournament, eventId: event.id)
                    updateEventAndTournament()
                }
            }
        }
        .onChange(of: viewModel.tournaments) { _, _ in
            updateEventAndTournament()
        }
    }
    
    private func placementColor(_ placement: Tournament.Placement) -> Color {
        switch placement {
        case .winner: return .green
        case .runnerUp: return .blue
        case .semifinal: return .purple
        case .quarterFinal: return .orange
        case .consWinner: return .mint
        case .consRunnerUp: return .teal
        default: return .gray
        }
    }
}

#Preview {
    NavigationStack {
        EventDetailView(
            viewModel: MatchTrackerViewModel(),
            tournament: Tournament(
                name: "Sample Tournament",
                code: "SAMP23",
                emoji: "🎾",
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 3),
                location: "Melbourne",
                surface: .hardcourt,
                environment: .outdoor,
                satisfaction: .neutral,
                events: []
            ),
            event: Tournament.Event(
                name: "Boys Singles",
                type: .singles,
                grade: "4",
                rankingPoints: 30,
                placement: .none,
                matches: [
                    Match(
                        id: UUID(),
                        date: Date(),
                        player: "Jayden",
                        opponent: "John Smith",
                        score: "6-4, 6-3",
                        result: .win,
                        round: "QF",
                        notes: "Good match",
                        status: nil
                    )
                ]
            )
        )
    }
} 
