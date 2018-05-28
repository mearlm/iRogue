//
//  InventorySectionUpdateEmitter.swift
//  iRogue
//
//  Created by Michael McGhan on 5/14/18.
//  Copyright © 2018 MSQR Laboratories. All rights reserved.
//

import Foundation

public struct InventorySectionUpdateEmitter : EventEmitter {
    public let tag: String
    public let preexisting: Bool
}
