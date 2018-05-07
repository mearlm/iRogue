//
//  GameUI.swift
//  iRogue
//
//  Created by Michael McGhan on 8/24/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import UIKit

public enum ServiceKey {
    case DummyService, DungeonService, InventoryService, CommandService, ToolsService
}

public protocol GameService : class {
    func loadData(for version: String)
    func registerDelegate<TService, TEventHandler : GameEventHandler>(protocolName: ServiceKey, protocolHandler: TEventHandler) -> TService?
}

public protocol GameUpdateService : class {
    func sendUpdate(for protocolName: ServiceKey, args: GameEventArgs, sender: Any?)
}

// base protocol for passing event data
public protocol GameEventArgs {
    
}

// protocol for sending events (data updates)
public protocol GameEventHandler : class {
    func update(sender: Any?, eventArgs: GameEventArgs)
}

public protocol InventoryCommandService : class {
    // send commands into the game
    func inventoryAction(item: InventoryItem, command: String, option: String?) -> Bool
}

//public struct Coordinates {
//    let row: Int
//    let col: Int
//}

//public protocol DungeonController : class {
//    // update dungeon when things happen in the model
//    
//    func showAt(location: Coordinates, character: String, actions: [String]?)
//}
