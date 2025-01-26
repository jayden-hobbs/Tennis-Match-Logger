import SwiftUI

struct PlayedMatchRow: View {
    let match: Match
    let myName: String?
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if let myName = myName {
                        if match.player == myName {
                            Text("def. \(match.opponent)")
                                .foregroundStyle(match.result == .win ? .primary : .secondary)
                        } else {
                            Text("lost to \(match.player)")
                                .foregroundStyle(match.result == .loss ? .primary : .secondary)
                        }
                    } else {
                        Text(match.player)
                        Text("def.")
                            .foregroundStyle(.secondary)
                        Text(match.opponent)
                    }
                    Spacer()
                    Text(match.score)
                }
                .font(.subheadline)
                
                Text(match.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 2)
        }
        .foregroundStyle(.primary)
    }
} 