//
//  MasterViewController.swift
//  iRogue
//
//  Created by Michael McGhan on 9/28/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import Foundation
import UIKit

protocol MainMenuDelegate: class {
    func toggleMenu()
}

class MasterViewController: UIViewController, MainMenuDelegate {
    //MARK: Main Menu properties
    var leftViewController: UIViewController? {
        willSet{
            self.leftViewController?.view?.removeFromSuperview()
            self.leftViewController?.removeFromParentViewController()
        }
        
        didSet{
            self.view!.addSubview(self.leftViewController!.view)
            self.addChildViewController(self.leftViewController!)
        }
    }
    
    var rightViewController: UIViewController? {
        willSet {
            self.rightViewController?.view?.removeFromSuperview()
            self.rightViewController?.removeFromParentViewController()
        }
        
        didSet{
            self.view!.addSubview(self.rightViewController!.view)
            self.addChildViewController(self.rightViewController!)
        }
    }
    
    var menuShown: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainNavigationController: GameViewController = storyboard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        mainNavigationController.menuDelegate = self
        
        let menuViewController: MenuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController")as! MenuViewController
        
        self.leftViewController = menuViewController
        self.rightViewController = mainNavigationController
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print("master segue to: \(String(describing: segue.identifier))")
//        if (segue.identifier == "dungeonSegue") {
//        }
//    }
    
    //MARK: Main Menu behaviors
    func toggleMenu() {
        if (menuShown) {
            hideMenu()
        }
        else {
            showMenu()
        }
    }
    
    func showMenu() {
        UIView.animate(withDuration: 0.3, animations: {
            self.rightViewController!.view.frame = CGRect(x: self.view.frame.origin.x + 235, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height)
        }, completion: { (Bool) -> Void in
            self.menuShown = true
        })
    }
    
    func hideMenu() {
        UIView.animate(withDuration: 0.3, animations: {
            self.rightViewController!.view.frame = CGRect(x: 0, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height)
        }, completion: { (Bool) -> Void in
            self.menuShown = false
        })
    }
}
