//
//  ServiceConfig.swift
//  TipCalculator
//
//  Created by JunXie on 14-6-18.
//  Copyright (c) 2014 xiejun. All rights reserved.
//

import Foundation

class ServiceConfig {
    
    class func sharedInstance() -> ServiceConfig! {
        struct Static {
            static var instance: ServiceConfig? = nil
            static var onceToken: dispatch_once_t = 0
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = self()
        }
        return Static.instance!
    }
    
    @required init() {
        
    }
    
    let configRate = ConfigRate(cachedPath: "configRate.plist", bundlePath: "configRate.plist")
    
    func save() {
        self.configRate.save()
    }
}