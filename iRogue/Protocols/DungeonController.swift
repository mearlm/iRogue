//
//  DungeonController.swift
//  iRogue
//
//  Created by Michael McGhan on 5/6/18.
//  Copyright © 2018 MSQR Laboratories. All rights reserved.
//

import UIKit

// support for DungeonViewController call-forward interfaces (see DungeonManager)
public protocol DungeonControllerService: AnyObject {
    func getFont() -> UIFont
    func getDungeonSize() -> (rows: Int, cols: Int)
    func getCharacterForCell(at: IndexPath) -> String
    func getHeroLocation() -> IndexPath
    
    // TESTING ONLY
    func teleportHero()
    
    func handleSingleTap(_ selectedIndexPath: IndexPath)
    func handleDoubleTap(_ selectedIndexPath: IndexPath)
    func handleLongPress(_ selectedIndexPath: IndexPath)
}

public protocol DungeonDataService: AnyObject {
    func getDungeonSize() -> (rows: Int, cols: Int)
    func getDungeonFont() -> UIFont
    func getHeroPosition() -> (col: Int, row: Int)
    func setHeroPositon(col: Int, row: Int)
    func getCharacterAt(row: Int, col: Int) -> String
}
