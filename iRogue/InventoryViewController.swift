//
//  InventoryViewController.swift
//  iRogue
//
//  Created by Michael McGhan on 7/29/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import UIKit

protocol InventoryViewControllerDelegate: class {
    func updateCount(number: Int, sender: InventoryData?)
}

class InventoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: Properties
    @IBOutlet weak var ctrlFilterSelector: UISegmentedControl!
    @IBOutlet weak var viewInventoryList: UITableView!
    
    fileprivate let cellIdentifier = "inventoryCell"
    
    var data: InventoryData?
    
    weak var delegate: InventoryViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let font = UIFont.systemFont(ofSize: 16)
        ctrlFilterSelector.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        
        self.loadData()
        
        viewInventoryList.reloadData();
        print("InventoryViewController did load")
    }

    func loadData() {
        // ToDo: for now, show some random sample data
        data = SampleData(ctrlFilterSelector: ctrlFilterSelector, responder: delegate!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func tagForSection(_ section: Int) -> String {
        return ctrlFilterSelector.titleForSegment(at: section + 1)!
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sectionList = data?.getItems(forTag: tagForSection(section)) {
            return sectionList.count
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data?.getItemTypeCount() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath)
        myCell.textLabel!.text = data?.getItems(forTag: tagForSection(indexPath.section))?[indexPath.row]
        
        // switch(ctrlFilterSelector.selectedSegmentIndex)
        
        return myCell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.data?.getTypeName(forTag: tagForSection(section))
    }
    
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
}
