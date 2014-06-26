//
//  RateDetailViewController.swift
//  TipCalculator
//
//  Created by JunXie on 14-6-25.
//  Copyright (c) 2014 xiejun. All rights reserved.
//

import UIKit

enum RateDetailViewControllerMode {
    case Add, Edit
}

@objc protocol RateDetailViewControllerDelegate {
    @optional func rateDetailViewController(controller: RateDetailViewController, didAddDataRate dataRate: DataRate)
    @optional func rateDetailViewController(controller: RateDetailViewController, didEditDataRate dataRate: DataRate, atIdx idx: Int)
    @optional func rateDetailViewController(controller: RateDetailViewController, didDeleteDataRate dataRate: DataRate, atIdx idx: Int)
}

class RateDetailViewController: UITableViewController, UIActionSheetDelegate , UIPickerViewDataSource, UIPickerViewDelegate {
    
    /// IB
    @IBOutlet var originWeightTextField : XJTextFieldNumber
    @IBOutlet var originTitleTextField : UITextField
    @IBOutlet var targetWeightTextField : XJTextFieldNumber
    @IBOutlet var targetUnitTitleLabel : UILabel
    @IBOutlet var targetUnitTitleCell : UITableViewCell
    @IBOutlet var clickToSwitchUnitCell : UITableViewCell
    @IBOutlet var deleteButton : UIButton
    
    @IBAction func onDone(sender : AnyObject) {
        
        let unitTitle: String = (originTitleTextField.text != nil && originTitleTextField.text != "") ? originTitleTextField.text : NSLocalizedString("New Rate Title", comment: "")
        let weight = targetWeightTextField.inputNumber != 0.0 ? targetWeightTextField.inputNumber : 1.0
        let unitWeight = (isInverted ? (1.0 / weight) : weight).bridgeToObjectiveC()
        let unit = self.targetUnitIdx.bridgeToObjectiveC()
        println("title = \(unitTitle), weight = \(unitWeight), unit = \(unit)")
        let raw = NSMutableDictionary()
        raw["title"] = unitTitle
        raw["weight"] = unitWeight
        raw["unit"] = unit
        self.dataRate = DataRate(raw: raw)
        
        switch self.mode {
        case .Add:
            self.delegate?.rateDetailViewController?(self, didAddDataRate: self.dataRate)
        case .Edit:
            self.delegate?.rateDetailViewController?(self, didEditDataRate: self.dataRate, atIdx: self.dataRateIdx)
        }
        self.navigationController.popViewControllerAnimated(true)
    }
    
