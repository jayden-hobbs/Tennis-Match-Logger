import SwiftUI

struct LeagueDetailView: View {
    @ObservedObject var viewModel: MatchTrackerViewModel
    let league: League
    @State private var showingAddMatch = false
    
    var body: some View {
        List {
            Section("League Info") {
                LabeledContent("Name", value: league.name)
                LabeledContent("Division", value: league.division)
                LabeledContent("Season", value: league.season)
            }
            
            Section("Matches") {
                if league.matches.isEmpty {
                    Text("No matches recorded")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(league.matches) { match in
                        MatchRow(match: match)
                    }
                }
            }
        }
        .navigationTitle("League Details")
        .toolbar {
            Button {
                showingAddMatch = true
            } label: {
                Label("Add Match", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showingAddMatch) {
            NavigationStack {
                AddMatchView(
                    viewModel: viewModel,
                    tournament: nil,  // No tournament for league matches
                    event: nil,       // No event for league matches
                    onSave: { match in
                        viewModel.addMatch(match, toLeague: league)
                    }
                )
            }
        }
    }
} 