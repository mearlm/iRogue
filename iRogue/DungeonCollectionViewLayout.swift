//
//  DungeonCollectionViewLayout.swift
//  iRogue
//
//  Created by Michael McGhan on 7/30/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import UIKit

// from: MultiDirectionViewLayout (https://github.com/kwandrews7/MultiDirectionCollectionView/tree/adding-sticky-headers)
// with additional concepts from: GridLayout (https://gist.github.com/smswz/393b2d6237b7837234015805c600ada2)
class DungeonCollectionViewLayout: UICollectionViewLayout {
    private var cellFont: UIFont
    private var cellHeight: CGFloat
    private var cellWidth: CGFloat
    
    init(font: UIFont) {
        self.cellFont = font
        
        self.cellWidth = String(UnicodeScalar(UInt8(32))).size(attributes: [NSFontAttributeName: font]).width
        self.cellHeight = font.lineHeight
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // performance cache
    var itemAttributesCache = Dictionary<IndexPath, UICollectionViewLayoutAttributes>()
    
    // Defines the size of the area the user can move around in
    // within the collection view.
    var contentSize = CGSize.zero
    
    // Used to determine if a data source update has occured.
    // Note: The data source would be responsible for updating
    // this value if an update was performed.
    var dataSourceDidUpdate = true
    
    override var collectionViewContentSize: CGSize {
        return self.contentSize
    }
    
    override func prepare() {
        if (!self.dataSourceDidUpdate) {
            // Determine current content offsets.
            let xOffset = collectionView!.contentOffset.x
            let yOffset = collectionView!.contentOffset.y
            
            if let sectionCount = collectionView?.numberOfSections, sectionCount > 0 {
                for section in 0..<sectionCount {
                    
                    // Confirm the section has items.
                    if let rowCount = collectionView?.numberOfItems(inSection: section), rowCount > 0 {
                        // Update all items in the first row.
                        if section == 0 {
                            for item in 0..<rowCount {
                                
                                // Build indexPath to get attributes from dictionary.
                                let indexPath = IndexPath(item: item, section: section)
                                
                                // Update y-position to follow user.
                                if let attrs = itemAttributesCache[indexPath] {
                                    var frame = attrs.frame
                                    
                                    // Also update x-position for corner cell.
                                    if item == 0 {
                                        frame.origin.x = xOffset
                                    }
                                    
                                    frame.origin.y = yOffset
                                    attrs.frame = frame
                                }
                                
                            }
                            
                            // For all other sections, we only need to update
                            // the x-position for the fist item.
                        } else {
                            // Build indexPath to get attributes from dictionary.
                            let indexPath = IndexPath(item: 0, section: section)
                            
                            // Update y-position to follow user.
                            if let attrs = itemAttributesCache[indexPath] {
                                var frame = attrs.frame
                                frame.origin.x = xOffset
                                attrs.frame = frame
                            }
                        } // else
                    } // num of items in section > 0
                } // sections for loop
            } // num of sections > 0
        }
        else {
            // Do not run attribute generation code
            // unless data source has been updated.

            // Cycle through each section of the data source.
            if let sectionCount = collectionView?.numberOfSections, sectionCount > 0 {
                for section in 0..<sectionCount {
                    
                    // Cycle through each item in the section.
                    if let rowCount = collectionView?.numberOfItems(inSection: section), rowCount > 0 {
                        for item in 0..<rowCount {

                            // Build the UICollectionViewLayoutAttributes for the cell.
                            let cellIndex = IndexPath(item: item, section: section)
                            let xPos = CGFloat(item) * cellWidth
                            let yPos = CGFloat(section) * cellHeight
                            
                            let cellAttributes = UICollectionViewLayoutAttributes(forCellWith: cellIndex)
                            cellAttributes.frame = CGRect(x: xPos, y: yPos, width: cellWidth, height: cellHeight)
                            
                            // Determine zIndex based on cell type.
                            if section == 0 && item == 0 {
                                cellAttributes.zIndex = 4
                            } else if section == 0 {
                                cellAttributes.zIndex = 3
                            } else if item == 0 {
                                cellAttributes.zIndex = 2
                            } else {
                                cellAttributes.zIndex = 1
                            }
                            
                            // Save the attributes.
                            itemAttributesCache[cellIndex] = cellAttributes
                        }
                    }
                }
            }

            // Update content size.
            let contentWidth = CGFloat(collectionView!.numberOfItems(inSection: 0)) * cellWidth
            let contentHeight = CGFloat(collectionView!.numberOfSections) * cellHeight
            self.contentSize = CGSize(width: contentWidth, height: contentHeight)
            
            dataSourceDidUpdate = false
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return itemAttributesCache.values.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return itemAttributesCache[indexPath]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let oldWidth = collectionView?.bounds.width
        let oldHeight = collectionView?.bounds.height
        
        let result = oldWidth != newBounds.width || oldHeight != newBounds.height
        // print("shouldInvalidateLayout: \(result) [\(String(describing: collectionView?.bounds)) => \(newBounds)]")
        
        return result
    }
}
