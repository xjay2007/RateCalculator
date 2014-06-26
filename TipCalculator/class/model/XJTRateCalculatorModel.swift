//
//  XJTRateCalculatorModel.swift
//  TipCalculator
//
//  Created by JunXie on 14-6-19.
//  Copyright (c) 2014 xiejun. All rights reserved.
//

import Foundation

//let NOTE_RATE_CALCULATOR_MODEL_RATE_DESCRIPTION_CHANGED = "NOTE_RATE_CALCULATOR_MODEL_RATE_DESCRIPTION_CHANGED"
//let NOTE_RATE_CALCULATOR_MODEL_CATEGORY_CHANGED = "NOTE_RATE_CALCULATOR_MODEL_CATEGORY_CHANGED"
//let NOTE_RATE_CALCULATOR_MODEL_UNIT_CHANGED = "NOTE_RATE_CALCULATOR_MODEL_UNIT_CHANGED"

@objc protocol XJTRateCalculatorDelegate {
    @optional func rateCalculator(model: XJTRateCalculatorModel, didChangeRateDescription description: String)
    @optional func rateCalculator(model: XJTRateCalculatorModel, didChangeCategory categoryIdx: Int, categoryTitle title: String)
    @optional func rateCalculator(model: XJTRateCalculatorModel, didChangeUnit unitIdx: Int, unitTitle title: String)
}

@objc class XJTRateCalculatorModel {
    
//    class func sharedInstance() -> XJTRateCalculatorModel! {
//        struct Static {
//            static var instance: XJTRateCalculatorModel? = nil
//            static var onceToken: dispatch_once_t = 0
//        }
//        dispatch_once(&Static.onceToken) {
//            Static.instance = self()
//        }
//        return Static.instance!
//    }
//    @required init() {
//        
//    }
    init() {
        
    }
    //
    weak var delegate: XJTRateCalculatorDelegate!
    
    // data 
    var dataPackage: DataPackage? {
    get {
        return ServiceConfig.sharedInstance().configRate[self.categoryIdx]
    }
    }
    
    // category index
    var categoryIdx: Int = -1 {
    didSet {
        if categoryIdx != oldValue && categoryIdx >= 0 && categoryIdx < self.categoryCount {
            let title = self.dataPackage?.title
            delegate?.rateCalculator?(self, didChangeCategory: categoryIdx, categoryTitle: title ? title! : "")
            println("category = \(categoryIdx), title = \(title)")
//            NSNotificationCenter.defaultCenter().postNotificationName(NOTE_RATE_CALCULATOR_MODEL_CATEGORY_CHANGED, object: self, userInfo: ["category": String(categoryIdx), "title": title ? title! : ""])
            unit = -1
        }
    }
    }
    
    // unit
    var unit: Int = 0 {
    didSet {
        if unit != oldValue && unit >= 0 && unit < self.unitCount {
            let title = self.dataPackage?.title(unitIdx: unit)
            delegate?.rateCalculator?(self, didChangeUnit: unit, unitTitle: title ? title! : "")
//            NSNotificationCenter.defaultCenter().postNotificationName(NOTE_RATE_CALCULATOR_MODEL_UNIT_CHANGED, object: self, userInfo: ["unit": String(unit), "title": title ? title! : ""])
        }
    }
    }
    
    // category count
    var categoryCount: Int {
    get {
        return ServiceConfig.sharedInstance().configRate.arrRates.count
    }
    }
    var unitCount: Int {
    get {
        if let dataPackage = self.dataPackage {
            return dataPackage.count
        } else {
            return 0
        }
    }
    }
    
    /// input number to calculate
    func inputNumberToCalculate(number: Double) -> Void {
        var ret = ""
        for i in 0..self.unitCount {
            if i == self.unit {
                continue
            }
            if let rate = self.dataPackage?.rate(fromOriginUnitIdx: self.unit, targetUnitIdx: i) {
                let targetValue = number * rate
                var targetTitle = self.dataPackage?.title(unitIdx: i)
                targetTitle = targetTitle ? targetTitle! : ""
                ret += "\(targetValue) \(targetTitle) \n"
            }
        }
        
        delegate?.rateCalculator?(self, didChangeRateDescription: ret)
        
//        NSNotificationCenter.defaultCenter().postNotificationName(NOTE_RATE_CALCULATOR_MODEL_RATE_DESCRIPTION_CHANGED, object: self, userInfo: ["description": ret])
    }
    
}