//
//  SettingsViewController.swift
//  Tipster
//
//  Created by Lee Cooper on 8/8/16.
//  Copyright © 2016 Lee Cooper. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var tipControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Settings page invoked")

        // set default tip
        let defaults = NSUserDefaults.standardUserDefaults()
        tipControl.selectedSegmentIndex = defaults.integerForKey("tipDefault")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tipDefaultChanged(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(tipControl.selectedSegmentIndex, forKey: "tipDefault")
        defaults.setBool(true, forKey: "loadDefault")
        defaults.synchronize()
        
        Flurry.logEvent("Tip default changed in Settings to index: " + String(tipControl.selectedSegmentIndex) + "; 0=15%; 1=18%; 2=20%")
    }
}
