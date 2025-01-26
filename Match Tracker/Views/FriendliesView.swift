import SwiftUI

struct FriendliesView: View {
    @ObservedObject var viewModel: MatchTrackerViewModel
    @State private var showingAddMatch = false
    
    var body: some View {
        List {
            if viewModel.friendlies.isEmpty {
                ContentUnavailableView {
                    Label("No Friendly Matches", systemImage: "person.2.fill")
                } description: {
                    Text("Add your first friendly match")
                } actions: {
                    Button {
                        showingAddMatch = true
                    } label: {
                        Text("Add Match")
                    }
                }
            } else {
                ForEach(viewModel.friendlies) { match in
                    MatchRow(match: match)
                }
            }
        }
        .navigationTitle("Friendlies")
        .toolbar {
            Button {
                showingAddMatch = true
            } label: {
                Label("Add Match", systemImage: "plus.circle.fill")
                    .font(.title3)
            }
            .tint(.blue)
        }
        .sheet(isPresented: $showingAddMatch) {
            NavigationStack {
                AddMatchView(
                    viewModel: viewModel,
                    tournament: nil,  // No tournament for friendlies
                    event: nil,       // No event for friendlies
                    onSave: { match in
                        viewModel.addFriendly(match)
                    }
                )
            }
        }
    }
} 