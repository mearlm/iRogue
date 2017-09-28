//
//  Thing.swift
//  iRogue
//
//  Created by Michael McGhan on 9/1/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import Foundation

enum DataLoadError: Error {
    case invalidAliasVariant(variant: String?, expected: String?)
    case insufficientAliases(variant: String?)
    case unknownAliasVariant(variant: String?)
    
    case noSuchVariant(thing: String, variant: String?)
    case expectedAlias(thing: String)
    
    case invalidNumberLiteral(value: String)
    case missingAttributeKey(key: String)
    case invalidComparison(value1: String, value2: String, expected: String)
    case invalidType(expected: String, received: String)
}

public struct Attribute<T> {
    public var value: T?
    public let name: String
    
    public init(name: String, value: T?) {
        self.name = name
        self.value = value
    }
}

public struct AttributesCollection {
    private var attributes: [String : Attribute<Any>] = [:]
    
    public init() {
    }
    
    public init(from collection: AttributesCollection) {
        self.attributes = collection.attributes     // copy on write
    }
    
    private mutating func add(attribute: Attribute<Any>) {
        self.attributes.updateValue(attribute, forKey: attribute.name)
    }
    
    public mutating func add(key: String, value: Any?) {
        if (nil == value) {
            self.remove(key)
        }
        else {
            let attribute = Attribute(name: key, value: value)
            self.add(attribute: attribute)
        }
    }
    
    public mutating func remove(_ key: String) {
        if let index = attributes.index(forKey: key) {
            self.attributes.remove(at: index)
        }
    }
    
    public func get(_ key: String) -> Any? {
        return attributes[key]?.value
    }
}

public struct AliasesCollection {
    public var aliases: [(names: [String], variant: String?)] = []
    
    public mutating func add(alias: String, variant: String? = nil) throws {
        let index = try findIndex(for: variant)
        if (0 <= index) {
            self.aliases[index].names.append(alias)
        }
        else {
            self.aliases.append(([alias], variant))
        }
    }
    
    private func findIndex(for variant: String?) throws -> Int {
        switch self.aliases.count {
        case 0:
            return -1;  // append new
        case 1:
            return (try isIndex(0, for: variant)) ? 0 : -1
        default:
            for index in 0..<aliases.count {
                if (try isIndex(index, for: variant)) {
                    return index
                }
            }
            return -1
        }
    }
    
    private func isIndex(_ index: Int, for variant: String?) throws -> Bool {
        if let v = self.aliases[index].variant {
            guard (nil != variant) else {
                throw DataLoadError.invalidAliasVariant(variant: variant, expected: v)
            }
            return (v == variant!)
        }
        
        guard (nil == variant) else {
            throw DataLoadError.invalidAliasVariant(variant: variant, expected: nil)
        }
        return true
    }
    
    public mutating func get(for variant: String?) throws -> String {
        let index = try findIndex(for: variant)
        guard (0 <= index) else {
            throw DataLoadError.unknownAliasVariant(variant: variant)
        }
        
        let names = self.aliases[index].names
            
        if let next = SampleData.randomItem(names) {
            // no re-use: delete from available choices
            // [ToDo: another option would be to use a dictionary of names,
            // and smudge them out as they are used]
            self.aliases[index].names = names.filter( { $0 != next } )
            return next
        }
        throw DataLoadError.insufficientAliases(variant: variant)
    }
}

public class ThingType {
    public let name: String
    public let group: String
    public let percentage: Int          // probability to create (within group)
    
    public var aliases: AliasesCollection?
    private let knownFormat: String     // label identified objects
    private let otherFormat: String?    // otherwise
    
    public init(name: String, group: String, percentage: Int, knownFormat: String, otherFormat: String? = nil) {
        self.name = name
        self.group = group
        self.percentage = percentage
        
        // label string patterns
        self.knownFormat = knownFormat
        self.otherFormat = otherFormat
    }
    
    // knownFormats:
    //   potion: (label: [ "typevariant", "withArticle", "asPlural",
    //             "name", "withOf", "nickname", "nicknamed", "(", "alias", ")" ]
    //   stick:  (label: [ "typevariant", "withArticle", "asPlural",
    //             "name", "withOf", "nickname", "nicknamed", "(", "alias", ")" ],
    //            attribution: [ "[", ":charges", "charges" "ifTerse", "not", "if", "]" ]),
    //   ring:   (label: [ "typevariant", "withArticle", "asPlural",
    //             "name", "withOf", "nickname", "nicknamed", "attributed",
    //             "(", "alias", ")", "(on %@ hand)", ":side", "format" ]
    //            attribution: [ "[", "aclass", "signed", "]" ]),
    //   scroll: (label: [ "typevariant", "withArticle", "asPlural",
    //           "name", "withOf", "nickname", "nicknamed" ], nil),
    //   food:   (label: [ "Some", "rations of", "ifCount", "name" ], nil),
    //   weapon: (label: [ ":name", "attributed", "withArticle", "asPlural",
    //             "nil", "nickname", "nicknamed", "(weapon in hand)", "ifUsed" ],
    //            attribution: [ ":hplus", "signed", ",", ":dplus", "signed", "name" ]),
    //   armor:  (label: [ ":name", "attributed", "withArticle", "asPlural",
    //             "nil", ":nickname", "nicknamed", "(being worn)", "ifUsed" ],
    //            attribution: [ ":aclass", ":bclass", "diff", "signed", "name", "[",
    //             "protection", "isTerse", "not", "if", "#10", ":aclass", "diff", "]")
    
