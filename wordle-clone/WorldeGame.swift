//
//  WorldeGamer.swift
//  wordle-clone
//
//  Created by Stephan Büeler on 05.12.2025.
//
import Foundation

// Status of letter in keyboard
enum LetterStatus {
    case correct // green
    case present // yellow
    case absent // blacked out
    case empty // unused slot
}

enum KeyStatus {
    case unused, correct, present, absent
}

struct Letter {
    var character: String
    var status: LetterStatus
}

class WordleGame: ObservableObject {
    @Published var solution = "SWORD"
    @Published var guesses: [[Letter]] = []
    @Published var currentGuess: String = ""
    @Published var keyStates: [String : KeyStatus] = [:]

    
    let maxGuesses = 6
    let wordLength = 5
    
    func enterLetter(_ char: String) {
        guard currentGuess.count < wordLength else { return }
        currentGuess += char.uppercased()
    }
    
    func deleteLetter() {
        guard !currentGuess.isEmpty else { return }
        currentGuess.removeLast()
    }
    
    func submitGuess() {
        guard currentGuess.count == wordLength else { return }
        guard guesses.count < maxGuesses else { return }
        let evaluation = evaluateGuess(currentGuess)
        updateKeyboardColors(for: evaluation)
        guesses.append(evaluation)
        currentGuess = ""
    }
    
    func evaluateGuess(_ guess: String) -> [Letter] {
        var result: [Letter] = []
        let solutionArray = Array(solution)
        for (i, char) in guess.uppercased().enumerated() {
            let solutionChar = solutionArray[i]
            
            if (char == solutionChar) {
                result.append(Letter(character: String(char), status: .correct));
            } else if (solutionArray.contains(char)) {
                result.append(Letter(character: String(char), status: .present));
            } else {
                result.append(Letter(character: String(char), status: .absent));
            }
        }
        return result
    }
    
    func updateKeyboardColors(for guess: [Letter]) {
        for letter in guess {
            let key = letter.character.uppercased()
            
            switch letter.status {
            case .correct:
                keyStates[key] = .correct
                
            case .present:
                // Only set to present if it’s not already correct
                if keyStates[key] != .correct {
                    keyStates[key] = .present
                }
                
            case .absent:
                // Only set to absent if not already better (correct/present)
                if keyStates[key] == nil || keyStates[key] == .unused {
                    keyStates[key] = .absent
                }
                
            case .empty:
                break
            }
        }
    }
    
}
