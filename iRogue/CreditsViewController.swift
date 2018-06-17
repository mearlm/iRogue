//
//  CreditsViewController.swift
//  iRogue
//
//  Created by Michael McGhan on 5/18/18.
//  Copyright © 2018 MSQR Laboratories. All rights reserved.
//

import UIKit

class CreditsViewController: UITableViewController { // UIViewController, UITableViewDataSource, UITableViewDelegate {
    fileprivate let cellIdentifier = "creditCell"
    fileprivate let creditSegueIdentifier = "creditPopover"
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == creditSegueIdentifier,
            let destination = segue.destination as? CreditPopoverViewController,
            let indexPath = self.tableView.indexPathForSelectedRow
        {
            if let credit = self.creditsManager!.getAcknowledgement(for: indexPath.section, row: indexPath.row) {
                destination.toValue = credit.creditTo
                destination.title = credit.creditTo
                destination.titleValue = credit.title
                destination.linkValue = credit.link?.absoluteString
            }
        }
    }
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return creditsManager!.getItemCount(for: section)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return creditsManager!.getSectionCount()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath)
        
        if let credit = self.creditsManager!.getAcknowledgement(for: indexPath.section, row: indexPath.row) {
            myCell.textLabel!.font = self.font!
            myCell.textLabel!.text = credit.creditTo
            myCell.detailTextLabel!.text = credit.title
            myCell.textLabel!.adjustsFontSizeToFitWidth = true
            myCell.textLabel!.minimumScaleFactor = 0.1
        }
        
        return myCell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.creditsManager!.getTitle(for: section)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
    }
}
