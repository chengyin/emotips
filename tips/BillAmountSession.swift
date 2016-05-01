//
//  BillAmountSession.swift
//  Emotips
//
//  Created by chengyin_liu on 5/1/16.
//  Copyright © 2016 chengyin_liu. All rights reserved.
//

import UIKit

let BILL_AMOUNT_SESSION_KEY_PREFIX = "bill_amount_session_"

let KEY_BILL_AMOUNT_VALUE = "\(BILL_AMOUNT_SESSION_KEY_PREFIX)value"
let KEY_BILL_AMOUNT_TIME = "\(BILL_AMOUNT_SESSION_KEY_PREFIX)time"

let BILL_AMOUNT_SESSION_TTL = 10.0 * 60.0

class BillAmountSession: NSObject {
    static func save(amount: Double?) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if (amount == nil) {
            defaults.removeObjectForKey(KEY_BILL_AMOUNT_VALUE)
            defaults.removeObjectForKey(KEY_BILL_AMOUNT_TIME)
        } else {
            defaults.setDouble(amount!, forKey: KEY_BILL_AMOUNT_VALUE)
            defaults.setObject(NSDate(), forKey: KEY_BILL_AMOUNT_TIME)
        }
            
        defaults.synchronize()
        print(NSUserDefaults.standardUserDefaults().dictionaryRepresentation())
    }
    
    static func get() -> Double? {
        print(NSUserDefaults.standardUserDefaults().dictionaryRepresentation())

        let defaults = NSUserDefaults.standardUserDefaults()
        let obj = defaults.objectForKey(KEY_BILL_AMOUNT_TIME)
        
        if (obj == nil) {
            return nil
        }
        
        let time = obj as! NSDate
        
        if (time.timeIntervalSinceNow * -1 > BILL_AMOUNT_SESSION_TTL) {
            return nil
        } else {
            return defaults.doubleForKey(KEY_BILL_AMOUNT_VALUE)
        }
    }
}
