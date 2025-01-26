import SwiftUI

struct AddEventView: View {
    @Environment(\.dismiss) var dismiss
    let onSave: (Tournament.Event) -> Void
    
    @State private var name = ""
    @State private var type = Tournament.Event.EventType.singles
    @State private var grade = ""
    @State private var rankingPoints = ""
    @State private var placement = Tournament.Placement.none
    
    var isValidEvent: Bool {
        !name.isEmpty && !grade.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Event Details") {
                    TextField("Event Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    Picker("Type", selection: $type) {
                        ForEach(Tournament.Event.EventType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    TextField("Grade (e.g. 3, 4, 5)", text: $grade)
                        .keyboardType(.numberPad)
                }
                
                Section("Result") {
                    Picker("Placement", selection: $placement) {
                        ForEach(Tournament.Placement.allCases, id: \.self) { placement in
                            Text(placement.rawValue)
                        }
                    }
                }
                
                Section("Optional Details") {
                    TextField("Ranking Points", text: $rankingPoints)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Add Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let event = Tournament.Event(
                            name: name,
                            type: type,
                            grade: grade,
                            rankingPoints: Int(rankingPoints),
                            placement: placement,
                            matches: []
                        )
                        onSave(event)
                        dismiss()
                    }
                    .disabled(!isValidEvent)
                }
            }
        }
    }
} 