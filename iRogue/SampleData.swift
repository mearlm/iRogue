//
//  SampleData.swift
//  iRogue
//
//  Created by Michael McGhan on 8/12/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import UIKit

// ToDo: move to own class file
protocol InventoryData {
    init(ctrlFilterSelector: UISegmentedControl)
    
    func getItems(forTag: String) -> [String]?
    func getTypeName(forTag: String) -> String?
}

class SampleData : InventoryData {
    static let sampleItemsByTag: [(tag: String, type: String, data: Array<String>)] = [
        (":", "food", ["slime-mold", "food"]),
        ("]", "armor", ["plate mail", "chain mail", "leather armor", "studded leather armor", "scale mail", "split mail", "banded mail"]),
        (")", "weapon", ["two handed sword", "long sword", "mace", "spear", "short bow", "dagger", "dart"]),
        ("!", "potion", ["healing", "blindness", "see invisible", "gain strength"]),
        ("?", "scroll", ["scare monster", "remove curse", "aggravate monsters", "enchant armor"]),
        ("/", "stick", ["lightening", "haste monster", "nothing", "slow monster", "striking"]),
        ("=", "ring", ["protection", "add strength", "see invisible", "adornment"]),
        (",", "amulet", [])
    ]
    
    var itemListByItemType = [String: (type: String, values: Dictionary<String, Int>)]()
    
    //MARK: public interface

    required init(ctrlFilterSelector: UISegmentedControl) {
        ctrlFilterSelector.removeAllSegments()
        ctrlFilterSelector.insertSegment(withTitle: "*", at: 0, animated: false)
        
        for (tag, type, data) in SampleData.sampleItemsByTag {
            let index = ctrlFilterSelector.numberOfSegments
            ctrlFilterSelector.insertSegment(withTitle: tag, at: index, animated: false)
            
            if (!data.isEmpty) {
                var count = random(3)
                if (!isPSRS(type)) {
                    count += 1
                }
                
                var result: [String: Int] = [:]
                for _ in 0..<count {
                    if (getSampleItemsForSegment(ofType: type, data: data, result: &result)) {
                        result["arrow"] = random(20) + 1
                    }
                }

                if (!result.isEmpty) {
                    itemListByItemType[tag] = (type, result)
                }
            }
        }
    }
    
    public func getItems(forTag: String) -> [String]? {
        if let (type, itemsForType) = itemListByItemType[forTag] {
            var result: [String] = []
            
            for name in itemsForType.keys {
                let count = itemsForType[name]
                result.append(getValue(type: type, name: name, count: count!))
            }
            
            return result
        }
        return nil
    }
    
    public func getTypeName(forTag: String) -> String? {
        if let (type, _) = itemListByItemType[forTag] {
            return type;
        }
        return nil
    }
    
    //MARK: private implementation
    
    private func isPSRS(_ type: String) -> Bool {
        switch (type) {
        case "potion", "scroll", "ring", "stick":
            return true;
        default:
            return false;
        }
    }
    
    private func getValue(type: String, name: String, count: Int) -> String {
        let ispsrs = isPSRS(type)
        
        if (count > 1) {
            if (ispsrs) {
                if (name.hasPrefix("of ")) {
                    // e.g. 3 potions of healing
                    return String(count) + " " + asPlural(type) + " " + name
                }
                else {
                    // e.g. 2 diamond rings
                    return String(count) + " " + name + " " + asPlural(type)
                }
            }
            else {
                // 2 slime-molds
                return String(count) + " " + asPlural(name)
            }
        }
        else {
            if (ispsrs) {
                if (name.hasPrefix("of ")) {
                    // a scroll of xyzzy
                    return withArticle(type) + " " + name
                }
                else {
                    // an oak staff
                    return withArticle(name) + " " + type
                }
            }
            else {
                return withArticle(name)
            }
        }
    }

    private func getSampleItemsForSegment(ofType type: String, data: Array<String>, result: inout [String: Int]) -> Bool {
        var name: String?
        
        if let selected = randomItem(data) {
            switch (type) {
            case "potion":
                name = psrsName(selected, choices: ["green", "aquamarine", "red", "black", "white", "brown"])
                break
            case "ring":
                name = psrsName(selected, choices: ["onyx", "diamond", "amethyst", "opal", "ruby", "sapphire"])
                break
            case "scroll":
                name = psrsName(selected, choices: ["xyzzy", "foobar", "fasjfelja", "zjvzvdue", "uoupvjzvjfe"])
                break
            case "stick":
                name = (1 == random(2))
                    ? psrsName(selected, choices: ["gold", "bronze", "iron"])
                    : psrsName(selected, choices: ["oak", "teak", "walnut"])
                break
            default:
                name = selected
                break
            }
        
            let count = result[name!]
            result[name!] = (count ?? 0) + 1
        }
        return name == "short bow"
    }
    
    private func psrsName(_ result: String, choices: [String]) -> String {
        if (1 == random(2)) {
            return "of " + result
        }
        else {
            return randomItem(choices)!
        }
    }

    private func randomItem(_ items: Array<String>) -> String? {
        if (items.isEmpty) {
            return nil;
        }
        return items[random(items.count)]
    }
    
    // return a value from 0 to limit-1
    private func random(_ limit: Int) -> Int {
        // encapsulate the foolishness...
        return Int(arc4random_uniform(UInt32(limit)))
    }

    // ToDo: String extensions
    private func withArticle(_ forString: String) -> String {
        let prefix = String(forString.lowercased().characters.prefix(1))
        let vowels: Set<String> = ["a", "e", "i", "o", "u"]
        if (vowels.contains(prefix)) {
            return "an " + forString + " "
        }
        return "a " + forString + " "
    }

    private func asPlural(_ forString: String) -> String {
        if (forString == "food") {
            return forString
        }
        return forString + "s"
    }
}

