//
//  ItemType.swift
//  iRogue
//
//  Created by Michael McGhan on 8/29/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import Foundation

public class ItemType : Hashable, Equatable {
    private let tag: String                 // display code: "!", "[", etc.
    private let name: String                // e.g. "stick", "weapon"
    private let grouped: Bool
    
    private var actions: [String: String?]
    
    public init(name: String, tag: String, grouped: Bool, actions: [String: String?]) {
        self.name = name
        self.tag = tag
        self.grouped = grouped
        self.actions = actions
    }
    
    public var hashValue: Int {
        return self.name.hashValue ^ self.name.hashValue
    }
    
    public static func == (lhs: ItemType, rhs: ItemType) -> Bool {
        return lhs.getTypeName() == rhs.getTypeName()
    }
    
    public func getTypeName() -> String {
        return self.name
    }
    
    public func getTypeTag() -> String {
        return self.tag
    }
    
    public func isGrouped() -> Bool {
        return self.grouped
    }
    
    public func getActions() -> [String: String?] {
        return self.actions
    }
}
