//
//  GameUI.swift
//  iRogue
//
//  Created by Michael McGhan on 8/24/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import UIKit

public protocol GameService : class {
    func loadData(for version: String)
    func getInventoryService() -> InventoryService
}

public protocol InventoryController : class {
    // update inventory when things happen in the model (item picked up, stolen, ...)
    func add(id: String, item: InventoryItem)
    func remove(id: String)
    
    func updateLabel(id: String, name: String)
    func setState(id: String, action: String, state: Bool)  // wield, wear, ...

//    func know(id: String)
//    func identify(id: String)
    
//    func addType(tag: String, name: String)
//    func getItemLabels(forTag: String) -> [String]?
//    func getItemCount() -> Int
//    
//    func getTypeName(forTag: String) -> String?
//    func getItemTypes() -> [InventoryItemType]
//    func getItemTypeCount() -> Int
}

public protocol InventoryService : class {
    func getPackItems() -> [InventoryItem]
    func getItemTypes() -> [InventoryItemType]      // ordered!
    
    func registerController(controller : InventoryController)
}

public protocol CommandService : class {
    // send commands into the game
}

public struct Coordinates {
    init(row: Int, col: Int) { }
}

public protocol DungeonController : class {
    // update dungeon when things happen in the model
    
    func showAt(location: Coordinates, character: String, actions: [String]?)
}
