//
//  SubPanelViewController.swift
//  iRogue
//
//  Created by Michael McGhan on 8/12/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import UIKit

class SubPanelViewController: UIViewController {
    @IBOutlet weak var subPanelStackView: SubPanelView!
    
    weak var keyDelegate: KeypadViewControllerDelegate?
    weak var invDelegate: InventoryControllerDelegate?
    
    let MINWIDTH: (lt: CGFloat, rb: CGFloat) = (300.0, 118.0)
    let MINHEIGHT: (lt: CGFloat, rb: CGFloat)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.subPanelStackView.setup(minWidth: self.MINWIDTH, minHeight: self.MINHEIGHT)
        print("SubPanelViewController did load")
    }

    func setup(keyDelegate: KeypadViewControllerDelegate, invDelegate: InventoryControllerDelegate) {
        self.keyDelegate = keyDelegate
        self.invDelegate = invDelegate
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("subpanel segue to: \(String(describing: segue.identifier))")
        if (segue.identifier == "keyboardSegue") {
            let vc = segue.destination as! KeypadViewController
            vc.delegate = keyDelegate!
        }
        if (segue.identifier == "inventorySegue") {
            let vc = segue.destination as! InventoryViewController
            vc.delegate = invDelegate!
        }
    }
}
