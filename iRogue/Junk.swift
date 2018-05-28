//
//  Junk.swift
//  iRogue
//
//  Created by Michael McGhan on 8/20/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import Foundation
import UIKit

public class Testing {
        
    public static func testFonts(_ cellFont: UIFont) {
        for ix in 10...20 {
            let size = CGFloat(ix)
            
            let font = cellFont.withSize(size)
            
            testFont(font: UIFont.systemFont(ofSize: size))
            testFont(font: UIFont.boldSystemFont(ofSize: size))
            testFont(font: font)
            testFont(font: font.fontWithBold())
            testFont(font: font.fontWithMonospacedNumbers())
        }
        print("end font test")
    }
    
    // UIFont.systemFontOfSize(14.0)
    private static func testFont(font: UIFont) {
        print("font: \(font.fontName); size: \(font.pointSize); height: \(font.lineHeight); leading: \(font.leading)\n\(font.debugDescription)")
        
        let str = "The quick red fox jumped over the lazy dog."
        let str2 = "THE QUICK RED FOX JUMPED OVER THE LAZY DOG."
        
        var size: CGSize = str.size(withAttributes: [NSAttributedStringKey.font: font])
        print("\(str): size: \(size); avg: \(size.width / CGFloat(str.count))")
        
        size = str2.size(withAttributes: [NSAttributedStringKey.font: font])
        print("\(str2): size: \(size); avg: \(size.width / CGFloat(str2.count))")
        
        var min: CGFloat = 0.0
        var minCharacter: String?
        var max: CGFloat = 0.0
        var maxCharacter: String?
        var avg: CGFloat = 0.0
        var count: Int = 0
        
        for ix in 32..<127 {
            let s = String(UnicodeScalar(UInt8(ix)))
            let sz: CGSize = s.size(withAttributes: [NSAttributedStringKey.font: font])
            if (min == 0.0 || min > sz.width) {
                min = sz.width
                minCharacter = s
            }
            if (max < sz.width) {
                max = sz.width
                maxCharacter = s
            }
            avg += sz.width
            count += 1
        }
        avg = avg / CGFloat(count)
        
        print("minSize: \(min) [\(minCharacter!)]\nmaxSize: \(max) [\(maxCharacter!)]\navgSize: \(avg))")
    }
    
    // FOR INVENTORY ITEM
    
    // InventoryItem naming
    private let alias: String?              // "unknown" name (immutable)
    private let name: String                // common (short) name (immutable)
    private var fullname: String            // fully attributed name
    private var nickname: String?           // "called-by" name
    private let typeVariant: String?        // type of stick, i.e. wand or staff (immutable)
    
    private var known: Bool                 // affects name
    private var identified: Bool            // affects name
    
    private init(fullname: String, name: String, type: InventoryItemType) {
        self.fullname = fullname
        self.name = name
        self.identified = false
        let av: (alias: String?, varient: String?) = (nil, nil)   // type.getAlias(itemNamed: name)
        self.alias = av.alias
        self.typeVariant = av.varient
        self.known = (nil == alias)
        self.nickname = nil
    }
    
    // ToDo: modify name to indicate state of worn or wielded items
    private func getName() -> String {
        if (self.isIdentified()) {
            return self.fullname
        }
        if (self.isNamed()) {
            return self.nickname!
        }
        if (self.isKnown()) {
            return self.name
        }
        return self.alias ?? "unknown!"
    }
    
    private func getFullName() -> String {
        return self.fullname
    }
    
    private func setNickname(name: String) {
        self.nickname = name
    }
    
    private func isNamed() -> Bool {
        return (self.nickname != nil)
    }
    
    private func know() {
        self.known = true
    }
    
    private func isKnown() -> Bool {
        return self.known
    }
    
    private func identify() {
        self.identified = true
    }
    
    private func isIdentified() -> Bool {
        return self.identified
    }
    
    private func isUnknown() -> Bool {
        return !isKnown() && !isNamed() && !isIdentified()
    }

    // FOR INVENTORY ITEM TYPE

    private var aliases: [String: [String]]?
    private var assignedAliases: [String: String] = [:]
    
    private func typeInit(aliases: [([String], varient: String?)]? = nil) {
        if (nil != aliases) {
            self.aliases = [:]
            
            for (names, varient) in aliases! {
                let v = varient ?? self.name
                self.aliases![v] = names
            }
        }
        else {
            self.aliases = nil
        }
    }
    
    public func hasAliases() -> Bool {
        return nil != self.aliases
    }
    
    // names for unknown objects of this type, e.g. colors for potions or syllables for scrolls
    fileprivate func getAlias(itemNamed: String) -> (String?, String?) {
        guard (nil != self.aliases) else {
            return (nil, nil)
        }
        
        let varients = Array(self.aliases!.keys)
        if let alias = self.assignedAliases[itemNamed] {
            for varient in varients {
                let found = self.aliases![varient]!.filter( { $0 == alias } )
                if (!found.isEmpty) {
                    return (alias, (varient == self.name) ? nil : varient)
                }
            }
            return (alias, nil)
        }
        
        if let varient = SampleData.randomItem(varients) {
            if let pool = self.aliases![varient] {
                if let selected = SampleData.randomItem(pool) {
                    self.assignedAliases[itemNamed] = selected
                    self.aliases![varient] = self.aliases![varient]!.filter( { $0 != selected } )
                    
                    return (selected, (varient == self.name) ? nil : varient)
                }
            }
        }
        return ("fAkEnAmE", nil)
    }

