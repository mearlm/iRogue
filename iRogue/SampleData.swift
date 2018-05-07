//
//  SampleData.swift
//  iRogue
//
//  Created by Michael McGhan on 8/12/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import UIKit

class SampleData : InventoryDataService, InventoryCommandService, ToolsControllerService {
//    let pattern = (type.name == SampleData.SCROLL.name)
//        ? prefix + asPlural(of: alias.variant, count: count) + " titled '%@'"
//        : prefix + "%@ " + asPlural(of: alias.variant, count: count)
//    

    enum ACTION_NAME: String {
        case WEAR = "wear"
        case REMOVE = "remove"
        case WIELD = "wield"
        case EAT = "eat"
        case THROW = "throw"
        case QUAFF = "quaff"
        case READ = "read"
        case PUT_ON = "put on"
        case TAKE_OFF = "take off"
        case ZAP = "zap"
        case CALL = "call"
        case DROP = "drop"
    }
    
    static let ACTIONS  = [
        ACTION_NAME.WEAR   : InventoryItemAction(action: ACTION_NAME.WEAR.rawValue,
                                          unaction: ACTION_NAME.REMOVE.rawValue,
                                          message: "being worn"
        ),
        ACTION_NAME.WIELD  : InventoryItemAction(action: ACTION_NAME.WIELD.rawValue,
                                          unaction: nil,
                                          message: "weapon in hand"        ),
        ACTION_NAME.EAT    : InventoryItemAction(action: ACTION_NAME.EAT.rawValue),
        ACTION_NAME.THROW  : InventoryItemAction(action: ACTION_NAME.THROW.rawValue),
        ACTION_NAME.QUAFF  : InventoryItemAction(action: ACTION_NAME.QUAFF.rawValue),
        ACTION_NAME.READ   : InventoryItemAction(action: ACTION_NAME.READ.rawValue),
        ACTION_NAME.PUT_ON : InventoryItemAction(action: ACTION_NAME.PUT_ON.rawValue,
                                          unaction: ACTION_NAME.TAKE_OFF.rawValue,
                                          message: "on %@",
                                          qualifiers: ["left hand", "right hand"]
        ),
        ACTION_NAME.ZAP    : InventoryItemAction(action: ACTION_NAME.ZAP.rawValue),
        ACTION_NAME.CALL   : InventoryItemAction(action: ACTION_NAME.CALL.rawValue),
        ACTION_NAME.DROP   : InventoryItemAction(action: ACTION_NAME.DROP.rawValue)
    ]

    private static var defaultActions: [InventoryItemAction] = {
        return [SampleData.ACTIONS[SampleData.ACTION_NAME.CALL]!
        ]
    }()
    
