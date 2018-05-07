//
//  InventoryController.swift
//  iRogue
//
//  Created by Michael McGhan on 4/29/18.
//  Copyright © 2018 MSQR Laboratories. All rights reserved.
//

import UIKit

// shared: UI <-> back-end
//public protocol InventoryViewControllerDelegate: class {
//    func updateRowInSection(for tag: String, row: Int)
//    func updateSection(for tag: String, preexisting: Bool)
//    func setEnabled(for tag: String, state: Bool)
//}
//
public struct UpdateRowInSectionArgs : GameEventArgs {
    public let tag: String
    public let row: Int
}

public struct UpdateSectionArgs : GameEventArgs {
    public let tag: String
    public let preexisting: Bool
}

public struct SetEnabledArgs : GameEventArgs {
    public let tag: String
    public let state: Bool
}

public struct SetInventoryArgs : GameEventArgs {
    public let items: [String : [String]]
}

public protocol InventoryControllerService: class {
    func getTotalItemCount() -> Int
    func getItemRowCount(for tag: String, offset: Int) -> Int
    func hasItems(for tag: String) -> Bool
    func getItemLabel(for tag: String, offset: Int, row: Int) -> (id: String, label: String)?
    func getItemTypeCount() -> Int
    func getItemTypesNames() -> [String]?                   // ordered!
    func getItemTypeName(for tag: String, offset: Int) -> String?
    func findSection(for tag: String) -> Int?
    func getActions(for tag: String, offset: Int, row: Int) -> [(String, [String]?)]?
    
    func doAction(for tag: String, offset: Int, row: Int, command: String, option: String?)
}

// ToDo: back-end only!
public protocol InventoryDataService : class {
    func getPackItems() -> [InventoryItem]
    func getItemTypes() -> [InventoryItemType]              // ordered!
    func getAction(for: String) -> InventoryItemAction?
    
    func processCreateObjectCommand(action: UIAlertAction)

    func registerController(controller: InventoryService)   // make as weak reference
}

public protocol InventoryService: class {
    func add(item: InventoryItem) -> Bool
    func remove(item: InventoryItem) -> Bool

    func updateCount(item: InventoryItem, count: Int) -> Bool
    func updateLabel(item: InventoryItem, name: String) -> Bool

    func setState(item: InventoryItem, name: String, state: String?) -> Bool
    func clrState(item: InventoryItem, name: String) -> Bool
    func findItemState(named: String, state: String?) -> (item: InventoryItem, action: InventoryItemAction)?
    
//    func messageBox(_ message: String)
}