    // otherFormats:
    //   potion, ring, stick: withArticle(thing.alias, count)
    //           + asPlural(thing.typevariant, count)
    //   scroll: asPlural(withArticle(thing.typevariant, count), count)
    //           + titled \(thing.alias)
    //   fruit: asPlural(withArticle(thing.alias, count), count)
    //   weapon: asPlural(withArticle(thing.name, count), count)
    //           + isUsed("weapon in hand", thing)
    //           + nicknamed(nil, thing.nickname)
    //   armor: \(thing.name)
    //           + isUsed("being worn", thing)
    //           + nicknamed(nil, thing.nickname)
    
    public func addAlias(name: String, variant: String?) throws {
        if (nil == aliases) {
            self.aliases = AliasesCollection()
        }
        try self.aliases!.add(alias: name, variant: variant)
    }
    
    public func getLabel(for thing: Thing, count: Int) -> String {
//        let typename = thing.prototype.variant ?? self.name
//        let isKnown = thing.prototype.isKnown
//        
//        if (count > 1) {
//            if (isKnown) {
//                String(format: "%d " + aliasFormat, count, )
//                return String(
//                // e.g. 2 diamond rings
//                return String(count) + " " + item.getName() + " " + asPlural(typename)
//            }
//            else {
//                // 2 slime-molds
//                return String(count) + " " + asPlural(item.getName())
//            }
//        }
//        else {
//            if (hasAlias) {
//                    // a scroll of xyzzy
//                    return withArticle(typename) + " " + item.getName()
//                }
//                else {
//                    // an oak staff
//                    return withArticle(item.getDisplayName()) + " " + typename
//                }
//            }
//            else {
//                // plate mail or a two handed sword
//                return withArticle(item.getDisplayName())
//            }
//        }
        return "UNDEFINED"
    }
}

public class ThingPrototype {
    public let type: ThingType
    public let name: String
    public let symbol: String       // a display character
    
    public let percentage: Int      // probability to create (within type)
    
    public let attributes = AttributesCollection()
    public let actions: [String : String] = [:]
    
    public let variant: String?
    public let alias: String?
    public var isKnown: Bool
    
    public init(type: ThingType, name: String, symbol: String, percentage: Int, variant: String? = nil) throws {
        self.type = type
        self.name = name
        self.symbol = symbol
        self.percentage = percentage
        self.variant = variant
        
        // N.B. if there is no alias, a thing is always "known"
        self.alias = try self.type.aliases?.get(for: variant)
        self.isKnown = (nil == self.alias)
    }
    
    fileprivate func know() {
        self.isKnown = true
    }
    
    // create individual instances of this Thing
    public func create() -> Thing {
        let result = Thing(prototype: self)
        result.when(event: "onCreate")
        
        return result
    }
}

public class Thing {
    public let prototype: ThingPrototype
    public var attributes: AttributesCollection
    
    public private(set) var identified = false
    public private(set) var nickname: String?
    
    public init(prototype: ThingPrototype) {
        self.prototype = prototype
        self.attributes = prototype.attributes
    }
    
    // ToDo: should this return a Bool?
    public func when(event: String) {
//        if let action = self.prototype.actions[event] {
//            // ToDo: perform a sequence of actions in response to an event
//        }
    }
    
    public func typeName() -> String {
        return (self.prototype.variant ?? self.prototype.type.name)
    }
    
    public func call(name: String) {
        self.nickname = name
    }
    
    public func identify() {
        self.identified = true
        self.know()
    }
    
    public func know() {
        self.prototype.know()
        self.reveal()
    }
    
    public func reveal() {
        self.attributes.remove("disguise")
    }
    
    public func disguise(symbol: String) {
        self.attributes.add(key: "disguise", value: symbol)
    }
    
    // ToDo: modify name to indicate state of worn or wielded items
    private func getName() -> String {
        var name = ""
        
        if (self.identified) {
            name = self.attributedName()
        }
        else if (self.prototype.isKnown) {
            name = self.prototype.name      // always known if alias is nil
        }
        else if (nil == self.nickname) {
            name = (self.prototype.alias ?? "unknown!")
        }
        
        if (nil != self.nickname) {
            name += "called " + self.nickname!
        }
        return name
    }
    
    public func alias() -> String  {
        return (self.prototype.alias ?? "unknown!")
    }

    public func name() -> String {
        return self.prototype.name
    }
    
    public func attributedName() -> String {
        // ToDo:
        return self.prototype.name
    }
}