    static let FOOD     = InventoryItemType(name: "food", displayName: "food", tag: ":",
                            actions: [SampleData.ACTIONS[ACTION_NAME.EAT]!,
                                      SampleData.ACTIONS[ACTION_NAME.THROW]!,
                                      SampleData.ACTIONS[ACTION_NAME.WIELD]!
                            ] + defaultActions,
                            isMulti: true
    )
    static let ARMOR    = InventoryItemType(name: "armor", displayName: "armor", tag: "]",
                            actions: [SampleData.ACTIONS[ACTION_NAME.WEAR]!] + defaultActions,
                            isMulti: false,
                            useArticle: false
    )
    static let WEAPON   = InventoryItemType(name: "weapon", displayName: "weapons", tag: ")",
                            actions: [SampleData.ACTIONS[ACTION_NAME.WIELD]!,
                                      SampleData.ACTIONS[ACTION_NAME.THROW]!
                            ] + defaultActions
    )
    static let POTION   = InventoryItemType(name: "potion", displayName: "potions", tag: "!",
                            actions: [SampleData.ACTIONS[ACTION_NAME.QUAFF]!,
                                      SampleData.ACTIONS[ACTION_NAME.THROW]!,
                                      SampleData.ACTIONS[ACTION_NAME.WIELD]!
                            ] + defaultActions,
                            isMulti: true
    )
    static let SCROLL   = InventoryItemType(name: "scroll", displayName: "scrolls", tag: "?",
                             actions: [SampleData.ACTIONS[ACTION_NAME.READ]!,
                                       SampleData.ACTIONS[ACTION_NAME.THROW]!,
                                       SampleData.ACTIONS[ACTION_NAME.WIELD]!
                             ] + defaultActions,
                             isMulti: true
    )
    static let STICK    = InventoryItemType(name: "stick", displayName: "staffs and wands", tag: "/",
                             actions: [SampleData.ACTIONS[ACTION_NAME.ZAP]!,
                                       SampleData.ACTIONS[ACTION_NAME.THROW]!,
                                       SampleData.ACTIONS[ACTION_NAME.WIELD]!
                             ] + defaultActions
    )
    static let RING     = InventoryItemType(name: "ring", displayName: "rings", tag: "=",
                             actions: [SampleData.ACTIONS[ACTION_NAME.PUT_ON]!,
                                       SampleData.ACTIONS[ACTION_NAME.THROW]!,
                                       SampleData.ACTIONS[ACTION_NAME.WIELD]!
                             ] + defaultActions
    )
    static let AMULET   = InventoryItemType(name: "aumlet", displayName: "amulets", tag: ",",
                              actions: [SampleData.ACTIONS[ACTION_NAME.THROW]!,
                                        SampleData.ACTIONS[ACTION_NAME.WIELD]!
                             ] + defaultActions
    )
    static let ITEM_NAMES: [InventoryItemType: [(name: String, pattern: String)?]] = [
//        SampleData.FOOD : [("food", "some %@"),
//                               ("food", "rations of %@"),
//                               ("slime mold", "%@"),
//                               ("slime mold", "%@s")
//        ],
        SampleData.ARMOR : [("ring mail", "+1 %@ [protection: 4]"),
                                ("chain mail", "%@"),
                                ("splint mail", "+0 %@ [protection: 6]"),
                                ("leather armor", "%@"),
                                ("studded leather armor", "%@"),
                                ("plate mail", "%@"),
                                ("plate mail", "+3 %@ [protection: 10]")
        ],
        SampleData.WEAPON : [("mace", "+1,+1 %@"),
                                 ("arrow", "%@"),
                                 ("two handed sword", "%@"),
                                 ("mace", "%@"),
                                 ("long sword", "%@"),
                                 ("dagger", "%@"),
                                 ("dart", "%@")
        ],
        SampleData.POTION : [nil,
                                 ("confusion", "potion of %@"),
                                 ("monster detection", "potion called %@"),
                                 ("healing", "potion of %@")
        ],
        SampleData.SCROLL : [nil,
                                 ("scare monster", "scroll of %@"),
                                 ("enchant weapon", "scroll of %@"),
                                 ("identify ring, wand or staff", "scroll of %@"),
                                 ("teleportation", "scroll called %@"),
                                 ("protection", "scroll called %@")
        ],
        SampleData.RING : [nil,
                               ("see invisible", "ring of %@"),
                               ("some random ring", "ring called %@"),
                               ("adornment", "ring of %@"),
                               ("add damage", "ring of %@ [-1]")
        ],
        SampleData.STICK : [nil,
                                ("polymorph", "staff called %@"),
                                ("striking", "wand of %@ [3 charges]"),
                                ("cold", "staff of %@ [1 charges]")
        ]
    ]
    static var ALIASES: [InventoryItemType : [(aliases: [String], variant: String?)]] = [
        SampleData.POTION: [(["green", "aquamarine", "red", "black", "white", "brown", "blue"], nil)],
        SampleData.SCROLL: [(["xy zzy rah", "foo baar oof", "fas jfe laja", "ziv zav zue", "vou pej zav jfie", "fie fei foe"], nil)],
        SampleData.STICK:  [(["gold", "bronze", "iron"], "wand"),
                            (["oak", "teak", "walnut"], "staff")],
        SampleData.RING: [(["onyx", "diamond", "amethyst", "opal", "ruby", "sapphire"], nil)]
    ]
    static let GROUPED: [String] = ["arrow", "dagger", "dart"]

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
    private var inventory: [InventoryItem] = [];
    
    private weak var controller : InventoryService?
    private weak var updateService: GameUpdateService?
    
