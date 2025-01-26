import Foundation
import SwiftUI

struct Tournament: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var code: String
    var emoji: String
    var startDate: Date
    var endDate: Date
    var location: String
    var surface: Surface
    var environment: Environment
    var satisfaction: Satisfaction
    var events: [Event]
    var tournamentURL: String?
    var notes: String?
    var photos: [Photo]
    
    struct Photo: Identifiable, Codable, Equatable {
        var id = UUID()
        var data: Data
        var date: Date
        
        init(id: UUID = UUID(), data: Data, date: Date = Date()) {
            self.id = id
            self.data = data
            self.date = date
        }
    }
    
    // Computed property for tournament display grade
    var displayGrade: String {
        let grades = Set(events.map { $0.grade })
        if grades.isEmpty {
            return "G?"
        }
        return "G" + grades.sorted().joined(separator: "+")
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        code: String,
        emoji: String = "🎾",
        startDate: Date,
        endDate: Date,
        location: String,
        surface: Surface = .hardcourt,
        environment: Environment = .outdoor,
        satisfaction: Satisfaction = .neutral,
        events: [Event] = [],
        tournamentURL: String? = nil,
        notes: String? = nil,
        photos: [Photo] = []
    ) {
        self.id = id
        self.name = name
        self.code = code
        self.emoji = emoji
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.surface = surface
        self.environment = environment
        self.satisfaction = satisfaction
        self.events = events
        self.tournamentURL = tournamentURL
        self.notes = notes
        self.photos = photos
    }
    
    enum Surface: String, Codable, CaseIterable {
        case hardcourt = "Hard"
        case clay = "Clay"
        case grass = "Grass"
        case carpet = "Carpet"
        case artificial = "Artificial"
    }
    
    enum Environment: String, Codable, CaseIterable {
        case indoor = "Indoor"
        case outdoor = "Outdoor"
        case both = "Indoor/Outdoor"
    }
    
    enum Placement: String, Codable, CaseIterable {
        case winner = "Winner"
        case runnerUp = "Runner Up"
        case semifinal = "Semi Final"
        case quarterFinal = "Quarter Final"
        case roundOf16 = "Round of 16"
        case roundOf32 = "Round of 32"
        case roundOf64 = "Round of 64"
        case consWinner = "Consolation Winner"
        case consRunnerUp = "Consolation Runner Up"
        case none = "Not Finished"
    }
    
    enum Satisfaction: String, Codable, CaseIterable {
        case happy = "Happy"
        case neutral = "Neutral"
        case unhappy = "Unhappy"
        
        var icon: String {
            switch self {
            case .happy: return "face.smiling.fill"
            case .neutral: return "face.neutral.fill"
            case .unhappy: return "face.frowning.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .happy: return .green
            case .neutral: return .orange
            case .unhappy: return .red
            }
        }
    }
    
    struct Event: Identifiable, Codable, Equatable {
        var id = UUID()
        var name: String
        var type: EventType
        var grade: String
        var rankingPoints: Int?
        var placement: Placement
        var matches: [Match]
        
        init(
            id: UUID = UUID(),
            name: String,
            type: EventType,
            grade: String,
            rankingPoints: Int? = nil,
            placement: Placement = .none,
            matches: [Match] = []
        ) {
            self.id = id
            self.name = name
            self.type = type
            self.grade = grade
            self.rankingPoints = rankingPoints
            self.placement = placement
            self.matches = matches
        }
        
        enum EventType: String, Codable, CaseIterable, Equatable {
            case singles = "Singles"
            case doubles = "Doubles"
        }
    }
} 