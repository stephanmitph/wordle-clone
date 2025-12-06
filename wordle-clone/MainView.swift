import SwiftUI

// MARK: - Main View

struct MainView: View {
    @StateObject private var game = WordleGame()
    @StateObject private var alertManager = AlertManager()
    
    @State private var rowShakeOffset: CGFloat = 0
    
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 15)
            
            // Game grid
            gameGrid
                .padding(.bottom, 20)
            
            Spacer()
            
            // Keyboard
            keyboard
        }
        .padding()
        .alertOverlay(alertManager)
    }
    
    // MARK: - Helper functions
    
    
    
    func shakeCurrentRow() {
        let duration = 0.08
        let offset: CGFloat = 10
        let animation = Animation.linear(duration: duration)
        withAnimation(animation) { rowShakeOffset = -offset }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration * 1) {
            withAnimation(animation) { rowShakeOffset = offset }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration * 2) {
            withAnimation(animation) { rowShakeOffset = -offset }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration * 3) {
            withAnimation(animation) { rowShakeOffset = offset }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration * 4) {
            withAnimation(animation) { rowShakeOffset = 0 }
        }
    }
    
    // MARK: - Game Grid
    
    private var gameGrid: some View {
        VStack(spacing: 4) {
            ForEach(0..<game.maxGuesses, id: \.self) { row in
                rowView(row)
            }
        }
    }
    
    // MARK: - Row Construction
    
    /// Renders a row of tiles based on the current game state
    /// - Parameter row: The row index to render
    /// - Returns: A view representing the row
    func rowView(_ row: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<game.wordLength, id: \.self) { column in
                tileView(letter: letterFor(row: row, column: column))
            }
        }
        .offset(x: row == game.guesses.count ? rowShakeOffset : 0)
    }
    
    /// Gets the letter for a specific position in the grid
    /// - Parameters:
    ///   - row: The row index
    ///   - column: The column index
    /// - Returns: The Letter object for this position
    private func letterFor(row: Int, column: Int) -> Letter {
        // Row is already submitted
        if row < game.guesses.count {
            return game.guesses[row][column]
        }
        
        // Row is the current active row
        if row == game.guesses.count {
            let currentLetters = Array(game.currentGuess)
            if column < currentLetters.count {
                return Letter(character: String(currentLetters[column]), status: .empty)
            }
        }
        
        // Empty cell
        return Letter(character: "", status: .empty)
    }
    
    // MARK: - Tile View
    
    /// Creates a tile view with flip animation
    /// - Parameter letter: The letter to display
    /// - Returns: An animated tile view
    func tileView(letter: Letter) -> some View {
        ZStack {
            // Front face - white tile with border
            tileFace(letter: letter, isBack: false)
                .opacity(letter.rotation < 90 ? 1 : 0)
            
            // Back face - colored tile
            tileFace(letter: letter, isBack: true)
                .opacity(letter.rotation >= 90 ? 1 : 0)
                .rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
        }
        .rotation3DEffect(
            .degrees(letter.rotation),
            axis: (x: 1, y: 0, z: 0),
            perspective: 0.5
        )
        .animation(.easeInOut(duration: 0.25), value: letter.rotation)
    }
    
    /// Creates a single face of the tile
    /// - Parameters:
    ///   - letter: The letter to display
    ///   - isBack: Whether this is the back face
    /// - Returns: A tile face view
    private func tileFace(letter: Letter, isBack: Bool) -> some View {
        Text(letter.character.uppercased())
            .font(.title)
            .fontWeight(.bold)
            .frame(width: 60, height: 60)
            .background(isBack ? colorForStatus(letter.status) : .white)
            .foregroundColor(isBack ? .white : .black)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isBack ? Color.clear : Color.gray, lineWidth: 2)
            )
    }
    
    /// Returns the appropriate color for a letter status
    /// - Parameter status: The letter status
    /// - Returns: The corresponding color
    private func colorForStatus(_ status: LetterStatus) -> Color {
        switch status {
        case .correct: return .green
        case .present: return .yellow
        case .absent: return .gray
        case .empty: return .white
        }
    }
}

// MARK: - Keyboard View

extension MainView {
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
    
    private func attemptSubmit() {
        if game.currentGuess.count == game.wordLength {
            game.submitGuess()
        } else {
            alertManager.showAlertMessage("Not enough letters")
            shakeCurrentRow()
        }
    }

    func keyRow(_ keys: [String], includeSpecial: Bool = false) -> some View {
        HStack(spacing: 6) {

            // Special key on right (Enter)
            if includeSpecial {
                Button(action: { attemptSubmit() }) {
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
    MainView()
}
