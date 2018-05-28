//
//  MenuViewController.swift
//  iRogue
//
//  Created by Michael McGhan on 9/28/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import Foundation
import UIKit

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var viewMainMenu: UITableView!
    fileprivate let cellIdentifier = "mainMenuCell"
    
    typealias Func = (UIAlertAction) -> Void
    
    // ToDo: get commands from GameEngine/model?
    private let COMMANDS = [
        "create object",
        "teleport"
    ]
    
    // ToDo: refactor to use command interface of InventoryControllerService
    private weak var toolsService: ToolsControllerService?
    private weak var dungeonService: DungeonControllerService?
    
    private var handlers = [ChangeEventHandler]()

    //MARK: UIViewController lifecycle
    // ToDo: convert to a slide-OVER menu; disable all? other game controls when open
    override func viewDidLoad() {
        super.viewDidLoad()

        // register callbacks for message-event handlers (observers)
        handlers.append(EventHandler<ToolsMessageEventEmitter>(onChange: {(_ args: ToolsMessageEventEmitter,_ sender: Any?) in
            let alertController = UIAlertController(title: "Message", message: args.message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }))

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let toolsService = appDelegate.game?.getToolsManager() else {
            fatalError("Tools Service Unavailable.")
        }
        self.toolsService = toolsService
        guard let dungeonService = appDelegate.game?.getDungeonManager() else {
            fatalError("Dungeon Service Unavailable.")
        }
        self.dungeonService = dungeonService
        
//        viewMainMenu.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
//        viewMainMenu.delegate = self
//        viewMainMenu.dataSource = self
        
        viewMainMenu.reloadData();
        print("MainMenuViewController did load")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedCell = tableView.cellForRow(at: indexPath) {
            switch selectedCell.textLabel!.text!.lowercased() {
            case COMMANDS[0]:
                let types = self.toolsService!.getItemTypesNames()
                chooseCommand(commands: types,
                              selectedCell: selectedCell,
                              processor: (self.toolsService!.processCreateObjectCommand(action:)))
                break;
            case COMMANDS[1]:
                dungeonService!.teleportHero()
                break
            default:
                break
            }
        }
    }
    
    //MARK: UITableViewDataSource    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return COMMANDS.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel!.text = COMMANDS[indexPath.row].capitalized
        return cell
    }

    // private implementation
    private func chooseCommand(commands: [String], selectedCell: UITableViewCell, processor: @escaping Func) {
        let alertController = UIAlertController(title: "Item Type", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (result : UIAlertAction) -> Void in
            print("Cancelled")
        }
        alertController.addAction(cancelAction)
        
        for command in commands {
            let action = UIAlertAction(title: command, style: .default) { (result : UIAlertAction) -> Void in
                processor(result)
            }
            alertController.addAction(action)
        }
        
        if let presenter = alertController.popoverPresentationController {
            presenter.sourceView = selectedCell
            presenter.sourceRect = selectedCell.bounds
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
}
