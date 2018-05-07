//
//  InventoryViewController.swift
//  iRogue
//
//  Created by Michael McGhan on 7/29/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import UIKit

public protocol InventoryCountDelegate: class {
    func updateInventoryCount(number: String)       // update item count shown on button
}

class InventoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GameEventHandler {
    //MARK: Properties
    @IBOutlet weak var ctrlFilterSelector: UISegmentedControl!
    @IBOutlet weak var viewInventoryList: UITableView!
    
    fileprivate let cellIdentifier = "inventoryCell"
    fileprivate let font = UIFont(name: "Courier", size: 18.0)
    
    private weak var inventory: InventoryControllerService?
    weak var delegate: InventoryCountDelegate?          // set in segue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // let font = UIFont.systemFont(ofSize: 18)
        ctrlFilterSelector.setTitleTextAttributes([NSAttributedStringKey.font: self.font!], for: .normal)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        inventory = appDelegate.getProtocolHandler(for: ServiceKey.InventoryService, delegate: self)
        
        if let types = inventory?.getItemTypesNames() {
            reset(types: types)
        }
        delegate?.updateInventoryCount(number: String(inventory!.getTotalItemCount()))
        
        viewInventoryList.reloadData();
        print("InventoryViewController did load")
    }
    
    //MARK:  EventHandler
    public func update(sender: Any?, eventArgs: GameEventArgs) {
        if let args = eventArgs as? SetEnabledArgs {
            setEnabled(for: args.tag, state: args.state)
        }
        else if let args = eventArgs as? UpdateRowInSectionArgs{
            updateRowInSection(for: args.tag, row: args.row)
        }
        else if let args = eventArgs as? UpdateSectionArgs {
            updateSection(for: args.tag, preexisting: args.preexisting)
        }
    }
    
    private func reset(types: [String]) {
        ctrlFilterSelector.removeAllSegments()
        if (types.count > 0) {
            var ix = 0
            for type in types {
                ctrlFilterSelector.insertSegment(withTitle: type, at: ix, animated: false)
                ix += 1
            }
            ctrlFilterSelector.selectedSegmentIndex = 0
            ctrlFilterSelector.setEnabled(true, forSegmentAt: 0)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func showAllSections() -> Bool {
        return (ctrlFilterSelector.selectedSegmentIndex <= 0)
    }
    
    private func isFilteredSelection(_ section: Int) -> Bool {
        if let selected = indexPathSelection() {
            return (section == selected)
        }
        return false
    }
    
    private func indexPathSelection() -> Int? {
        let selection = ctrlFilterSelector.selectedSegmentIndex
        guard (0 < selection) else {
            return nil
        }
        return selection - 1
    }
    
    private func selectedTag() -> String {
        return ctrlFilterSelector.titleForSegment(at: ctrlFilterSelector.selectedSegmentIndex) ?? ""
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tag = selectedTag()
        let result = inventory?.getItemRowCount(for: tag, offset: section) ?? 0
        print("showing showing \(result) rows for \(tag) [section \(section)]")
        return result
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var result = 0
        if (showAllSections()) {
            result = (inventory?.getItemTypeCount() ?? 0)
        }
        else {
            result = (inventory?.hasItems(for: selectedTag()) ?? false) ? 1 : 0
        }
        print("showing \(result) sections")
        return result
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath)

        if let result = inventory?.getItemLabel(for: selectedTag(), offset: indexPath.section, row: indexPath.row) {

            myCell.textLabel!.font = self.font!
            myCell.textLabel!.text = "\(result.id)) " + result.label
            myCell.textLabel!.adjustsFontSizeToFitWidth = true
            myCell.textLabel!.minimumScaleFactor = 0.1
        }

        // myCell.accessoryType = UITableViewCellAccessoryType.detailButton
        
        return myCell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let name = inventory?.getItemTypeName(for: selectedTag(), offset: section) {
            return name
        }
        return nil
    }
    
    private func addCommandAction(controller: UIAlertController, command: String, option: String?, style: UIAlertActionStyle, indexPath: IndexPath) {
        let title = (nil == option) ? command : (command + " " + option!)
        let action = UIAlertAction(title: title.capitalized, style: style) { (result : UIAlertAction) -> Void in
            // all commands process via a single (inventory) command processor interface
            self.inventory?.doAction(for: self.selectedTag(),
                             offset: indexPath.section,
                             row: indexPath.row,
                             command: command,
                             option: option
            )
        }
        controller.addAction(action)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let actionNames = inventory?.getActions(for: selectedTag(), offset: indexPath.section, row: indexPath.row),
            let selectedCell = tableView.cellForRow(at: indexPath) {
            
            if let result = inventory?.getItemLabel(for: selectedTag(), offset: indexPath.section, row: indexPath.row) {
                let alertController = UIAlertController(title: "Available Actions", message: result.label, preferredStyle: UIAlertControllerStyle.alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
                    print("Cancelled")
                }
                alertController.addAction(cancelAction)

                for pair: (name: String, options: [String]?) in actionNames {
                    if let options = pair.options {
                        for option in options {
                            addCommandAction(controller: alertController, command: pair.name, option: option, style: UIAlertActionStyle.default, indexPath: indexPath)
                        }
                    }
                    else {
                        addCommandAction(controller: alertController, command: pair.name, option: nil, style: UIAlertActionStyle.default, indexPath: indexPath)
                    }
                }
                addCommandAction(controller: alertController, command: "drop", option: nil, style: UIAlertActionStyle.destructive, indexPath: indexPath)

                if let presenter = alertController.popoverPresentationController {
                    presenter.sourceView = selectedCell
                    presenter.sourceRect = selectedCell.bounds
                }
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // alternating list background colors...
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if (indexPath.row % 2 == 0) {
//            let altCellColor = UIColor(white:0.7, alpha:0.25)
//            cell.backgroundColor = altCellColor;
//        }
//    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return tableView.rowHeight * 1.2
//    }
//    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let title = UILabel()
//        if (showAllSections()) {
//            title.text = self.data?.getItemTypeName(by: section)
//        }
//        else if let name = data?.getItemTypeName(for: selectedTag()) {
//            title.text = name
//        }
//        title.numberOfLines = 1
//        title.textAlignment = .center
//        title.backgroundColor = UIColor.init(red: 0.88, green: 0.88, blue: 0.88, alpha: 1.0)
//        
//        return title
//    }
    
    //MARK: Actions    
    @IBAction func filterChanged(_ sender: UISegmentedControl) {
        viewInventoryList.reloadData()
    }
    
    // ToDo:
    // enable name change ("call")
    
    //MARK: InventoryViewControllerDelegate
    public func updateRowInSection(for tag: String, row: Int) {
        if (showAllSections() || selectedTag() == tag) {
            if let section = (showAllSections()) ? inventory!.findSection(for: tag) : 0 {
                let indexPath = IndexPath(row: row, section: section)
                print("updating inventory row \(row) in section \(section) with tag \(tag)")
                viewInventoryList.reloadRows(at: [indexPath], with: .middle)
            }
        }
    }
    
    public func updateSection(for tag: String, preexisting: Bool) {
        if (!inventory!.hasItems(for: tag) || !preexisting) {
            print("reloading inventory view [preexisting=\(preexisting)]")
            viewInventoryList.reloadData()
        }
        else if let section = (showAllSections()) ? inventory!.findSection(for: tag) : 0 {
            print("updating inventory section \(section) for tag \(tag)")
            viewInventoryList.reloadSections(IndexSet(integer: section), with: .middle)
        }
        setEnabled(for: tag, state: inventory?.hasItems(for: tag) ?? false)
        let count = inventory?.getTotalItemCount() ?? 0
        delegate?.updateInventoryCount(number: String(count))
    }
    
    public func setEnabled(for tag: String, state: Bool) {
        for ix in 1..<ctrlFilterSelector.numberOfSegments {
            if (tag == ctrlFilterSelector.titleForSegment(at: ix)) {
                ctrlFilterSelector.setEnabled(state, forSegmentAt: ix)
                break
            }
        }
    }
}