    public func getTypeName() -> String {
        return self.name
    }
    
    public let label: String = ""

    // ToDo: this should be a call into a type-specific formatter within the game
//    public func getLabel(for item: InventoryItem) -> String {
//        let typename = item.getTypeVariant() ?? self.getTypeName()
//        let count = item.getCount()
//        
//        if (count > 1) {
//            if (self.hasAliases()) {
//                if (!isUnknown()) {
//                    // e.g. 3 potions of healing
//                    return String(count) + " " + asPlural(typename) + " " + item.getDisplayName()
//                }
//                else {
//                    // e.g. 2 diamond rings
//                    return String(count) + " " + item.getDisplayName() + " " + asPlural(typename)
//                }
//            }
//            else {
//                // 2 slime-molds
//                return String(count) + " " + asPlural(item.getDisplayName())
//            }
//        }
//        else {
//            if (self.hasAliases()) {
//                if (!isUnknown()) {
//                    // a scroll of xyzzy
//                    return withArticle(typename) + " " + item.getDisplayName()
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
//    }
    
    // ToDo: String extensions??
    private func withArticle(_ forString: String) -> String {
        let prefix = String(forString.lowercased().prefix(1))
        let vowels: Set<String> = ["a", "e", "i", "o", "u"]
        if (vowels.contains(prefix)) {
            return "an " + forString + " "
        }
        return "a " + forString + " "
    }
    
    private func asPlural(_ forString: String) -> String {
        if (forString == "food") {
            return forString
        }
        return forString + "s"
    }
    
    static let FOOD     = ItemType(name: "food", tag: ":", grouped: true,
                                   actions: ["eat" : nil, "throw" : nil]
    )
    static let ARMOR    = ItemType(name: "armor", tag: "]", grouped: false,
                                   actions: ["wear" : "remove"]
    )
    static let WEAPON   = ItemType(name: "weapon", tag: ")", grouped: false,
                                   actions: ["weild" : "unwield", "throw" : nil]
    )
    static let POTION   = ItemType(name: "potion", tag: "!", grouped: true,
                                   actions: ["quaff" : nil, "throw" : nil]
    )
    static let SCROLL   = ItemType(name: "scroll", tag: "?", grouped: true,
                                   actions: ["read" : nil, "throw" : nil]
    )
    static let STICK    = ItemType(name: "stick", tag: "/", grouped: true,
                                   actions: ["zap" : nil, "wield" : "unwield", "throw" : nil]
    )
    static let RING     = ItemType(name: "ring", tag: "=", grouped: true,
                                   actions: ["wear" : "remove", "throw" : nil]
    )
    static let AMULET   = ItemType(name: "aumlet", tag: ",", grouped: false,
                                   actions: ["throw" : nil]
    )
    
//    static let sampleItemNamesByType: [ItemType : [String]] = [
//        SampleData.FOOD     : ["slime-mold", "food"],
//        SampleData.ARMOR    : ["plate mail", "chain mail", "leather armor", "studded leather armor", "scale mail", "split mail", "banded mail"],
//        SampleData.WEAPON   : ["two handed sword", "long sword", "mace", "spear", "short bow", "dagger", "dart", "weapon"],
//        SampleData.POTION   : ["healing", "blindness", "see invisible", "gain strength"],
//        SampleData.SCROLL   : ["scare monster", "remove curse", "aggravate monsters", "enchant armor"],
//        SampleData.STICK    : ["lightening", "haste monster", "nothing", "slow monster", "striking"],
//        SampleData.RING     : ["protection", "add strength", "see invisible", "adornment"],
//        SampleData.AMULET   : []
//    ]
//    
//    static var sampleAliasesByType: [ItemType : [(aliases: [String], variant: String?)]] = [
//        SampleData.POTION: [(["green", "aquamarine", "red", "black", "white", "brown", "blue"], nil)],
//        SampleData.SCROLL: [(["xyzzy", "foobar", "fasjfelja", "zjvzvdue", "uoupvjzvjfe"], nil)],
//        SampleData.STICK:  [(["gold", "bronze", "iron"], "wand"),
//                            (["oak", "teak", "walnut"], "staff")],
//        SampleData.RING: [(["onyx", "diamond", "amethyst", "opal", "ruby", "sapphire"], nil)]
//    ]
    
}

//MARK: other interesting stuff

//class Dice {
//    let sides: Int
//    let generator: RandomNumberGenerator
//    init(sides: Int, generator: RandomNumberGenerator) {
//        self.sides = sides
//        self.generator = generator
//    }
//    func roll() -> Int {
//        return Int(generator.random() * Double(sides)) + 1
//    }
//}
// var d6 = Dice(sides: 6, generator: LinearCongruentialGenerator())


// source:  https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Generics.html
//
//protocol Container {
//    associatedtype Item
//    mutating func append(_ item: Item)
//    var count: Int { get }
//    subscript(i: Int) -> Item { get }
//}

