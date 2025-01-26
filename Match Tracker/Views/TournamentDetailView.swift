import SwiftUI

struct TournamentDetailView: View {
    @ObservedObject var viewModel: MatchTrackerViewModel
    @State private var tournament: Tournament
    @State private var showingAddMatch = false
    @State private var selectedMatch: Match?
    @State private var showingEditTournament = false
    @State private var selectedEventId: UUID?
    @State private var showingAddEvent = false
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var notes = ""
    @State private var expandedEventId: UUID?
    @State private var showingEditEvent = false
    @State private var showingEmojiPicker = false
    @State private var isEditingTitle = false
    @State private var editingName: String = ""
    
    init(viewModel: MatchTrackerViewModel, tournament: Tournament) {
        self.viewModel = viewModel
        _tournament = State(initialValue: tournament)
    }
    
    private var selectedEvent: Tournament.Event? {
        guard let eventId = selectedEventId else { return nil }
        return tournament.events.first { $0.id == eventId }
    }
    
    var body: some View {
        List {
            Section {
                HStack(spacing: 12) {
                    Button {
                        showingEmojiPicker = true
                    } label: {
                        Text(tournament.emoji)
                            .font(.title)
                    }
                    
                    Text(tournament.name)
                        .font(.title)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .padding(.vertical, 8)
            }
            
            tournamentInfoSection
            datesSection
            eventsSection
            photosSection
            notesSection
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    editingName = tournament.name
                    isEditingTitle = true
                } label: {
                    Image(systemName: "pencil")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditTournament = true
                }
            }
        }
        .alert("Edit Tournament Name", isPresented: $isEditingTitle) {
            TextField("Tournament Name", text: $editingName)
            
            Button("Cancel", role: .cancel) {
                isEditingTitle = false
            }
            
            Button("Save") {
                var updatedTournament = tournament
                updatedTournament.name = editingName
                viewModel.updateTournament(updatedTournament)
                tournament = updatedTournament
                isEditingTitle = false
            }
        } message: {
            Text("Enter a new name for this tournament")
        }
        .sheet(isPresented: $showingAddEvent) {
            AddEventView { event in
                viewModel.addEvent(event, toTournament: tournament)
                if let updatedTournament = viewModel.tournaments.first(where: { $0.id == tournament.id }) {
                    tournament = updatedTournament
                }
            }
        }
        .sheet(item: $selectedMatch) { match in
            NavigationStack {
                EditMatchView(match: match, player: "Jayden") { updatedMatch in
                    var matchWithPlayer = updatedMatch
                    matchWithPlayer.player = "Jayden"
                    viewModel.updateMatch(matchWithPlayer, inTournament: tournament, eventId: selectedEventId!)
                }
            }
        }
        .sheet(isPresented: $showingAddMatch) {
            NavigationStack {
                AddMatchView(
                    viewModel: viewModel,
                    tournament: tournament,
                    event: selectedEvent,
                    onSave: { match in
                        if let event = selectedEvent {
                            viewModel.addMatch(match, toTournament: tournament, eventId: event.id)
                        }
                    }
                )
            }
        }
        .sheet(isPresented: $showingEditTournament) {
            EditTournamentView(tournament: tournament) { updatedTournament in
                viewModel.updateTournament(updatedTournament)
            }
        }
        .sheet(isPresented: $showingEditEvent) {
            if let eventId = selectedEventId,
               let event = tournament.events.first(where: { $0.id == eventId }) {
                EditEventView(event: event) { updatedEvent in
                    var updatedTournament = tournament
                    if let eventIndex = updatedTournament.events.firstIndex(where: { $0.id == eventId }) {
                        updatedTournament.events[eventIndex] = updatedEvent
                        viewModel.updateTournament(updatedTournament)
                        if let refreshedTournament = viewModel.tournaments.first(where: { $0.id == tournament.id }) {
                            tournament = refreshedTournament
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: .photoLibrary) { image in
                if let imageData = image.jpegData(compressionQuality: 0.7) {
                    var updatedTournament = tournament
                    updatedTournament.photos.append(Tournament.Photo(data: imageData))
                    viewModel.updateTournament(updatedTournament)
                    if let refreshedTournament = viewModel.tournaments.first(where: { $0.id == tournament.id }) {
                        tournament = refreshedTournament
                    }
                }
            }
        }
        .sheet(isPresented: $showingCamera) {
            ImagePicker(sourceType: .camera) { image in
                if let imageData = image.jpegData(compressionQuality: 0.7) {
                    var updatedTournament = tournament
                    updatedTournament.photos.append(Tournament.Photo(data: imageData))
                    viewModel.updateTournament(updatedTournament)
                    if let refreshedTournament = viewModel.tournaments.first(where: { $0.id == tournament.id }) {
                        tournament = refreshedTournament
                    }
                }
            }
        }
        .sheet(isPresented: $showingEmojiPicker) {
            NavigationStack {
                EmojiTextField(text: Binding(
                    get: { tournament.emoji },
                    set: { newEmoji in
                        var updatedTournament = tournament
                        updatedTournament.emoji = String(newEmoji.prefix(1))
                        viewModel.updateTournament(updatedTournament)
                        if let refreshedTournament = viewModel.tournaments.first(where: { $0.id == tournament.id }) {
                            tournament = refreshedTournament
                        }
                    }
                ))
                .navigationTitle("Select Emoji")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingEmojiPicker = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            showingEmojiPicker = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
    
    private var tournamentInfoSection: some View {
        Section("Tournament Info") {
            LabeledContent("Name", value: tournament.name)
            LabeledContent("Code", value: tournament.code)
            LabeledContent("Location", value: tournament.location)
            LabeledContent("Surface", value: tournament.surface.rawValue)
            LabeledContent("Environment", value: tournament.environment.rawValue)
            if let url = tournament.tournamentURL {
                Link("Tournament Page", destination: URL(string: url)!)
            }
        }
    }
    
    private var datesSection: some View {
        Section("Dates") {
            LabeledContent("Start Date", value: tournament.startDate.formatted(date: .long, time: .omitted))
            LabeledContent("End Date", value: tournament.endDate.formatted(date: .long, time: .omitted))
        }
    }
    
    private var eventsSection: some View {
        Section {
            if tournament.events.isEmpty {
                ContentUnavailableView {
                    Label("No Events", systemImage: "trophy")
                } description: {
                    Text("Add your first event")
                }
            } else {
                ForEach(tournament.events) { event in
                    NavigationLink {
                        EventDetailView(
                            viewModel: viewModel,
                            tournament: tournament,
                            event: event
                        )
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.name)
                                .font(.headline)
                            Text("G\(event.grade) - \(event.placement.rawValue)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            showingEditEvent = true
                            selectedEventId = event.id
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
            
            addEventButton
        } header: {
            Text("Events")
        }
    }
    
    private var addEventButton: some View {
        Button {
            showingAddEvent = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.blue)
                    .frame(width: 44, height: 44)
                Text("Add Event")
                    .foregroundStyle(.primary)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var photosSection: some View {
        Section("Photos") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Button {
                        showingCamera = true
                    } label: {
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                            Text("Camera")
                                .font(.caption)
                        }
                        .frame(width: 100, height: 100)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    Button {
                        showingImagePicker = true
                    } label: {
                        VStack {
                            Image(systemName: "photo.fill")
                                .font(.title2)
                            Text("Photos")
                                .font(.caption)
                        }
                        .frame(width: 100, height: 100)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    ForEach(tournament.photos) { photo in
                        if let uiImage = UIImage(data: photo.data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .listRowInsets(EdgeInsets())
        }
    }
    
    private var notesSection: some View {
        Section("Notes") {
            TextEditor(text: Binding(
                get: { tournament.notes ?? "" },
                set: { newValue in
                    var updatedTournament = tournament
                    updatedTournament.notes = newValue.isEmpty ? nil : newValue
                    viewModel.updateTournament(updatedTournament)
                    if let refreshedTournament = viewModel.tournaments.first(where: { $0.id == tournament.id }) {
                        tournament = refreshedTournament
                    }
                }
            ))
            .frame(minHeight: 100)
        }
    }
}

// Helper view to use system emoji picker
struct EmojiTextField: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.textAlignment = .center
        textField.font = .systemFont(ofSize: 50)
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>
        
        init(text: Binding<String>) {
            self.text = text
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text.wrappedValue = textField.text ?? ""
        }
    }
}

#Preview {
    NavigationStack {
        TournamentDetailView(
            viewModel: MatchTrackerViewModel(),
            tournament: Tournament(
                name: "Sample Tournament",
                code: "SAMP23",
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 3),
                location: "Melbourne",
                surface: .hardcourt,
                environment: .outdoor,
                satisfaction: .neutral,
                events: [
                    Tournament.Event(
                        name: "Boys Singles",
                        type: .singles,
                        grade: "4",
                        rankingPoints: 30,
                        placement: .none,
                        matches: []
                    )
                ]
            )
        )
    }
} 