//
//  MenuViewController.swift
//  iRogue
//
//  Created by Michael McGhan on 9/28/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import Foundation
import UIKit

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GameEventHandler {
    @IBOutlet weak var viewMainMenu: UITableView!
    fileprivate let cellIdentifier = "mainMenuCell"
    
    typealias Func = (UIAlertAction) -> Void
    
    private let COMMANDS = [
        "create object"
    ]
    
    // ToDo: refactor to use command interface of InventoryControllerService
    private weak var toolsService: ToolsControllerService?

    //MARK: UIViewController lifecycle    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        toolsService = appDelegate.getProtocolHandler(for: ServiceKey.ToolsService, delegate: self)
        
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
                if let types = toolsService?.getItemTypesNames() {
                    chooseCommand(commands: types,
                                  selectedCell: selectedCell,
                                  processor: (self.toolsService?.processCreateObjectCommand(action:))!)
                }
                break;
            default:
                break;
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
    
    // MARK: GameEventHandler
    func update(sender: Any?, eventArgs: GameEventArgs) {
        if let args = eventArgs as? ToolMessageArgs {
            let alert = UIAlertController(title: args.message, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
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
