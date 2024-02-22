// The Swift Programming Language

import Foundation


public let parameterKey: String = "parameter"
public let commandKey: String = "command"
public let valueKey: String = "values"

private var currentBoard: Board = Board();

var CommandList: [Command] = [
    HowTo(),
    Move(),
    Display(),
    StartNewGame()
]

let DebugMode: Bool = false


// === Move ====

final class Move : Command{

    override init(){
        super.init()
        Name = "Move"
        description = "Executes a move for the current Player then displays the board."
        validInputs = ["move"]
        activeParameters = [XPos(), YPos()]
        hasParameters = true
        minNumParameters = 0
        maxNumParameters = 2
        
        compileParameters()
    }
    
    override func runCommand(parameters: [String : [String]]) {
        
        var gotRow: Bool = false
        var row: Int = 0
        var gotCol: Bool = false
        var col: Int = 0
        
        Debug("Move: Debug 0.1: parameters.count == \(parameters.count)")
        
        for key: String in parameters.keys{
            if let currentParamClass = registeredParameters[key] {
                
                Debug("Move: Debug 0.2: currentParamClass.Name == \(currentParamClass.Name)")
                
                if (currentParamClass == activeParameters[0]){
                    guard let rowTemp: Int = Int(parameters[key]![0]) else{
                        print("Parameter `\(currentParamClass.Name)` for command `\(Name)` called with flag `\(key)` " + 
                        "expected an Int value but received `\(String(describing: parameters[key]?[0]))`")
                        return
                    }
                    row = rowTemp - 1
                    gotRow = true;
                }
                
                else if (currentParamClass == activeParameters[1]){
                    guard let colTemp: Int = Int(parameters[key]![0]) else{
                        print("Parameter `\(currentParamClass.Name)` for command `\(Name)` called with flag `\(key)` " + 
                        "expected an Int value but received `\(String(describing: parameters[key]?[0]))`")
                        return
                    }
                    col = colTemp - 1
                    gotCol = true;
                }
            } else {
                fatalError("Parameters is not in the right format: \(String(describing: dictionaryToString(parameters)))")
            }
        }

        let currentPlayerSymbol: String = String(currentBoard.GetCurrentPlayerSymbol())
        
        
        if(gotRow != true){
            Debug("Move: Debug 1: Getting row")
            var validInput: Bool = false
            while (validInput == false){
                print("Enter the row you would like to play in: \(currentPlayerSymbol)>", terminator: "")
                let rawUserInput = readLine()
                Debug("Move: Debug 1.1: rawUserInput == `\(String(describing: rawUserInput))`")
                var tempRow: Int
                if let convertedInput = Int(rawUserInput!){
                    tempRow = convertedInput
                }
                else{
                    tempRow = -1
                }
                
                Debug("Move: Debug 1.2: tempRow == \(tempRow)")
                
                if (tempRow == 1 || tempRow == 2 || tempRow == 3){
                    validInput = true
                    row = tempRow - 1
                }
                else{
                    print("Please input 1, 2 or 3.")
                }
                
                Debug("Move: Debug 1.3: row == \(row)")
            }
            
        }

        if(gotCol != true){
            Debug("Move: Debug 2: Getting Col")
            var validInput: Bool = false
            while (validInput == false){
                print("Enter the column you would like to play in: \(currentPlayerSymbol)>", terminator: "")
                
                let rawUserInput = readLine()
                Debug("Move: Debug 2.1: rawUserInput == `\(String(describing: rawUserInput))`")
                
                let tempCol: Character
                
                if rawUserInput!.count == 1{
                    tempCol = rawUserInput!.first!
                }
                else{
                    tempCol = "f"
                }
                
                Debug("Move: Debug 2.2: tempCol == \(tempCol)")
                
                validInput = true
                switch tempCol.lowercased() {
                case "1", "a":
                    col = 0
                case "2", "b":
                    col = 1
                case "3", "c":
                    col = 2
                default:
                    print("Please input a, b, or c.")
                    validInput = false
                }
                
                Debug("Move: Debug 2.3: col == \(col)")
            }
            
        }
        
        Debug("Move: Debut 3: making the move")
        Debug("Move: Debug 3.1: row == \(row), col == \(col)")

        var success: Bool
        var gameOver: Bool

        (success, gameOver) = currentBoard.move(row: row, column: col)

        print(currentBoard.display())

        if (success == true){
            print("Success! it is now Player `\(currentBoard.GetCurrentPlayerSymbol())`'s turn")
        }
        else{
            print("Move Failed. It is still Player \(currentBoard.GetCurrentPlayerSymbol())'s turn")
        }

        if (gameOver == true){
            print("Game Over! Start a new game with the `start` command!")
        }
    }
}

