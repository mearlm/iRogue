//
//  GameEngine.swift
//  iRogue
//
//  Created by Michael McGhan on 9/1/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import Foundation
import UIKit

// Singleton, owned by AppDelegate
// provides loading of and access to DataService, to higher layers of application

public class GameEngine : GameService {
    public private(set) var options: OptionsDataService?
    public private(set) var data: InventoryDataService?

    public private(set) var version: String?

    public private(set) var inventoryManager: InventoryControllerService?
    public private(set) var commandManager: InventoryCommandService?
    public private(set) var toolsManager: ToolsControllerService?
    public private(set) var dungeonManager: DungeonControllerService?
    public private(set) var optionsManager: OptionsControllerService?
    public private(set) var creditsManager: CreditsControllerService?
    
    public func loadOptions() -> OptionsDataService? {
        // ToDo: support options load from system
        let options = OptionsManager()
        self.options = options
        self.optionsManager = options

        return self.options
    }

    // DataService loader
    public func loadData(for version: String) -> InventoryDataService? {
        self.creditsManager = CreditsManager()
        
        // load game data and restore state (if appropriate)
        self.version = version

        // ToDo: support load from json definitions
        if (version == "SampleData") {
            self.loadSampleData()
        }
        return self.data
    }
    
    private func loadSampleData() {
        let sampleData = SampleData()
        self.data = sampleData
        self.commandManager = sampleData        // ToDo: should use CommandManager
        self.toolsManager = sampleData          // ToDo: should use ToolsManager
        self.inventoryManager = InventoryManager(commands: self.commandManager!, data: self.data!, options: self.options!)
        self.dungeonManager = DungeonManager(data: sampleData, options: self.options!)
    }
    
    public func getOptionsManager() -> OptionsControllerService? {
        return self.optionsManager
    }
    
    public func getInventoryManager() -> InventoryControllerService? {
        return self.inventoryManager
    }
    
    public func getCommandManager() -> InventoryCommandService? {
        return self.commandManager
    }
    
    public func getToolsManager() -> ToolsControllerService? {
        return self.toolsManager
    }
    
    public func getDungeonManager() -> DungeonControllerService? {
        return self.dungeonManager
    }
    
    public func getCreditsManager() -> CreditsControllerService? {
        return self.creditsManager
    }
}
