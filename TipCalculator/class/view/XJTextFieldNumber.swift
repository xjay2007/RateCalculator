//
//  XJTextFieldNumber.swift
//  TipCalculator
//
//  Created by JunXie on 14-6-25.
//  Copyright (c) 2014 xiejun. All rights reserved.
//

import UIKit

let XJTextFieldNumberDidChangeNotification = XJTextFieldNumber.CONSTANTS.XJTextFieldNumberDidChangeNotification

class XJTextFieldNumber: UITextField, UITextFieldDelegate {
    
    struct CONSTANTS {
        static let MAX_INTEGER_DIGITS: Int = 18
        static let MAX_FRACTION_DIGITS: Int = 6
        static let XJTextFieldNumberDidChangeNotification = "XJTextFieldNumberDidChangeNotification"
    }
    
    // input string
    var cachedInputString = "0.0"
    // input number
    var inputNumber: Double {
    get {
        return cachedInputString.bridgeToObjectiveC().doubleValue
    }
    set {
        var strFraction: String?
        let numInteger = CLongLong(newValue)
        let numFraction = newValue - Double(numInteger)
        if numFraction > 0.0 {
            strFraction = String(numFraction)
            strFraction = strFraction!.bridgeToObjectiveC().substringFromIndex(1) // remove zero at the integer part
        }
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        var ret = formatter.stringFromNumber(NSNumber(longLong: numInteger))
        ret = ret + (strFraction ? strFraction! : "")
        self.text = ret
    }
    }
    
    // real delegate
    weak var tDelegate: UITextFieldDelegate!

    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
        self.placeholder = cachedInputString
        super.delegate = self
    }
    
    override var delegate: UITextFieldDelegate! {
    set {
        tDelegate = newValue
    }
    get {
        return tDelegate
    }
    }
    override var keyboardType: UIKeyboardType {
    set {
        super.keyboardType = UIKeyboardType.DecimalPad
    }
    get {
        return super.keyboardType
    }
    }
    
    override func forwardingTargetForSelector(aSelector: Selector) -> AnyObject! {
        if tDelegate?.respondsToSelector(aSelector) == true {
           return tDelegate
        }
        return super.forwardingTargetForSelector(aSelector)
    }
    
    func textFieldDidBeginEditing(textField: UITextField!) {
        cachedInputString = "0"
        textField.text = cachedInputString
        
        NSNotificationCenter.defaultCenter().postNotificationName(CONSTANTS.XJTextFieldNumberDidChangeNotification, object: self)
        
        tDelegate?.textFieldDidBeginEditing?(textField)
    }
    
    func textField(textField: UITextField!, shouldChangeCharactersInRange range: NSRange, replacementString string: String!) -> Bool {
        
        if string == "." {
            // input dot
            let range = cachedInputString.bridgeToObjectiveC().rangeOfString(string)
            if range.length == 0 {
                // integer
                cachedInputString += string
            }
        } else if string == "" {
            // backspace
            cachedInputString = cachedInputString.bridgeToObjectiveC().substringToIndex(max(0, cachedInputString.bridgeToObjectiveC().length - 1))
            
        } else {
            if let x = string?.bridgeToObjectiveC().integerValue {
                cachedInputString += string
            }
        }
        
        // split the string
        var range = cachedInputString.bridgeToObjectiveC().rangeOfString(".")
        var strInteger: String?
        var strFraction: String?
        if range.length == 0 {
            // pure integer
            strInteger = cachedInputString
        } else {
            strInteger = cachedInputString.bridgeToObjectiveC().substringToIndex(range.location)
            strFraction = cachedInputString.bridgeToObjectiveC().substringFromIndex(range.location)
        }
        
        // length == 0 check
        if strInteger?.bridgeToObjectiveC().length == 0 {
            strInteger = "0"
        }
        
        // is integer over length check
        var isIntegerOverLength = (strInteger?.bridgeToObjectiveC().length > CONSTANTS.MAX_INTEGER_DIGITS)
        if isIntegerOverLength {
            strInteger = strInteger!.bridgeToObjectiveC().substringToIndex(CONSTANTS.MAX_INTEGER_DIGITS + 1)
        }
        var isFractionOverLength = (strFraction != nil ) && (strFraction?.bridgeToObjectiveC().length > CONSTANTS.MAX_FRACTION_DIGITS+1 )
        if isFractionOverLength {
            strFraction = strFraction!.bridgeToObjectiveC().substringToIndex(CONSTANTS.MAX_FRACTION_DIGITS+1)
        }
        // change the cachedInputString
        cachedInputString = strInteger! + (strFraction ? strFraction! : "")
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        let numInteger = strInteger!.bridgeToObjectiveC().longLongValue
        var ret = formatter.stringFromNumber(NSNumber(longLong: numInteger))
        if strFraction {
            ret = ret + strFraction!
        }
        textField.text = ret
        
        let number = cachedInputString.bridgeToObjectiveC().doubleValue
        println("cachedInputString = \(cachedInputString), number = \(number), text = \(ret)")
        
        NSNotificationCenter.defaultCenter().postNotificationName(CONSTANTS.XJTextFieldNumberDidChangeNotification, object: self)
        
        if let ret =  tDelegate?.textField?(self, shouldChangeCharactersInRange: range, replacementString: string) {
            return ret
        }
        return false
    }
}
