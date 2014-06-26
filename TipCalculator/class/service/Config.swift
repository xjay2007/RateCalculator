//
//  Config.swift
//  TipCalculator
//
//  Created by JunXie on 14-6-18.
//  Copyright (c) 2014 xiejun. All rights reserved.
//

import Foundation

class Config {
    // cached path in document directory
    let cachedPath: String
    // bundle path to load
    let bundlePath: String
    
    var raw: NSDictionary = NSDictionary()
    var isRawModified = false
    
    init(cachedPath: String, bundlePath: String) {
        let docDirectory = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let docPath = docDirectory.bridgeToObjectiveC().lastObject as String
        self.cachedPath = docPath.stringByAppendingPathComponent(cachedPath)
        self.bundlePath = NSBundle.mainBundle().pathForResource(bundlePath.stringByDeletingPathExtension, ofType: bundlePath.pathExtension)
        load()
    }
    
    func load() -> Void {
        let fileMgr = NSFileManager.defaultManager()
        if fileMgr.fileExistsAtPath(self.bundlePath) {
            self.raw = NSDictionary(contentsOfFile: self.bundlePath)
        } else if fileMgr.fileExistsAtPath(self.cachedPath) {
            self.raw = NSDictionary(contentsOfFile: self.cachedPath)
        } else {
            assert(false, "Config NO PATH EXISTED")
        }
    }
    
    func save() -> Void {
        dispatch_async(dispatch_get_current_queue(), {
            if self.isRawModified {
                self.isRawModified = false
                self.updateRaw()
            }
            let ret = self.raw.writeToFile(self.cachedPath, atomically: true)
            NSLog("file write successfully:\(ret)")
            })
    }
    
    func updateRaw() {
        
    }
}

class ConfigRate: Config {
    init(cachedPath: String, bundlePath: String) {
        super.init(cachedPath: cachedPath, bundlePath: bundlePath)
        let arrRates = self.raw["rates"] as NSArray
        for raw: AnyObject in arrRates {
            let data = DataPackage(raw: raw as NSDictionary)
            self.arrRates.addObject(data)
        }
    }
    
    var arrRates = NSMutableArray()
    
    subscript(i: Int) -> DataPackage? {
    get {
        if i < self.arrRates.count {
            return self.arrRates[i] as? DataPackage
        } else {
            return nil
        }
    }
    }
    
    override func updateRaw() {
        let newRaw = NSMutableDictionary()
        let arrRates = NSMutableArray()
        for data: AnyObject in arrRates {
            let subRaw = (data as DataPackage).raw()
            arrRates.addObject(subRaw)
        }
        newRaw["rates"] = arrRates
        self.raw = newRaw
    }
}