//
//  InventoryManager.swift
//  iRogue
//
//  Created by Michael McGhan on 8/23/17.
//  Copyright © 2017, 2018 MSQR Laboratories. All rights reserved.
//

import UIKit

public class InventoryManager : InventoryControllerService, InventoryService {
    private weak var inventoryData: InventoryDataService?
    private weak var commandService: InventoryCommandService?
    private weak var options: OptionsDataService?

    public static let ALLTYPES_TAG = "*"
    
    // N.B. InventoryItem array is ordered (by display-row within type-section)
    private var itemsByType: [InventoryItemType : [InventoryItem]] = [:]
    private var itemsWithStates: [InventoryItem] = []    // sticky actions
    
    required public init(commands: InventoryCommandService, data: InventoryDataService, options: OptionsDataService) {
        self.commandService = commands
        self.inventoryData = data
        self.options = options

        data.registerController(controller: self)       // weak back-reference
        self.reset()
    }
    
    // private implementation
    private func reset() {
        if let items = self.inventoryData?.getPackItems() {
            for item in items {
                self.addItem(item: item)
                InventoryEnabledUpdateEmitter(tag: item.type.tag, state: true).notifyHandlers(self)
            }
        }
    }
    
    private func findTag(by offset: Int) -> String? {
        var count = 0
        
        if let types = self.inventoryData?.getItemTypes() {        // ordered
            for ix in 0..<types.count {
                if let _ = itemsByType[types[ix]] {
                    if (count == offset) {
                        return types[ix].tag
                    }
                    count += 1
                }
            }
        }
        return nil
    }
    
    private func findType(for tag: String, offset: Int) -> InventoryItemType? {
        let key = (InventoryManager.ALLTYPES_TAG == tag) ? findTag(by: offset) : tag
        for type in itemsByType.keys {
            if (type.tag == key) {
                return type
            }
        }
        return nil
    }

    private func findRow(for item: InventoryItem) -> Int? {
        if let row = itemsByType[item.type]?.index(of: item) {
            return row
        }
        return nil
    }
    
    private func addItem(item: InventoryItem) {
        var list = itemsByType[item.type]
        if (nil == list) {
            list = [item]
//            InventoryEnabledUpdateEmitter(tag: item.type.tag, state: true).notifyHandlers(self)
        }
        else {
            // sort on append (only)
            list = (list! + [item]).sorted(by: areInAscendingOrder(lhs:rhs:))
        }
        itemsByType[item.type] = list
        
        if (!itemsWithStates.contains(item) && !item.actionStates.isEmpty) {
            itemsWithStates.append(item)
        }
    }

    // NB: list is not changed!
//    private func removeItem(from list: [InventoryItem], item: InventoryItem) -> [InventoryItem] {
//        var result = list
//        if let ix = result.index(of: item) {
//            result.remove(at: ix)
//            if (result.count == 0) {
//                InventoryEnabledUpdateEmitter(tag: item.type.tag, state: false).notifyHandlers(self)
//            }
//        }
//        return result
//    }

    //MARK: InventoryControllerService Implementation (see InventoryViewController)
    public func findSection(for tag: String) -> Int? {
        var count = 0
        
        if let types = self.inventoryData?.getItemTypes() {       // ordered
            for ix in 0..<types.count {
                if let _ = itemsByType[types[ix]] {
                    if (types[ix].tag == tag) {
                        return count
                    }
                    count += 1
                }
            }
        }
        return nil
    }

    public func getTotalItemCount() -> Int {
        var total = 0
        for (type, items) in itemsByType {
            for item in items {
                total += (type.isMulti) ? item.count : 1
            }
        }
        return total
    }
    
    public func getItemRowCount(for tag: String, offset: Int) -> Int {
        if let type = findType(for: tag, offset: offset) {
            return itemsByType[type]!.count
        }
        return 0
    }
    
    public func hasItems(for tag: String) -> Bool {
        return getItemRowCount(for: tag, offset: -1) > 0
    }
    
    private func areInAscendingOrder(lhs: InventoryItem, rhs: InventoryItem) -> Bool {
        return lhs.id < rhs.id
    }
    
    private func getItem(for tag: String, offset: Int,  row: Int) -> InventoryItem? {
        if let type = findType(for: tag, offset: offset) {
            return itemsByType[type]![row]      // unchecked row-index!
        }
        return nil
    }
    
    public func getItemLabel(for tag: String, offset: Int, row: Int) -> (id: String, label: String)? {
        if let item = getItem(for: tag, offset: offset, row: row) {
            return (item.id, item.getDisplayName())
        }
        return nil
    }
    
    // number of types currently in pack
    public func getItemTypeCount() -> Int {
        return itemsByType.keys.count
    }
    
    public func getItemTypesNames() -> [String] {
        if let types = inventoryData?.getItemTypes() {
            return types.map( { $0.name } )
        }
        return [String]()
    }
    
    public func getItemTypeTags() -> [String] {
        if let types = inventoryData?.getItemTypes() {
            return types.map( { $0.tag } )
        }
        return [String]()
    }

