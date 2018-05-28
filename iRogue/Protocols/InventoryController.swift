//
//  InventoryController.swift
//  iRogue
//
//  Created by Michael McGhan on 4/29/18.
//  Copyright © 2018 MSQR Laboratories. All rights reserved.
//

import UIKit

// support for InventoryViewController call-forward interfaces (see InventoryManager)
public protocol InventoryControllerService: AnyObject {
    func getTotalItemCount() -> Int
    func getItemRowCount(for tag: String, offset: Int) -> Int
    func hasItems(for tag: String) -> Bool
    func getItemLabel(for tag: String, offset: Int, row: Int) -> (id: String, label: String)?
    func getItemTypeCount() -> Int
    func getItemTypesNames() -> [String]                    // ordered
    func getItemTypeTags() -> [String]                      // ordered
    func getItemTypeName(for tag: String, offset: Int) -> String?
    func findSection(for tag: String) -> Int?
    func getActions(for tag: String, offset: Int, row: Int) -> [(String, [String]?)]?
    
    func doAction(for tag: String, offset: Int, row: Int, command: String, option: String?)
}

// support for user specified inventory-related actions (see SampleData)
public protocol InventoryCommandService : AnyObject {
    // send inventory-related commands into the game
    func inventoryAction(item: InventoryItem, command: String, option: String?) -> Bool
}

// ToDo: back-end only! (see SampleData)
public protocol InventoryDataService : AnyObject {
    func getPackItems() -> [InventoryItem]
    func getItemTypes() -> [InventoryItemType]              // ordered
    func getAction(for: String) -> InventoryItemAction?
    
    func processCreateObjectCommand(action: UIAlertAction)

    // ToDo: should this use callback events?
    func registerController(controller: InventoryService)   // make as weak reference
}

// support for model-based inventory updates (see InventoryManager)
public protocol InventoryService: AnyObject {
    func add(item: InventoryItem) -> Bool
    func remove(item: InventoryItem) -> Bool

    func updateCount(item: InventoryItem, count: Int) -> Bool
    func updateLabel(item: InventoryItem, name: String) -> Bool

    func setState(item: InventoryItem, name: String, state: String?) -> Bool
    func clrState(item: InventoryItem, name: String) -> Bool
    func findItemWithState(named: String, state: String?) -> (item: InventoryItem, action: InventoryItemAction)?
}
