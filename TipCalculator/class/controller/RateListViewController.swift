//
//  RateListViewController.swift
//  TipCalculator
//
//  Created by JunXie on 14-6-23.
//  Copyright (c) 2014 xiejun. All rights reserved.
//

import Foundation
import UIKit

class RateListViewController: UITableViewController, RateDetailViewControllerDelegate {
    
    // Data
    var dataPackage: DataPackage!
    
    /// prepared
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "AddRate" || segue.identifier == "EditRate" {
            if let rateDetailVC = segue.destinationViewController as? RateDetailViewController {
                rateDetailVC.dataPackage = self.dataPackage
                rateDetailVC.delegate = self
                if segue.identifier == "AddRate" {
                    // Add
                    rateDetailVC.mode = .Add
                } else if segue.identifier == "EditRate" {
                    // Edit
                    rateDetailVC.mode = .Edit
                    if let cell = sender as? UITableViewCell {
                        if let indexPath = self.tableView.indexPathForCell(cell) {
                            if let dataRate = self.dataPackage?[indexPath.row] {
                                rateDetailVC.dataRate = dataRate
                                rateDetailVC.dataRateIdx = indexPath.row
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// RateDetailViewControllerDelegate
    func rateDetailViewController(controller: RateDetailViewController, didAddDataRate dataRate: DataRate) {
        if self.dataPackage.addDataRate(dataRate) {
            self.tableView.reloadData()
        }
    }
    func rateDetailViewController(controller: RateDetailViewController, didEditDataRate dataRate: DataRate, atIdx idx: Int) {
        if self.dataPackage.editDataRate(dataRate, atIdx: idx) {
            self.tableView.reloadData()
        }
    }
    func rateDetailViewController(controller: RateDetailViewController, didDeleteDataRate dataRate: DataRate, atIdx idx: Int) {
        if self.dataPackage.deleteDataRate(atIdx: idx) {
            self.tableView.reloadData()
        }
    }
    
    // 
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.dataPackage.count
    }
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("RateCell") as UITableViewCell
        if let dataPackage = self.dataPackage {
            if let dataRate: DataRate = dataPackage[indexPath.row] {
                let title = dataRate.title
                let weight = dataRate.weight
                let unitTitle = dataPackage.title(unitIdx: dataRate.unit)
                cell.textLabel.text = "1 \(title)"
                cell.detailTextLabel.text = "= \(weight) \(unitTitle)"
                
                // change the raw color
                let textColor = dataPackage.isRawUnit(unitIdx: indexPath.row) ? UIColor.redColor() : nil
                cell.textLabel.textColor = textColor
                cell.detailTextLabel.textColor = textColor
            }
        }
        return cell
    }
    override func tableView(tableView: UITableView!, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath!) {
        println("\(indexPath.row)")
        if let tableCell = tableView.cellForRowAtIndexPath(indexPath) {
            if self.dataPackage?.isRawUnit(unitIdx: indexPath.row) == false {
                performSegueWithIdentifier("EditRate", sender: tableCell)
            }
        }
    }
}