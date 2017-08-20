//
//  Junk.swift
//  iRogue
//
//  Created by Michael McGhan on 8/20/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import Foundation
import UIKit

public class Testing {
    
    public static func testFonts(_ cellFont: UIFont) {
        for ix in 10...20 {
            let size = CGFloat(ix)
            
            let font = cellFont.withSize(size)
            
            testFont(font: UIFont.systemFont(ofSize: size))
            testFont(font: UIFont.boldSystemFont(ofSize: size))
            testFont(font: font)
            testFont(font: font.fontWithBold())
            testFont(font: font.fontWithMonospacedNumbers())
        }
        print("end font test")
    }
    
    // UIFont.systemFontOfSize(14.0)
    private static func testFont(font: UIFont) {
        print("font: \(font.fontName); size: \(font.pointSize); height: \(font.lineHeight); leading: \(font.leading)\n\(font.debugDescription)")
        
        let str = "The quick red fox jumped over the lazy dog."
        let str2 = "THE QUICK RED FOX JUMPED OVER THE LAZY DOG."
        
        var size: CGSize = str.size(attributes: [NSFontAttributeName: font])
        print("\(str): size: \(size); avg: \(size.width / CGFloat(str.characters.count))")
        
        size = str2.size(attributes: [NSFontAttributeName: font])
        print("\(str2): size: \(size); avg: \(size.width / CGFloat(str2.characters.count))")
        
        var min: CGFloat = 0.0
        var minCharacter: String?
        var max: CGFloat = 0.0
        var maxCharacter: String?
        var avg: CGFloat = 0.0
        var count: Int = 0
        
        for ix in 32..<127 {
            let s = String(UnicodeScalar(UInt8(ix)))
            let sz: CGSize = s.size(attributes: [NSFontAttributeName: font])
            if (min == 0.0 || min > sz.width) {
                min = sz.width
                minCharacter = s
            }
            if (max < sz.width) {
                max = sz.width
                maxCharacter = s
            }
            avg += sz.width
            count += 1
        }
        avg = avg / CGFloat(count)
        
        print("minSize: \(min) [\(minCharacter!)]\nmaxSize: \(max) [\(maxCharacter!)]\navgSize: \(avg))")
    }
}
