//
//  MenuView.swift
//  wordle-clone
//
//  Created by Stephan Büeler on 06.12.2025.
//

import SwiftUI

struct MenuView: View {
    @State private var selectedGame: GameType?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Title
                Text("passtime games")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 60)
                
                // Games list
                VStack(spacing: 16) {
                    NavigationLink(value: GameType.wordle) {
                        gameCard(title: "Wordle", icon: "🔤")
                    }
                    
                    // Placeholder for future games
                    gameCard(title: "Coming Soon", icon: "🎮")
                        .opacity(0.5)
                        .disabled(true)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationDestination(for: GameType.self) { game in
                if game == .wordle {
                    WorldeView()
                }
            }
        }
    }
    
    private func gameCard(title: String, icon: String) -> some View {
        HStack {
            Text(icon)
                .font(.largeTitle)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

enum GameType: Hashable {
    case wordle
}

#Preview {
    MenuView()
}
