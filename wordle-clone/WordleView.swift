import SwiftUI

// MARK: - Main View

struct WorldeView: View {
    @StateObject private var game = WordleGame()
    @StateObject private var alertManager = AlertManager()
    
    @State private var rowShakeOffset: CGFloat = 0
    
    private var isGameFinished: Bool {
        // Won - found the word
        if let lastGuess = game.guesses.last {
            if lastGuess.allSatisfy({ $0.status == .correct }) {
                return true
            }
        }
        // Lost - ran out of guesses
        return game.guesses.count >= game.maxGuesses
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer(minLength: 15)
                
                // Game grid
                gameGrid
                    .padding(.bottom, 20)
                
                Spacer()
                
                // Keyboard
                keyboard
                    .disabled(isGameFinished)
                    .opacity(isGameFinished ? 0.5 : 1.0)
            }
            .padding()
            .alertOverlay(alertManager)
            
            // Floating restart button
            if isGameFinished {
                VStack {
                    Button(action: {
                        game.newGame()
                    }) {
                        Text("New Word")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.top, 20)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    
                    Spacer()
                }
            }
        }
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
            .frame(width: 65, height: 65)
            .background(isBack ? colorForStatus(letter.status) : .white)
            .foregroundColor(isBack ? .white : .black)
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(isBack ? Color.clear : Color.gray, lineWidth: 1)
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

extension WorldeView {
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
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let keySpacing: CGFloat = 6
            let specialKeyWidth: CGFloat = 55
            
            // All letter keys should be the same size
            // Top row has 10 keys
            let topRowKeyCount: CGFloat = 10
            let topRowKeyWidth = (totalWidth - (keySpacing * (topRowKeyCount - 1))) / topRowKeyCount
            
            // Use the same key size for all rows for consistency
            let keyWidth = topRowKeyWidth
            
            VStack(spacing: 8) {
                // Top row - 10 keys
                keyRow(["Q","W","E","R","T","Y","U","I","O","P"], keyWidth: keyWidth, spacing: keySpacing)
                
                // Middle row - 9 keys, centered
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: keyWidth / 2)
                    keyRow(["A","S","D","F","G","H","J","K","L"], keyWidth: keyWidth, spacing: keySpacing)
                    Spacer()
                        .frame(width: keyWidth / 2)
                }
                
                // Bottom row - 7 keys with special keys on both sides
                keyRow(["Z","X","C","V","B","N","M"], includeSpecial: true, keyWidth: keyWidth, specialKeyWidth: specialKeyWidth, spacing: keySpacing)
            }
        }
        .frame(height: 200)
    }
    
    private func attemptSubmit() {
        if game.currentGuess.count != game.wordLength {
            alertManager.showAlertMessage("Not enough letters")
            shakeCurrentRow()
            return
        }
        
        if !WordList.isValid(game.currentGuess) {
            alertManager.showAlertMessage("Not in word list")
            shakeCurrentRow()
            return
        }
        
        game.submitGuess()
    }

    func keyRow(_ keys: [String], includeSpecial: Bool = false, keyWidth: CGFloat, specialKeyWidth: CGFloat = 65, spacing: CGFloat) -> some View {
        HStack(spacing: spacing) {
            // Special key on left (Enter)
            if includeSpecial {
                Button(action: { if !isGameFinished { attemptSubmit() } }) {
                    Text("Enter")
                        .keyboardSpecialKeyStyle(width: specialKeyWidth)
                }
            }

            // Main letter keys
            ForEach(keys, id: \.self) { key in
                Button(action: { if !isGameFinished { game.enterLetter(key) } }) {
                    Text(key)
                        .keyboardKeyStyle(color: keyColor(key), width: keyWidth)
                }
            }
            
            // Special key on right (⌫)
            if includeSpecial {
                Button(action: { if !isGameFinished { game.deleteLetter() } }) {
                    Text("⌫")
                        .keyboardSpecialKeyStyle(width: specialKeyWidth)
                }
            }
        }
    }
}

extension View {
    func keyboardKeyStyle(color: Color, width: CGFloat) -> some View {
        self
            .font(.system(size: 20, weight: .bold))
            .frame(width: width, height: 58)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(4)
    }

    func keyboardSpecialKeyStyle(width: CGFloat) -> some View {
        self
            .font(.system(size: 13, weight: .bold))
            .frame(width: width, height: 58)
            .background(Color.gray.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(4)
    }
}


#Preview {
    WorldeView()
}
