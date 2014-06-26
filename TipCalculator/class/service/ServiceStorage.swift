//
//  ServiceStorage.swift
//  TipCalculator
//
//  Created by JunXie on 14-6-18.
//  Copyright (c) 2014 xiejun. All rights reserved.
//

import Foundation

class ServiceStorage {
    class func sharedInstance() -> ServiceStorage! {
        struct Static {
            static var instance: ServiceStorage? = nil
            static var onceToken: dispatch_once_t = 0
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = self()
        }
        return Static.instance!
    }
    
    class func rootDocument() -> String {
        let dirs = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        return dirs[dirs.count-1] as String
    }
    
    class func rootCache() -> String {
        let dirs = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        return dirs[dirs.count-1] as String
    }
    
    class func rootTemporary() -> String {
        return NSTemporaryDirectory()
    }
    
    class func rootResource() -> String {
        return NSBundle.mainBundle().bundlePath
    }
    
    let STORAGE_QUEUE = dispatch_queue_create("com.xj.storage", nil)
    
    @required init() {
        
    }
    
    deinit {
        dispatch_release(STORAGE_QUEUE)
    }
    
    func read(file: String, atPath path: String) -> AnyObject? {
        let thePath = path.stringByAppendingPathComponent(file)
        
        let fm = NSFileManager.defaultManager()
        if fm.fileExistsAtPath(thePath) {
            let ret = NSData(contentsOfURL: NSURL(fileURLWithPath: thePath))
            return ret
        } else {
            NSLog("找不到指定文件:\(thePath)")
            return nil
        }
    }
    
    func write(data: NSData, toFile file: String, atPath path: String) -> Void {
        let thePath = path.stringByAppendingPathComponent(file)
        data.writeToFile(thePath, atomically: true)
    }
    
    func readAsync(file: String, atPath path: String, withBlock block: (NSData) -> Void) -> Void {
        let queue = dispatch_get_current_queue()
        
        dispatch_async(STORAGE_QUEUE) {
            [unowned self] in
            let data = self.read(file, atPath: path) as? NSData
            if data {
                dispatch_async(queue) {
                    block(data!)
                }
            }
        }
    }
    
    func writeAsync(data: NSData, toFile file: String, atPath path: String, withBlock block: (() -> Void)? ) -> Void {
        let queue = dispatch_get_current_queue()
        
        dispatch_async(STORAGE_QUEUE) {
            [unowned self] in
            self.write(data, toFile: file, atPath: path)
            
            if block {
                dispatch_async(queue) {
                    block!()
                }
            }
        }
    }
}