//
//  Location.swift
//  iRogue
//
//  Created by Michael McGhan on 4/29/18.
//  Copyright © 2018 MSQR Laboratories. All rights reserved.
//

import Foundation

public typealias Point = (x : Int, y : Int)

public class Location {
    private let coord : Point
    
    required public init(x: Int, y: Int) {
        self.coord = (x, y)
    }
    
    public func getCoord() -> Point {
        return self.coord
    }
}
