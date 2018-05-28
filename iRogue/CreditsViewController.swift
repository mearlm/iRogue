//
//  CreditsViewController.swift
//  iRogue
//
//  Created by Michael McGhan on 5/18/18.
//  Copyright © 2018 MSQR Laboratories. All rights reserved.
//

import UIKit

class CreditsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    fileprivate let cellIdentifier = "creditsCell"
    fileprivate let font = UIFont(name: "Courier", size: 18.0)
    
    private weak var creditsManager: CreditsControllerService?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let creditsManager = appDelegate.game?.getCreditsManager() else {
            fatalError("Credits Manager Service Unavailable.")
        }
        self.creditsManager = creditsManager
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return creditsManager!.getItemCount(for: section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return creditsManager!.getSectionCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath)
        
        if let label = self.creditsManager!.getLabel(for: indexPath.section, row: indexPath.row) {
            
            myCell.textLabel!.font = self.font!
            myCell.textLabel!.text = label
            myCell.textLabel!.adjustsFontSizeToFitWidth = true
            myCell.textLabel!.minimumScaleFactor = 0.1
        }
        
        // myCell.accessoryType = UITableViewCellAccessoryType.detailButton
        
        return myCell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.creditsManager!.getTitle(for: section)
    }
}
