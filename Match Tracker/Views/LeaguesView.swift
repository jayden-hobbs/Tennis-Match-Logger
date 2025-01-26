import SwiftUI

struct LeaguesView: View {
    @ObservedObject var viewModel: MatchTrackerViewModel
    @State private var showingAddLeague = false
    
    var body: some View {
        List {
            if viewModel.leagues.isEmpty {
                ContentUnavailableView {
                    Label("No Leagues", systemImage: "list.number")
                } description: {
                    Text("Add your first league")
                } actions: {
                    Button {
                        showingAddLeague = true
                    } label: {
                        Text("Add League")
                    }
                }
            } else {
                ForEach(viewModel.leagues) { league in
                    NavigationLink {
                        LeagueDetailView(viewModel: viewModel, league: league)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(league.name)
                                .font(.headline)
                            Text("\(league.division) - \(league.season)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Leagues")
        .toolbar {
            Button {
                showingAddLeague = true
            } label: {
                Label("Add League", systemImage: "plus.circle.fill")
                    .font(.title3)
            }
            .tint(.blue)
        }
        .sheet(isPresented: $showingAddLeague) {
            NavigationStack {
                AddLeagueView(viewModel: viewModel)
            }
        }
    }
} 