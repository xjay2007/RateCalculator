//
//  ViewController.swift
//  TipCalculator
//
//  Created by Xie Jun on 14-6-18.
//  Copyright (c) 2014 xiejun. All rights reserved.
//

import UIKit

let PICKER_VIEW_SHOW_DUARATION: NSTimeInterval = 0.3

class ViewController: UIViewController, XJTRateCalculatorDelegate, UITabBarDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet var inputTextField : XJTextFieldNumber
    @IBOutlet var unitLabel : UILabel
    @IBOutlet var resultsTextView : UITextView
    @IBOutlet var categoryTabBar : UITabBar
    @IBOutlet var unitPickerView : UIPickerView
    
    @IBAction func viewTapped(sender : AnyObject) {
        inputTextField.resignFirstResponder()
        hidePickerView()
    }

    // cached input string
    var cachedInputStr: String = ""
    
    // calculator model
    let model = XJTRateCalculatorModel()
    
    // picker view position init
    var posPickerViewHide: CGPoint = CGPointZero
    var posPickerViewShow: CGPoint = CGPointZero
    var isPickerViewShowing = false
    var isPickerViewShowed = false
    
    //
    func switchUnit(sender: AnyObject) -> Void {
        if self.inputTextField.isFirstResponder() {
            return
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Add notification
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateRateDescription:", name: NOTE_RATE_CALCULATOR_MODEL_RATE_DESCRIPTION_CHANGED, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCategoryIdx:", name: NOTE_RATE_CALCULATOR_MODEL_CATEGORY_CHANGED, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUnitIdx:", name: NOTE_RATE_CALCULATOR_MODEL_UNIT_CHANGED, object: nil)
        
        // navigation bar
        let leftBarButtonItem = self.navigationItem.leftBarButtonItem
        leftBarButtonItem.title = ""
        leftBarButtonItem.target = self
        leftBarButtonItem.action = "switchUnit:"
        
        self.categoryTabBar.selectedItem = categoryTabBar.items[0] as UITabBarItem
        self.model.delegate = self
        self.model.categoryIdx = 0
        self.model.unit = 0
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onXJTextFieldNumberDidChange:", name: XJTextFieldNumber.CONSTANTS.XJTextFieldNumberDidChangeNotification, object: self.inputTextField)
        
        self.unitPickerView.hidden = true
        self.unitPickerView.center = posPickerViewHide
        
    }
    override func viewDidUnload() {
        super.viewDidUnload()
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "ShowRateList" {
            if let rateListVC = segue.destinationViewController as? RateListViewController {
                rateListVC.dataPackage = self.model.dataPackage
            }
        }
    }
    
    /// Logic
    func onXJTextFieldNumberDidChange(note: NSNotification) {
        self.model.inputNumberToCalculate(self.inputTextField.inputNumber)
    }
    
    // UI update
    func updateRateDescription(note: NSNotification) {
        resultsTextView.text = note.userInfo["description"] as String
    }
    func updateCategoryIdx(note: NSNotification) {
        
        let title = note.userInfo["title"] as String
        let category = note.userInfo["category"] as String
        let categoryIdx = category.bridgeToObjectiveC().integerValue
        
        self.navigationItem.title = title
        resultsTextView.text = ""
        
        unitPickerView.hidden = true
        unitPickerView.reloadAllComponents()
    }
    func updateUnitIdx(note: NSNotification) {
        let title = note.userInfo["title"] as String
        let unit = note.userInfo["unit"] as String
        let unitIdx = unit.bridgeToObjectiveC().integerValue
        
        self.unitLabel.text = title + " ="
        self.navigationItem.leftBarButtonItem.title = title
        
        let number = cachedInputStr.bridgeToObjectiveC().doubleValue
        self.model.inputNumberToCalculate(number)
    }
    
    // XJTRateCalculatorDelegate
    func rateCalculator(model: XJTRateCalculatorModel, didChangeRateDescription description: String) {
        resultsTextView.text = description
    }
    func rateCalculator(model: XJTRateCalculatorModel, didChangeCategory categoryIdx: Int, categoryTitle title: String) {
        self.navigationItem.title = title
        resultsTextView.text = ""
        
        unitPickerView.hidden = true
        unitPickerView.reloadAllComponents()
    }
    func rateCalculator(model: XJTRateCalculatorModel, didChangeUnit unitIdx: Int, unitTitle title: String) {
        self.unitLabel.text = title + " ="
        self.navigationItem.leftBarButtonItem.title = title
        
        let number = cachedInputStr.bridgeToObjectiveC().doubleValue
        self.model.inputNumberToCalculate(number)
    }
    
    // UITextFieldDelegate

    // UITabBarDelegate
    func tabBar(tabBar: UITabBar!, didSelectItem item: UITabBarItem!) {
        println("select bar item tag \(item.tag)")
        self.model.categoryIdx = item.tag
        self.model.unit = 0
        self.unitPickerView.selectRow(0, inComponent: 0, animated: false)
    }
    
    //UIPickerViewDataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView!) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int {
        return self.model.unitCount
    }
    
    // UIPickerViewDelegate
    func pickerView(pickerView: UIPickerView!, titleForRow row: Int, forComponent component: Int) -> String!
    {
        return self.model.dataPackage?.title(unitIdx: row)
    }
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int) {
        self.model.unit = row
    }
}

