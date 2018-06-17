//
//  Calculator.swift
//  iRogue
//
//  Created by Michael McGhan on 9/2/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import Foundation

// calculate a String, Numeric (Int), or Boolean result
// using a sequence of instructions and object attributes
public class OriginalCalculator {
    private let attributes: AttributesCollection
    private let breakOnMissing: Bool
    
    private var stack: [ Any? ] = []
    
    public init(using attributes: AttributesCollection, breakOnMissing: Bool) {
        self.attributes = attributes
        self.breakOnMissing = breakOnMissing
    }
    
    public func calculateString(from tokens: [String]) throws -> String? {
        stack.removeAll()       // clean up previous use, if any
        try self.process(tokens)
        
        return stack.compactMap({String(describing: $0)}).joined(separator: " ");
    }
    
    private func process(_ tokens: [String]) throws {
        for token in tokens {
            if (token.hasPrefix("#")) {
                // number literal: push to stack
                try pushLiteral(for: token)
            }
            else if (token.hasPrefix(":")) {
                // attribute: push to stack
                let result = pushAttribute(for: token, using: attributes)
                if (breakOnMissing && !result) {
                    stack.removeAll()
                }
            }
            else {
                // command
                switch token {
                case "*asPlural":
                    // change top stack element to a plural string
                    try push(asPlural(for: pop(), name: pop()))
                    break
                case "*attributed":
                    // generate and push the attributed name onto the stack
                    try push(attributed(name: pop(), attributes: attributes))
                    break
                case "*diff":
                    // calculate the difference of the top two stack items and push it back
                    try push(difference(first: pop(), second: pop()))
                    break
                case "*format":
                    // format a string using the top stack element's value and format-string
                    try push(format(value: pop(), format: pop()))
                    break
                case "*if":
                    // test the top element of the stack...
                    if (!(try pop() as Bool)) {
                        try _ = pop() as Any        // false: discard the top item
                    }
                    break
                case "*ifEqual":
                    // compare top two (numeric, boolean or string) stack elements, pushing back result
                    try push(ifEqual(top: pop(), next: pop()))
                    break
                case "*ifGreater":
                    // compare top two numeric stack elements, pushing back result
                    try push(ifGreater(top: pop(), next: pop()))
                    break
                case "*nicknamed":
                    // NB: nicknames are optional elements (nilable)
                    if let name = nicknamed(nickname: popString(), name: popString()) {
                        push(name)
                    }
                    break
                case "*nil":
                    push(nil)
                    break
                case "*not":
                    try push(not(pop()))
                    break
                case "*signed":
                    try push(signed(pop()))
                    break
                case "*sum":
                    // calculate the sum of the top two stack items and push it back
                    try push(sum(first: pop(), second: pop()))
                    break
                case "*withArticle":
                    // prefix top stack element with an article or number
                    try push(withArticle(for: pop(), name: pop()))
                    break
                case "*withOf":
                    // prefix top stack element with "of "
                    try push(withOf(pop()))
                    break
                default:
                    // string literal: push to stack
                    push(token)
                }
            }
        }
    }
    
    //MARK: stack management
    
    // remove and return the top element of the stack
    // if the stack is empty, this will throw an exception
    private func pop<T>() throws -> T {
        let top = stack.popLast()
        guard let value = top as? T else {
            throw DataLoadError.invalidType(expected: String(describing: T.self),
                                            received: String(describing: top))
        }
        return value
    }
    
    // return a possibly null string
    private func popString() -> String? {
        return stack.popLast() as? String
    }
    
    // return a possibly null number
    private func popInt() -> Int? {
        return stack.popLast() as? Int
    }
    
    private func push(_ value: Any?) {
        stack.append(value)
    }
    
    private func pushLiteral(for token: String) throws {
        var strval = token
        strval.remove(at: strval.startIndex)
        
        guard let intval = Int(token) else {
            throw DataLoadError.invalidNumberLiteral(value: token)
        }
        push(intval)
    }
    
    private func pushAttribute(for token: String, using attributes: AttributesCollection) -> Bool {
        var key = token
        key.remove(at: key.startIndex)
        
        let attval = attributes.get(key)
        push(attval)           // missing attributes are marked as null values
        
        return (nil != attval)
    }
    
    //MARK: String processors
    
    private func asPlural(for count: Int, name: String) -> String {
        if (1 == count) {
            return name
        }
        else {
            return "\(name)s"
        }
    }
    
    private func attributed(name: String, attributes: AttributesCollection) throws -> String {
        guard let tokenString = attributes.get("attribution") as! String? else {
            throw DataLoadError.missingAttributeKey(key: "attribution")
        }
        let tokens = tokenString.components(separatedBy: ",")
        
        var updated = AttributesCollection(from: attributes)
        updated.add(key: "name", value: name)
        
        let calc = OriginalCalculator(using: updated, breakOnMissing: true)
        
        // attribution may fail (e.g. for rings that don't protect)
        if let attributedName = try calc.calculateString(from: tokens) {
            return attributedName
        }
        return name
    }
    
