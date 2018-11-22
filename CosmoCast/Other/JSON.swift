//
//  JSON.swift
//  CosmoCast
//
//  Created by Shihab Mehboob on 07/08/2018.
//  Copyright © 2018 Shihab Mehboob. All rights reserved.
//

import Foundation

public enum JSON : Equatable, CustomStringConvertible {
    
    case string(String)
    case number(Double)
    case object(Dictionary<String, JSON>)
    case array(Array<JSON>)
    case bool(Bool)
    case null
    case invalid
    
    public init(_ rawValue: Any) {
        switch rawValue {
        case let json as JSON:
            self = json
            
        case let array as [JSON]:
            self = .array(array)
            
        case let dict as [String: JSON]:
            self = .object(dict)
            
        case let data as Data:
            do {
                let object = try JSONSerialization.jsonObject(with: data, options: [])
                self = JSON(object)
            } catch {
                self = .invalid
            }
            
        case let array as [Any]:
            let newArray = array.map { JSON($0) }
            self = .array(newArray)
            
        case let dict as [String: Any]:
            var newDict = [String: JSON]()
            for (key, value) in dict {
                newDict[key] = JSON(value)
            }
            self = .object(newDict)
            
        case let string as String:
            self = .string(string)
            
        case let number as NSNumber:
            self = number.isBoolean ? .bool(number.boolValue) : .number(number.doubleValue)
            
        case _ as Optional<Any>:
            self = .null
            
        default:
            assert(true, "This location should never be reached")
            self = .invalid
        }
        
    }
    
    public var string : String? {
        guard case .string(let value) = self else {
            return nil
        }
        return value
    }
    
    public var integer : Int? {
        guard case .number(let value) = self else {
            return nil
        }
        return Int(value)
    }
    
    public var double : Double? {
        guard case .number(let value) = self else {
            return nil
        }
        return value
    }
    
    public var object : [String: JSON]? {
        guard case .object(let value) = self else {
            return nil
        }
        return value
    }
    
    public var array : [JSON]? {
        guard case .array(let value) = self else {
            return nil
        }
        return value
    }
    
    public var bool : Bool? {
        guard case .bool(let value) = self else {
            return nil
        }
        return value
    }
    
    public subscript(key: String) -> JSON {
        guard case .object(let dict) = self, let value = dict[key] else {
            return .invalid
        }
        return value
    }
    
    public subscript(index: Int) -> JSON {
        guard case .array(let array) = self, array.count > index else {
            return .invalid
        }
        return array[index]
    }
    
    public static func parse(jsonData: Data) throws -> JSON {
        do {
            let object = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
            return JSON(object)
        } catch {
            return nil
        }
    }
    
    public static func parse(string : String) throws -> JSON {
        do {
            guard let data = string.data(using: .utf8, allowLossyConversion: false) else {
                return nil
            }
            return try parse(jsonData: data)
        } catch {
            return nil
        }
    }
    
    public func stringify(_ indent: String = "  ") -> String? {
        guard self != .invalid else {
            assert(true, "The JSON value is invalid")
            return nil
        }
        return prettyPrint(indent, 0)
    }
    
    public var description: String {
        guard let string = stringify() else {
            return "<INVALID JSON>"
        }
        return string
    }
    
    private func prettyPrint(_ indent: String, _ level: Int) -> String {
        let currentIndent = (0...level).map({ _ in "" }).joined(separator: indent)
        let nextIndent = currentIndent + "  "
        
        switch self {
        case .bool(let bool):
            return bool ? "true" : "false"
            
        case .number(let number):
            return "\(number)"
            
        case .string(let string):
            return "\"\(string.replacingOccurrences(of: "\"", with: "\\\"").replacingOccurrences(of: "\r", with: "").replacingOccurrences(of: "\n", with: "\\n"))\""
            
        case .array(let array):
            return "[\n" + array.map { "\(nextIndent)\($0.prettyPrint(indent, level + 1))" }.joined(separator: ",\n") + "\n\(currentIndent)]"
            
        case .object(let dict):
            return "{\n" + dict.map { "\(nextIndent)\"\($0)\" : \($1.prettyPrint(indent, level + 1))"}.joined(separator: ",\n") + "\n\(currentIndent)}"
            
        case .null:
            return "null"
            
        case .invalid:
            assert(true, "This should never be reached")
            return ""
        }
    }
    
}

public func ==(lhs: JSON, rhs: JSON) -> Bool {
    switch (lhs, rhs) {
    case (.null, .null):
        return true
        
    case (.bool(let lhsValue), .bool(let rhsValue)):
        return lhsValue == rhsValue
        
    case (.string(let lhsValue), .string(let rhsValue)):
        return lhsValue == rhsValue
        
    case (.number(let lhsValue), .number(let rhsValue)):
        return lhsValue == rhsValue
        
    case (.array(let lhsValue), .array(let rhsValue)):
        return lhsValue == rhsValue
        
    case (.object(let lhsValue), .object(let rhsValue)):
        return lhsValue == rhsValue
        
    default:
        return false
    }
}



extension JSON: ExpressibleByStringLiteral,
    ExpressibleByIntegerLiteral,
    ExpressibleByBooleanLiteral,
    ExpressibleByFloatLiteral,
    ExpressibleByArrayLiteral,
    ExpressibleByDictionaryLiteral,
ExpressibleByNilLiteral {
    
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(value)
    }
    
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(value)
    }
    
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
    
    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(value)
    }
    
    public init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }
    
    public init(dictionaryLiteral elements: (String, Any)...) {
        let object = elements.reduce([String: Any]()) { $0 + [$1.0: $1.1] }
        self.init(object)
    }
    
    public init(arrayLiteral elements: AnyObject...) {
        self.init(elements)
    }
    
    public init(nilLiteral: ()) {
        self.init(NSNull())
    }
    
}

private func +(lhs: [String: Any], rhs: [String: Any]) -> [String: Any] {
    var lhs = lhs
    for element in rhs {
        lhs[element.key] = element.value
    }
    return lhs
}

private extension NSNumber {
    
    var isBoolean: Bool {
        return NSNumber(value: true).objCType == self.objCType
    }
}
