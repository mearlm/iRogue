//
//  InventoryItemModel.swift
//  iRogue
//
//  Created by Michael McGhan on 9/16/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

// action: "quaff"; "wear" or "remove"
public class InventoryItemAction {
    private let actionCommand: String
    private let unActionCommand: String?
    
    public init(action: String, unaction: String?) {
        self.actionCommand = action         // mutually exclusive actions
        self.unActionCommand = unaction
    }
    
    public func getName() -> String {
        return actionCommand
    }
    
    public func getCommand(for state: [String: Bool]) -> String {
        if let isUsed = state[self.actionCommand] {
            return (isUsed) ? self.unActionCommand! : self.actionCommand
        }
        return self.actionCommand
    }
}

public class InventoryItemType : Hashable, Equatable {
    public let tag: String                 // filter code: "!", "[", etc.
    public let name: String                // e.g. "stick", "weapon"
    
    private var actions: [InventoryItemAction] = []
    
    public init(name: String, tag: String, actions: [String: String?]) {
        self.name = name
        self.tag = tag
        
        for action in actions.keys {
            self.actions.append(InventoryItemAction(action: action, unaction: actions[action]!))
        }
    }
    
    public var hashValue: Int {
        return self.name.hashValue ^ self.name.hashValue
    }
    
    public static func == (lhs: InventoryItemType, rhs: InventoryItemType) -> Bool {
        return lhs.name == rhs.name
    }
    
    // NB: actions are just command names to be sent to the command processor (with the item id)
    // e.g. throw, drop, quaff, read, wear, remove, etc.
    // the command processor is responsible for "actioning" the command and updating the model
    fileprivate func getActions(for state: [String : Bool]) -> [String] {
        var result: [String] = []
        
        for action in self.actions {
            result.append(action.getCommand(for: state))
        }
        return result
    }
}

public class InventoryItem {
    public let type: InventoryItemType
    private let name: String
    
    public let id: String                  // item identifier (immutable) [e.g. a-z]
    public private(set) var label: String  // display name
    
    // e.g. state of worn or wielded items
    private var actionState: [String: Bool] = [:]
    
    public init(id: String, name: String, label: String, type: InventoryItemType) {
        self.id = id
        self.name = name
        self.label = label
        self.type = type
    }
    
    public func getTrueName() -> String {
        return self.name
    }
    
    public func getDisplayName() -> String {
        return self.label
    }
    
    // updates whenever item attributes change
    public func setDisplayName(_ name: String) {
        self.label = name
    }
    
    // updates when un/wielded or un/worn
    public func setState(for action: String, state: Bool) {
        actionState.updateValue(state, forKey: action)      // update or insert
    }
    
    // names of actions this item can perform, e.g. "quaff" or "eat"
    public func getActions() -> [String] {
        return self.type.getActions(for: self.actionState)
    }
}
