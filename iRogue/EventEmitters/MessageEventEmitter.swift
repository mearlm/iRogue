//
//  MessageEventEmitter.swift
//  iRogue
//
//  Created by Michael McGhan on 6/9/18.
//  Copyright © 2018 MSQR Laboratories. All rights reserved.
//

import Foundation

// ToDo: pause (in MessageEventEmitter handler) until user clicks "More" button
public struct MessageEventEmitter : EventEmitter {
    public let message: String
    public let more: Bool
}
