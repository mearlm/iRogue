//
//  CreditsManager.swift
//  iRogue
//
//  Created by Michael McGhan on 5/18/18.
//  Copyright © 2018 MSQR Laboratories. All rights reserved.
//

import Foundation

import UIKit

public class CreditsManager : CreditsControllerService {
    public func getItemCount(for section: Int) -> Int {
        return 0
    }

    public func getSectionCount() -> Int {
        return 0
    }
    
    public func getLabel(for section: Int, row: Int) -> String? {
        return nil
    }
    
    public func getTitle(for section: Int) -> String? {
        return nil
    }
}
