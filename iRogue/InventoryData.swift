//
//  InventoryItem.swift
//  iRogue
//
//  Created by Michael McGhan on 8/23/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import UIKit

public class InventoryData : InventoryController {
    private let responder: InventoryViewControllerDelegate
    private let service: InventoryService
    
    private var itemsByType: [InventoryItemType : [String : InventoryItem]] = [:]
    
    required public init(ctrlFilterSelector: UISegmentedControl, responder: InventoryViewControllerDelegate, service: InventoryService) {
        self.responder = responder

        ctrlFilterSelector.removeAllSegments()
        ctrlFilterSelector.insertSegment(withTitle: "*", at: 0, animated: false)
        ctrlFilterSelector.selectedSegmentIndex = 0
        
        self.service = service
        self.service.registerController(controller: self)
        
        reset(ctrlFilterSelector)
    }
    
    private func reset(_ ctrlFilterSelector: UISegmentedControl) {
        let types = self.service.getItemTypes()
        for ix in 0..<types.count {
            ctrlFilterSelector.insertSegment(withTitle: types[ix].tag, at: ix+1, animated: false)
            ctrlFilterSelector.setEnabled(false, forSegmentAt: ix+1)
        }

        let items = self.service.getPackItems()
        for item in items {
            self.addItem(id: item.id, item: item)
            self.responder.setEnabled(for: item.type.tag, state: true)
        }
    }
    
    private func findType(by offset: Int) -> InventoryItemType? {
        var count = 0
        
        let types = self.service.getItemTypes()
        for ix in 0..<types.count {
            if let _ = itemsByType[types[ix]] {
                if (count == offset) {
                    return types[ix]
                }
                count += 1
            }
        }
        return nil
    }
    
    private func findType(for tag: String) -> InventoryItemType? {
        for type in itemsByType.keys {
            if (type.tag == tag) {
                return type
            }
        }
        return nil
    }

    private func findItem(by id: String) -> (row: Int, item: InventoryItem)? {
        for type in itemsByType.keys {
            var row = 0
            for (key, item) in itemsByType[type]! {
                if (key == id) {
                    return (row, item)
                }
                row += 1
            }
        }
        return nil
    }
    
    private func addItem(id: String, item: InventoryItem) {
        var list = itemsByType[item.type]
        if (nil == list) {
            list = [id : item]
        }
        else {
            list![id] = item
        }
        itemsByType[item.type] = list
    }


    //MARK: InventoryData
    public func getItemCount(by offset: Int) -> Int {
        if (0 > offset) {
            var total = 0
            for type in itemsByType.keys {
                total += itemsByType[type]!.count
            }
            return total
        }
        else if let type = findType(by: offset) {
            return itemsByType[type]!.count
        }
        return 0
    }
    
    public func getItemCount(for tag: String) -> Int {
        if let type = findType(for: tag) {
            return itemsByType[type]!.count
        }
        return 0
    }
    
    // ToDo: inefficient - improve performance
    private func getItemLabelForType(_ type: InventoryItemType, row: Int) -> String {
        var result: [String] = []
        for (key, item) in itemsByType[type]! {
            result.append(key + ") " + item.getDisplayName())
        }
        return result.sorted()[row]
    }
    
    public func getItemLabel(by offset: Int, row: Int) -> String? {
        if let type = findType(by: offset) {
            return getItemLabelForType(type, row: row)
        }
        return nil
    }
    
    public func getItemLabel(for tag: String, row: Int) -> String? {
        if let type = findType(for: tag) {
            return getItemLabelForType(type, row: row)
        }
        return nil
    }
    
    // number of types currently in pack
    public func getItemTypeCount() -> Int {
        return itemsByType.keys.count
    }

    public func getItemTypeName(by offset: Int) -> String? {
        if let type = findType(by: offset) {
            return type.name
        }
        return nil
    }
    
    public func getItemTypeName(for tag: String) -> String? {
        if let type = findType(for: tag) {
            return type.name
        }
        return nil
    }

    //MARK: InventoryController delegate
    public func add(id: String, item: InventoryItem) {
        if let (_, _) = findItem(by: id) {
            print("unexpected add: items with \(id) is already in the inventory list")
        }
        
        addItem(id: id, item: item)
        self.responder.updateSection(for: item.type.tag)
    }
    
    public func remove(id: String) {
        if let (_, item) = findItem(by: id) {
            itemsByType[item.type]!.removeValue(forKey: id)
            if (itemsByType.count == 0) {
                itemsByType.removeValue(forKey: item.type)
            }
            self.responder.updateSection(for: item.type.tag)
        }
        else {
            print("unexpected remove: no item with \(id) is in the inventory list")
        }
    }
    
    public func updateLabel(id: String, name: String) {
        if let (row, item) = findItem(by: id) {
            item.setDisplayName(name)
            self.responder.updateRowInSection(for: item.type.tag, row: row)
        }
        else {
            print("unexpected update-label: missing item \(id)")
        }
    }
    
    public func setState(id: String, action: String, state: Bool) {
        if let (_, item) = findItem(by: id) {
            item.setState(for: action, state: state)
        }
        else {
            print("unexpected update-state: missing item \(id)")
        }
        // NB: no visual change (i.e. responder); affects command list only
    }
}
