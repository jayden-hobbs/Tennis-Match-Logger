import SwiftUI

struct EventRow: View {
    let event: Tournament.Event
    @Binding var isExpanded: Bool
    let onAddMatch: () -> Void
    let onSelectMatch: (Match) -> Void
    
    var eventSummary: String {
        "G\(event.grade) - \(event.placement.rawValue)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(event.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(eventSummary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundStyle(.secondary)
                }
                .frame(minHeight: 44) // Apple's minimum touch target
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Button(action: onAddMatch) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Match")
                        }
                        .foregroundStyle(.blue)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .frame(height: 44)
                    }
                    
                    if event.matches.isEmpty {
                        Text("No matches recorded")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(event.matches) { match in
                            MatchRow(match: match)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    onSelectMatch(match)
                                }
                        }
                    }
                }
                .padding(.leading, 16) // Consistent indentation
            }
        }
    }
} 