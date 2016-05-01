//
//  PercentageSettings.swift
//  tips
//
//  Created by chengyin_liu on 4/27/16.
//  Copyright © 2016 chengyin_liu. All rights reserved.
//

import UIKit

let PERCENTAGE_KEY_PREFIX = "settings_percentage_";

let KEY_LOW = "\(PERCENTAGE_KEY_PREFIX)low";
let KEY_NORMAL = "\(PERCENTAGE_KEY_PREFIX)normal";
let KEY_HIGH = "\(PERCENTAGE_KEY_PREFIX)high";

let DEFAULT_LOW = 10
let DEFAULT_NORMAL = 15
let DEFAULT_HIGH = 20

func userDefaultIntegerForKey(key: String, withFallback: Int) -> Int {
    let defaults = NSUserDefaults.standardUserDefaults()
    return defaults.objectForKey(key) == nil ? withFallback : defaults.integerForKey(key)
}

func setDefaultPercentageInteger(value: Int, forKey: String) {
    if (value > 100 || value < 0) {
        return;
    }
    
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setInteger(value, forKey: forKey)
    defaults.synchronize()
}

struct PercentageSettings {
    static var low: Int {
        get {
            return userDefaultIntegerForKey(KEY_LOW, withFallback: DEFAULT_LOW)
        }
        
        set(low) {
            setDefaultPercentageInteger(low, forKey: KEY_LOW);
        }
    }
    
    static var normal: Int {
        get {
            return userDefaultIntegerForKey(KEY_NORMAL, withFallback: DEFAULT_NORMAL)
        }
        
        set(normal) {
            setDefaultPercentageInteger(normal, forKey: KEY_NORMAL)
        }
    }
    
    static var high: Int {
        get {
            return userDefaultIntegerForKey(KEY_HIGH, withFallback: DEFAULT_HIGH)
        }
        
        set(high) {
            setDefaultPercentageInteger(high, forKey: KEY_HIGH)
        }
    }
}
