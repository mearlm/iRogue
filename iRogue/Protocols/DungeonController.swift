//
//  DungeonController.swift
//  iRogue
//
//  Created by Michael McGhan on 5/6/18.
//  Copyright © 2018 MSQR Laboratories. All rights reserved.
//

import UIKit

// shared: UI <-> back-end
public struct FontUpdateArgs : GameEventArgs {
    public let font: UIFont
}

public protocol DungeonControllerService: class {
}
