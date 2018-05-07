//
//  InventoryItemModel.swift
//  iRogue
//
//  Created by Michael McGhan on 9/16/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

// action: "quaff"; "wear" or "remove"
public class InventoryItemAction : Hashable, Equatable {
    public let actionCommand: String
    public let unActionCommand: String?
    public let message: String?
    public let qualifiers: [String]?
    
    public init(action: String,
                unaction: String? = nil,
                message: String? = nil,
                qualifiers: [String]? = nil)
    {
        self.actionCommand = action         // mutually exclusive actions
        self.unActionCommand = unaction
        self.message = message
        self.qualifiers = qualifiers
    }
    
    public func getName() -> String {
        return actionCommand
    }
    
    // only turn on one state with a message per item
    public func isExclusive() -> Bool {
        return (nil != self.message)
    }
    
    public func getCommand(for item: InventoryItem, current: [InventoryItem], actions: [String]) -> (String, [String]?)? {
        if current.contains(item) {
            for (action, state) in item.actionStates {
                if (action == self) {
                    // in use: unaction (if any) needed for this item
                    if let unActionCommand = self.unActionCommand {
                        let unqualifier = (nil == state) ? nil : [state!]
                        return (unActionCommand, unqualifier)
                    }
                    return nil
                }
                else if self.isExclusive() && action.isExclusive() {
                    // different sticky-actions are mutually exclusive for any specific item
                    // e.g. can put-on or wield a ring, but not both
                    return nil
                }
            }
        }
        // not already in use or use-excluded

        var qualifiers = self.qualifiers
        if self.isExclusive() {
            for actioned in current {
                if (actioned == item) {
                    continue                // already processed (see above)
                }
                
                for (action, state) in actioned.actionStates {
                    if (!actions.contains(action.getName())) {
                        continue            // action is not related to current item
                    }

                    if (action == self) {
                        // use is limited to number of distinct qualified states, or 1 item if none
                        if (nil != qualifiers) {
                            qualifiers = qualifiers!.filter( { $0 != state! } )
                            if (qualifiers!.isEmpty) {
                                // all qualified actions have been used
                                return nil  // action not allowed for this item
                            }
                        }
                        else if let _ = self.unActionCommand {
                            // unqualified actions only allow single use if they must be undone
                            // this allows wield without requiring current weapon to be unwielded
                            return nil      // action not allowed for this item
                        }
                        break               // next item
                    }
                }
            }
            // action is unqualified
            // or not all qualifying actions are used
        }
        // not a sticky-action
        return (self.actionCommand, qualifiers)
    }
    
    public func getMessageWith(qualifier: String?) -> String? {
        if var message = self.message {
            if (nil != qualifier) {
                message = String(format: message, qualifier!)
            }
            return " (\(message))"
        }
        return nil
    }
    
    public var hashValue: Int {
        return self.actionCommand.hashValue ^ self.actionCommand.hashValue
    }
    
    public static func == (lhs: InventoryItemAction, rhs: InventoryItemAction) -> Bool {
        return lhs.actionCommand == rhs.actionCommand
    }
}

public class InventoryItemType : Hashable, Equatable {
    public let tag: String                  // filter code: "!", "[", etc.
    public let name: String                 // e.g. "stick", "weapon"
    public let displayName: String          // header in inventory listing
    public let isMulti: Bool                // count groups or items
    public let useArticle: Bool             // names use an article as prefix
    
    // N.B. ordered list (must be array, not dictionary)
    public private(set) var actions: [InventoryItemAction] = []
    
    public init(name: String, displayName: String, tag: String, actions: [InventoryItemAction], isMulti: Bool = false, useArticle: Bool = true) {
        self.name = name
        self.displayName = displayName
        self.tag = tag
        self.isMulti = isMulti
        self.useArticle = useArticle
        
        for action in actions {
            self.actions.append(action)
        }
    }
    
    public var hashValue: Int {
        return self.name.hashValue ^ self.name.hashValue
    }
    
    public static func == (lhs: InventoryItemType, rhs: InventoryItemType) -> Bool {
        return lhs.name == rhs.name
    }
    
    //MARK: Actions
    
    // NB: actions are just command names to be sent to the command processor (with the item id)
    // e.g. throw, drop, quaff, read, wear, remove, etc.
    // the command processor is responsible for "actioning" the command and updating the model
    fileprivate func getActions(for item: InventoryItem,
                                current: [InventoryItem]) -> [(String, [String]?)] {
        var result: [(String, [String]?)] = []
        
        let other = self.actions.map( { $0.getName() } )
        for action in self.actions {
            if let value = action.getCommand(for: item, current: current, actions: other) {
                result.append(value)
            }
        }
        return result
    }
}

public class InventoryItem: Hashable, Equatable {
    public let type: InventoryItemType

    public let id: String                       // unique item identifier (immutable) [e.g. a-z]
    
    public let name: String                     // generic name
    public private(set) var pattern: String     // label string needing plural 's' and prefix
    
    public var count: Int                       // how many for IsMultiple (e.g. food, potion, scroll) items
    
    public private(set) var actionStates: [InventoryItemAction : String?] = [:]
    
    public init(id: String, name: String, pattern: String, type: InventoryItemType) {
        self.id = id
        self.name = name
        self.pattern = pattern
        self.type = type
        self.count = 1
    }
    
    public func getTrueName() -> String {
        return self.name
    }
    
    private static let vowelCharacters : [Character] = ["a","e","i","o","u"]
    
    private func withPrefix(for label: String) -> String {
        if (1 < self.count) {
            return "\(count) \(label)"
        }
        if (!self.type.useArticle || self.name == "food") {
            return label
        }
        if let startsWith = label.lowercased().first,
            InventoryItem.vowelCharacters.contains(startsWith) {
            return "An \(label)"
        }
        return "A \(label)"
    }
    
    private func asPlural() -> String {
        return String(format: self.pattern, (self.count > 1) ? "s" : "")
    }
    
    public func getDisplayName() -> String {
        let label = withPrefix(for: self.asPlural())
        for (action, state) in actionStates {
            // NB: only one message allowed per item
            if let message = action.getMessageWith(qualifier: state) {
                return label + message
            }
        }
        return label
    }
    
    // updates when user-named or is-known
    public func setPattern(_ pattern: String) {
        self.pattern = pattern
    }
    
    // updates when un/wielded or un/worn
    public func getInventoryCount() -> Int {
        return (type.isMulti) ? count : 1
    }
    
    public func setActionState(action: InventoryItemAction, state: String?) {
        self.actionStates.updateValue(state, forKey: action)
    }
    
    public func unsetActionState(action: InventoryItemAction) {
        self.actionStates.removeValue(forKey: action)
    }
    
    // names of actions this item can perform, e.g. "quaff" or "eat" or "put on, [left hand, right hand]"
    public func getActions(current: [InventoryItem]) -> [(String, [String]?)] {
        return self.type.getActions(for: self, current: current)
    }
    
    public var hashValue: Int {
        return self.id.hashValue ^ self.id.hashValue
    }
    
    public static func == (lhs: InventoryItem, rhs: InventoryItem) -> Bool {
        return lhs.id == rhs.id
    }
}
