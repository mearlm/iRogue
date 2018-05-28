//
//  KeypadViewController.swift
//  iRogue
//
//  Created by Michael McGhan on 8/9/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import UIKit

class KeypadViewController : UIViewController {
    //MARK: Properties
    let MAXLENGTH = 2   // numbers from 1 to 99
    
    let ENTER = -2
    let ERASE = -1
    
    @IBOutlet weak var btnZero: UIButton!
    @IBOutlet weak var btnOne: UIButton!
    @IBOutlet weak var btnTwo: UIButton!
    @IBOutlet weak var btnThree: UIButton!
    @IBOutlet weak var btnFour: UIButton!
    @IBOutlet weak var btnFive: UIButton!
    @IBOutlet weak var btnSix: UIButton!
    @IBOutlet weak var btnSeven: UIButton!
    @IBOutlet weak var btnEight: UIButton!
    @IBOutlet weak var btnNine: UIButton!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnEnter: UIButton!
    
    private var number: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setState()
        print("KeypadViewController did load")
    }
    
    private func setState() {
        let isEmpty = (self.number.count == 0)
        let isFull = (self.number.count == MAXLENGTH)
    
        // btnEnter.isEnabled = !isEmpty;
        btnBack.isEnabled = !isEmpty;
        btnZero.isEnabled = !isEmpty && !isFull;
        btnOne.isEnabled = !isFull;
        btnTwo.isEnabled = !isFull;
        btnThree.isEnabled = !isFull;
        btnFour.isEnabled = !isFull;
        btnFive.isEnabled = !isFull;
        btnSix.isEnabled = !isFull;
        btnSeven.isEnabled = !isFull;
        btnEight.isEnabled = !isFull;
        btnNine.isEnabled = !isFull;
    }
    
    @IBAction func KeyboardHandler(_ sender: UIButton) {
        let value = sender.tag
        
        switch (value) {
        case ERASE:
            // backspace
            self.number = String(self.number.dropLast())
            break
        case ENTER:
            // enter: dismiss keyboard
            RepeatCountUpdateEmitter(count: self.number, complete: true).notifyHandlers(self)
            number = ""
        default:
            // 0-9: append
            self.number = self.number + String(value)
            break
        }
        setState()

        if (ENTER != value) {
            RepeatCountUpdateEmitter(count: self.number, complete: false).notifyHandlers(self)
        }
    }
}
