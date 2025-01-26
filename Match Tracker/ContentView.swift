//
//  ContentView.swift
//  Match Tracker
//
//  Created by Jayden Hobbs on 23/01/2025.
//

import SwiftUI

struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            if icon.first?.isEmoji == true {
                Text(icon)
                    .font(.system(size: 24))  // Adjusted size to match SF Symbols
                    .foregroundColor(color)    // Added color to match SF Symbols
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            Text(title)
                .font(.body.weight(.medium))
            
            Spacer()
        }
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// Add this extension to check for emojis
extension Character {
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji
    }
}

struct ContentView: View {
    @StateObject var viewModel = MatchTrackerViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        TournamentsView(viewModel: viewModel)
                    } label: {
                        MenuButton(title: "Tournaments", icon: "trophy.fill", color: .orange)
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink {
                        BoxLeaguesView(viewModel: viewModel)
                    } label: {
                        MenuButton(title: "Box Leagues", icon: "square.grid.3x3.fill", color: .blue)
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink {
                        LeaguesView(viewModel: viewModel)
                    } label: {
                        MenuButton(title: "Leagues", icon: "list.number", color: .green)
                    }
                    .buttonStyle(.plain)
                } header: {
                    Text("Competitions")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .textCase(nil)
                        .padding(.bottom, 4)
                }
                
                Section {
                    NavigationLink {
                        FriendliesView(viewModel: viewModel)
                    } label: {
                        MenuButton(title: "Friendlies", icon: "person.2.fill", color: .purple)
                    }
                    .buttonStyle(.plain)
                }
                
                Section {
                    NavigationLink {
                        StatsView(viewModel: viewModel)
                    } label: {
                        MenuButton(title: "Statistics", icon: "chart.bar.fill", color: .red)
                    }
                    .buttonStyle(.plain)
                }
                
                // Add gap with empty section
                Section { }
                
                // New settings section
                Section {
                    NavigationLink {
                        SettingsView(viewModel: viewModel)
                    } label: {
                        MenuButton(title: "Settings", icon: "gearshape.fill", color: .gray)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Match Logger 🎾")
            .listStyle(.insetGrouped)
        }
    }
}

#Preview {
    ContentView()
}
