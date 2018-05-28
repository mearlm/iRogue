//
//  OptionsManager.swift
//  iRogue
//
//  Created by Michael McGhan on 5/14/18.
//  Copyright © 2018 MSQR Laboratories. All rights reserved.
//

import Foundation
import UIKit

public class OptionsManager : OptionsControllerService, OptionsDataService {
    private var defaults = [String : Any]()
    private var preferences = [String : Any?]()
    private let null: Any? = nil
    private var isInitialized = false
    
    public init() {
        let pathStr = URL(fileURLWithPath: Bundle.main.path(forResource: "Settings", ofType: "bundle")!)
        loadDefaults(for: "Root", at: pathStr)  // initialize the self.preferences keys
        
        UserDefaults.standard.register(defaults: defaults)
        NotificationCenter.default.addObserver(self, selector: #selector(preferencesChanged), name: UserDefaults.didChangeNotification, object: nil)

        // ToDo: can defer this to e.g. GameViewController.viewDidLayoutSubviews()
        // and use updates to initialize option values
        // (rather than directed calls to the various Managers), if desired
        setPreferences()                        // initialize the self.preferences values
    }
    
    private func getSettings(for file: String, at path: URL) -> NSArray {
        let plistFullName = String(format: "%@.plist", file);
        let finalPath = path.appendingPathComponent(plistFullName).path
        // finalPath    String    "~/Library/Developer/CoreSimulator/Devices/95A1E3A3-57AF-4D6B-BCF4-266EEEE4D402/data/Containers/Bundle/Application/AB06EC42-0C46-4E1F-84BA-62694AFDD480/iRogue.app/Settings.bundle/Root.plist"
        let settingsDict = NSDictionary(contentsOfFile: finalPath)
        return settingsDict?.object(forKey: "PreferenceSpecifiers") as! NSArray
    }
    
    // load defaults from bundle and register [recursive]
    private func loadDefaults(for file: String, at path: URL) {
        let values = getSettings(for: file, at: path)

        for case let item as NSDictionary in values {
            let type = item.object(forKey: "Type") as? String ?? "missing-type"
            print("item type: \(type)")
            
            if type == "PSChildPaneSpecifier" {
                if let filename = item.object(forKey: "File") as? String {
                    loadDefaults(for: filename, at: path)
                }
            }
            else if let key = item.object(forKey: "Key") as? String {
                self.preferences[key] = self.null   // insert placeholder for key
                if let defaultValue = item.object(forKey: "DefaultValue") {
                    self.defaults[key] = defaultValue
                }
            }
            else {
                print("ignoring default: \(String(describing: item.object))")
            }
        }
    }
    
    @objc private func preferencesChanged(_ notification: Notification) {
        print("preferences changed")
        if (self.isInitialized) {
            self.setPreferences()
        }
    }

    private func areEqual(old: Any?, new: Any) -> Bool {
        switch(String(describing: type(of: new))) {
        case "String":
            return old != nil && (new as! String == old as! String)
        case "Double":
            return old != nil && (new as! Double == old as! Double)
        case "Int":
            return old != nil && (new as! Int == old as! Int)
        default:
            return true
        }
    }
    
    public func setPreferences() {
        let prefs = UserDefaults.standard.dictionaryRepresentation()
//        let filtered = prefs.filter { defaults.keys.contains($0.key) }

        for (key, value) in self.preferences {
            var isChanged = false
            if let newval = prefs[key] {
                if let oldval = value {
                    if (!areEqual(old: oldval, new: newval)) {
                        self.preferences[key] = newval
                        isChanged = self.isInitialized
                    }
                }
                else {      // added
                    self.preferences[key] = newval
                    isChanged = self.isInitialized
                }
            }
            else {
                // deleted (should not happen)
                self.preferences[key] = self.null   // reset to placeholder
                isChanged = self.isInitialized
            }
            
            if (isChanged) {
                print("\(key) value changed")
                
                switch (key) {
                case "font_preference", "font_size_preference":
                    _ = FontChangeEventEmitter(font: getDungeonFont()!).notifyHandlers(self)
                    break
                case "user_name", "version_preference":
                    break       // ignored for now...
                default:
                    break       // otherwise -- ignored
                }
            }
        }
        printPreferences()
        self.isInitialized = true               // begin firing change events...
    }
    
    deinit { //Not needed for iOS9 and above. ARC deals with the observer in higher versions.
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: OptionsDataService Implementation
    public func getVersion() -> String {
        if let version = UserDefaults.standard.string(forKey: "version_preference") {
            return version
        }
        return "SampleData"
    }
    
    public func getDungeonFont() -> UIFont? {
        let size = round(UserDefaults.standard.float(forKey: "font_size_preference"))   // 1 - 5
        
        let fontsize : CGFloat = 15.0 + CGFloat(size) * 5.0
        let fontname = UserDefaults.standard.value(forKey: "font_preference") as? String ?? "Courier"

        return UIFont(name: fontname, size: fontsize)!.fontWithBold()
    }
    
    private func isChanged(_ item: (key: String, value: Any)) -> Bool {
        //return (item.value.before !== item.value.after)
        return true
    }
    
    private func printPreferences() {
        for (key, value) in self.preferences {
            print("\(key) = \(String(describing: value))")
        }
    }
}