    public init(updateService : GameUpdateService) {
        self.updateService = updateService
        
        // add required items
        getSampleFood()

        for type in SampleData.ITEM_NAMES.keys {
            let items = SampleData.ITEM_NAMES[type]!
            if let required = items[0] {
                let added = addItem(type: type,
                            name: required.name,
                            pattern: String(format: required.pattern, required.name + "%@")
                )
                if (type.name == SampleData.WEAPON.name) {
                    added.setActionState(action: SampleData.ACTIONS[ACTION_NAME.WIELD]!, state: nil)
                }
                else if (type.name == SampleData.ARMOR.name) {
                    added.setActionState(action: SampleData.ACTIONS[ACTION_NAME.WEAR]!, state: nil)
                }
            }
        }
        
        _ = addItem(type: SampleData.WEAPON, name: "short bow", pattern: "+1,+0 short bow%@")
        _ = addItem(type: SampleData.WEAPON, name: "arrow", pattern: "+0,+0 arrow%@", count: SampleData.random(15) + 25)

        // add random items
        for type in SampleData.ITEM_NAMES.keys {
            var items = SampleData.ITEM_NAMES[type]!
            items.remove(at: 0)

            getSampleItemsForSegment(of: type, probability: SampleData.random(15) + 20, items: items as! [(name: String, pattern: String)])
        }
    }
    
    // MARK: DataService implementation
    func getInventoryDataService() -> InventoryDataService? {
        return self
    }
    
    //MARK: InventoryDataService Implementation
    public func getPackItems() -> [InventoryItem] {
        return inventory
    }
    
    // ordered!
    public func getItemTypes() -> [InventoryItemType] {
        return inventoryTypes
    }
    
    public func getAction(for name: String) -> InventoryItemAction? {
        if let action = SampleData.ACTION_NAME(rawValue: name) {
            return SampleData.ACTIONS[action]
        }
        return nil
    }
    
    public func registerController(controller: InventoryService) {
        self.controller = controller
    }
    
    private func lookupAction(for undoAction: SampleData.ACTION_NAME) -> InventoryItemAction? {
        for action in SampleData.ACTIONS.values {
            if (action.unActionCommand == undoAction.rawValue) {
                return action
            }
        }
        return nil
    }
    
    //MARK: ToolsControllerService
    public func processCreateObjectCommand(action: UIAlertAction) {
        let typename = action.title?.lowercased()
        if (SampleData.FOOD.name == typename ) {
            getSampleFood()
        }
        else if (SampleData.AMULET.name == typename) {
            _ = addItem(type: SampleData.AMULET, name: "amulet", pattern: "amulet of yendor")
        }
        else {
            let types = SampleData.ITEM_NAMES.keys.filter( { $0.name == typename } )
            if let type = types.first {
                var items = SampleData.ITEM_NAMES[type]!
                items.remove(at: 0)
                
                getSampleItemForSegment(of: type, using: items as! [(name: String, pattern: String)])
            }
        }
    }
    
    public func getItemTypesNames() -> [String] {
        return getItemTypes().map( { $0.name } )
    }
    
    //MARK: InventoryCommandService Implementation
    public func inventoryAction(item: InventoryItem, command: String, option: String?) -> Bool {
        if let action = SampleData.ACTION_NAME(rawValue: command) {
            switch action {
            case SampleData.ACTION_NAME.EAT:
                // ToDo: affect hero
                let message = (SampleData.random(100) < 50) ? "Yum!" : "Yuck!"
                messageBox(message)
                return controller!.remove(item: item)
            case SampleData.ACTION_NAME.THROW:
                // ToDo: affect hero
                messageBox("Oof!")
                return controller!.remove(item: item)
            case SampleData.ACTION_NAME.QUAFF:
                // ToDo: affect hero
                messageBox("Mmmmm! [staggers around...]")
                return controller!.remove(item: item)
            case SampleData.ACTION_NAME.READ:
                // ToDo: affect hero
                messageBox("You feel enlightened...")
                return controller!.remove(item: item)
            case SampleData.ACTION_NAME.WEAR:
                return controller!.setState(item: item, name: command, state: option)
            case SampleData.ACTION_NAME.REMOVE:
                if let lookup = lookupAction(for: action) {
                    return controller!.clrState(item: item, name: lookup.actionCommand)
                }
                break
            case SampleData.ACTION_NAME.WIELD:
                if let result = controller!.findItemState(named: command, state: option) {
                    _ = controller!.clrState(item: result.item, name: command)
                }
                return controller!.setState(item: item, name: command, state: option)
            case SampleData.ACTION_NAME.PUT_ON:
                return controller!.setState(item: item, name: command, state: option)
            case SampleData.ACTION_NAME.TAKE_OFF:
                if let lookup = lookupAction(for: action) {
                    return controller!.clrState(item: item, name: lookup.actionCommand)
                }
                break
            case SampleData.ACTION_NAME.ZAP:
                // ToDo: ask direction and action command
                // ToDo: change charges attribute
                messageBox("zing!")
                return true
            case SampleData.ACTION_NAME.CALL:
                // get new name from user and...
                // return controller!.updateLabel(item: item, name: label)
                break;
            case SampleData.ACTION_NAME.DROP:
                // ToDo: place object in dungeon
                if (SampleData.random(100) < 20) {
                    messageBox("Agh! [dances on one foot...]")
                }
                return controller!.remove(item: item)
            }
        }
        print("ERROR: unknown action \(command) with option \(option ?? "nil") not performed on: "
            + item.getDisplayName() + " [id=\(item.id)]"
        )
        return false
    }
    
