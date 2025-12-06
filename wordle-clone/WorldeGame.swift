//
//  WorldeGame.swift
//  wordle-clone
//
//  Created by Stephan Büeler on 05.12.2025.
//
import Foundation

// MARK: - Enums

/// Represents the status of a letter in a guessed word
enum LetterStatus {
    case correct    // Letter is in the correct position (green)
    case present    // Letter exists but in wrong position (yellow)
    case absent     // Letter is not in the word (gray)
    case empty      // Empty slot (no letter yet)
}

/// Represents the status of a keyboard key
enum KeyStatus {
    case correct    // Key is in correct position in at least one guess
    case present    // Key exists in word but wrong position
    case absent     // Key is not in the word
    case unused     // Key hasn't been used yet
}

// MARK: - Models

/// Represents a single letter tile in the game
struct Letter {
    let character: String
    let status: LetterStatus
    var rotation: Double = 0.0  // Animation state: 0° = front, 180° = back
}

// MARK: - Game Logic

/// Main game controller for Wordle
class WordleGame: ObservableObject {
    // MARK: - Published Properties
    
    @Published var solution = "SWORD"
    @Published var guesses: [[Letter]] = []
    @Published var currentGuess: String = ""
    @Published var keyStates: [String: KeyStatus] = [:]
    
    // MARK: - Constants
    
    let maxGuesses = 6
    let wordLength = 5
    
    // MARK: - Input Methods
    
    /// Adds a letter to the current guess
    /// - Parameter char: The character to add
    func enterLetter(_ char: String) {
        guard currentGuess.count < wordLength else { return }
        currentGuess += char.uppercased()
    }
    
    /// Removes the last letter from the current guess
    func deleteLetter() {
        guard !currentGuess.isEmpty else { return }
        currentGuess.removeLast()
    }
    
    // MARK: - Guess Submission
    
    /// Submits the current guess, evaluates it, and animates the result
    func submitGuess() {
        guard currentGuess.count == wordLength else { return }
        guard guesses.count < maxGuesses else { return }
        
        let evaluated = evaluateGuess(currentGuess)
        guesses.append(evaluated)
        
        // Animate each tile with a staggered delay
        for i in 0..<evaluated.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
                self.guesses[self.guesses.count - 1][i].rotation = 180.0
            }
        }
        
        updateKeyboardColors(for: evaluated)
        currentGuess = ""
    }
    
    // MARK: - Evaluation Logic
    
    /// Evaluates a guess against the solution
    /// - Parameter guess: The word to evaluate
    /// - Returns: Array of Letter objects with their statuses
    func evaluateGuess(_ guess: String) -> [Letter] {
        let guessArray = Array(guess.uppercased())
        let solutionArray = Array(solution)
        
        return guessArray.enumerated().map { index, character in
            let status: LetterStatus
            
            if character == solutionArray[index] {
                status = .correct
            } else if solutionArray.contains(character) {
                status = .present
            } else {
                status = .absent
            }
            
            return Letter(character: String(character), status: status)
        }
    }
    
    // MARK: - Keyboard Updates
    
    /// Updates keyboard key colors based on the evaluated guess
    /// Priority: correct > present > absent
    /// - Parameter guess: Array of evaluated letters
    func updateKeyboardColors(for guess: [Letter]) {
        for letter in guess {
            let key = letter.character.uppercased()
            let currentState = keyStates[key]
            
            switch letter.status {
            case .correct:
                keyStates[key] = .correct
                
            case .present:
                // Only update to present if not already correct
                if currentState != .correct {
                    keyStates[key] = .present
                }
                
            case .absent:
                // Only update to absent if not already correct or present
                if currentState == nil || currentState == .unused {
                    keyStates[key] = .absent
                }
                
            case .empty:
                break
            }
        }
    }
}
