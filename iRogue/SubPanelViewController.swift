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
    
    let MINWIDTH: (lt: CGFloat, rb: CGFloat) = (300.0, 118.0)
    let MINHEIGHT: (lt: CGFloat, rb: CGFloat)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.subPanelStackView.setup(minWidth: self.MINWIDTH, minHeight: self.MINHEIGHT)
        print("SubPanelViewController did load")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("subpanel segue to: \(String(describing: segue.identifier))")
    }
}
