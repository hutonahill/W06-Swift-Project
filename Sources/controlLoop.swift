

class CommandLoop {
    private var running: Bool = true;

    private var CommandList: [any Command]
    
    private let DebugMode: Bool = false

    private var CommandRegistry: [String : any Command] = [:]

    init(CommandListInput: [any Command]){
        CommandList = CommandListInput

        CommandRegistry = CompileCommands()
        
        CheckFundimental(helpInputs)
        CheckFundimental(exitInputs)
        CheckFundimental(commandHelpInputs)

        Main()
    }

    private let exitInputs: [String] = ["exit", "back", "-exit", "-e"]
    
    private let helpInputs: [String] = ["help", "-help", "-h"]
    
    private let commandHelpInputs: [String] = ["commandhelp", "commands", "command"]

    private func Main(){
        while (running == true){
            // get input from user

            var validInput: Bool = false
            var processedCommand: [String : [[String: [String]]]] = [:]

            while (validInput == false){
                Debug("Main: Debug 1, Waiting for user Input")

                print(">", terminator: "")
                let rawCommand: String = readLine() ?? " "
                Debug("Main: Debug 1.1: rawCommand == `\(rawCommand)`")
                
                // parse that input into a command
                processedCommand = parseCommand(rawCommand)
                
                Debug("Main: Debug 1.3: processed command == \(dictionaryToString(processedCommand)!)")

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
            
            Debug("Main: Debug 2.1: processedCommand.keys == \(processedCommand.keys)")
            
            // if the program is still running and there is anything in the
            // processed command (anything more than 1 was checked above)
            if (running == true && processedCommand.keys.count == 1){
                // use registry to get the command
                let commandName: String = processedCommand.keys.first!
                let ParameterList: [[String : [String]]] = processedCommand[commandName]!
                Debug("Main: Debug 2.2: commandName == \(commandName)")
                
                if (exitInputs.contains(commandName) ) {
                    validInput = true
                    Debug("main: Debug 1.2: detected exit command, ending control loop")
                    end()
                }
                else if (helpInputs.contains(commandName)){
                    Help()
                }
                else if CommandRegistry.keys.contains(commandName){
                    if let targetCommand: any Command = CommandRegistry[commandName]{
                        // run the command
                        targetCommand.run(parameters: ParameterList)
                        
                    }
                    else{
                        print("ERROR")
                    }
                }
                
                 else{
                    print("Invalid Command. Please try the `help` command.")
                }
                print()
            }
            Debug("Main: Debug 3: end of control loop")
        }
    }


    private func CompileCommands() -> [String : Command]{
        var output: [String : Command] = [:]
        
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
    
    private func CheckFundimental(_ validInputs: [String]){
        for validInput:String in validInputs{
            guard !CommandRegistry.keys.contains(validInput) else{
                fatalError("valid input `\(validInput)` for command `\(CommandRegistry[validInput]!.Name)` overwrites a fundimental command")
            }
        }
    }
    
    private func Debug(_ msg: String){
        if (DebugMode == true){
            print("\tCommandLoop/" + msg.replacingOccurrences(of: "\n", with: "\n\t"))
        }
    }
    
    public func end(){
        running = false
    }
    
    private func CommandHelp(){
        let output: String = (
            "Welcome to the command Helper!\n" +
            "\n" +
            "This Program uses a command system. Every action has a command. To see a list of the implemented commands and the valid inputs this program will recognize use the `help` command.\n" +
            "\n" +
            "Some command have flags. Each command has a list of flags in its portion of the help page. Each flag will then have a list of valid inputs that the program will recognize as that flag. \n" +
            "\n" +
            "To use a flag type one of its valid inputs after its command with a space in between, for example here is a command with two flags:\n" +
            "`command flag1 flag2`\n" +
            "\n" +
            "Some flags have values. If it does you need to put the value within parentheses. Values may not include parentheses or comas. \n" +
            "\n" +
            "Here is an example of how to include values. flag1 has one value and flag2 as 2 values while flag3 has no values:\n" +
            "`command flag1(value) flag2(valueA, valueB) flag 3\n" +
            "\n" +
            "That should be every thing you need to know to use this command system!"
        )
    }
    
    private func Help(){
        var output: String = ""
        
        // I am itching to create a better system for fundimental commands, but i dont have time.
        
        // print info about help.
        output += "Help\n"
        output += "\tDescription: Prints this help page\n"
        output += "\tValid Inputs: "
        
        for value: String in helpInputs{
            output += "`\(value)`, "
        }
        
        output = String(output.prefix(output.count - 2)) + "\n"
        output += "\tCommand Does Not Have Flags\n\n"
        
        // print info about exit
        output += "Exit\n"
        output += "\tDescription: Closes the progam\n"
        output += "\tValid Inputs: "
        
        for value: String in helpInputs{
            output += "`\(value)`, "
        }
        
        output = String(output.prefix(output.count - 2)) + "\n"
        output += "\tCommand Does Not Have Flags\n\n"
        
        // print info about commandhelp
        output += "Command Help\n"
        output += "\tDescription: Prints a help page explaning how to use the command system\n"
        output += "\tValid Inputs: "
        
        for value: String in commandHelpInputs{
            output += "`\(value)`, "
        }
        
        output = String(output.prefix(output.count - 2)) + "\n"
        output += "\tCommand Does Not Have Flags\n\n"
        
        print(output)
        
        // print info about all other commands.
        for command: any Command in self.CommandList{
            print(getCommandData(command))
        }
    }
    
    private func getCommandData(_ cmd: any Command) -> String{
        var output: String = "";
        output += cmd.Name + "\n"
        output += "\tDescription: " + cmd.description + "\n"
        output += "\tValid Inputs: "
        
        for value: String in cmd.validInputs{
            output += "`\(value)`, "
        }
        
        output = String(output.prefix(output.count - 2)) + "\n"
        
        if (cmd.hasParameters == true){
            output += "\tCommand Has Flags\n"
            for flag: any Parameter in cmd.activeParameters{
                output += GetFlagData(flag)
            }
        }
        else{
            output += "\tCommand Does Not Have Flags\n"
        }
        
        return output
    }
    
    private func GetFlagData(_ flag: any Parameter, tabLevel: Int = 1) -> String{
        var output: String = ""
        
        var tabValue = ""
        for _index: Int in 0..<tabLevel {
            tabValue += "\t"
        }
        
        output += tabValue + flag.Name + "\n"
        
        output += tabValue + "\tDescription: \(flag.description)\n"
        
        output += tabValue + "\tValid Flags: "
        for value: String in flag.validFlags{
            output += "`\(value)`, "
        }
        output = String(output.prefix(output.count - 2)) + "\n"
        
        if(flag.hasValues == true){
            output += tabValue + "\tFlag has values\n"
            output += tabValue + "\tMinimum number of values: \(flag.minNumValues)\n"
            output += tabValue + "\tMaximum number of values: \(flag.maxNumValues)\n"
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

        Debug("parseCommand: Debug 0: components.count == \(components.count)")

        // Extract command (the first component)
        guard let command: String = components.first else{
            fatalError("ERROR command in bad format")
        }

        components.removeFirst()

        // Extract parameters 
        while components.count > 0 {
            var component:String = components[0]

            Debug("Debug 1: component==\(component)")

            // Check if the component contains '(' and ')', indicating it has values
            Debug("parseCommand: Debut 1.1 components == \(arrayToString(components))")
            Debug("parseCommand: Debug 1.2: component = \(component)")
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
                        return ["error": [["Mismatched parentheses":[]]]]
                    }
                    component += " " + components[i]
                    Debug("parseCommand: Debug 3.1[\(i)]: component = \(component)")
                }

                guard component.last == ")" else{
                    return ["error": [["Parameters with values must end with `)`. A Parameter in the input ends with `\(String(describing: component.last))`":[]]]]
                }

                Debug("Debug 4: component==\(component)")

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

