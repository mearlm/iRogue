//
//  OptionsController.swift
//  iRogue
//
//  Created by Michael McGhan on 5/14/18.
//  Copyright © 2018 MSQR Laboratories. All rights reserved.
//

import Foundation
import UIKit

public protocol OptionsControllerService : AnyObject {
    
}

// ToDo: back-end only! (see SampleData)
public protocol OptionsDataService : AnyObject {
    func getVersion() -> String
    func getDungeonFont() -> UIFont?
}
