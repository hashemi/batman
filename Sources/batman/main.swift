enum Token: CustomStringConvertible {
    enum Punctuator: Character {
        case leftParen = "("
        case rightParen = ")"
        case comma = ","
        case assign = "="
        case plus = "+"
        case minus = "-"
        case asterisk = "*"
        case slash = "/"
        case caret = "^"
        case tilde = "~"
        case bang = "!"
        case question = "?"
        case colon = ":"
    }
    
    case punctuator(Punctuator)
    case name(String)
    
    var description: String {
        switch self {
        case let .name(name):
            return name
        
        case let .punctuator(p):
            return String(p.rawValue)
        }
    }
}

enum Precedence: Int {
    case assignment = 1
    case conditional
    case sum
    case product
    case exponent
    case prefix
    case postfix
    case call
}

struct Lexer: IteratorProtocol {
    private var index: String.Index
    private var text: String
    
    init(_ text: String) {
        self.text = text
        self.index = self.text.startIndex
    }
    
    mutating func next() -> Token? {
        while index < text.endIndex {
            let c = text[index]
            index = text.index(after: index)

            if let p = Token.Punctuator(rawValue: c) {
                return .punctuator(p)
            }
            
            if c.isLetter {
                let start = text.index(before: index)
                while index < text.endIndex {
                    if !text[index].isLetter { break }
                    index = text.index(after: index)
                }
                
                let name = String(text[start..<index])
                return .name(name)
            }
            
            // ignore all other characters
        }
        
        return nil
    }
}

extension Character {
    var isLetter: Bool {
        return (self >= "A" && self <= "Z") || (self >= "a" && self <= "z")
    }
}

indirect enum Expression: CustomStringConvertible {
    case assign(name: String, right: Expression)
    case call(function: Expression, args: [Expression])
    case conditional(condition: Expression, thenArm: Expression, elseArm: Expression)
    case name(name: String)
    case op(left: Expression, op: Token.Punctuator, right: Expression)
    case postfix(left: Expression, op: Token.Punctuator)
    case prefix(op: Token.Punctuator, right: Expression)
    
    var description: String {
        switch self {
        case let .assign(name, right):
            return "(\(name) = \(right))"
        
        case let .call(function, args):
            return "\(function)(\(args.map({ $0.description }).joined(separator: ", ")))"
            
        case let .conditional(condition, thenArm, elseArm):
            return "(\(condition) ? \(thenArm) : \(elseArm))"
            
        case let .name(name):
            return name
            
        case let .op(left, op, right):
            return "(\(left) \(op.rawValue) \(right))"
            
        case let .postfix(left, op):
            return "(\(left)\(op.rawValue))"
            
        case let .prefix(op, right):
            return "(\(op.rawValue)\(right))"
        }
    }
}

var l = Lexer("b + a")
print(l.next())
print(l.next())
print(l.next())
