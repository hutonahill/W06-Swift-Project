struct Space: Equatable {
    let symbol: Character
    let validInputs: [String]
    let isEmpty: Bool

    init(symbol: Character, validInputs: [String], isEmpty: Bool) {
        self.symbol = symbol
        self.validInputs = validInputs
        self.isEmpty = isEmpty
    }
    
    static func == (lhs: Space, rhs: Space) -> Bool {
        return lhs.symbol == rhs.symbol
    }
}

let EmptySpace = Space(symbol: "-", validInputs: ["-", "blank", "empty"], isEmpty: true)
let XSpace = Space(symbol: "X", validInputs: ["x"], isEmpty: false)
let OSpace = Space(symbol: "O", validInputs: ["o"], isEmpty: false)



class Board{

    private let Empty: Space = EmptySpace

    private let O: Space = OSpace
    private let X: Space = XSpace
    
    private let DebugMode = false;
    
    private var isGameOver = false;

    public let boardSize = 3

    private var boardList: [Space] = []

    private let XStarts: Bool = true;

    private var isXTurn: Bool

    init(){
        isXTurn = XStarts;
        boardList = createBoardList()
        assembleBoardString()
    }

    private func createBoardList() -> [Space] {
        return [
            Empty, Empty, Empty,
            Empty, Empty, Empty,
            Empty, Empty, Empty
        ]
    }

    var boardString: String = "";

    private func assembleBoardString(){
        boardString = (
            "   a     b     c  \n" +
            "      |     |     \n" +
            "1  \(boardList[0].symbol)  |  \(boardList[1].symbol)  |  \(boardList[2].symbol)  \n" +
            " _____|_____|_____\n" +
            "      |     |     \n" +
            "2  \(boardList[3].symbol)  |  \(boardList[4].symbol)  |  \(boardList[5].symbol)  \n" +
            " _____|_____|_____\n" +
            "      |     |     \n" +
            "3  \(boardList[6].symbol)  |  \(boardList[7].symbol)  |  \(boardList[8].symbol)  \n" +
            "      |     |     "
        )
    }

    private var moveRecord:[String] = []

    public func getMoveRecord() -> [String]{
        return moveRecord
    }
    
    public func getIsGameOver() -> Bool{
        return isGameOver
    }

    public func GetCurrentPlayerSymbol() -> Character{
        if(isXTurn == true){
            return X.symbol
        }
        else{
            return O.symbol
        }
    }
    
    private func Debug(_ msg: String){
        if (DebugMode == true){
            print("\tBoard/" + msg.replacingOccurrences(of: "\n", with: "\n\t"))
        }
    }

    public func move(row: Int, column: Int) -> (didMove: Bool, gameOver: Bool){
        
        if (isGameOver == true){
            return (false, true)
        }
        
        let targetLocation = RCtoInt(row: row, column: column)
        var didMove: Bool = false
        var gameOver: Bool = false
        
        Debug("move: Debug 1.1: targetLocation == \(targetLocation)")
        
        if(boardList[targetLocation].isEmpty == true){
            var newSpace: Space
            Debug("move: Debug 1.2: isXTurn == \(isXTurn)")
            
            if(isXTurn == true){
                newSpace = X
                isXTurn = false
            }
            else{
                newSpace = O
                isXTurn = true
            }
            
            Debug("move: Debug 1.3: isXTurn == \(isXTurn)")
            
            boardList[targetLocation] = newSpace
            assembleBoardString()

            didMove = true
        }

        // Check for a win
        gameOver = checkForWin()
        Debug("move: Debug 2: gameOver == \(gameOver)")
            
        if (gameOver == false){
            var boardFull = true;

            for boardSpace: Space in boardList{
                if(boardSpace.isEmpty == false){
                    boardFull = false
                }
            }

            if (boardFull == true){
                gameOver = true
            }
        }
        
        isGameOver = gameOver
        

        return (didMove, gameOver)
    }

    private func checkForWin() -> Bool {
        // Check rows
        for i in stride(from: 0, to: 9, by: boardSize) {
            if (boardList[i] == boardList[i + 1] && boardList[i + 1] == boardList[i + 2] && boardList[i].isEmpty == false){
                Debug("checkForWin: Debug 1: rows. i == \(i)")
                return true
            }
        }

        // Check columns
        for i in 0..<3 {
            if (boardList[i] == boardList[i + (1*boardSize)] && boardList[i + (1*boardSize)] == boardList[i + (2*boardSize)] && boardList[i].isEmpty == false){
                Debug("checkForWin: Debug 2: cols. i == \(i)")
                return true
            }
        }

        // Check diagonals
        if (boardList[0] == boardList[4] && boardList[4] == boardList[8] && boardList[0].isEmpty == false){
            Debug("checkForWin: Debug 3: Diag 1.")
            return true
        }
        if (boardList[2] == boardList[4] && boardList[4] == boardList[6] && boardList[2].isEmpty == false){
            Debug("checkForWin: Debug 4: Diag 2.")
            return true
        }

        return false
    }

    private func RCtoInt(row: Int, column: Int) -> Int{
        return row * boardSize + column
    }

    public func display() -> String{
        return boardString
    }
}
