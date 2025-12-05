import SwiftUI

struct ContentView: View {
    @StateObject var game = WordleGame()

    var body: some View {
        VStack {
            Spacer(minLength: 20)
            
            // Word grid
            ForEach(0..<game.maxGuesses, id: \.self) { row in
                HStack {
                    rowView(row)
                }
            }
            .padding(.bottom, 2)
            
            Spacer()

            // Keyboard
            keyboard
            
        }
        .padding()
    }

    // Render a row
    func rowView(_ row: Int) -> some View {
        // This row is already submitted
        if row < game.guesses.count {
            let guessLetters = game.guesses[row]
            return HStack {
                ForEach(0..<game.wordLength, id: \.self) { i in
                    tileView(letter: guessLetters[i])
                }
            }
        }

        // This row is the active typing row
        if row == game.guesses.count {
            let letters = Array(game.currentGuess.map { Letter(character: String($0), status: .empty) })
            return HStack {
                ForEach(0..<game.wordLength, id: \.self) { i in
                    tileView(letter: i < letters.count ? letters[i] : Letter(character: "", status: .empty))
                }
            }
        }

        // All future rows are empty
        return HStack {
            ForEach(0..<game.wordLength, id: \.self) { _ in
                tileView(letter: Letter(character: "", status: .empty))
            }
        }
    }

    
    // Tile view
    func tileView(letter: Letter) -> some View {
        // Determine background and border
        let bgColor: Color = {
            switch letter.status {
            case .correct: return .green
            case .present: return .yellow
            case .absent: return .black.opacity(0.6)
            case .empty: return .white
            }
        }()
        
        let borderColor: Color = {
            switch letter.status {
            case .empty: return Color.gray
            default: return Color.clear
            }
        }()
        
        return Text(letter.character)
            .font(.title)
            .frame(width: 60, height: 60)
            .background(bgColor)
            .foregroundColor(letter.status == .empty ? .black : .white)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(letter.status == .empty ? Color.gray : Color.clear, lineWidth: 2)
            )
            .cornerRadius(5)
    }

}
extension ContentView {
    func keyColor(_ key: String) -> Color {
        switch game.keyStates[key] {
        case .correct:
            return .green
        case .present:
            return .yellow
        case .absent:
            return .black.opacity(0.6)
        default:
            return Color.gray.opacity(0.8)
        }
    }
    
    var keyboard: some View {
        VStack(spacing: 8) {
            keyRow(["Q","W","E","R","T","Y","U","I","O","P"])
            keyRow(["A","S","D","F","G","H","J","K","L"])
            keyRow(["Z","X","C","V","B","N","M"], includeSpecial: true)
        }
        .padding(.horizontal)
    }

    func keyRow(_ keys: [String], includeSpecial: Bool = false) -> some View {
        HStack(spacing: 6) {

            // Special key on right (Enter)
            if includeSpecial {
                Button(action: { game.submitGuess() }) {
                    Text("Enter")
                        .keyboardSpecialKeyStyle()
                }
            }

            // Main letter keys
            ForEach(keys, id: \.self) { key in
                Button(action: { game.enterLetter(key) }) {
                    Text(key)
                        .keyboardKeyStyle(color: keyColor(key))
                }
            }
            
            // Special key on left (⌫)
            if includeSpecial {
                Button(action: { game.deleteLetter() }) {
                    Text("⌫")
                        .keyboardSpecialKeyStyle()
                }
            }

        }
    }
}

extension View {

    func keyboardKeyStyle(color: Color) -> some View {
        self
            .font(.title3)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 46)
            .padding(.horizontal, 2)
            .minimumScaleFactor(0.5)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(6)
    }

    func keyboardSpecialKeyStyle() -> some View {
        self
            .font(.headline)
            .frame(minWidth: 50, maxWidth: 65, minHeight: 46)
            .minimumScaleFactor(0.5)
            .background(Color.gray.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(6)
    }
}




#Preview {
    ContentView()
}
