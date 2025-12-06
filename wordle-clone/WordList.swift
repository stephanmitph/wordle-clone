//
//  WordList.swift
//  wordle-clone
//
//  Created by Stephan Büeler on 06.12.2025.
//


import Foundation

class WordList {
    private static let allWords: [String] = {
        guard let url = Bundle.main.url(forResource: "words", withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            print("⚠️ Failed to load words.txt, using fallback words")
            return ["SWORD", "APPLE", "HOUSE", "PIANO", "TIGER"]
        }
        
        return content
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces).uppercased() }
            .filter { $0.count == 5 }
    }()
    
    /// Returns a random 5-letter word from the list
    static func randomWord() -> String {
        return allWords.randomElement() ?? "SWORD"
    }
    
    /// Checks if a word exists in the word list
    static func isValid(_ word: String) -> Bool {
        return allWords.contains(word.uppercased())
    }
}