    private func messageBox(_ message: String) {
        let eventArgs = ToolMessageArgs(message: message)
        updateService?.sendUpdate(for: ServiceKey.ToolsService, args: eventArgs, sender: self)
    }
    
    //MARK: private implementation
    private func getAliasForType(_ type: InventoryItemType) -> (alias: String, variant: String?)? {
        if let variants = SampleData.ALIASES[type] {
            let index = SampleData.random(variants.count)
            var variant = variants[index]
            
            if let next = SampleData.randomItem(variant.aliases) {
                if let ix = variant.aliases.index(of: next) {
                    variant.aliases.remove(at: ix)
                    SampleData.ALIASES[type]![index].aliases = variant.aliases
                }
                return (next, variant.variant)
            }
            return ("fAkEnAmE", variant.variant)        // need more aliases!
        }
        return nil
    }
    
    private func nextID() -> String {
        let choices = Array(UnicodeScalar("a").value...UnicodeScalar("z").value)
        return String(UnicodeScalar(choices[self.inventory.count])!);
    }
    
    private func addItem(type: InventoryItemType, name: String, pattern: String, count: Int = 1) -> InventoryItem {
        // id: String, name: String, pattern: String, type: InventoryItemType, variant: String? = nil
        
        if (type.isMulti) {
            let items = inventory.filter( { $0.type == type && $0.name == name } )
            if let item = items.first {
                if !(controller?.updateCount(item: item, count: item.count + count) ?? false) {
                    item.count += count
                }
                return item
            }
        }

        let item = InventoryItem(id: nextID(), name: name, pattern: pattern, type: type);
        if (1 < count) {
            item.count = count
        }
        self.inventory.append(item)
        
        _ = controller?.add(item: item)
        
        return item
    }
    
    private func getSampleFood() {
        let selected = (SampleData.random(100) < 20)
            ? SampleData.randomItem([("fruit", "slime mold%@", 1), ("fruit", "slime mold%@", 3)])!
            : SampleData.randomFromDistribution([("food", "some food", 1), ("food", "ration%@ of food", 2)], probabilities: [67, 33])!
        
        _ = addItem(type: SampleData.FOOD, name: selected.0, pattern: selected.1, count: selected.2)
    }
    
    private func getSampleItemForSegment(of type: InventoryItemType, using: [(name: String, pattern: String)]) {
        var selected : (name: String, pattern: String)
        
        let count = (type.isMulti) ? SampleData.randomFromDistribution([1,2,3], probabilities: [80,15,5])! : 1
        
        if let alias = getAliasForType(type) {
            if (80 > SampleData.random(100)) {
                let pattern = (type.name == SampleData.SCROLL.name)
                    ? "\(alias.variant ?? type.name)%@ titled '\(alias.alias)'"
                    : "\(alias.alias) \(alias.variant ?? type.name)%@"
                
                selected = (alias.alias, pattern)
            }
            else {
                selected = SampleData.randomItem(using)!
                selected.pattern = (SampleData.SCROLL == type)
                    ? String(format: selected.pattern, selected.name)
                    : String(format: selected.pattern + "(%@)", selected.name, alias.alias)
                if (type.isMulti) {     // N.B. food is never a type here!
                    selected.pattern = selected.pattern.replacingOccurrences(of: type.name, with: type.name + "%@")
                }
            }
        }
        else {
            selected = SampleData.randomItem(using)!
            selected.pattern = String(format: selected.pattern, selected.name + "%@")
        }
        
        _ = addItem(type: type, name: selected.name, pattern: selected.pattern, count: count)
        return
    }

    private func getSampleItemsForSegment(of type: InventoryItemType, probability: Int, items: [(name: String, pattern: String)]) {
        var remainder = probability
        
        while (0 < remainder) {
            if (remainder > SampleData.random(100)) {
                getSampleItemForSegment(of: type, using: items)
            }
            remainder -= 10
        }
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
