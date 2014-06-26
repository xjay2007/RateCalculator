//
//  Data.swift
//  TipCalculator
//
//  Created by JunXie on 14-6-18.
//  Copyright (c) 2014 xiejun. All rights reserved.
//

import Foundation

@objc class Data {
    init(raw: NSDictionary) {
        
    }
    
    func raw() -> NSDictionary {
        return NSDictionary()
    }
}

// list of rate
class DataPackage: Data {
    var title: String //
    var arrRates: DataRate[] = DataRate[]()
    init(raw: NSDictionary) {
        self.title = raw["title"] as String
        let rates = raw["items"] as NSArray
        for subRaw : AnyObject in rates {
            let data = DataRate(raw: subRaw as NSDictionary)
            self.arrRates.append(data)
        }
        super.init(raw: raw)
    }
    
    // how many rate are there
    var count: Int {
    get {
        return self.arrRates.count
    }
    }
    // a rate of 1 originUnit = ? targetUnit
    func rate(fromOriginUnitIdx originIdx: Int, targetUnitIdx targetIdx: Int) -> Double {
        if originIdx < 0 || originIdx >= self.count || targetIdx < 0 || targetIdx >= self.count {
            return 0.0
        }
        if originIdx == targetIdx {
            return 1.0
        } else {
            let originRate = rate(unitIdx: originIdx)
            let targetRate = rate(unitIdx: targetIdx)
            let ret = originRate / targetRate
            return ret
        }
    }
    // a rate of 1 unit = ? rawUnit
    func rate(unitIdx idx: Int) -> Double {
        if idx < 0 || idx >= self.count {
            return 0.0
        }
        var ret = 1.0
        var curIdx = idx
        var isStop = false
        do {
            let data = self.arrRates[curIdx] as DataRate
            ret *= data.weight
            isStop = (data.unit == curIdx)
            curIdx = data.unit
        } while !isStop
        return ret
    }
    
    func title(unitIdx idx: Int) -> String? {
        if idx < 0 || idx >= self.count {
            return nil
        }
        let data = self.arrRates[idx] as DataRate
        return data.title
    }
    
    subscript(i: Int) -> DataRate? {
        if i < 0 || i >= self.count {
            return nil
        }
        return self.arrRates[i] as DataRate
    }
    
    // raw unit
    func rawUnit() -> DataRate! {
        for unit: DataRate in self.arrRates {
            if unit.unit == self.arrRates.bridgeToObjectiveC().indexOfObject(unit) {
                return unit
            }
        }
        assert(false, "should not be here")
        return nil
    }
    func isRawUnit(unitIdx idx: Int) -> Bool {
        return self.rawUnit()!.unit == idx
    }
    
    // modify
    func addDataRate(dataRate: DataRate) -> Bool {
        if dataRate == nil {
            return false
        }
        self.arrRates.append(dataRate)
        return true
    }
    func editDataRate(dataRate: DataRate, atIdx idx: Int) -> Bool {
        if dataRate == nil || idx < 0 || idx >= self.arrRates.count {
            return false
        }
        self.arrRates[idx] = dataRate
        return true
    }
    func deleteDataRate(atIdx idx: Int) -> Bool {
        if idx < 0 || idx >= self.arrRates.count || self.isRawUnit(unitIdx: idx) {
            return false
        }
        self.arrRates.removeAtIndex(idx)
        for i in idx..self.arrRates.count {
            let data = self.arrRates[i] as DataRate
            var subRaw = data.raw().mutableCopy() as NSMutableDictionary
            let subUnit = (subRaw["unit"] as NSNumber).integerValue - 1
            subRaw["unit"] = subUnit.bridgeToObjectiveC()
            let dataNew = DataRate(raw: subRaw)
            self.arrRates[i] = dataNew
        }
        return true
    }
    
    // raw
    override func raw() -> NSDictionary {
        let ret = NSMutableDictionary()
        ret["title"] = self.title
        let rates = NSMutableArray()
        for dataRate: DataRate in self.arrRates {
            rates.addObject(dataRate.raw())
        }
        ret["rates"] = rates
        return ret.copy() as NSDictionary
    }
}

// 换算率
class DataRate: Data {
    let title: String // 名称
    let weight: Double // 权重
    let unit: Int // 权重单位
    init(raw: NSDictionary) {
        self.title = raw["title"] as String
        let weight = raw["weight"] as NSNumber
        self.weight = weight.doubleValue
        let unit = raw["unit"] as NSNumber
        self.unit = unit.integerValue
        super.init(raw: raw)
    }
    
    
    override func raw() -> NSDictionary {
        let ret = NSMutableDictionary()
        ret["title"] = self.title
        ret["weight"] = self.weight.bridgeToObjectiveC()
        ret["unit"] = self.unit.bridgeToObjectiveC()
        return ret.copy() as NSDictionary
    }
    
}