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
class ViewController: UIViewController, KeypadViewControllerDelegate, InventoryViewControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var txtMessageOrCommand: UITextField!
    @IBOutlet weak var btnRepeat: UIButton!
    @IBOutlet weak var btnSetRepeatCount: UIBarButtonItem!
    @IBOutlet weak var btnInventory: UIBarButtonItem!
    @IBOutlet weak var btnTools: UIBarButtonItem!
    @IBOutlet weak var topStackView: SubPanelView!
    @IBOutlet var subPanelHeight: NSLayoutConstraint!  // height constraint for SubPanelStackView
    
    private weak var subPanelStackView: SubPanelView?
    private var stackFrameHeight: CGFloat?
    
    private let MINHEIGHT = CGFloat(150.0)                  // minimum height of SubPanelStackView
    private let SPACING = CGFloat(5.0)
//    private var oldRepeatCount = "1"
//    private var inventorySize = CGSize.zero
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

        self.topStackView.setup(minWidth: nil,
                                minHeight: (0.0, MINHEIGHT)
        )
        self.hideSubPanel()

        print("ViewController did load")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // NB: need to use viewDidAppear as the status bar offset isn't set in viewDidLoad
        adjustSubPanelIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        // fix the missing badges
    }
    
    // inhibit screen rotation when subpanel is showing
    override var shouldAutorotate: Bool {
        return !isShowSubPanel(forSide: .Either);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func statusBarHeight() -> CGFloat {
        let statusBarSize = UIApplication.shared.statusBarFrame.size
        return Swift.min(statusBarSize.width, statusBarSize.height)
    }
    
    private func cellSize() -> (wd: Double, ht: Double) {
        // ToDo: Dungeon Cell Label is using courier 12 font (for now)
        // 6 lines-per-inch (height); 10 characters-per-inch (width)
        let height = pixelsPerInch() / 6.0 * FACTOR
        let width = pixelsPerInch() / 10.0 * FACTOR

        return (width, height)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("main segue to: \(String(describing: segue.identifier))")
        if (segue.identifier == "dungeonSegue") {
            let vc = segue.destination as! DungeonViewController
            let view = vc.collectionView!
            
            var cellFont = UIFont.init(name: "Menlo-Regular", size: 15.0)
            if (nil == cellFont) {
                cellFont = UIFont.init(name: "Courier", size: 15.0)
            }
            guard let font = cellFont else {
                fatalError("Monospaced font not installed!")
            }
            vc.cellFont = font
            
            let layout = DungeonCollectionViewLayout(font: font.fontWithBold())
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
        // ToDo: should update the model, then load value from the model
        btnSetRepeatCount.setBadge(text: number)
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
        // ToDo: should update the model, then load value from the model
        btnInventory.setBadge(text: String(number))
    }
    
    //MARK: SubPanel View Management
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // topStackView.axis = axisForSize(size)
        coordinator.animate(alongsideTransition: nil, completion: { (context) -> Void in
            self.adjustSubPanelIfNeeded()
        })
    }
    
    private func adjustSubPanelIfNeeded() {
        guard let dungeonViewController = childViewControllers.first as? DungeonViewController else {
            fatalError("Check storyboard for missing DungeonViewController")
        }
        
        if let maxHeight = dungeonViewController.collectionView?.contentSize.height {
            self.stackFrameHeight = self.topStackView.frame.height
            let excess = self.stackFrameHeight! - MINHEIGHT - maxHeight - SPACING

            if (excess > 0.0) {
                let height = MINHEIGHT + excess
                
                subPanelHeight.constant = height
                print("subpanel resized to \(height) height [excess = \(excess); frame = \(self.stackFrameHeight!)] with constraint: \(subPanelHeight.debugDescription)")
            }
        }
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
        btnSetRepeatCount.isEnabled = !showSubPanel(favored: .LeftTop)
//        
//        print("top-stack-view-frame: \(self.topStackView.frame.size)")
//        for view in topStackView.arrangedSubviews {
//            print("  subview-frame: \(view.frame.size)")
//        }
    }
    
    private func showKeyboard() {
        _ = showSubPanel(favored: .RightBottom)
        btnSetRepeatCount.isEnabled = false
    }
    
    private func showSubPanel(favored: SubPanelView.PanelEnum) -> Bool {
        _ = topStackView.showBoth(favored: .RightBottom)
        return !subPanelStackView!.showBoth(favored: favored)
    }
    
    private func hideSubPanel() {
        topStackView.showLeftTopOnly()
        btnInventory.isEnabled = true
        btnSetRepeatCount.isEnabled = true
    }
    
    //MARK: Tool Bar Actions
    @IBAction func toggleInventory(_ sender: UIBarButtonItem) {
        // inventory (toggle)
        if (isShowSubPanel(forSide: .LeftTop)) {
            hideSubPanel()
        }
        else {
            showInventory()
        }
    }
    
    @IBAction func toggleSetRepeatCount(_ sender: UIBarButtonItem) {
        if (isShowSubPanel(forSide: .RightBottom)) {
            hideSubPanel()
        }
        else {
            showKeyboard()
        }
    }

    @IBAction func actTools(_ sender: Any) {
    }

    //MARK: NOT USED

    // e.g. called from viewDidAppear()
    private func testFontsForDungeon() {
        guard let dungeonViewController = childViewControllers.first as? DungeonViewController else {
            fatalError("Check storyboard for missing DungeonViewController")
        }
        
        let cellFont = dungeonViewController.cellFont!
        Testing.testFonts(cellFont)
    }
    
    // very inaccurate.  see: https://ivomynttinen.com/blog/ios-design-guidelines
    private func pixelsPerInch() -> Double {
        return 160.0
        //        let ppi = 160.0
        //        let scale = Double(UIScreen.main.scale)
        //        let bounds = UIScreen.main.bounds
        //        return ppi * scale
    }
}

