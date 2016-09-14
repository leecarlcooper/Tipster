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
    
    func UIColorFromHex2(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Flurry.logEvent("Settings page invoked")

        // set default tip
        let defaults = NSUserDefaults.standardUserDefaults()
        tipControl.selectedSegmentIndex = defaults.integerForKey("tipDefault")
        
        tipControl.tintColor = UIColorFromHex2(0x00A698, alpha: 1.0)
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
