//
//  CreditsControllerService.swift
//  iRogue
//
//  Created by Michael McGhan on 5/18/18.
//  Copyright © 2018 MSQR Laboratories. All rights reserved.
//

import Foundation

public protocol CreditsControllerService : AnyObject {
    func getItemCount(for section: Int) -> Int
    func getSectionCount() -> Int
    func getTitle(for section: Int) -> String?
    func getLabel(for section: Int, row: Int) -> String?
}
