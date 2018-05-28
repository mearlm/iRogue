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
class GameViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var txtMessageOrCommand: UITextField!
    @IBOutlet weak var btnRepeat: UIButton!
    @IBOutlet weak var btnSetRepeatCount: UIBarButtonItem!
    @IBOutlet weak var btnInventory: UIBarButtonItem!
    @IBOutlet weak var btnHero: UIBarButtonItem!
    @IBOutlet weak var btnTools: UIBarButtonItem!
    @IBOutlet weak var topStackView: SubPanelView!
    @IBOutlet weak var subPanelHeight: NSLayoutConstraint!  // height constraint for SubPanelStackView
    @IBOutlet weak var statsStackView: UIStackView!
    @IBOutlet weak var toolBar: UIToolbar!
    
    private weak var dungeonViewController: DungeonViewController?
    private weak var subPanelStackView: SubPanelView?
    private var stackFrameHeight: CGFloat?
    weak var menuDelegate: MainMenuDelegate?
    
    private var handlers = [ChangeEventHandler]()
    
    private var repeatCount = ""
    private var inventoryCount = ""
    
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
        
        handlers.append(EventHandler<InventoryCountUpdateEmitter>(onChange: {[unowned self] (_ args: InventoryCountUpdateEmitter,_ sender: Any?) in
            self.updateInventoryCount(number: String(args.count))
        }))
        handlers.append(EventHandler<RepeatCountUpdateEmitter>(onChange: {[unowned self] (_ args: RepeatCountUpdateEmitter,_ sender: Any?) in
            if (args.complete) {
                self.updateComplete()
            }
            else {
                self.updateRepeatCount(number: args.count)
            }
        }))

        guard let subPanelViewController = childViewControllers.last as? SubPanelViewController else {
            fatalError("Check storyboard for missing SubPanelViewController")
        }        
        self.subPanelStackView = subPanelViewController.subPanelStackView

        self.topStackView.setup(minWidth: nil,
                                minHeight: (0.0, MINHEIGHT)
        )
        self.hideSubPanel()     // ToDo: determine if subpanel should hide or not based on screen size
                                // Also, if not hidden, ensure that inventory/keyboard tools are disabled
        
        self.pinBackground(statsBackgroundView, to: statsStackView)
        
        self.updateRepeatCount(number: "1")
        self.updateComplete()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let inventoryManager = appDelegate.game?.getInventoryManager() else {
            fatalError("Inventory Manager Service Unavailable.")
        }
        self.updateInventoryCount(number: String(inventoryManager.getTotalItemCount()))
        
        print("ViewController did load")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // NB: need to use viewDidAppear as the status bar offset isn't set in viewDidLoad
        adjustSubPanelIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        // fix the missing badges
        updateRepeatCount(number: self.repeatCount)
        updateInventoryCount(number: self.inventoryCount)
        btnHero.isEnabled = true
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
            self.dungeonViewController = (segue.destination as! DungeonViewController)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            guard let dungeonManager = appDelegate.game!.getDungeonManager() else {
                fatalError("Dungeon Manager Service Unavailable.")
            }
            self.dungeonViewController!.setDungeonManager(dungeonManager)

            let view = self.dungeonViewController!.collectionView!

            // NB: the view controller's collectionViewLayout property is NOT updated
            let layout = DungeonCollectionViewLayout(font: self.dungeonViewController!.cellFont!, hasRowHeaders: false, hasColHeaders: false)
            view.setCollectionViewLayout(layout, animated: false)
            
            print(String(describing: self.dungeonViewController!.collectionViewLayout))
            
            view.reloadData()
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    private func changeEnabledState(button: UIBarButtonItem, state: Bool, text: String) {
        if (state != button.isEnabled) {
            button.isEnabled = state
            button.setBadge(text: text)
        }
    }

    //MARK: RepeatCountUpdateEmitter
    func updateRepeatCount(number: String) {
        btnRepeat.setTitle(number, for: .normal)
        // ToDo: should update the model, then load value from the model
        self.repeatCount = number
        changeEnabledState(button: btnInventory, state: (number != ""), text: self.inventoryCount)
        btnSetRepeatCount.isEnabled = btnInventory.isEnabled
        btnSetRepeatCount.setBadge(text: self.repeatCount)
    }
    
    // NB: this will hide the keyboard if it is the only panel showing
    // but not if both it and the inventory panel are displayed
    func updateComplete() {
        if (isShowSubPanel(forSide: .RightBottom) && !isShowSubPanel(forSide: .LeftTop)) {
            self.hideSubPanel()
        }
        else {
            changeEnabledState(button: btnInventory, state: true, text: self.inventoryCount)
            changeEnabledState(button: btnSetRepeatCount, state: true, text: self.repeatCount)
        }
    }
    
    //MARK: InventoryCountUpdateEmitter
    func updateInventoryCount(number: String) {
        self.inventoryCount = number
        btnInventory.setBadge(text: self.inventoryCount)
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
        // btnSetRepeatCount.isEnabled =
        _ = showSubPanel(favored: .LeftTop)
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
        let result = !subPanelStackView!.showBoth(favored: favored)
        return result
    }
    
    private func hideSubPanel() {
        topStackView.showLeftTopOnly()
        changeEnabledState(button: btnInventory, state: true, text: self.inventoryCount)
        changeEnabledState(button: btnSetRepeatCount, state: true, text: self.repeatCount)
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

    @IBAction func actTools(_ sender: UIBarButtonItem) {
        // select dungeon cell/character (point) size
        // select font family?
        // select dungeon cell background color and/or foreground color
        // save game (automatic!?)
        // load game? (automatic!?)
        // fight near death
        // find/run (tab/double-tap??)
        
        self.menuDelegate?.toggleMenu()
    }
    
    @IBAction func actHelp(_ sender: UIBarButtonItem) {
        // ToDo: implement help
        self.dungeonViewController?.teleportHero()
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
    
    @IBAction func actHero(_ sender: Any) {
        self.dungeonViewController?.centerHero()
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
    
//    let button = UIButton(type: .system)
//    button.setImage(UIImage(named: "AlarmIcon"), for: .normal)
//    button.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
//    button.addTarget(self, action: #selector(BaseTabBarController.activityViewsBarButtonItemPressed(_:)), for: .touchUpInside)
//
//    return UIBarButtonItem(customView: button)
}

