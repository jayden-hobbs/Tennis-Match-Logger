import SwiftUI

struct AddLeagueView: View {
    @ObservedObject var viewModel: MatchTrackerViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var division = ""
    @State private var season = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("League Details") {
                    TextField("League Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Division", text: $division)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Season", text: $season)
                        .textInputAutocapitalization(.words)
                }
            }
            .navigationTitle("Add League")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let league = League(
                            name: name,
                            division: division,
                            season: season,
                            matches: []
                        )
                        viewModel.addLeague(league)
                        dismiss()
                    }
                    .disabled(name.isEmpty || division.isEmpty || season.isEmpty)
                }
            }
        }
    }
} 