    public func getItemTypeName(for tag: String, offset: Int) -> String? {
        if let type = findType(for: tag, offset: offset) {
            return type.displayName
        }
        return nil
    }
    
    public func getActions(for tag: String, offset: Int, row: Int) -> [(String, [String]?)]? {
        if let item = getItem(for: tag, offset: offset, row: row) {
            return item.getActions(current: itemsWithStates)
        }
        return nil
    }
    
    public func doAction(for tag: String, offset: Int, row: Int, command: String, option: String?) {
        if let item = getItem(for: tag, offset: offset, row: row) {
            if (!commandService!.inventoryAction(item: item, command: command.lowercased(), option: option)) {
                print("WARN: command \(command) with option \(option ?? "nil") failed for item: "
                    + item.getTrueName() + " [id=\(item.id)]")
            }
        }
        else {
            print("ERROR: unexpected action on missing item @ \(tag), \(offset), \(row): "
                + "command \(command) with option \(option ?? "nil")"
            )
        }
    }

    //MARK: InventoryService Implementation (see InventoryCommandService)
    public func add(item: InventoryItem) -> Bool {
        if let _ = findRow(for: item) {
            print("ERROR: unexpected add: items with \(item.id) is already in the inventory list")
            return false
        }
        
        let preexisting = hasItems(for: item.type.tag)
        
        addItem(item: item)
        InventorySectionUpdateEmitter(tag: item.type.tag, preexisting: preexisting).notifyHandlers(self)
        return true
    }
    
    // ToDo: is itemsByType accessible?  see addItem, removeItem, above
    public func remove(item: InventoryItem) -> Bool {
        if let row = findRow(for: item) {
            if (item.type.isMulti) {
                item.count -= 1
            }

            if (!item.type.isMulti || 0 >= item.count) {
                // delete it
                itemsByType[item.type]!.remove(at: row)
                if (itemsByType[item.type]!.count == 0) {
                    // also remove section, if empty
                    itemsByType.removeValue(forKey: item.type)
//                    InventoryEnabledUpdateEmitter(tag: item.type.tag, state: false).notifyHandlers(self)
                }
                
                if let ix = itemsWithStates.index(of: item) {
                    itemsWithStates.remove(at: ix)
                }
            }
            InventorySectionUpdateEmitter(tag: item.type.tag, preexisting: true).notifyHandlers(self)
            return true
        }
        print("ERROR: unexpected remove: no item with \(item.id) is in the inventory list")
        return false
    }
    
    public func updateCount(item: InventoryItem, count: Int) -> Bool {
        if let row = findRow(for: item) {
            if (count != item.count) {          // optimized
                item.count = count
                InventoryRowInSectionUpdateEmitter(tag: item.type.tag, row: row).notifyHandlers(self)
            }
            return true
        }
        print("ERROR: unexpected update-count: missing item \(item.id)")
        return false
    }
    
    public func updateLabel(item: InventoryItem, name: String) -> Bool {
        if let row = findRow(for: item) {
            item.setPattern(name)
            InventoryRowInSectionUpdateEmitter(tag: item.type.tag, row: row).notifyHandlers(self)
            return true
        }
        print("ERROR: unexpected update-label: missing item \(item.id)")
        return false
    }
    
    public func setState(item: InventoryItem, name: String, state: String?) -> Bool {
        if let row = findRow(for: item) {
            if let action = inventoryData?.getAction(for: name) {
                item.setActionState(action: action, state: state)
                if (action.isExclusive()) {
                    itemsWithStates.append(item)
                    
                    // change in sticky-action state => refresh (e.g. weapon in hand)
                    InventoryRowInSectionUpdateEmitter(tag: item.type.tag, row: row).notifyHandlers(self)
                }
                // else: no visual change; affects available commands list only
                return true
            }
        }
        print("ERROR: unexpected update-state [\(name)]: missing item \(item.id)")
        return false
    }
    
    public func clrState(item: InventoryItem, name: String) -> Bool {
        if let row = findRow(for: item) {
            if let action = inventoryData?.getAction(for: name) {
                item.unsetActionState(action: action)
                if (action.isExclusive()) {
                    if let ix = itemsWithStates.index(of: item) {
                        itemsWithStates.remove(at: ix)
                    }

                    // change in sticky-action state => refresh (e.g. weapon in hand)
                    InventoryRowInSectionUpdateEmitter(tag: item.type.tag, row: row).notifyHandlers(self)
                }
                // else: no visual change; affects available commands list only
                return true
            }
        }
        print("ERROR: unexpected clear-state [\(name)]: missing item \(item.id) or action \(name)")
        return false
    }
    
    public func findItemWithState(named: String, state: String?) -> (item: InventoryItem, action: InventoryItemAction)? {
        if let action = inventoryData?.getAction(for: named) {
            for item in itemsWithStates {
                let match = item.actionStates.keys.filter(
                    { $0 == action && item.actionStates[$0]! == state }
                )
                if let found = match.first {
                    return (item, found)
                }
            }
        }
        return nil      // normal return (no such state for any item)
    }
}
