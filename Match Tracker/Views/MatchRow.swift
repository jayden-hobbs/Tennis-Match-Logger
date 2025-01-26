import SwiftUI

struct MatchRow: View {
    let match: Match
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(match.opponent)
                    .font(.headline)
                Spacer()
                Text(match.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                if let wtn = match.wtn {
                    Text("WTN: \(wtn, specifier: "%.1f")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                if let ranking = match.ranking {
                    if match.wtn != nil {
                        Text("•")
                            .foregroundStyle(.secondary)
                    }
                    Text("Rank: #\(ranking)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            HStack {
                Text(match.score)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("•")
                    .foregroundStyle(.secondary)
                Text("\(match.round)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Text(match.result.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(resultColor(match.result).opacity(0.1))
                    .foregroundStyle(resultColor(match.result))
                    .clipShape(Capsule())
                
                Text("•")
                    .foregroundStyle(.secondary)
                Text(match.handedness)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    func resultColor(_ result: Match.Result) -> Color {
        switch result {
        case .win: return .green
        case .loss: return .red
        case .draw: return .orange
        }
    }
} 