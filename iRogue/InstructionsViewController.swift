//
//  InstructionsViewController.swift
//  iRogue
//
//  Created by Michael McGhan on 9/28/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import Foundation
import UIKit

class InstructionsViewController: UIPageViewController {
    //MARK: UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func actExit(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "unwindToGameViewController", sender: self)
    }
}
