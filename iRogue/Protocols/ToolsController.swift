//
//  ToolsController.swift
//  iRogue
//
//  Created by Michael McGhan on 5/6/18.
//  Copyright © 2018 MSQR Laboratories. All rights reserved.
//

import Foundation
import UIKit

// shared: UI <-> back-end
public struct ToolMessageArgs : GameEventArgs {
    public let message: String
}

public protocol ToolsControllerService: class {
    func getItemTypesNames() -> [String]                   // ordered!
    func processCreateObjectCommand(action: UIAlertAction)
}
