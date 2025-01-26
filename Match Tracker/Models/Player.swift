import Foundation

struct Player: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var name: String
    var wtn: Double?
    var ranking: Int?
    var handedness: String
    var notes: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        wtn: Double? = nil,
        ranking: Int? = nil,
        handedness: String = "Right",
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.wtn = wtn
        self.ranking = ranking
        self.handedness = handedness
        self.notes = notes
    }
    
    // Implement hash(into:) for Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // We already have Equatable conformance through the synthesized implementation
} 