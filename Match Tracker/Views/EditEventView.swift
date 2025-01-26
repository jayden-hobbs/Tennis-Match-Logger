import SwiftUI

struct EditEventView: View {
    @Environment(\.dismiss) var dismiss
    let event: Tournament.Event
    let onSave: (Tournament.Event) -> Void
    
    @State private var name: String
    @State private var type: Tournament.Event.EventType
    @State private var grade: String
    @State private var rankingPoints: String
    @State private var placement: Tournament.Placement
    
    init(event: Tournament.Event, onSave: @escaping (Tournament.Event) -> Void) {
        self.event = event
        self.onSave = onSave
        
        _name = State(initialValue: event.name)
        _type = State(initialValue: event.type)
        _grade = State(initialValue: event.grade)
        _rankingPoints = State(initialValue: event.rankingPoints.map(String.init) ?? "")
        _placement = State(initialValue: event.placement)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Event Details") {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    Picker("Type", selection: $type) {
                        ForEach(Tournament.Event.EventType.allCases, id: \.self) { type in
                            Text(type.rawValue)
                        }
                    }
                    
                    TextField("Grade", text: $grade)
                        .keyboardType(.numberPad)
                }
                
                Section("Result") {
                    Picker("Placement", selection: $placement) {
                        ForEach(Tournament.Placement.allCases, id: \.self) { placement in
                            Text(placement.rawValue)
                        }
                    }
                }
                
                Section("Optional") {
                    TextField("Ranking Points", text: $rankingPoints)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updatedEvent = event
                        updatedEvent.name = name
                        updatedEvent.type = type
                        updatedEvent.grade = grade
                        updatedEvent.rankingPoints = Int(rankingPoints)
                        updatedEvent.placement = placement
                        onSave(updatedEvent)
                        dismiss()
                    }
                    .disabled(name.isEmpty || grade.isEmpty)
                }
            }
        }
    }
} 