//
//  DungeonViewController.swift
//  iRogue
//
//  Created by Michael McGhan on 7/29/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import UIKit

class DungeonViewController: UICollectionViewController {
    private static let NUM_ROWS = 24       // sections (rows)
    private static let NUM_COLS = 80       // items per section (columns per row)
    
    private let reuseIdentifier = "dungeonCell"
    
    // call-forward dungeon services
    private var dungeonManager: DungeonControllerService?
    
    private var handlers = [ChangeEventHandler]()
    
    // ToDo: make private with public setter?  validate updates? ...
    public var cellFont: UIFont?
    private var numRows: Int = DungeonViewController.NUM_ROWS
    private var numCols: Int = DungeonViewController.NUM_COLS
    
//    public override var collectionViewLayout: UICollectionViewLayout {
//        get {
//            return self.collectionView!.collectionViewLayout
//        }
//    }
    
    public func setDungeonManager(_ dungeonManager: DungeonControllerService) {
        self.dungeonManager = dungeonManager
        self.cellFont = dungeonManager.getFont()
        (self.numRows, self.numCols) = dungeonManager.getDungeonSize()
        
        self.handlers.append(EventHandler<DungeonReloadEventEmitter>(onChange: {[unowned self] (_ args: DungeonReloadEventEmitter,_ sender: Any?) in
            self.collectionView?.reloadItems(at: args.indexPaths)
        }))
        self.handlers.append(EventHandler<FontChangeEventEmitter>(onChange: {(_ args: FontChangeEventEmitter,_ sender: Any?) in
            self.cellFont = args.font
        }))
    }
    
//    func synchronized<T>(_ lock: AnyObject, _ body: () throws -> T) rethrows -> T {
//        objc_sync_enter(lock)
//        defer { objc_sync_exit(lock) }
//        return try body()
//    }
    
    override func viewDidLoad() {
        // Single Tap
        let singleTap: UITapGestureRecognizer =  UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(sender:)))
        singleTap.numberOfTapsRequired = 1
        self.collectionView?.addGestureRecognizer(singleTap)
        
        // Double Tap
        let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap(sender:)))
        doubleTap.numberOfTapsRequired = 2
        self.collectionView?.addGestureRecognizer(doubleTap)
        
        // Long Press
        let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(sender:)))
        self.collectionView?.addGestureRecognizer(longPress)

        singleTap.require(toFail: doubleTap)
        singleTap.delaysTouchesBegan = true
        doubleTap.delaysTouchesBegan = true
        
        print("DungeonViewController did load")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.collectionViewLayout.invalidateLayout()
    }
    
    //MARK: UI CollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.numRows
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numCols
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DungeonCell
        
        cell.lblDungeonCell.text = dungeonManager!.getCharacterForCell(at: indexPath)

        // Configure the cell
        cell.backgroundColor = UIColor.black
        cell.lblDungeonCell.textColor = UIColor.green
        cell.lblDungeonCell.font = self.cellFont
        
        return cell
    }

    // TEMP (Testing Only)
    public func teleportHero() {
        self.dungeonManager?.teleportHero()
        // ToDo: there is a timing issue with the position update not completing before the centerHero call
        // to move the view.  Need to coordinate the two calls somehow.  Similar to the issue with scrolling
        // both horizontally and vertically with animation in centerHero.
        centerHero()
    }
    
    public func centerHero() {
        let indexPath = dungeonManager!.getHeroLocation()

        let layout = self.collectionView!.collectionViewLayout as! DungeonCollectionViewLayout
        let cellSize = layout.getCellSize()

        let yOffset = collectionView!.contentOffset.y
        let xOffset = collectionView!.contentOffset.x
        let width = collectionView!.bounds.width
        let height = collectionView!.bounds.height
        
        let limit = (xMin: width / 2, yMin: height / 2, xMax: CGFloat(self.numCols) * cellSize.width - width / 2, yMax: CGFloat(self.numRows) * cellSize.height - height / 2)
        let heroPosition = (x: CGFloat(indexPath.row) * cellSize.width, y: CGFloat(indexPath.section) * cellSize.height)
        let currentCenter = (x: xOffset + limit.xMin, y: yOffset + limit.yMin)
        
        let delta = (x: max(min(heroPosition.x, limit.xMax), limit.xMin) - currentCenter.x,
                     y: max(min(heroPosition.y, limit.yMax), limit.yMin) - currentCenter.y)
        
        if (abs(delta.y) > abs(delta.x)) {
            print("scrolling vertically: \(delta.x), \(delta.y)")
            collectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: false)
            collectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredVertically, animated: true)
        }
        else {
            print("scrolling horizontally: \(delta.x), \(delta.y)")
            collectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredVertically, animated: false)
            collectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
        }
    }

    //MARK: Gesture Handlers
    @objc func handleSingleTap(sender: UITapGestureRecognizer) {
        let pointInCollectionView: CGPoint = sender.location(in: self.collectionView)
        if let selectedIndexPath = self.collectionView?.indexPathForItem(at: pointInCollectionView) {
            dungeonManager!.handleSingleTap(selectedIndexPath)

            // let selectedCell = self.collectionView!.cellForItem(at: selectedIndexPath)
            // let frame = selectedCell?.frame
        }
    }
    
    @objc func handleDoubleTap(sender: UITapGestureRecognizer) {
        let pointInCollectionView: CGPoint = sender.location(in: self.collectionView)
        if let selectedIndexPath = self.collectionView?.indexPathForItem(at: pointInCollectionView) {
            dungeonManager!.handleDoubleTap(selectedIndexPath)
        }
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if (sender.state == UIGestureRecognizerState.began) {
            let pointInCollectionView: CGPoint = sender.location(in: self.collectionView)
            if let selectedIndexPath = self.collectionView?.indexPathForItem(at: pointInCollectionView) {
                dungeonManager!.handleLongPress(selectedIndexPath)
            }
        }
    }
}
