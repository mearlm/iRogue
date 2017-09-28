//
//  InventoryViewController.swift
//  iRogue
//
//  Created by Michael McGhan on 7/29/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import UIKit

public protocol InventoryViewControllerDelegate: class {
    func updateRowInSection(for tag: String, row: Int)
    func updateSection(for tag: String)
    func setEnabled(for tag: String, state: Bool)
}

public protocol InventoryControllerDelegate: class {
    func updateCount(number: Int)
}

class InventoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, InventoryViewControllerDelegate {

    //MARK: Properties
    @IBOutlet weak var ctrlFilterSelector: UISegmentedControl!
    @IBOutlet weak var viewInventoryList: UITableView!
    
    fileprivate let cellIdentifier = "inventoryCell"
    fileprivate let font = UIFont(name: "Courier", size: 18.0)
    
    private var data: InventoryData?
    weak var delegate: InventoryControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // let font = UIFont.systemFont(ofSize: 18)
        ctrlFilterSelector.setTitleTextAttributes([NSFontAttributeName: self.font!], for: .normal)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        data = InventoryData(ctrlFilterSelector: ctrlFilterSelector, responder: self, service: appDelegate.game!.getInventoryService())
        
        delegate?.updateCount(number: data?.getItemCount(by: -1) ?? 0)
        
        viewInventoryList.reloadData();
        print("InventoryViewController did load")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func tagForSection(_ section: Int) -> String {
        return ctrlFilterSelector.titleForSegment(at: section + 1)!
    }
    
    private func sectionForTag(_ tag: String) -> Int? {
        for ix in 1..<ctrlFilterSelector.numberOfSegments {
            if (tag == ctrlFilterSelector.titleForSegment(at: ix)) {
                if (showAllSections()) {
                    return ix - 1
                }
                else if (isFilteredSelection(ix-1)) {
                    return 0
                }
            }
        }
        return nil
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
        if (showAllSections()) {
            return data?.getItemCount(by: section) ?? 0
        }
        return data?.getItemCount(for: selectedTag()) ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (showAllSections()) {
            return (data?.getItemTypeCount() ?? 0)
        }
        return (0 < data?.getItemCount(for: selectedTag()) ?? 0) ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath)
        myCell.textLabel?.font = self.font!

        if (showAllSections()) {
            myCell.textLabel!.text = data?.getItemLabel(by: indexPath.section, row: indexPath.row)
        }
        else {
            myCell.textLabel!.text = data?.getItemLabel(for: selectedTag(), row: indexPath.row)
        }
        myCell.accessoryType = UITableViewCellAccessoryType.detailButton
        
        return myCell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (showAllSections()) {
            return self.data?.getItemTypeName(by: section)
        }
        else if let name = data?.getItemTypeName(for: selectedTag()) {
            return name
        }
        return nil
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
    // make the filter work
    // indent the items below the headings
    // color headings
    // enable name change ("call")
    // enable item-dependent actions: use(wear, quaff, read, zap, etc.), unuse?, throw?;
    //    and item-independent actions: drop
    
    //MARK: InventoryViewControllerDelegate
    public func updateRowInSection(for tag: String, row: Int) {
        if let section = sectionForTag(tag) {
            let indexPath = IndexPath(row: row, section: section)
            viewInventoryList.reloadRows(at: [indexPath], with: .top)
        }
    }
    
    public func updateSection(for tag: String) {
        if let _ = sectionForTag(tag) {
            viewInventoryList.reloadData()
        }
        setEnabled(for: tag, state: 0 < (data?.getItemCount(for: tag) ?? 0))
        delegate?.updateCount(number: data?.getItemCount(by: 0) ?? 0)
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
