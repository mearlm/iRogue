//
//  TextFieldNoCaret.swift
//  iRogue
//
//  Created by Michael McGhan on 7/29/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import UIKit

class TextFieldNoCaret: UITextField {
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero;
    }
}
