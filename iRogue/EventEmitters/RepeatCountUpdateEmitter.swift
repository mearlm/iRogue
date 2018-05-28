//
//  RepeatCountUpdateEmitter.swift
//  iRogue
//
//  Created by Michael McGhan on 5/15/18.
//  Copyright © 2018 MSQR Laboratories. All rights reserved.
//

import Foundation

public struct RepeatCountUpdateEmitter : EventEmitter {
    public let count : String
    public let complete : Bool
}
