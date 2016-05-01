//
//  TipViewController.swift
//  tips
//
//  Created by chengyin_liu on 4/27/16.
//  Copyright © 2016 chengyin_liu. All rights reserved.
//

import UIKit

let KEYBOARD_ANIMATION_MIN_HEIGHT = 376.0
let DURATION_COVER_ENTER = 0.25

func doubleWithTwoDecimalPlaces(amount: Double) -> Double {
    return Double(NSString(format: "%.2f", amount) as String)!;
}

class TipViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet weak var currencySymbolLabel: UILabel!
    @IBOutlet weak var billField: UITextField!
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var resultStackView: UIStackView!
    
    @IBOutlet var resultLabels: [UILabel]!
    @IBOutlet var percentageLabels: [UILabel]!
    @IBOutlet var tipLabels: [UILabel]!
    
    @IBOutlet weak var resultsStackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputContainerViewHeightConstraint: NSLayoutConstraint!
    
    var defaultInputHeight: CGFloat = 0.0
    var keyboardHeight: CGFloat = 0.0
    var isInCoverMode = true
    
    lazy var numberFormatter: NSNumberFormatter = {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle

        return numberFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navbar = self.navigationController?.navigationBar
        
        navbar!.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navbar!.shadowImage = UIImage()
        
        self.defaultInputHeight = self.inputContainerView.bounds.height
        
        self.currencySymbolLabel.text = self.numberFormatter.currencySymbol
        
        let billAmount = BillAmountSession.get()
        
        if (billAmount == nil) {
            self.enterCoverMode()
            self.billField.text = ""
        } else {
            self.exitCoverMode()
            self.billField.text = String(billAmount!)
        }
        
        self.billField.becomeFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TipViewController.keyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TipViewController.keyboardWillHideNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)

        self.showPercentageSettings()
        self.setCalculatedLabels(self.getBillAmount(true))
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        // recalculate the height
        if (self.isInCoverMode) {
            self.enterCoverMode()
        }
        
        super.viewWillLayoutSubviews()
    }
    
    func getBillAmount(withSavedValue: Bool = false) -> Double? {
        let billText = self.billField.text
        var billAmount: Double?
        
        if (withSavedValue && (billText == nil || billText == "")) {
            billAmount = BillAmountSession.get()
        } else {
            let localBillAmount = self.numberFormatter.numberFromString("\(self.numberFormatter.currencySymbol)\(billText!)")
            if (localBillAmount != nil) {
                billAmount = Double(localBillAmount!)
            } else {
                billAmount = Double(billText!)
            }
        }
        
        return billAmount
    }
    
    func enterCoverMode(animated: Bool = false) {
        let height = self.view.bounds.height - self.topLayoutGuide.length - self.keyboardHeight
        self.inputContainerViewHeightConstraint.constant = height
        self.isInCoverMode = true
        self.resultStackView.alpha = 0.1
        
        let duration = animated ? 0.25 : 0.0;
        
        UIView.animateWithDuration(duration, delay: 0.0, options: .BeginFromCurrentState, animations: {
            self.view.layoutIfNeeded()
            self.resultStackView.alpha = 0.1
            }, completion: nil
        )
    }
    
    func exitCoverMode(animated: Bool = false) {
        self.inputContainerViewHeightConstraint.constant = self.defaultInputHeight
        self.isInCoverMode = false
        
        UIView.animateWithDuration(animated ? 0.25 : 0, delay: 0.0, options: .BeginFromCurrentState, animations: {
            self.view.layoutIfNeeded()
            self.resultStackView.alpha = 0.4
            }, completion: {(_) in
                UIView.animateWithDuration(animated ? 0.15: 0, delay: 0.0, options: .BeginFromCurrentState, animations: {
                    self.resultStackView.alpha = 1.0
                    }, completion: nil)
        })
        
    }
    
    func showPercentageSettings() {
        self.percentageLabels[0].text? = "\(PercentageSettings.low)%"
        self.percentageLabels[1].text? = "\(PercentageSettings.normal)%"
        self.percentageLabels[2].text? = "\(PercentageSettings.high)%"
    }
    
    func setCalculatedLabels(billAmount: Double?) {
        if (billAmount == nil) {
            resultLabels.forEach { (label) in
                label.text = ""
            }
            
            tipLabels.forEach { (label) in
                label.text = ""
            }
        } else {
            let tipLow = doubleWithTwoDecimalPlaces(Double(PercentageSettings.low) * billAmount! / 100.0)
            let tipNormal = doubleWithTwoDecimalPlaces(Double(PercentageSettings.normal) * billAmount! / 100.0)
            let tipHigh = doubleWithTwoDecimalPlaces(Double(PercentageSettings.high) * billAmount! / 100.0)
            
            self.tipLabels[0].text? = self.numberFormatter.stringFromNumber(tipLow)!
            self.tipLabels[1].text? = self.numberFormatter.stringFromNumber(tipNormal)!
            self.tipLabels[2].text? = self.numberFormatter.stringFromNumber(tipHigh)!
            
            self.resultLabels[0].text? = self.numberFormatter.stringFromNumber(tipLow + billAmount!)!
            self.resultLabels[1].text? = self.numberFormatter.stringFromNumber(tipNormal + billAmount!)!
            self.resultLabels[2].text? = self.numberFormatter.stringFromNumber(tipHigh + billAmount!)!
        }
    }
    
    func keyboardWillShowNotification(notification: NSNotification) {
        updateLayoutConstraintWithNotification(notification)
    }
    
    func keyboardWillHideNotification(notification: NSNotification) {
        updateLayoutConstraintWithNotification(notification)
    }
    
    func updateLayoutConstraintWithNotification(notification: NSNotification) {
        let viewBoundHeight = Double(view.bounds.height)
        let userInfo = notification.userInfo!
        
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let convertedKeyboardEndFrame = view.convertRect(keyboardEndFrame, fromView: view.window)
        let rawAnimationCurve = (notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).unsignedIntValue << 16
        let animationOptions = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve)).union(.BeginFromCurrentState)
        let bottom =  CGRectGetMaxY(view.bounds) - CGRectGetMinY(convertedKeyboardEndFrame)
        
        self.keyboardHeight = bottom

        var inputContainerHeight = self.defaultInputHeight

        if (self.isInCoverMode) {
            inputContainerHeight = self.view.bounds.height - self.topLayoutGuide.length - bottom
        }
        
        self.inputContainerViewHeightConstraint.constant = inputContainerHeight
        
        if (viewBoundHeight > KEYBOARD_ANIMATION_MIN_HEIGHT) {
            self.resultsStackViewBottomConstraint.constant = 0 - bottom
        }

        UIView.animateWithDuration(animationDuration, delay: 0.0, options: animationOptions, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    
    @IBAction func onTap(sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func onBillFieldEditingChanged(sender: AnyObject) {
        let billAmount = self.getBillAmount()
        
        if (billAmount == nil) {
            self.enterCoverMode(true)
        } else if (self.isInCoverMode) {
            self.exitCoverMode(true)
        }
        
        BillAmountSession.save(billAmount)
        self.setCalculatedLabels(billAmount)
    }
}

