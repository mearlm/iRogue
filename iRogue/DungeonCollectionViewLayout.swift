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
    private var cellAttributes : CellAttributes
    
    private let hasRowHeaders: Bool     // enable or disable sticky headings
    private let hasColHeaders: Bool
    
    private var handlers = [ChangeEventHandler]()
    
    init(font: UIFont, hasRowHeaders: Bool, hasColHeaders: Bool) {
        self.cellAttributes = CellAttributes(font: font)
        self.hasRowHeaders = hasRowHeaders
        self.hasColHeaders = hasColHeaders
        
        super.init()
        
        // register callbacks for dungeon-event handlers (observers)
        self.handlers.append(EventHandler<FontChangeEventEmitter>(onChange: {(_ args: FontChangeEventEmitter,_ sender: Any?) in
            self.cellAttributes = CellAttributes(font: args.font)
            self.dataSourceDidUpdate = true
            self.invalidateLayout()
        }))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func getCellSize() -> (width: CGFloat, height: CGFloat) {
        return (cellAttributes.cellWidth, cellAttributes.cellHeight)
    }
    
    // performance cache
    var itemAttributesCache = Dictionary<IndexPath, UICollectionViewLayoutAttributes>()
    
    // Defines the size of the area the user can move around in
    // within the collection view.
    var contentSize = CGSize.zero
    
    // Used to determine if a data source update has occured.
    // Note: The data source would be responsible for updating
    // this value if an update was performed.
    // This value needs to change if the cell sizes or number of rows(sections)/columns(items) changes
    var dataSourceDidUpdate = true
    
    override var collectionViewContentSize: CGSize {
        return self.contentSize
    }

    override func prepare() {
        // print("DungeonCollectionViewLayout.prepare: \(self.dataSourceDidUpdate)")
        if (!self.dataSourceDidUpdate) {
            // stick first row (column headers) and/or first column (row headers)
            // by adjusting their cell frame's origin x and/or y to match the contentOffset's
            
            // Determine current content offsets.
            let xOffset = collectionView!.contentOffset.x
            let yOffset = collectionView!.contentOffset.y
            // print("Origin: xoffset=\(xOffset), yoffset=\(yOffset)")
            
            guard(xOffset >= 0 && yOffset >= 0) else {
                return
            }
            
            if let rowCount = collectionView?.numberOfSections, rowCount > 0 {
                for rowIndex in 0..<rowCount {
                    // Confirm the row has columns
                    if let colCount = collectionView?.numberOfItems(inSection: rowIndex), colCount > 0 {
                        if (0 == rowIndex) {
                            // Update all columns in the top row.
                            for colIndex in 0..<colCount {
                                // Build indexPath to get attributes from dictionary.
                                let indexPath = IndexPath(item: colIndex, section: rowIndex)
                                
                                // Update y-position to follow user.
                                if let attrs = itemAttributesCache[indexPath] {
                                    var frame = attrs.frame
                                    
                                    // Also update x-position for corner cell.
                                    if (hasRowHeaders && colIndex == 0) {
                                        frame.origin.x = xOffset
                                    }
                                    if (!hasColHeaders) {
                                        break       // no more columns to update (for top row)
                                    }
                                    
                                    frame.origin.y = yOffset
                                    attrs.frame = frame
                                }
                            }
                        }
                        else if (!hasRowHeaders) {
                            break                   // no more rows to update (for first column)
                        }
                        else {
                            // For all other sections, we only need to update
                            // the x-position for the fist column.

                            // Build indexPath to get attributes from dictionary.
                            let indexPath = IndexPath(item: 0, section: rowIndex)
                            
                            // Update x-position to follow user.
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
            if let rowCount = collectionView?.numberOfSections, rowCount > 0 {
                for rowIndex in 0..<rowCount {
                    // Cycle through each item in the section.
                    if let colCount = collectionView?.numberOfItems(inSection: rowIndex), colCount > 0 {
                        for colIndex in 0..<colCount {
                            // Build the UICollectionViewLayoutAttributes (frame location/size/layer) for the cell.
                            let cellIndex = IndexPath(item: colIndex, section: rowIndex)
                            let xPos = CGFloat(colIndex) * self.cellAttributes.cellWidth
                            let yPos = CGFloat(rowIndex) * self.cellAttributes.cellHeight
                            
                            let cellAttributes = UICollectionViewLayoutAttributes(forCellWith: cellIndex)
                            cellAttributes.frame = CGRect(x: xPos, y: yPos, width: self.cellAttributes.cellWidth, height: self.cellAttributes.cellHeight)

                            // Determine zIndex based on cell type; needed to keep row/col headers on top
                            if (rowIndex == 0 && colIndex == 0) {
                                cellAttributes.zIndex = 3
                            } else if (rowIndex == 0 || colIndex == 0) {
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
            let contentWidth = CGFloat(collectionView!.numberOfItems(inSection: 0)) * self.cellAttributes.cellWidth
            let contentHeight = CGFloat(collectionView!.numberOfSections) * self.cellAttributes.cellHeight
            self.contentSize = CGSize(width: contentWidth, height: contentHeight)
            
            dataSourceDidUpdate = false
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // print("rect: \(rect)")
        return itemAttributesCache.values.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return itemAttributesCache[indexPath]
    }

    // scroll grid on cell boundaries
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        var x0 = proposedContentOffset.x
        var y0 = proposedContentOffset.y

        if let rowCount = collectionView?.numberOfSections, rowCount > 0 {
            if let colCount = collectionView?.numberOfItems(inSection: 0), colCount > 0 {
                let xMax = x0 + self.collectionView!.bounds.width
                if (xMax < CGFloat(colCount) * self.cellAttributes.cellWidth) {
                    x0 = CGFloat(Int(proposedContentOffset.x / self.cellAttributes.cellWidth)) * self.cellAttributes.cellWidth
                }
                
                let yMax = y0 + self.collectionView!.bounds.height
                if (yMax < CGFloat(rowCount) * self.cellAttributes.cellHeight) {
                    y0 = CGFloat(Int(proposedContentOffset.y / self.cellAttributes.cellHeight)) * self.cellAttributes.cellHeight
                }
            }
        }
        return CGPoint(x: x0, y: y0)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return (hasColHeaders || hasRowHeaders)
    }
//
//    public func validate2() {
//        if let cells = collectionView?.visibleCells {
//            var minX : CGFloat = CGFloat.greatestFiniteMagnitude
//            var minY : CGFloat = CGFloat.greatestFiniteMagnitude
//            var maxX : CGFloat = 0
//            var maxY : CGFloat = 0
//
//            for cell in cells {
//                let origin = cell.frame.origin
//                if (minY > origin.y) {
//                    minY = origin.y
//                }
//                if (maxY < origin.y) {
//                    maxY = origin.y
//                }
//                if (minX > origin.x) {
//                    minX = origin.x
//                }
//                if (maxX < origin.x) {
//                    maxX = origin.x
//                }
//            }
//            print("X: \(minX), \(maxX); y: \(minY), \(maxY)")
//
//            let yOffset = collectionView!.contentOffset.y
//            let xOffset = collectionView!.contentOffset.x
//            let width = collectionView!.bounds.width
//            let height = collectionView!.bounds.height
//            print("Rect: \(xOffset), \(yOffset), \(xOffset + width), \(yOffset + height)")
//        }
//    }
//
//    public func validate() {
//        let yOffset = collectionView!.contentOffset.y
//        let xOffset = collectionView!.contentOffset.x
//
//        if let sectionCount = collectionView?.numberOfSections, sectionCount > 0 {
//            for section in 0..<sectionCount {
//                let yPos = CGFloat(section) * cellHeight + ((0 == section) ? yOffset : 0)
//
//                // Confirm the section has items.
//                if let rowCount = collectionView?.numberOfItems(inSection: section), rowCount > 0 {
//                    for item in 0..<rowCount {
//
//                        let xPos = CGFloat(item) * cellWidth + ((0 == item) ? xOffset : 0)
//
//                        // Build indexPath to get attributes from dictionary.
//                         let indexPath = IndexPath(item: item, section: section)
//
//                        // validate x- and y-origin for every cell
//                        if let attrs = itemAttributesCache[indexPath] {
//                            let frame = attrs.frame
//                            if (frame.origin.y != xPos || frame.origin.x != yPos) {
//                                print("\(indexPath): frame.origin \(frame.origin) not at \(xOffset), \(yOffset)")
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    private func fontChangeHandler(_ args: FontChangeEventEmitter, _ sender: Any?) {
//        self.cellAttributes = CellAttributes(font: args.font)
//        self.dataSourceDidUpdate = true
//        self.invalidateLayout()
//    }

    private class CellAttributes {
        public let cellFont : UIFont
        public let cellWidth : CGFloat
        public let cellHeight : CGFloat
        
        init(font: UIFont) {
            self.cellFont = font
            
            let leading = (self.cellFont.leading == 0.0) ? (self.cellFont.lineHeight - self.cellFont.pointSize) : self.cellFont.leading
            self.cellWidth = String(UnicodeScalar(UInt8(32))).size(withAttributes: [NSAttributedStringKey.font: self.cellFont]).width + leading
            self.cellHeight = self.cellFont.lineHeight
        }
    }
}
