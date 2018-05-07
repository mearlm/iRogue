//
//  DungeonViewController.swift
//  iRogue
//
//  Created by Michael McGhan on 7/29/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import UIKit

class DungeonViewController: UICollectionViewController {
    fileprivate let reuseIdentifier = "dungeonCell"
    
    var cellFont: UIFont?
    
    let centerDot: Character = "." // "\u{00B7}"
    let passage: Character = "#"
    let topBottomWall: Character = "-"
    let leftRightWall: Character = "|"
    
    // ToDo: make these externally configurable
    let NUM_ROWS = 24       // items per section
    let NUM_COLS = 80       // sections
    
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
        return NUM_ROWS
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NUM_COLS
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DungeonCell
        
        // fake up the dungeon -- replace with call to GameEngine to get cell text
        if ((indexPath.section - 6) % 9 == 0 && Int(indexPath.item / 10) % 2 == 0) {
            cell.lblDungeonCell.text = String(topBottomWall)
        }
        else if (indexPath.item % 9 == 0 && Int((indexPath.section + 4) / 10) % 2 == 1) {
            cell.lblDungeonCell.text = String(leftRightWall)
        }
        else {
            cell.lblDungeonCell.text = String(centerDot);
        }
        // end fake up
        
        // Configure the cell
        cell.backgroundColor = UIColor.black
        cell.lblDungeonCell.textColor = UIColor.green
        cell.lblDungeonCell.font = self.cellFont
        
        return cell
    }
    
    //MARK: Gesture Handlers
    @objc func handleSingleTap(sender: UITapGestureRecognizer) {
        let pointInCollectionView: CGPoint = sender.location(in: self.collectionView)
        let selectedIndexPath = self.collectionView?.indexPathForItem(at: pointInCollectionView)
        let selectedCell = self.collectionView!.cellForItem(at: selectedIndexPath!)
        
        let frame = selectedCell?.frame
        print("Single Tap at \(String(describing: selectedIndexPath))! @ \(String(describing: frame))")
    }
    
    @objc func handleDoubleTap(sender: UITapGestureRecognizer) {
        let pointInCollectionView: CGPoint = sender.location(in: self.collectionView)
        let selectedIndexPath = self.collectionView?.indexPathForItem(at: pointInCollectionView)
        // let selectedCell = self.collectionView!.cellForItem(at: selectedIndexPath!)

        print("Double Tap at \(String(describing: selectedIndexPath))!")
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if (sender.state == UIGestureRecognizerState.began) {
            let pointInCollectionView: CGPoint = sender.location(in: self.collectionView)
            let selectedIndexPath = self.collectionView?.indexPathForItem(at: pointInCollectionView)
            // let selectedCell = self.collectionView!.cellForItem(at: selectedIndexPath!)
            
            print("Long Press at \(String(describing: selectedIndexPath))!")
        }
    }
}
