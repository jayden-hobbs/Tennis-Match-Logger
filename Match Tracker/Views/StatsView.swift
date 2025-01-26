import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: MatchTrackerViewModel
    
    var allMatches: [Match] {
        var matches: [Match] = []
        matches.append(contentsOf: viewModel.tournaments.flatMap { tournament in
            tournament.events.flatMap { $0.matches }
        })
        matches.append(contentsOf: viewModel.leagues.flatMap { $0.matches })
        matches.append(contentsOf: viewModel.friendlies)
        return matches
    }
    
    var winningMatches: [Match] {
        allMatches.filter { $0.result == .win }
    }
    
    var highestWTN: Match? {
        winningMatches.max(by: { ($0.wtn ?? 0) < ($1.wtn ?? 0) })
    }
    
    var lowestWTN: Match? {
        winningMatches.min(by: { ($0.wtn ?? 0) < ($1.wtn ?? 0) })
    }
    
    var winPercentage: Double {
        guard !allMatches.isEmpty else { return 0 }
        return Double(winningMatches.count) / Double(allMatches.count) * 100
    }
    
    var body: some View {
        List {
            Section("Overall Stats") {
                StatRow(title: "Total Matches", value: "\(allMatches.count)")
                StatRow(title: "Win Percentage", value: String(format: "%.1f%%", winPercentage))
            }
            
            Section("Notable Wins") {
                if let highestWTN = highestWTN {
                    StatRow(
                        title: "Highest WTN Win",
                        value: String(format: "%.2f", highestWTN.wtn ?? 0),
                        detail: "\(highestWTN.opponent) - \(highestWTN.date.formatted(date: .abbreviated, time: .omitted))"
                    )
                }
                
                if let lowestWTN = lowestWTN {
                    StatRow(
                        title: "Lowest WTN Win",
                        value: String(format: "%.2f", lowestWTN.wtn ?? 0),
                        detail: "\(lowestWTN.opponent) - \(lowestWTN.date.formatted(date: .abbreviated, time: .omitted))"
                    )
                }
            }
        }
        .navigationTitle("Statistics")
    }
}

struct StatRow: View {
    let title: String
    let value: String
    var detail: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text(value)
                    .font(.headline)
                    .foregroundStyle(.blue)
            }
            
            if let detail = detail {
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
} 