//
//  ToolsManager.swift
//  iRogue
//
//  Created by Michael McGhan on 5/6/18.
//  Copyright © 2018 MSQR Laboratories. All rights reserved.
//

import Foundation
import UIKit

public class ToolsManager : ToolsControllerService {
    private weak var options: OptionsControllerService?
    
    public init(options: OptionsControllerService) {
        self.options = options
    }

    public func getItemTypesNames() -> [String] {
        return []
    }                   // ordered!
    
    public func processCreateObjectCommand(action: UIAlertAction) {
        
    }
}
