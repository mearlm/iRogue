//
//  DungeonManager.swift
//  iRogue
//
//  Created by Michael McGhan on 5/6/18.
//  Copyright © 2018 MSQR Laboratories. All rights reserved.
//

import Foundation
import UIKit

public class DungeonManager : DungeonControllerService {
    private weak var options: OptionsDataService?
    private weak var data: DungeonDataService?

    public init(data: DungeonDataService, options: OptionsDataService) {
        self.data = data
        self.options = options
    }
    
    public func getFont() -> UIFont {
        return options!.getDungeonFont() ?? data!.getDungeonFont()
    }
    
    public func getDungeonSize() -> (rows: Int, cols: Int) {
        return data!.getDungeonSize()
    }
    
    public func getCharacterForCell(at indexPath: IndexPath) -> String {
        return data!.getCharacterAt(row: indexPath.section, col: indexPath.row)
    }
    
    public func getHeroLocation() -> IndexPath {
        let heroPosition = data!.getHeroPosition()
        print("hero @: \(heroPosition.col), \(heroPosition.row)")       // consistent with IndexPath ordering
        return IndexPath(item: heroPosition.col, section: heroPosition.row)
    }
    
    private func toIndexPath(_ col: Int, _ row: Int) -> IndexPath {
        return IndexPath(item: col, section: row)
    }
    
    // ToDo: change to use external instructions
    public func teleportHero() {
        let dungeonSize = getDungeonSize()
        let oldLocation = data!.getHeroPosition()
        let newLocation = (col: SampleData.random(dungeonSize.cols), row: SampleData.random(dungeonSize.rows))
        data!.setHeroPositon(col: newLocation.col, row: newLocation.row)
        DungeonReloadEventEmitter(indexPaths: [toIndexPath(oldLocation.col, oldLocation.row), toIndexPath(newLocation.col, newLocation.row)]).notifyHandlers(self)
    }
    
    public func handleSingleTap(_ selectedIndexPath: IndexPath) {
        print("Single Tap at \(String(describing: selectedIndexPath))!")
    }
    
    public func handleDoubleTap(_ selectedIndexPath: IndexPath) {
        print("Double Tap at \(String(describing: selectedIndexPath))!")
    }
    
    public func handleLongPress(_ selectedIndexPath: IndexPath) {
        print("Long Press at \(String(describing: selectedIndexPath))!")
    }
}
