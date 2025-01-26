import SwiftUI

struct BoxLeaguesView: View {
    @ObservedObject var viewModel: MatchTrackerViewModel
    @State private var showingAddBoxLeague = false
    
    var body: some View {
        NavigationStack {
            List {
                if viewModel.boxLeagues.isEmpty {
                    ContentUnavailableView {
                        Label("No Box Leagues", systemImage: "square.grid.3x3.fill")
                    } description: {
                        Text("Add your first box league")
                    }
                } else {
                    ForEach(viewModel.boxLeagues) { boxLeague in
                        NavigationLink {
                            BoxLeagueDetailView(viewModel: viewModel, boxLeague: boxLeague)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(boxLeague.name)
                                    .font(.headline)
                                Text("\(boxLeague.box) - \(boxLeague.season)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Box Leagues")
            .toolbar {
                Button {
                    showingAddBoxLeague = true
                } label: {
                    Label("Add Box League", systemImage: "plus.circle.fill")
                        .font(.title3)
                }
                .tint(.blue)
            }
            .sheet(isPresented: $showingAddBoxLeague) {
                AddBoxLeagueView(viewModel: viewModel)
            }
        }
    }
} 