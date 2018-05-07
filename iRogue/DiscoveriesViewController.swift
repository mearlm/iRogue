//
//  DiscoveriesViewController.swift
//  iRogue
//
//  Created by Michael McGhan on 9/28/17.
//  Copyright © 2017 MSQR Laboratories. All rights reserved.
//

import Foundation
import UIKit

class DiscoveriesViewController: UITableViewController {
    
    //MARK: UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "discoveriesCell", for: indexPath)
        configureCell(cell: cell, forRowAt: indexPath)
        return cell
    }
    
    private func configureCell(cell: UITableViewCell, forRowAt: IndexPath) {
        
    }
    
    //MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