    private func format(value: CVarArg, format: String) -> String {
        return String(format: format, value)
    }
    
    private func nicknamed(nickname: String?, name: String?) -> String? {
        if (nil != nickname) {
            return " called \(nickname!)"
        }
        return name
    }
    
    private func signed(_ value: Int) -> String {
        return String(format: "%@\(value)", (0 > value) ? "" : "+")
    }
    
    private func withArticle(for count: Int, name: String) -> String {
        if (1 == count) {
            let prefix = String(name.lowercased().prefix(1))
            let vowels: Set<String> = ["a", "e", "i", "o", "u"]
            if (vowels.contains(prefix)) {
                return "an \(name) "
            }
            return "a \(name) "
        }
        else {
            return "\(count) \(name)"
        }
    }
    
    private func withOf(_ value: String) -> String {
        return "of \(value)"
    }
    
    //MARK: Boolean proessors
    
    private func ifEqual(top: Any, next: Any) throws -> Bool {
        if let second = top as? Int {
            guard let first = top as? Int else {
                throw DataLoadError.invalidComparison(value1: String(describing: top), value2: String(describing: next), expected: "Int")
            }
            return (second == first)
        }
        else if let second = top as? Bool {
            guard let first = top as? Bool else {
                throw DataLoadError.invalidComparison(value1: String(describing: top), value2: String(describing: next), expected: "Bool")
            }
            return (second == first)
        }
        let second = String(describing: top)
        let first = String(describing: next)
        return (second == first)
    }
    
    private func ifGreater(top: Int, next: Int) -> Bool {
        return (top > next)
    }
    
    private func not(_ value: Bool) throws -> Bool {
        return !value
    }
    
    //MARK: Number processors
    
    private func difference(first: Int, second: Int) -> Int {
        return (first - second)
    }
    
    private func sum(first: Int, second: Int) -> Int {
        return (first + second)
    }
}

// "#10"
// "("
// "(being worn)"
// "(on %@ hand)"
// "(weapon in hand)"
// ")"
// ","
// ":aclass"
// ":alias"
// ":bclass"
// ":charges"
// ":count"
// ":count@1"
// ":dplus"
// ":hplus"
// ":name"
// ":nickname"
// ":side"
// ":typevariant"
// "Some"
// "["
// "]"
// "*asPlural"
// "*attributed"
// "*diff"
// "*format"
// "*if"
// "*ifEqual"
// "*ifGreater"
// "*nicknamed"
// "*not"
// "*signed"
// "*withArticle"
// "*withOf"

// knownFormats:
//   potion: (label: [ ":typevariant", ":count", "*withArticle", ":count", "*asPlural",
//             ":name", "*withOf", ":nickname", "*nicknamed", "(", ":alias", ")" ],
//            nil),
//   stick:  (label: [ ":typevariant", ":count", "*withArticle", ":count", "*asPlural",
//             ":name", "*withOf", ":nickname", "*nicknamed", "(", ":alias", ")",
//             "*attributed" ],
//            attribution: [ "[", ":charges", "charges" ":terse", "*not", "*if", "]" ]),
//   ring:   (label: [ ":typevariant", ":count", "*withArticle", "*asPlural",
//             ":name", "*withOf", ":nickname", "*nicknamed", "*attributed",
//             "(", ":alias", ")", "(on %@ hand)", ":side", "*format", ":used", "*if" ]
//            attribution: [ "[", ":aclass", "*signed", "]" ]),
//   scroll: (label: [ ":typevariant", ":count", "*withArticle", "*asPlural",
//             ":name", "*withOf", ":nickname", "*nicknamed" ],
//            nil),
//   food:   (label: [ "Some", ":count", "#1", "*ifEqual", "*if",
//             "%d rations of", ":count", "*format", ":count", "#1", "*ifGreater",
//             "*not", "*if", ":name" ],
//            nil),
//   weapon: (label: [ ":name", "*attributed", ":count", "*withArticle", "*asPlural",
//             "*nil", ":nickname", "*nicknamed",
//             "(weapon in hand)", ":used", "*if" ],
//            attribution: [ ":hplus", "*signed", ",", ":dplus", "*signed", ":name" ]),
//   armor:  (label: [ ":name", "*attributed", ":count", "*withArticle", "*asPlural",
//             "*nil", ":nickname", "*nicknamed",
//             "(being worn)", ":used", "*if" ],
//            attribution: [ ":aclass", ":bclass", "*diff", "*signed", ":name", "[",
//             "protection", ":terse", "*not", "*if", "#10", ":aclass", "*diff", "]")
   
