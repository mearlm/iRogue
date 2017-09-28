//
//  ItemPrototype.swift
//  iRogue
//
//  Created by Michael McGhan on 8/29/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import Foundation

public class ItemPrototype {
    public let type: ItemType
    public let name: String
    public let alias: String?
    public let variant: String?
    
    public init(type: ItemType, name: String, alias: (alias: String, variant: String?)?) {
        self.type = type
        self.name = name
        
        self.alias = alias?.alias
        self.variant = alias?.variant
    }
}
