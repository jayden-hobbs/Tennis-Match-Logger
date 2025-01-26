import SwiftUI

struct TournamentsView: View {
    @ObservedObject var viewModel: MatchTrackerViewModel
    @State private var showingAddTournament = false
    @State private var searchText = ""
    @State private var sortOption = SortOption.dateModified
    @State private var tournamentToDelete: Tournament?
    
    enum SortOption {
        case dateModified
        case nameAsc
        case nameDesc
        
        var text: String {
            switch self {
            case .dateModified: return "Date Modified"
            case .nameAsc: return "Name (A-Z)"
            case .nameDesc: return "Name (Z-A)"
            }
        }
    }
    
    var sortOptions: [SortOption] = [.dateModified, .nameAsc, .nameDesc]
    
    var filteredAndSortedTournaments: [Tournament] {
        let filtered = searchText.isEmpty ? viewModel.tournaments : viewModel.tournaments.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.code.localizedCaseInsensitiveContains(searchText) ||
            $0.location.localizedCaseInsensitiveContains(searchText)
        }
        
        switch sortOption {
        case .dateModified:
            return filtered.sorted { $0.startDate > $1.startDate }
        case .nameAsc:
            return filtered.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .nameDesc:
            return filtered.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
        }
    }
    
    var body: some View {
        List {
            if filteredAndSortedTournaments.isEmpty {
                ContentUnavailableView {
                    Label("No Tournaments", systemImage: "trophy")
                } description: {
                    if searchText.isEmpty {
                        Text("Add your first tournament")
                    } else {
                        Text("No tournaments match your search")
                    }
                }
            } else {
                ForEach(filteredAndSortedTournaments) { tournament in
                    NavigationLink {
                        TournamentDetailView(viewModel: viewModel, tournament: tournament)
                    } label: {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(.gray)
                                .frame(width: 44, height: 44)
                                .overlay {
                                    Text(tournament.emoji)
                                        .font(.title2)
                                }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(tournament.name)
                                    .font(.headline)
                                Text("\(tournament.location)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text(tournament.startDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            tournamentToDelete = tournament
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Tournaments")
        .searchable(text: $searchText, prompt: "Search tournaments")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Picker("Sort By", selection: $sortOption) {
                        ForEach(sortOptions, id: \.text) { option in
                            Text(option.text).tag(option)
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                        .font(.title3)
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddTournament = true
                } label: {
                    Label("Add Tournament", systemImage: "plus.circle.fill")
                        .font(.title3)
                }
                .tint(.blue)
            }
        }
        .sheet(isPresented: $showingAddTournament) {
            AddTournamentView(viewModel: viewModel)
        }
        .confirmationDialog(
            "Delete Tournament?",
            isPresented: .init(
                get: { tournamentToDelete != nil },
                set: { if !$0 { tournamentToDelete = nil } }
            ),
            presenting: tournamentToDelete
        ) { tournament in
            Button("Delete '\(tournament.name)'", role: .destructive) {
                withAnimation {
                    viewModel.deleteTournament(tournament)
                }
                tournamentToDelete = nil
            }
        } message: { tournament in
            Text("Are you sure you want to delete '\(tournament.name)'? This action cannot be undone and will delete all associated events and matches.")
        }
    }
    
    func placementColor(_ placement: Tournament.Placement) -> Color {
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
    
    func placementShorthand(_ placement: Tournament.Placement) -> String {
        switch placement {
        case .winner: return "W"
        case .runnerUp: return "RU"
        case .semifinal: return "SF"
        case .quarterFinal: return "QF"
        case .roundOf16: return "16"
        case .roundOf32: return "32"
        case .roundOf64: return "64"
        case .consWinner: return "CW"
        case .consRunnerUp: return "CR"
        case .none: return "-"
        }
    }
} 