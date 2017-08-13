//
//  KeypadViewController.swift
//  iRogue
//
//  Created by Michael McGhan on 8/9/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import UIKit

protocol KeypadViewControllerDelegate: class {
    func update(number: String)
}

class KeypadViewController : UIViewController {
    //MARK: Properties
    let MAXLENGTH = 2   // numbers from 1 to 99
    
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
    
    weak var delegate: KeypadViewControllerDelegate?
    
    private var number: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setState()
    }
    
    private func setState() {
        let isEmpty = (self.number.characters.count == 0)
        let isFull = (self.number.characters.count == MAXLENGTH)
    
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
        if let value = sender.title(for: .normal) {
            switch (value) {
            case "B":
                // backspace
                self.number = String(self.number.characters.dropLast())
                break
            case "E":
                // enter: dismiss keyboard
                break
            default:
                // 0-9: append
                self.number = self.number + value
                break
            }
            setState()

            delegate?.update(number: self.number)
        }
    }
}
