//
//  ChangeHandler.swift
//  iRogue
//
//  Created by Michael McGhan on 5/8/18.
//  Copyright © 2018 MSQR Laboratories. All rights reserved.
//

import Foundation
import UIKit

// protocol for sending events (data updates)
public protocol EventEmitter {
    func notifyHandlers(_ sender: Any?)
}
extension EventEmitter {
    public func notifyHandlers(_ sender: Any?) {
        if let handlers = ChangeEventHandler.getRegistrations(for: self.typeName) {
            for handler in handlers {
                handler.update(sender: sender, eventArgs: self)
            }
            print("\(handlers.count) handlers notified for \(self.typeName)")
        }
        else {
            print("no handlers notified for \(self.typeName)")
        }
    }
    
    public var typeName: String {
        return String(describing: type(of: self))
    }
    public static var typeName: String {
        return String(describing: self)
    }
}

public class ChangeEventHandler {
    fileprivate let key: Int
    
    fileprivate init() {
        key = ChangeEventHandler.getHandlerKey()     // assign unique key to this instance
    }

    // must-override
    public func update(sender: Any?, eventArgs: EventEmitter) {
        fatalError("subclass must implement override method: update")
    }

    // EventHandler support
    private static var handlerKey = 0
    private static func getHandlerKey() -> Int {
        let index = ChangeEventHandler.handlerKey
        ChangeEventHandler.handlerKey += 1
        return index
    }

    // EventEmitter support
    private static var registrations = [String : [WeakRef<ChangeEventHandler>]]()
    
    // see: EventEmitter
    fileprivate static func getRegistrations(for key: String) -> [ChangeEventHandler]? {
        return registrations[key]?.filter{$0.value != nil}.map{$0.value!}
    }
    
    // see: EventHandler<T: EventEmitter>
    fileprivate static func registerHandler(for typeOf : String, handler : ChangeEventHandler) {
        let value = WeakRef(value: handler, key: handler.key)
        if var list = registrations[typeOf] {
            list.append(value)
        }
        else {
            registrations[typeOf] = [value]
        }
    }
    
    fileprivate static func removeHandler(for typeOf : String, key: Int) {
        if let handlers = registrations[typeOf] {
            registrations[typeOf] = handlers.filter{$0.key != key}
        }
    }
    
//    func createEmitter<T : EventEmitter>(forType emitter: T.Type) -> T {
//        return emitter()
//    }
}

public class EventHandler<T : EventEmitter> : ChangeEventHandler {
    private let forType: String
    private let onChange: (_ args: T, _ sender: Any?) -> Void
    
    public init(onChange handler: @escaping (_ args: T, _ sender: Any?) -> Void) {
        self.forType = T.typeName
        self.onChange = handler
        
        super.init()
        
        ChangeEventHandler.registerHandler(for: forType, handler: self)
    }
    
    deinit {
        // ToDo: strong (array) reference prevents this from firing
        ChangeEventHandler.removeHandler(for: self.forType, key: self.key)
    }
    
    private func update(sender: Any?, eventArgs: T) {
        onChange(eventArgs, sender)
    }
    
    public override func update(sender: Any?, eventArgs: EventEmitter) {
        if let args = eventArgs as? T {
            self.update(sender: sender, eventArgs: args)
        }
        else {
            print("invalid type: \(String(describing: eventArgs)), expecting: \(self.forType)")
        }
    }
}
