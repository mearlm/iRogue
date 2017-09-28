//
//  SampleData.swift
//  iRogue
//
//  Created by Michael McGhan on 8/12/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import UIKit

class SampleData : InventoryService {
    static let FOOD     = InventoryItemType(name: "food", tag: ":",
                                            actions: ["eat" : nil, "throw" : nil, "wield" : "unwield"]
    )
    static let ARMOR    = InventoryItemType(name: "armor", tag: "]",
                                   actions: ["wear" : "remove"]
    )
    static let WEAPON   = InventoryItemType(name: "weapons", tag: ")",
                                   actions: ["weild" : "unwield", "throw" : nil]
    )
    static let POTION   = InventoryItemType(name: "potions", tag: "!",
                                   actions: ["quaff" : nil, "throw" : nil, "wield" : "unwield"]
    )
    static let SCROLL   = InventoryItemType(name: "scrolls", tag: "?",
                                   actions: ["read" : nil, "throw" : nil, "wield" : "unwield"]
    )
    static let STICK    = InventoryItemType(name: "staffs and wands", tag: "/",
                                   actions: ["zap" : nil, "throw" : nil, "wield" : "unwield"]
    )
    static let RING     = InventoryItemType(name: "rings", tag: "=",
                                   actions: ["put on" : "take off", "throw" : nil, "wield" : "unwield"]
    )
    static let AMULET   = InventoryItemType(name: "aumlets", tag: ",",
                                   actions: ["throw" : nil, "wield" : "unwield"]
    )
    static let ITEM_NAMES: [InventoryItemType: [(name: String, pattern: String)?]] = [
//        SampleData.FOOD : [("food", "some %@"),
//                               ("food", "2 rations of %@"),
//                               ("slime mold", "a %@"),
//                               ("slime mold", "3 %@s")
//        ],
        SampleData.ARMOR : [("ring mail", "+1 %@ [protection: 4]"),
                                ("chain mail", "%@"),
                                ("splint mail", "+0 %@ [protection: 6]"),
                                ("leather armor", "%@"),
                                ("studded leather armor", "%@"),
                                ("plate mail", "%@"),
                                ("plate mail", "+3 %@ [protection: 10]")
        ],
        SampleData.WEAPON : [("mace", "A +1,+1 %@"),
                                 ("arrow", "13 %@s"),
                                 ("two handed sword", "A %@"),
                                 ("mace", "A %@"),
                                 ("long sword", "A %@"),
                                 ("dagger", "A %@"),
                                 ("dart", "10 %@s")
        ],
        SampleData.POTION : [nil,
                                 ("confusion", "A potion of %@"),
                                 ("monster detection", "A potions called %@"),
                                 ("healing", "2 potions of %@")
        ],
        SampleData.SCROLL : [nil,
                                 ("scare monster", "A scroll of %@"),
                                 ("enchant weapon", "A scroll of %@"),
                                 ("identify ring, wand or staff", "3 scrolls of %@"),
                                 ("teleportation", "A scroll called %@"),
                                 ("protection", "A scroll called %@")
        ],
        SampleData.RING : [nil,
                               ("see invisible", "A ring of %@"),
                               ("some random ring", "A ring called %@"),
                               ("adornment", "A ring of %@"),
                               ("add damage", "A ring of %@ [-1]")
        ],
        SampleData.STICK : [nil,
                                ("oak staff", "An %@"),
                                ("striking", "A wand of %@ [3 charges]"),
                                ("cold", "A staff of %@ [1 charges]")
        ]
    ]
    static var ALIASES: [InventoryItemType : [(aliases: [String], variant: String)]] = [
        SampleData.POTION: [(["green", "aquamarine", "red", "black", "white", "brown", "blue"], "potion")],
        SampleData.SCROLL: [(["xy zzy rah", "foo baar oof", "fas jfe laja", "ziv zav zue", "vou pej zav jfie", "fie fei foe"], "scroll")],
        SampleData.STICK:  [(["gold", "bronze", "iron"], "wand"),
                            (["oak", "teak", "walnut"], "staff")],
        SampleData.RING: [(["onyx", "diamond", "amethyst", "opal", "ruby", "sapphire"], "ring")]
    ]

    private let inventoryTypes: [InventoryItemType] = [
        SampleData.FOOD,
        SampleData.ARMOR,
        SampleData.WEAPON,
        SampleData.POTION,
        SampleData.SCROLL,
        SampleData.RING,
        SampleData.STICK,
        SampleData.AMULET
    ]
    private var inventoryData: [InventoryItem] = [];
    
    private weak var controller : InventoryController?
    
