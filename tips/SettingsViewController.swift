//
//  SettingsViewController.swift
//  tips
//
//  Created by chengyin_liu on 4/27/16.
//  Copyright © 2016 chengyin_liu. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet var percentageFields: [UITextField]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateLabelTexts()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.savePercentages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateLabelTexts() {
        percentageFields[0].text? = "\(PercentageSettings.low)"
        percentageFields[1].text? = "\(PercentageSettings.normal)"
        percentageFields[2].text? = "\(PercentageSettings.high)"
    }
    
    func savePercentages() {
        PercentageSettings.low = Int(percentageFields[0].text!)!
        PercentageSettings.normal = Int(percentageFields[1].text!)!
        PercentageSettings.high = Int(percentageFields[2].text!)!
    }
    
    @IBAction func percentageFieldEditingDidEnd(sender: AnyObject) {
        savePercentages()
        updateLabelTexts()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
