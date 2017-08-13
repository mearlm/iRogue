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

        self.topStackView.setup(minWidth: -1.0, minHeight: 150.0)
        self.configureViewForSize(size: view.bounds.size)
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
    func update(number: String) {
        btnRepeat.setTitle(number, for: .normal)
        btnSetRepeatCount.badgeValue = number
    }
    
    //MARK: Inventory Management
    func updateCount(number: Int) {
        btnInventory.badgeValue = String(number)
    }
    
//    func addDoneButton() {
//        let keyboardToolbar = UIToolbar()
//        keyboardToolbar.sizeToFit()
//        
//        let cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel,
//                                              target: self, action: #selector(cancelButtonTapped(_:)))
//        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
//                                            target: nil, action: nil)
//        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done,
//                                            target: self, action: #selector(doneRepeatEdit(_:)))
//        keyboardToolbar.items = [cancelBarButton, flexBarButton, doneBarButton]
//        
//        self.txtKeyboard.inputAccessoryView = keyboardToolbar
//    }
//    
//    func cancelButtonTapped(_ sender: UIBarButtonItem) {
//        updateRepeatCount(oldRepeatCount)           // restore original value
//        doneRepeatEdit(sender)
//    }
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("in touchesBegan");
//        doneRepeatEdit(self)
//    }
//    
//    //MARK: UITextFieldDelegate
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        // Hide the keyboard.
//        doneRepeatEdit(textField)
//        return true
//    }
//    
//    func doneRepeatEdit(_ sender: AnyObject) {
//        print("hiding keyboard")
//
//        self.txtKeyboard.text = ""
//        self.txtKeyboard.resignFirstResponder()
//    }
//
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let textFieldText: NSString = (textField.text ?? "") as NSString
//        let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
//        let length = txtAfterUpdate.characters.count
//
//        if (txtAfterUpdate != "0" && length <= 2) {
//            self.updateRepeatCount(txtAfterUpdate)          // 1-99
//            return true
//        }
//        return false
//    }
//    
//    // handles clear button on text field
//    func textFieldShouldClear(_ textField: UITextField) -> Bool {
//        self.updateRepeatCount("")
//        return true
//    }
//    
//    private func updateRepeatCount(_ toString: String) {
//        btnRepeat.setTitle(toString, for: .normal)
//        btnSetRepeatCount.badgeValue = toString
//    }
    
    //MARK: SubPanel View Management
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        configureViewForSize(size: size)
    }
    
    private func configureViewForSize(size: CGSize) {
        if size.width > size.height {
            topStackView.axis = .horizontal
        } else {
            topStackView.axis = .vertical
        }
    }
    
    private func isShowSubPanel() -> Bool {
        return topStackView.isShowRightBottom()
    }
    
    private func showInventory() {
        topStackView.showBoth(favored: .Both)
        subPanelStackView?.showBoth(favored: .LeftTop)
    }
    
    private func showKeyboard() {
        topStackView.showBoth(favored: .Both)
        subPanelStackView?.showBoth(favored: .RightBottom)
    }
    
    func hideSubPanel() {
        topStackView.showLeftTopOnly()
    }
    
    //MARK: UITabBarDelegate
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch(item.tag) {
        case 0:
            // home
            if (isShowSubPanel()) {
                hideSubPanel()
            }
            break;
        case 1:
            // inventory (toggle)
            if (isShowSubPanel()) {
                hideSubPanel()
            }
            else {
                showInventory()
            }
            break;
        case 2:
            // set repeat count
            if (isShowSubPanel()) {
                hideSubPanel()
            }
            else {
                showKeyboard()
            }
            break
        case 3:
            // help
//            topStackView.axis = (topStackView.axis == .horizontal) ? .vertical : .horizontal
            break
        default:
            print("toolbar didSelect unknown button: \(item.tag)")
            break
        }
    }
}

