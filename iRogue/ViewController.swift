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
class ViewController: UIViewController, KeypadViewControllerDelegate, InventoryControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var txtMessageOrCommand: UITextField!
    @IBOutlet weak var btnRepeat: UIButton!
    @IBOutlet weak var btnSetRepeatCount: UIBarButtonItem!
    @IBOutlet weak var btnInventory: UIBarButtonItem!
    @IBOutlet weak var btnTools: UIBarButtonItem!
    @IBOutlet weak var topStackView: SubPanelView!
    @IBOutlet var subPanelHeight: NSLayoutConstraint!  // height constraint for SubPanelStackView
    @IBOutlet weak var statsStackView: UIStackView!
    @IBOutlet weak var toolBar: UIToolbar!
    
    private weak var subPanelStackView: SubPanelView?
    private var stackFrameHeight: CGFloat?
    
    private let MINHEIGHT = CGFloat(150.0)                  // minimum height of SubPanelStackView
    private let SPACING = CGFloat(5.0)

    // ToDo: make cellsize configurable
    private let INVENTORY_EXTENT = 0.33     // 1/3 of total view space
    
    private lazy var statsBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        _ = view.addBorder(edges: [.top, .bottom], color: UIColor.black, thickness: 1)
//        view.layer.borderWidth = 2
//        view.layer.borderColor = UIColor.black.cgColor
        
        return view
    }()

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
        self.hideSubPanel()     // ToDo: determine if subpanel should hide or not based on screen size
                                // Also, if not hidden, ensure that inventory/keyboard tools are disabled
        
        // BUG: if dungeon collection is scrolled and subpanel is shown, then dungeon cells move
        // and row 0 shifts to within the grid (while some other row vanishes)
        
        self.pinBackground(statsBackgroundView, to: statsStackView)
        
        self.update(number: "1", sender: nil)
        self.updateComplete(sender: nil)
        
        print("ViewController did load")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // NB: need to use viewDidAppear as the status bar offset isn't set in viewDidLoad
        adjustSubPanelIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        // fix the missing badges
    }
    
    // inhibit screen rotation when subpanel (inventory or keyboard) is showing
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("main segue to: \(String(describing: segue.identifier))")
        if (segue.identifier == "dungeonSegue") {
            let vc = segue.destination as! DungeonViewController
            let view = vc.collectionView!
            
            let pointSize = CGFloat(25.0)
            var cellFont = UIFont.init(name: "Menlo-Regular", size: pointSize)
            if (nil == cellFont) {
                cellFont = UIFont.init(name: "Courier", size: pointSize)
            }
            guard let font = cellFont else {
                fatalError("Monospaced font not installed!")
            }
            vc.cellFont = font.fontWithBold()
            
            let layout = DungeonCollectionViewLayout(font: vc.cellFont!)
            view.setCollectionViewLayout(layout, animated: false)
            view.reloadData()
        }
        else if (segue.identifier == "subPanelSegue") {
            let vc = segue.destination as! SubPanelViewController
            vc.setup(keyDelegate: self, invDelegate: self)
        }
    }
    
    //MARK: Keyboard Management
    func update(number: String, sender: KeypadViewController?) {
        btnRepeat.setTitle(number, for: .normal)
        // ToDo: should update the model, then load value from the model
        btnSetRepeatCount.setBadge(text: number)
        btnInventory.isEnabled = (number == "")
        btnSetRepeatCount.isEnabled = btnInventory.isEnabled
    }
    
    // NB: this will hide the keyboard if it is the only panel showing
    // but not if both it and the inventory panel are displayed
    func updateComplete(sender: KeypadViewController?) {
        if (isShowSubPanel(forSide: .RightBottom) && !isShowSubPanel(forSide: .LeftTop)) {
            self.hideSubPanel()
        }
        else {
            btnSetRepeatCount.isEnabled = true
            btnInventory.isEnabled = true
        }
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

            let height = MINHEIGHT + ((excess > 0.0) ? excess : 0.0)
            
            subPanelHeight.constant = height
            print("subpanel resized to \(height) height [excess = \(excess); frame = \(self.stackFrameHeight!)] with constraint: \(subPanelHeight.debugDescription)")
        }
    }
    
    private func isShowSubPanel(forSide: SubPanelView.PanelEnum) -> Bool {
        if (topStackView.isShowRightBottom()) {
            switch (forSide) {
            case .Either:
                return subPanelStackView!.isShowEither()
            case .Both:
                return subPanelStackView!.isShowBoth()
            case .LeftTop:
                return subPanelStackView!.isShowLeftTop()
            case .RightBottom:
                return subPanelStackView!.isShowRightBottom()
            }
        }
        return false
    }
    
    private func showInventory() {
        btnSetRepeatCount.isEnabled = showSubPanel(favored: .LeftTop)
//        
//        print("top-stack-view-frame: \(self.topStackView.frame.size)")
//        for view in topStackView.arrangedSubviews {
//            print("  subview-frame: \(view.frame.size)")
//        }
    }
    
    private func showKeyboard() {
        _ = showSubPanel(favored: .RightBottom)
        // btnSetRepeatCount.isEnabled = false
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
        // select dungeon cell/character (point) size
        // select font family?
        // select dungeon cell background color and/or foreground color
        // save game (automatic!?)
        // load game? (automatic!?)
        // fight near death
        // find/run (tab/double-tap??)
        
    }
    
    //MARK: Stats View
    private func pinBackground(_ view: UIView, to stackView: UIStackView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        stackView.insertSubview(view, at: 0)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: (stackView.superview?.leadingAnchor)!),
            view.trailingAnchor.constraint(equalTo: (stackView.superview?.trailingAnchor)!),
            view.topAnchor.constraint(equalTo: stackView.topAnchor),
            view.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
        ])
    }
    
    //MARK: Tool Menu
    var leftViewController: UIViewController? {
        willSet{
            self.leftViewController?.view?.removeFromSuperview()
            self.leftViewController?.removeFromParentViewController()
//            if self.leftViewController != nil {
//                if self.leftViewController!.view != nil {
//                    self.leftViewController!.view!.removeFromSuperview()
//                }
//                self.leftViewController!.removeFromParentViewController()
//            }
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
//            if self.rightViewController != nil {
//                if self.rightViewController!.view != nil {
//                    self.rightViewController!.view!.removeFromSuperview()
//                }
//                self.rightViewController!.removeFromParentViewController()
//            }
        }
        
        didSet{            
            self.view!.addSubview(self.rightViewController!.view)
            self.addChildViewController(self.rightViewController!)
        }
    }
    
    var menuShown: Bool = false
    
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
    
    //MARK: NOT USED

//    // e.g. called from viewDidAppear()
//    private func testFontsForDungeon() {
//        guard let dungeonViewController = childViewControllers.first as? DungeonViewController else {
//            fatalError("Check storyboard for missing DungeonViewController")
//        }
//        
//        let cellFont = dungeonViewController.cellFont!
//        Testing.testFonts(cellFont)
//    }
//    
//    // very inaccurate.  see: https://ivomynttinen.com/blog/ios-design-guidelines
//    private func pixelsPerInch() -> Double {
//        return 160.0
//        //        let ppi = 160.0
//        //        let scale = Double(UIScreen.main.scale)
//        //        let bounds = UIScreen.main.bounds
//        //        return ppi * scale
//    }
//    
//    private let FACTOR = 0.75
//    
//    private func cellSize_NOT_USED() -> (wd: Double, ht: Double) {
//        // ToDo: Dungeon Cell Label is using courier 12 font (for now)
//        // 6 lines-per-inch (height); 10 characters-per-inch (width)
//        let height = pixelsPerInch() / 6.0 * FACTOR
//        let width = pixelsPerInch() / 10.0 * FACTOR
//        
//        return (width, height)
//    }
}

