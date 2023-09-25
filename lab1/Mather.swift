import Foundation

class Mather {
    var infixExpression: String = ""
    var postfixExpression: String = ""
    private let operationPriority: [Character:Int] = [
        "(" : 0,
        "+" : 1,
        "-" : 1,
        "*" : 2,
        "/" : 2,
        "^" : 3,
        "~" : 4, //unary minus
        "&" : 3 //logarithm
    ]
    
    private enum ThrowableError: Error { //
        case badError(howBad: String)
    }
    
    private func getStringNumber(from expression: String, in position: Int) throws -> (String, Int) {
        var stringNumber = ""
        var pos = position
        var isDecimal = false
        while pos < expression.count {
            let digit = expression[expression.index(expression.startIndex, offsetBy: pos)]
            if digit.isNumber {
                stringNumber += String(digit)
                pos += 1
            } else if digit == "." && isDecimal == false {
                stringNumber += String(digit)
                pos += 1
                isDecimal = true
            } else if digit == "." && isDecimal == true {
                throw ThrowableError.badError(howBad: "Delete excessive dots")
            } else {
                pos-=1
                break
            }
        }
        if stringNumber.first == "." {
            stringNumber.insert("0", at: stringNumber.startIndex)
        }
        return (stringNumber, pos)
    }
    
    private func toPostfix(from infixExpr1: String) throws -> String {
        if infixExpr1.filter({$0 == "("}).count != infixExpr1.filter({$0 == ")"}).count {
            throw ThrowableError.badError(howBad: "The number of brackets doesn't match")
        }
        var postfixString = ""
        var infixExpr = infixExpr1
        var stack: [Character] = []
        var index = 0
        let regex = try! NSRegularExpression(pattern: "log\\((.*?),(.*?)\\)")
        while infixExpr.contains(try! Regex("log\\((.*?),(.*?)\\)")){ 
            infixExpr = regex.stringByReplacingMatches(in: infixExpr, range: NSRange(infixExpr.startIndex..., in: infixExpr), withTemplate: "($1&$2)")
        }
        if operationPriority[infixExpr.last ?? "0"] != nil {
            throw ThrowableError.badError(howBad: "The operator is on the last position")
        }
        while index < infixExpr.count {
            let char = infixExpr[infixExpr.index(infixExpr.startIndex, offsetBy: index)]
            if index >= 1 {
                let charPrevious = infixExpr[infixExpr.index(infixExpr.startIndex, offsetBy: index - 1)]
                if operationPriority[char] != nil && operationPriority[charPrevious] != nil && char == charPrevious && char != "(" {
                    print(String(char) + " " + String(charPrevious))
                    throw ThrowableError.badError(howBad: "Repetitive operators")
                }
            }
            if !char.isNumber && operationPriority[char] == nil && char != ")" && char != " " && char != "." { //если не число и не оператор
                print(String(char))
                throw ThrowableError.badError(howBad: "Foreign characters in a string")
            }
            if char.isNumber || char == "." {
                let (stringNumber, indexGot) = try getStringNumber(from: infixExpr, in: index)
                postfixString += stringNumber + " ";
                index = indexGot
            } else if char == "(" {
                stack.append(char)
            } else if char == ")" {
                while stack.count > 0 && stack.last != "(" {
                    postfixString += String(stack.removeLast())
                }
                stack.removeLast()
            } else if operationPriority[char] != nil {
                var operation = char
                if operation == "-" && (index == 0 || (index > 1 && (operationPriority[infixExpr[infixExpr.index(infixExpr.startIndex, offsetBy: index - 1)]] != nil))) {
                    operation = "~"
                }
                while stack.count > 0 && operationPriority[stack.last ?? "0"] ?? 0 >= operationPriority[operation] ?? -1 {
                    postfixString += String(stack.removeLast())
                }
                stack.append(operation)
            }
            index += 1
        }
        for oper in stack.reversed() {
            postfixString += String(oper)
        }
        return postfixString
        
    }
    
    private func execute(operation: Character, first: Double, second: Double) throws -> Double {
        switch operation {
        case "+":
            return first + second
        case "-":
            return first - second
        case "*":
            return first * second
        case "/":
            if second == 0 {
                throw ThrowableError.badError(howBad: "Division by zero")
            }
            return first / second
        case "^":
            return pow(first, second)
        case "&":
            if (second <= 0 || first <= 0 || first == 1) {
                throw ThrowableError.badError(howBad: "Wrong numbers in the logarithm")
            }
            return log(second) / log(first)
        default:
            return 0
        }
    }
    
    func Calc() -> Double? {
        do{
            if postfixExpression == "e" {
                throw ThrowableError.badError(howBad: "")
            }
            var locals: [Double] = [] //результаты действий
            var counter = 0
            var index = 0
            while index < postfixExpression.count {
                let char = postfixExpression[postfixExpression.index(postfixExpression.startIndex, offsetBy: index)]
                if char.isNumber || char == "." {
                    let (stringNumber, indexGot) = try getStringNumber(from: postfixExpression, in: index)
                    locals.append(Double(stringNumber) ?? 0)
                    index = indexGot
                } else if (operationPriority[char] != nil) {
                    counter += 1
                    if char == "~" {
                        let last = locals.count > 0 ? locals.removeLast() : 0
                        locals.append(try execute(operation: "-", first: 0, second: last))
                        print("\(counter)) \(char) \(last) = \(locals.last ?? 0)")
                        index += 1
                        continue
                    }
                    let second = locals.count > 0 ? locals.removeLast() : 0
                    let first = locals.count > 0 ? locals.removeLast() : 0
                    locals.append(try execute(operation: char, first: first, second: second))
                    print("\(counter)) \(first) \(char) \(second) = \(locals.last ?? 0)")
                }
                index += 1
            }
            if locals.isEmpty {
                return 0
            } else {
                return locals.removeLast()
            }
        }
        catch ThrowableError.badError(howBad: let howBad){
            print(howBad)
            return nil
        } catch {
            print("other error")
            return nil
        }
    }
    
    init(expression: String = "") {
        do{
            infixExpression = expression
            postfixExpression = try toPostfix(from: infixExpression)
        }
        catch ThrowableError.badError(howBad: let howBad){
            postfixExpression = "e"
            print(howBad)
        } catch {
            print("other error")
        }
        
    }
}

