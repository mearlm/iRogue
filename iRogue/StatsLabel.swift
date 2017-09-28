//
//  StatsLabel.swift
//  iRogue
//
//  Created by Michael McGhan on 9/28/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//
//  source: https://stackoverflow.com/questions/41278153/the-default-text-color-for-all-uilabels

import UIKit

@IBDesignable class StatsLabel: UILabel {
    @IBInspectable var txtColor: UIColor = UIColor.green {
        didSet {
            self.textColor = txtColor
        }
    }
    
    func setup() {
        self.textColor = txtColor
    }
    
    override func awakeFromNib() {
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        setup()
    }
}