final class XPos : Parameter{
    
    override init(){
        super.init()
        Name = "X Position"
        validFlags = ["-x", "x", "letter", "-letter", "l", "-l", "row", "-row", "r", "-r"]
        hasValues = true
        maxNumValues = 1;
        minNumValues = 1;
        description = "Allows the user to set the x position (also known as letter or row) of the move in the move function"
    }
}

final class YPos : Parameter{
    
    override init(){
        super.init()
        Name = "Y Position"
        validFlags = ["-y", "y", "num", "-num", "n", "-n", "column", "-column", "col", "-col", "c", "-c"]
        hasValues = true
        maxNumValues = 1;
        minNumValues = 1;
        description = "Allows the user to set the y position (also know as column) of the move in the move function"
    }
}

// === How To ===

final class HowTo : Command {
    
    
    override init(){
        super.init()
        Name = "How To"
        validInputs = ["howto", "how", "tutorial", "tut"]
        description = "Prints a guid explaining how to play the game."
        activeParameters = []
        hasParameters = false
        minNumParameters = 0
        maxNumParameters = 0
        
        compileParameters()
    }
    
    override func runCommand(parameters: [String : [String]]){
        print("Welcome to Tic Tac Toe!\n" +

            "This is a game of trying to match 3 in a row.\n\n" + 

            "To make a move use the Move command. (If you want you can use the row and " + 
            "col parameters to pass in the row or column numbers, but if you don't the " + 
            "system will prompt you for them.) \n\n" +  

            "If your row and column are valid the current players Symbol will be placed " + 
            "in the space and it will become the next person's turn.\n\n" +

            "The game ends when the board is full or when simone gets 3 in a row.\n\n" + 

            "If you ever forget who's turn it is the Move command will display the current " + 
            "player's character at the start of its prompt if you don't pass in any parameters."
        )
    }

    
}

// === Display ===
final class Display : Command{
    
    
    
    override init(){
        super.init()
        Name = "Display"
        validInputs = ["display", "show"]
        description = "shows the current state of the board";
        activeParameters = []
        hasParameters = false
        minNumParameters = 0
        maxNumParameters = 0
        
        compileParameters()
    }
    
    override func runCommand(parameters: [String : [String]]) {
        print("\nit is \(currentBoard.GetCurrentPlayerSymbol())'s turn")
        print(currentBoard.display())
    }
}

// === Start New Game
final class StartNewGame : Command{
    
    override init(){
        super.init()
        Name = "Start New Game"
        validInputs = ["start", "newgame", "startnewgame", "begin"]
        description = "Starts a new game"
        activeParameters = []
        hasParameters = false;
        minNumParameters = 0
        maxNumParameters = 0;
        
        compileParameters()
    }
    
    override func runCommand(parameters: [String : [String]]) {
        if(currentBoard.getIsGameOver() == true){
            currentBoard = Board()
        }
        else{
            print("The current game is not over.")
            
            var validInput: Bool = false
            
            while (validInput == false){
                print("Are you sure you want ot start a new game? (y/n): ", terminator: "")
                let rawUserInput: String = readLine()!.lowercased()
                
                switch rawUserInput{
                    case "y", "yes", "continue":
                        currentBoard = Board()
                        validInput = true
                    case "n", "no":
                        validInput = true
                    default:
                        print("Invalid Input. Please Input `y` or `n`")
                }
            }
            
            
        }
    }
}


