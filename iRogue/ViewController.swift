//
//  ViewController.swift
//  iRogue
//
//  Created by Michael McGhan on 7/24/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import Foundation
import UIKit

// ToDo: move InventoryControllerDelegate to separate class
class ViewController: UIViewController, UITabBarDelegate, KeypadViewControllerDelegate, InventoryViewControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var txtMessageOrCommand: UITextField!
    @IBOutlet weak var btnRepeat: UIButton!
    @IBOutlet weak var btnSetRepeatCount: UITabBarItem!
    @IBOutlet weak var btnInventory: UITabBarItem!
    @IBOutlet weak var btnHome: UITabBarItem!
    @IBOutlet weak var topStackView: SubPanelView!
    weak var subPanelStackView: SubPanelView?
    @IBOutlet weak var tabBar: UITabBar!
    
    private var oldRepeatCount = "1"
    private var inventorySize = CGSize.zero
    // ToDo: make cellsize configurable
    private let FACTOR = 0.75
    private let INVENTORY_EXTENT = 0.33     // 1/3 of total view space

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        guard let subPanelViewController = childViewControllers.last as? SubPanelViewController else {
            fatalError("Check storyboard for missing SubPanelViewController")
        }        
        self.subPanelStackView = subPanelViewController.subPanelStackView

        self.topStackView.setup(minWidth: nil, minHeight: (0.0, 150.0))
        // self.topStackView.axis = axisForSize(view.bounds.size)
        self.hideSubPanel()
        //self.addDoneButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func pixelsPerInch() -> Double {
        return 160.0
//        let ppi = 160.0
//        let scale = Double(UIScreen.main.scale)
//        let bounds = UIScreen.main.bounds
//        return ppi * scale
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("main segue to: \(String(describing: segue.identifier))")
        if (segue.identifier == "dungeonSegue") {
            let vc = segue.destination as! DungeonViewController
            let view = vc.collectionView!
            
            // ToDo: Dungeon Cell Label is using courier 12 font (for now)
            // 6 lines-per-inch (height); 10 characters-per-inch (width)
            let height = pixelsPerInch() / 6.0 * FACTOR
            let width = pixelsPerInch() / 10.0 * FACTOR
            
            let layout = DungeonCollectionViewLayout(cellWidth: width, cellHeight: height)
            view.setCollectionViewLayout(layout, animated: false)
            view.reloadData()
        }
        else if (segue.identifier == "subPanelSegue") {
            let vc = segue.destination as! SubPanelViewController
            vc.setup(invDelegate: self, keyDelegate: self)
        }
    }
    
    //MARK: Keyboard Management
    func update(number: String, sender: KeypadViewController) {
        btnRepeat.setTitle(number, for: .normal)
        btnSetRepeatCount.badgeValue = number
        btnInventory.isEnabled = (number == "")
    }
    
    func updateComplete(sender: KeypadViewController) {
        if (!subPanelStackView!.isShowLeftTop()) {
            self.hideSubPanel()
        }
        btnSetRepeatCount.isEnabled = true
        btnInventory.isEnabled = true
    }
    
    //MARK: Inventory Management
    func updateCount(number: Int) {
        btnInventory.badgeValue = String(number)
    }
    
    //MARK: SubPanel View Management
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // topStackView.axis = axisForSize(size)
    }
    
    private func axisForSize(_ size: CGSize) -> UILayoutConstraintAxis {
        return size.width > size.height ? .horizontal : .vertical
    }
    
    private func isShowSubPanel(forSide: SubPanelView.PanelEnum) -> Bool {
        if (topStackView.isShowRightBottom()) {
            if (forSide == .RightBottom) {
                return subPanelStackView!.isShowRightBottom()
            }
            else if (forSide == .LeftTop) {
                return subPanelStackView!.isShowLeftTop()
            }
            return true
        }
        return false
    }
    
    private func showInventory() {
        _ = topStackView.showBoth(favored: .RightBottom)
        btnSetRepeatCount.isEnabled = !subPanelStackView!.showBoth(favored: .LeftTop)
    }
    
    private func showKeyboard() {
        _ = topStackView.showBoth(favored: .RightBottom)
        _ = subPanelStackView!.showBoth(favored: .RightBottom)
        btnSetRepeatCount.isEnabled = false
    }
    
    func hideSubPanel() {
        topStackView.showLeftTopOnly()
        btnInventory.isEnabled = true
        btnSetRepeatCount.isEnabled = true
    }
    
    //MARK: UITabBarDelegate
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch(item.tag) {
        case 0:
            // home
            if (isShowSubPanel(forSide: .Both) && (btnSetRepeatCount.isEnabled || btnInventory.isEnabled)) {
                hideSubPanel()
            }
            break;
        case 1:
            // inventory (toggle)
            if (isShowSubPanel(forSide: .LeftTop)) {
                hideSubPanel()
            }
            else {
                showInventory()
            }
            break;
        case 2:
            // set repeat count
            if (isShowSubPanel(forSide: .RightBottom)) {
                hideSubPanel()
            }
            else {
                showKeyboard()
            }
            break
        case 3:
            // help
            // segue to Help screen
            // self.btnHome.isEnabled = true
            break
        default:
            print("toolbar didSelect unknown button: \(item.tag)")
            break
        }
    }
}

