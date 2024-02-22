

internal protocol CommandInternal{
    func runCommand(parameters: [String : [String]]) 
    var registeredParameters: [String:any Parameter] {get set}
}

protocol Command : CommandInternal{
    var Name: String {get}
    var validInputs: [String] {get}
    var activeParameters:[any Parameter] {get}
    var registeredParameters: [String: any Parameter] {get set}
    var hasParameters:Bool {get}
    var minNumParameters: Int {get}
    var maxNumParameters: Int {get}
    func runCommand(parameters: [String : [String]]) 
    func run(parameters: [[String : Any]])

    var description:String {get}

    init ()
}

extension Command{
    init(){
        self.init()
        self.registeredParameters = compileParameters()
    }


    private func compileParameters() -> [String:any Parameter]{

        var output: [String:any Parameter] = [:]
        for param: any Parameter in activeParameters {
            for flag:String in param.validFlags {
                output[flag.lowercased()] = param
            }
        }

        return output
    }

    func run(parameters: [[String : Any]]){
        // check the number of parameters is correct.
        guard parameters.count <= maxNumParameters else{
            print("Error: Command \(Name) may only accept up to \(maxNumParameters) parameters. " + 
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
        for parameter: [String : Any] in parameters{
            // badly formatted input is a programer problem so we throw a fatal error.
            guard let ParamName = parameter[parameterKey] as? String else{
                fatalError("Parameters is not in the right format: \(String(describing: dictionaryToString(parameter)))")
            }

            // make sure the parameter is registered to the command.
            guard let currentParamClass: any Parameter = registeredParameters[ParamName] else{
                print("The Parameter `\(ParamName)` for the command `\(Name)` was not found")
                return
            }

            // get the min and max values for the current parameter
            
            let currentMaxValues: Int = currentParamClass.maxNumValues
            let currentMinValues: Int = currentParamClass.minNumValues

            var valueList: [String] = []

            // if there were values passed in, put them in a list
            if (parameter.keys.contains(valueKey)){
                guard let valueListTemp: [String] = parameter[valueKey] as? [String] else{
                    fatalError("Parameters is not in the right format: \(String(describing: dictionaryToString(parameter)))")
                }

                valueList = valueListTemp
            }

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

            // add it to the output list.
            ParamList[ParamName] = valueList
        }

        


        // if we made it this far, run the command's code.
        runCommand(parameters: ParamList);
    }
}

protocol Parameter: Equatable {
    var Name: String { get }
    var validFlags: [String] { get }
    var hasValues: Bool { get }
    var maxNumValues: Int { get }
    var minNumValues: Int { get }
    var description: String { get }
}

extension Parameter {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.Name == rhs.Name && lhs.validFlags == rhs.validFlags
    }
}

