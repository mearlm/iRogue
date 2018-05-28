//
//  WeakRef.swift
//  iRogue
//
//  Created by Michael McGhan on 5/16/18.
//  Copyright © 2018 MSQR Laboratories. All rights reserved.
//
// source: https://marcosantadev.com/swift-arrays-holding-elements-weak-references/

import Foundation

public class WeakRef<T> where T: AnyObject {
    let key: Int
    private(set) weak var value: T?
    
    public init(value: T?, key: Int) {
        self.key = key
        self.value = value
    }
}
