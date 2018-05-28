//
//  GameUI.swift
//  iRogue
//
//  Created by Michael McGhan on 8/24/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import UIKit

public protocol GameService : AnyObject {
    func loadOptions() -> OptionsDataService?
    func loadData(for version: String) -> InventoryDataService?
    
    func getInventoryManager() -> InventoryControllerService?
    func getCommandManager() -> InventoryCommandService?        // ToDo: CommandService?
    func getToolsManager() -> ToolsControllerService?
    func getOptionsManager() -> OptionsControllerService?
    func getDungeonManager() -> DungeonControllerService?
    func getCreditsManager() -> CreditsControllerService?
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
