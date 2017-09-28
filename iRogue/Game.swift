//
//  Game.swift
//  iRogue
//
//  Created by Michael McGhan on 9/1/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import Foundation

public class Game : GameService {
    public private(set) var version: String?
    private var data: InventoryService?
    
    public init() {
    }
    
    public func loadData(for version: String) {
        self.version = version
        
        // load game data and restore state (if appropriate)
        if (version == "SampleData") {
            self.loadSampleData()
        }
    }
    
    private func loadSampleData() {
        data = SampleData()
    }
    
    public func getInventoryService() -> InventoryService {
        return data!
    }
}