    @IBAction func onSetInverted(sender : UIButton) {
        self.isInverted = !self.isInverted
        
        updateUI()
    }
    @IBAction func onDelete(sender : UIButton) {
        // show the action sheet
        if UIDevice.currentDevice().systemVersion >= "8.0" {
            //
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: UIAlertActionStyle.Destructive, handler: {
                (alertAction: UIAlertAction!) -> Void in
                // handler
                self.deleteRate()
                }))
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            let cancel = NSLocalizedString("Cancel", comment: "Cancel")
            let delete = NSLocalizedString("Delete", comment: "Delete")
            let title = "Action"
            let actionSheet = UIActionSheet()
            actionSheet.delegate = self
            actionSheet.addButtonWithTitle(delete)
            actionSheet.addButtonWithTitle(cancel)
            actionSheet.destructiveButtonIndex = 0
            actionSheet.cancelButtonIndex = 1
            actionSheet.showInView(self.view)
        }
    }
    
    /// UIPickerView
    var posPickerViewHide: CGPoint = CGPointZero
    var posPickerViewShow: CGPoint = CGPointZero
    var isPickerViewShowing = false
    var isPickerViewShowed = false
    var unitPickerView = UIPickerView()
    func switchUnit(sender: AnyObject) -> Void {
        
        if unitPickerView.superview == nil {
            self.view.addSubview(unitPickerView)
        }
        
        let unitPickerViewWidth = unitPickerView.frame.width * 0.5
        let unitPickerViewHeight = unitPickerView.frame.height * 0.5
        posPickerViewHide = CGPointMake(unitPickerViewWidth, self.view.frame.height + unitPickerViewHeight)
        posPickerViewShow = CGPointMake(unitPickerViewWidth, self.view.frame.height - unitPickerViewHeight)
        if !isPickerViewShowed {
            showPickerView()
        } else {
            hidePickerView()
        }
    }
    func showPickerView() {
        if isPickerViewShowing || isPickerViewShowed {
            return
        }
        isPickerViewShowing = true
        unitPickerView.center = posPickerViewHide
        unitPickerView.hidden = false
        UIView.animateWithDuration(PICKER_VIEW_SHOW_DUARATION, animations: {
            self.unitPickerView.center = self.posPickerViewShow
            }, completion: {
                isStop in
                println("isstop = \(isStop), center = \(self.unitPickerView.center)")
                self.isPickerViewShowing = false
                self.isPickerViewShowed = true
            })
        unitPickerView.selectRow(self.targetUnitIdx, inComponent: 0, animated: true)
    }
    func hidePickerView() -> Void {
        if isPickerViewShowing || !isPickerViewShowed {
            return
        }
        isPickerViewShowing = true
        unitPickerView.center = posPickerViewShow
        UIView.animateWithDuration(PICKER_VIEW_SHOW_DUARATION, animations: {
            self.unitPickerView.center = self.posPickerViewHide
            }, completion: {
                isStop in
                println("isstop = \(isStop), center = \(self.unitPickerView.center)")
                self.isPickerViewShowing = false
                self.isPickerViewShowed = false
                self.unitPickerView.hidden = true
            })
    }
    
    /// Mode
    var mode: RateDetailViewControllerMode = .Add {
    didSet {
        var title = ""
        switch mode {
        case .Add: title = "Add Rate"
        case .Edit: title = "Edit Rate"
        }
        self.navigationItem.title = NSLocalizedString(title, comment: "")
    }
    }
    var isInverted = false
    
    /// Rate
    var dataRate: DataRate!
    var dataPackage: DataPackage!
    var targetUnitIdx: Int = 0
    var dataRateIdx: Int = -1
    
    // Delegate
    weak var delegate: RateDetailViewControllerDelegate!
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
        self.unitPickerView.dataSource = self
        self.unitPickerView.delegate = self
        unitPickerView.showsSelectionIndicator = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.dataRate {
            self.targetUnitIdx = self.dataRate.unit
        } else {
            self.targetUnitIdx = self.dataPackage.rawUnit().unit
            let raw: Dictionary<String, AnyObject> = ["title": "", "weight": 1.0.bridgeToObjectiveC(), "unit": self.targetUnitIdx.bridgeToObjectiveC()]
            self.dataRate = DataRate(raw: raw)
        }
        updateUI()
    }
    
    func updateUI() {
        
        //
        originWeightTextField.enabled = isInverted
        originWeightTextField.borderStyle = originWeightTextField.enabled ? .Line : .None
        originWeightTextField.inputNumber = isInverted ? (1.0/self.dataRate.weight) : 1.0
        originTitleTextField.text = self.dataRate.title != "" ? self.dataRate.title : nil
        //
        targetWeightTextField.enabled = !isInverted
        targetWeightTextField.borderStyle = targetWeightTextField.enabled ? .Line : .None
        targetWeightTextField.inputNumber = isInverted ? 1.0 : self.dataRate.weight
        targetUnitTitleLabel.text = self.dataPackage.title(unitIdx: self.targetUnitIdx)
        
        //
        deleteButton.hidden = (self.mode == .Add)
    }
    
    func deleteRate() {
        self.delegate?.rateDetailViewController?(self, didDeleteDataRate: self.dataRate, atIdx: self.dataRateIdx)
        self.navigationController.popViewControllerAnimated(true)
    }
    
    func resignTextFieldsFirstResponder() {
        
        originWeightTextField.resignFirstResponder()
        originTitleTextField.resignFirstResponder()
        targetWeightTextField.resignFirstResponder()
        if isPickerViewShowed {
            hidePickerView()
        }
    }

    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        
        resignTextFieldsFirstResponder()
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell == targetUnitTitleCell || cell == clickToSwitchUnitCell {
                // show unit switch
                println("click to switch")
                switchUnit(self)
            } else {
                // some thing else
            }
        }
    }
    // UIActionSheetDelegate
    func actionSheet(actionSheet: UIActionSheet!, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex == actionSheet.destructiveButtonIndex {
            deleteRate()
        }
    }
    
    // UIPickerViewDataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView!) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int {
        return self.dataPackage.count
    }
    func pickerView(pickerView: UIPickerView!, titleForRow row: Int, forComponent component: Int) -> String! {
        let dataRate = self.dataPackage[row] as DataRate
        return dataRate.title
    }
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int) {
        self.targetUnitIdx = row
        targetUnitTitleLabel.text = self.dataPackage.title(unitIdx: self.targetUnitIdx)
    }
}