    public init() {
        let selected = (SampleData.random(100) < 20)
            ? SampleData.randomItem(["a slime mold", "3 slime molds"])!
            : SampleData.randomItem(["some food", "2 rations of food", "some food"])!
        
        addItem(type: SampleData.FOOD, name: "food", label: selected)

        for type in SampleData.ITEM_NAMES.keys {
            let items = SampleData.ITEM_NAMES[type]!
            if let required = items[0] {
                addItem(type: type, name: required.name,
                        label: String(format: required.pattern, required.name)
                )
            }
        }
        
        addItem(type: SampleData.WEAPON, name: "short bow", label: "A +1,+0 short bow")
        
        let arrows = String(format: "%d +0,+0 arrows", SampleData.random(15) + 25)
        addItem(type: SampleData.WEAPON, name: "arrow", label: arrows)
        
        for type in SampleData.ITEM_NAMES.keys {
            var items = SampleData.ITEM_NAMES[type]!
            items.remove(at: 0)

            getSampleItemsForSegment(of: type, probability: SampleData.random(15) + 20, items: items as! [(name: String, pattern: String)])
        }
    }

    //MARK: InventoryService
    public func getPackItems() -> [InventoryItem] {
        return inventoryData
    }
    
    // ordered!
    public func getItemTypes() -> [InventoryItemType] {
        return inventoryTypes
    }
    
    public func registerController(controller: InventoryController) {
        self.controller = controller
    }
    
    //MARK: private implementation
    private func getAliasForType(_ type: InventoryItemType) -> (alias: String, variant: String)? {
        if let variants = SampleData.ALIASES[type] {
            let index = SampleData.random(variants.count)
            let variant = variants[index]
            
            if let next = SampleData.randomItem(variant.aliases) {
                SampleData.ALIASES[type]![index].aliases = variant.aliases.filter( { $0 != next } )
                return (next, variant.variant)
            }
            return ("fAkEnAmE", variant.variant)        // need more aliases!
        }
        return nil
    }
    
    private func nextID() -> String {
        let choices = Array(UnicodeScalar("a").value...UnicodeScalar("z").value)
        return String(UnicodeScalar(choices[self.inventoryData.count])!);
    }
    
    private func addItem(type: InventoryItemType, name: String, label: String) {
        let item = InventoryItem(id: nextID(), name: name, label: label, type: type);
        self.inventoryData.append(item)
        
        controller?.add(id: item.id, item: item)
    }

    private func getSampleItemsForSegment(of type: InventoryItemType, probability: Int, items: [(name: String, pattern: String)]) {
        var remainder = probability
        while (remainder > 0) {
            if (remainder > SampleData.random(100)) {
                var selected : (name: String, pattern: String)
                
                if let alias = getAliasForType(type),
                    (80 > SampleData.random(100)),
                    let count = SampleData.randomFromDistribution([1,2,3], probabilities: [80,15,5]) {
                    
                    let prefix = ((count == 1) ? getArticle(for: alias.alias) : "\(count)") + " "
                    
                    let pattern = (type.name == SampleData.SCROLL.name)
                        ? prefix + asPlural(of: alias.variant, count: count) + " titled '%@'"
                        : prefix + "%@ " + asPlural(of: alias.variant, count: count)
                    
                    selected = (alias.alias, pattern)
                }
                else {
                    selected = SampleData.randomItem(items)!
                }
                
                addItem(type: type, name: selected.name,
                        label: String(format: selected.pattern, selected.name)
                )
            }
            remainder -= 10
        }
    }
    
    private static let vowelCharacters : [Character] = ["a","e","i","o","u"]
    
    private func getArticle(for name: String) -> String {
        if let startsWith = name.lowercased().characters.first {
            if (SampleData.vowelCharacters.contains(startsWith)) {
                return "An"
            }
        }
        return "A"
    }
    
    private func asPlural(of name: String, count: Int) -> String {
        return (count > 1) ? name + "s" : name
    }
    
    // ToDo: move to common class (Game?)
    public static func randomFromDistribution<T>(_ items: [T], probabilities: [Int]) -> T? {
        guard (!items.isEmpty) else {
            return nil
        }

        let value = SampleData.random(100)  // equal probability
        var total = probabilities[0]
        var ix = 0
        
        while (value >= total && ix < items.count) {
            ix += 1
            total += probabilities[ix]
        }
        return items[ix]
    }

    public static func randomItem<T>(_ items: [T]) -> T? {
        guard (!items.isEmpty) else {
            return nil;
        }
        
        return items[SampleData.random(items.count)]
    }
    
    // return a value from 0 to limit-1
    public static func random(_ limit: Int) -> Int {
        // encapsulate the foolishness...
        return Int(arc4random_uniform(UInt32(limit)))
    }
}

