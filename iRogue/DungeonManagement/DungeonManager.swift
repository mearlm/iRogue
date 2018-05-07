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
    private weak var updateService: GameUpdateService?
    
    public init(updateService: GameUpdateService) {
        self.updateService = updateService
        
        let args = FontUpdateArgs(font: getFont())
        self.updateService?.sendUpdate(for: ServiceKey.DungeonService, args: args, sender: self)
    }
    
    private func getFont() -> UIFont {
        let pointSize = CGFloat(25.0)
        var cellFont = UIFont.init(name: "Menlo-Regular", size: pointSize)
        if (nil == cellFont) {
            cellFont = UIFont.init(name: "Courier", size: pointSize)
        }
        guard let font = cellFont else {
            fatalError("Monospaced font not installed!")
        }
        return font.fontWithBold()
    }
}
