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

public class GameEngine : GameService, GameUpdateService {
    public private(set) var version: String?
    private var data: InventoryDataService?
    
    private var inventoryManager: InventoryControllerService?
    private var commandManager: InventoryCommandService?
    private var toolsManager: ToolsControllerService?
    
    //MARK: GameService
    private var handlerRegistry = [ServiceKey : GameEventHandler]()
    
    public func registerDelegate<TService, TEventHandler : GameEventHandler>(protocolName: ServiceKey, protocolHandler: TEventHandler) -> TService? {
        handlerRegistry[protocolName] = protocolHandler
        
        switch protocolName {
        case ServiceKey.DungeonService:
            return DungeonManager(updateService: self) as? TService
        case ServiceKey.InventoryService:
            return self.inventoryManager as? TService
        case ServiceKey.CommandService:
            return self.commandManager as? TService
        case ServiceKey.ToolsService:
            return self.toolsManager as? TService
        default:
            return nil
        }
    }
    
    public func sendUpdate(for protocolName: ServiceKey, args: GameEventArgs, sender: Any?) {
        if let handler = handlerRegistry[protocolName] {
            handler.update(sender: sender, eventArgs: args)
        }
    }

    // DataService loader
    public func loadData(for version: String) {
        // load game data and restore state (if appropriate)
        self.version = version

        // ToDo: support load from json definitions
        if (version == "SampleData") {
            self.loadSampleData()
        }
    }
    
    private func loadSampleData() {
        let sampleData = SampleData(updateService: self)
        self.data = sampleData
        self.commandManager = sampleData
        self.toolsManager = sampleData
        self.inventoryManager = InventoryManager(updateService: self, commands: self.commandManager!, data: self.data!)
    }
    
    public func setFont(font: UIFont) {
        let eventArgs = FontUpdateArgs(font: font)
        sendUpdate(for: ServiceKey.DungeonService, args: eventArgs, sender: self)
    }
}

//// Container from:  https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Generics.html
//
//protocol Container {
//    associatedtype Item
//    mutating func append(_ item: Item)
//    var count: Int { get }
//    subscript(i: Int) -> Item { get }
//}
