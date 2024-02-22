

class Command{
    private let CommandDebugMode: Bool = false
    internal private(set) var registeredParameters: [String: Parameter] = [:]
    public internal(set) var Name: String 
    public internal(set) var description:String
    public internal(set) var validInputs: [String]
    public internal(set) var activeParameters:[Parameter]
    public internal(set) var hasParameters:Bool
    public internal(set) var minNumParameters: Int
    public internal(set) var maxNumParameters: Int
    internal func runCommand(parameters: [String : [String]]){}
    public func run(parameters: [[String : [String]]]){
        
        Debug("run: Debug 0.1: parameters.count = \(parameters.count)")
        
        // check the number of parameters is correct.
        guard parameters.count <= maxNumParameters else{
            print("The Command \(Name) may only accept up to \(maxNumParameters) parameters. " +
            "You passed in \(parameters.count). If you need help, try the `-help` command.")
            return
        }
        guard parameters.count >= minNumParameters else{
            print("Error: Command \(Name) must have at least \(minNumParameters) parameters. " +
            "You passed in \(parameters.count). If you need help, try the `-help` command.")
            return
        }

        var ParamList: [String:[String]] = [:]

        // validate each parameters
        for parameter: [String : [String]] in parameters{
            
            var ParamName: String
            if (parameter.keys.count == 1) {
                ParamName = parameter.keys.first!
                Debug("run: Debug 1.1: ParamName == \(ParamName)")
            }
            else{
                // badly formatted input is a programer problem so we throw a fatal error.
                let errorMsg = "Parameter dict should only have one entry \(dictionaryToString(parameter)!)"
                print(errorMsg)
                fatalError()
            }
            
            Debug("run: Debug 1.2: registeredParameters.keys.count == \(registeredParameters.keys.count)")

            // make sure the parameter is registered to the command.
            guard let currentParamClass: Parameter = registeredParameters[ParamName] else{
                print("The Parameter `\(ParamName)` for the Command `\(Name)` was not found")
                return
            }

            // get the min and max values for the current parameter
            
            let currentMaxValues: Int = currentParamClass.maxNumValues
            let currentMinValues: Int = currentParamClass.minNumValues
            
            var valueList: [String] = []
            
            if (currentParamClass.hasValues == true){
                guard let valueListTemp: [String] = parameter[ParamName] else{
                    fatalError("Parameters is not in the right format: \(dictionaryToString(parameter)!)")
                }

                valueList = valueListTemp
                Debug("run: Debug 1.2: valueList.count == \(valueList.count)")
                

                // compar the actual number of values to the expected number of values.
                guard valueList.count >= currentMinValues else{
                    print("Parameter `\(ParamName)` for Command `\(Name)` expected at least " +
                    "\(currentMinValues) values but only got \(valueList.count)")
                    return
                }
                guard valueList.count <= currentMaxValues else{
                    print("Parameter `\(ParamName)` for Command `\(Name)` expected " +
                    "\(currentMaxValues) values at most but got \(valueList.count)")
                    return
                }
            }
            
            // add it to the output list.
            ParamList[ParamName] = valueList
        }

        


        // if we made it this far, run the command's code.
        runCommand(parameters: ParamList);
    }
    
    internal func compileParameters(){

        var output: [String:Parameter] = [:]
        for param: Parameter in activeParameters {
            for flag:String in param.validFlags {
                output[flag.lowercased()] = param
            }
        }

        registeredParameters = output
    }
    
    private func Debug(_ msg: String){
        if (CommandDebugMode){
            print("\tCommand/" + msg.replacingOccurrences(of: "\n", with: "\n\t"))
        }
    }

    init (){
        Name = "nil"
        description = "nil"
        validInputs = []
        activeParameters = []
        hasParameters = false
        minNumParameters = -1
        maxNumParameters = -1
    }
    
    
}



class Parameter: Equatable {
    public internal(set) var Name: String
    public internal(set) var description: String
    public internal(set) var validFlags: [String]
    public internal(set) var hasValues: Bool
    public internal(set) var maxNumValues: Int
    public internal(set) var minNumValues: Int
    
    public static func == (lhs: Parameter, rhs: Parameter) -> Bool {
        return lhs.Name == rhs.Name && lhs.validFlags == rhs.validFlags
    }
    
    init(){
        Name = "nil"
        description = "nil"
        validFlags = []
        hasValues = false
        maxNumValues = -1
        minNumValues = -1
    }
}