func convertInput<T>(_ input: String, to type: T.Type) -> T? {
    return input as? T
}


// for parsing the elements of a command from its string.



func dictionaryToString(_ dictionary: [String: Any]) -> String? {
    do {
        // Convert the dictionary to Data with indented formatting
        let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted])

        // Convert the Data to a String
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        } else {
            print("Failed to convert Data to String.")
            return nil
        }
    } catch {
        print("Error serializing dictionary to JSON: \(error)")
        return nil
    }
}

func arrayToString(_ array: [String]) -> String {
    let items: String = array.joined(separator: "`, `")
    return "[`\(items)`]"
}

private func parseCommand(_ input: String) -> [String: Any] {
    var parameters: [[String: [String]]] = []

    // Split the input string into components using space as the delimiter
    var components: [String] = input.components(separatedBy: " ")

    Debug("Debug 0: components.count == \(components.count)")

    // Extract command (the first component)
    guard let command: String = components.first else{
        fatalError("ERROR command in bad format")
    }

    components.removeFirst()

    // Extract parameters 
    while components.count > 0 {
        var component:String = components[0]

        //print("Debug 1: component==\(component)")

        // Check if the component contains '(' and ')', indicating it has values
        Debug("Debut 1.1 components == \(arrayToString(components))")
        Debug("Debug 1.2: component = \(component)")
        if component.contains("(") {

            // Step 1 is to find the matching closing parentheses.
            // We do this by looping through the next elements in 
            // the list of components and adding them to the current 
            // component until we add one that contains ')'.
            Debug("Debug 2")
            var i : Int = 0
            while !component.contains(")") {
                // i will also be used to rem>voe all components that we combined
                // when we are done parsing this peram. 
                i += 1
                Debug("\tDebug 3[\(i)]")

                // if we got to the end fo the command before we find the close, throw an error.
                guard i < components.count else {
                    // Error: Mismatched parentheses
                    return ["error": "Mismatched parentheses"]
                }
                component += " " + components[i]
                Debug("\tDebug 3.1[\(i)]: component = \(component)")
            }

            guard component.last == ")" else{
                return ["error": "Parameters with values must end with `)`. A Parameter in the input ends with `\(String(describing: component.last))`"]
            }

            //print("Debug 4: component==\(component)")

            // now we split off the title of the parameter
            let parts:[String] = component.components(separatedBy: "(")

            guard parts.count == 2  else{
                return ["error": "the values of parameters may not include the '(' character."]
            }

            let parameterName:String = parts.first ?? ""

            var values: [String] = []

            // And we remove the closing ')'
            let valuesString:String = parts.last?.replacingOccurrences(of: ")", with: "") ?? ""

            // Split valuesString into individual values using ','
            values = valuesString.components(separatedBy: ",")
            let parameterDictionary: [String: [String]] = [parameterName.lowercased() : values]
            

            // add the result to the parameter list
            parameters.append(parameterDictionary)

            // finally, remove all used components.
            for _ in 0...i {
                components.removeFirst()
            }

        } else {
            // Extract parameter without values
            parameters.append([component.lowercased() : []])
            components.removeFirst()
        }

    }

    // Assign the parameters array to the "parameters" key in the result dictionary
    return [command : parameters]
}

private func Debug(_ msg: String){
    if (DebugMode == true){
        print("\t" + msg.replacingOccurrences(of: "\n", with: "\n\t"))
    }
}

var command: String = "run title(this is a great title) scripts(1, 2) short"

command = "run"

// print()
// print(command)
// print()
// print(dictionaryToString(parseCommand(command)) ?? "NULL" )

let Program: CommandLoop = CommandLoop(CommandListInput: CommandList)

// control loop

