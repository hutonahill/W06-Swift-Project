
class CommandLoop {
    private var running: Bool = true;

    private var CommandList: [any Command]

    private var CommandRegistry: [String : any Command] = [:]

    init(CommandListInput: [any Command]){
        CommandList = CommandListInput

        CommandRegistry = CompileCommands()

        Main()
    }

    private let exitInputs: [String] = ["exit", "back"]

    private func Main(){
        while (running == true){
            // get input from user

            var validInput: Bool = false
            let processedCommand: [String : [[String: [String]]]] = [:]

            while (validInput == false){
                print("CommandLoop: Debug 1")

                print(">")
                let rawCommand: String = readLine() ?? " "

                print("CommandLoop: Debug 1.1: rawCommand == `\(rawCommand)`")

                if (exitInputs.contains(rawCommand.lowercased()) ) {
                    validInput = true
                    end()
                }
                else{
                    // parse that input into a command
                    let processedCommand: [String : [[String: [String]]]] = parseCommand(rawCommand)

                    if (processedCommand.keys.count > 1){
                        print("ERROR: parseCommand returned a dict with more than 1 key")
                        validInput = true
                        end();
                    }

                    if let errorCommand:[[String : [String]]] = processedCommand["error"], !errorCommand.isEmpty,
                        let errorMessage = errorCommand[0].values.first {
                        print(errorMessage)
                    } else {
                        validInput = true
                    }
                }
            }

            // if the program is still running and there is anything in the
            // processed command (anything more than 1 was checked above)
            if (running == true && processedCommand.keys.count == 1){
                // use registry to get the command
                let commandName: String = processedCommand.keys.first!
                let ParameterList: [[String : [String]]] = processedCommand[commandName]!

                if let targetCommand: any Command = CommandRegistry[commandName]{
                    // run the command
                    targetCommand.run(parameters: ParameterList)
                } else{
                    print("Invalid Command")
                }

                

                print()
            }
        }
    }

    public func end(){
        running = false
    }

    private func CompileCommands() -> [String : Command]{
        var output: [String : Command] = [:]

        for exitInput:String in exitInputs{
            output[exitInput.lowercased()] = nil;
        }

        for method: any Command in CommandList {
            for validInput: String in method.validInputs{

                guard !output.keys.contains(validInput) else{
                    fatalError("duplicate key `\(validInput)` for command `\(method.Name)`")
                }

                output[validInput.lowercased()] = method
            }
        }

        return output
    }

    

    private func parseCommand(_ input: String) -> [String: [[String: [String]]]] {
        var parameters: [[String: [String]]] = []
        if input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // The string is either empty or contains only spaces
            return [:];
        }
        
        

        // Split the input string into components using space as the delimiter
        var components: [String] = input.split(separator: " ").map(String.init)

        print("parseCommand: Debug 0: components.count == \(components.count)")

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
            print("parseCommand: Debut 1.1 components == \(arrayToString(components))")
            print("parseCommand: Debug 1.2: component = \(component)")
            if component.contains("(") {

                // Step 1 is to find the matching closing parentheses.
                // We do this by looping through the next elements in 
                // the list of components and adding them to the current 
                // component until we add one that contains ')'.
                //print("Debug 2")
                var i : Int = 0
                while !component.contains(")") {
                    // i will also be used to rem>voe all components that we combined
                    // when we are done parsing this peram. 
                    i += 1
                    //print("\tDebug 3[\(i)]")

                    // if we got to the end fo the command before we find the close, throw an error.
                    guard i < components.count else {
                        // Error: Mismatched parentheses
                        return ["error": [["Mismatched parentheses":[]]]]
                    }
                    component += " " + components[i]
                    print("\tparseCommand: Debug 3.1[\(i)]: component = \(component)")
                }

                guard component.last == ")" else{
                    return ["error": [["Parameters with values must end with `)`. A Parameter in the input ends with `\(String(describing: component.last))`":[]]]]
                }

                //print("Debug 4: component==\(component)")

                // now we split off the title of the parameter
                let parts:[String] = component.components(separatedBy: "(")

                guard parts.count == 2  else{
                    return ["error": [["the values of parameters may not include the '(' character.":[]]]]
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

}



