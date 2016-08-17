//
//  ViewController.swift
//  Tipster
//
//  Created by Lee Cooper on 8/7/16.
//  Copyright © 2016 Lee Cooper. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var tipTitleLabel: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tipControl: UISegmentedControl!
    @IBOutlet var tipSwipeView: UIView!
    @IBOutlet var totalSwipeView: UIView!
    
    let tipSwipeRightRec = UISwipeGestureRecognizer()
    let tipSwipeLeftRec = UISwipeGestureRecognizer()
    let totalSwipeRightRec = UISwipeGestureRecognizer()
    let totalSwipeLeftRec = UISwipeGestureRecognizer()
    
    let tipTitles = ["TIP (+15%)", "TIP (+18%)", "TIP (+20%)"]
    let tipDefaultPercentages = [0.15, 0.18, 0.20]
    var tipPercentage: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Flurry.startSession("JJGPHNJFH7C655XH7PR6")
        Flurry.logEvent("Launched application")
        
        // Customize nav bar
        navigationController!.navigationBar.barTintColor = UIColor(red: 48/255, green: 172/255, blue: 179/255, alpha: 1)
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        // open view with keypad open for entering bill/check amount
        amountField.keyboardAppearance = UIKeyboardAppearance.Dark
        amountField.delegate = self
        amountField.becomeFirstResponder()
        
        // setup up swipe detection
        tipSwipeRightRec.direction = UISwipeGestureRecognizerDirection.Right
        tipSwipeRightRec.addTarget(self, action: #selector(ViewController.tipSwipedRightView))
        tipSwipeView.addGestureRecognizer(tipSwipeRightRec)
        tipSwipeLeftRec.direction = UISwipeGestureRecognizerDirection.Left
        tipSwipeLeftRec.addTarget(self, action: #selector(ViewController.tipSwipedLeftView))
        tipSwipeView.addGestureRecognizer(tipSwipeLeftRec)
        tipSwipeView.userInteractionEnabled = true
        
        totalSwipeRightRec.direction = UISwipeGestureRecognizerDirection.Right
        totalSwipeRightRec.addTarget(self, action: #selector(ViewController.totalSwipedRightView))
        totalSwipeView.addGestureRecognizer(totalSwipeRightRec)
        totalSwipeLeftRec.direction = UISwipeGestureRecognizerDirection.Left
        totalSwipeLeftRec.addTarget(self, action: #selector(ViewController.totalSwipedLeftView))
        totalSwipeView.addGestureRecognizer(totalSwipeLeftRec)
        totalSwipeView.userInteractionEnabled = true
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey: "loadDefault")
        defaults.synchronize()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let defaults = NSUserDefaults.standardUserDefaults()
        let loadDefault = defaults.boolForKey("loadDefault")
        
        // recalculate tipTitleLabel and tipLabel each time (in case there is a default or default change)
        // do not recalculate if simply going to the settings page and not making a change
        if loadDefault {
            tipControl.selectedSegmentIndex = defaults.integerForKey("tipDefault")
            tipPercentage = tipDefaultPercentages[tipControl.selectedSegmentIndex]
            calculateTip(nil)
            defaults.setBool(false, forKey: "loadDefault")
            defaults.synchronize()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onTap(sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func tipControlValueChanges(sender: AnyObject) {
        tipPercentage = tipDefaultPercentages[tipControl.selectedSegmentIndex]
        calculateTip(nil)
        
        Flurry.logEvent("Tip changed using tipControl to index: " + String(tipControl.selectedSegmentIndex) + "; 0=15%; 1=18%; 2=20%")
    }
    
    @IBAction func calculateTip(sender: AnyObject?) {
        let amount = Double(amountField.text!) ?? 0
        let tip = tipPercentage * amount
        let total = amount + tip
                
        if amount == 0 {
            tipLabel.text = " "
            totalLabel.text = " "
        } else {
            tipLabel.text = String(format: "%.2f", tip)
            totalLabel.text = String(format: "%.2f", total)
            tipTitleLabel.text = "TIP (+" + calculateTipPercentageString() + "%)"
        }
    }
    
    func calculateTipPercentageString() -> String {
        let amount = Double(amountField.text!) ?? 0
//        if let tip = Double(tipLabel.text!) {
        if tipPercentage > 0 {
            var tipPercentageString: String
            let tipPercentageRounded = round(tipPercentage*100*10)/10 // round to 10th decimal place
            if (tipPercentageRounded % 1) == 0 {
                tipPercentageString = String(format: "%.0f", tipPercentageRounded)
            } else {
                tipPercentageString = String(format: "%.1f", tipPercentageRounded)
            }
            return tipPercentageString
        } else if amount > 0 {   // tip is zero
            return "0"
        } else {
            return ""
        }
    }
    
    func tipSwipedRightView() {
        let amount = Double(amountField.text!) ?? 0
        if amount > 0 {
            var tip = Double(tipLabel.text!) ?? 0
            if tip % 1 != 0 {
                tip = ceil(tip)
            } else {
                tip += 1
            }
            tipPercentage = tip / amount
            tipLabel.text = String(format: "%.2f", tip)
            let total = amount + tip
            totalLabel.text = String(format: "%.2f", total)
            adjustTipTextAndTipControl()
            
            Flurry.logEvent("Tip rounded up using swipe")
        }
    }

    func tipSwipedLeftView() {
        let amount = Double(amountField.text!) ?? 0
        if amount > 0 {
            var tip = Double(tipLabel.text!) ?? 0
            if tip % 1 != 0 {
                tip = ceil(tip) - 1
            } else if tipPercentage > 0 {
                tip -= 1
            }
            
            tipPercentage = tip / amount
            let total = amount + tip
            totalLabel.text = String(format: "%.2f", total)
            
            if tipPercentage > 0 {
                tipLabel.text = String(format: "%.2f", tip)
            } else {
                tipLabel.text = " "
            }
            adjustTipTextAndTipControl()

            Flurry.logEvent("Tip rounded down using swipe")
        }
    }
    
    func adjustTipTextAndTipControl() {
        // recalc the Tip title %
        tipTitleLabel.text = "TIP (+" + calculateTipPercentageString() + "%)"
        
        // enable/disable the tip control as appropriate
        for defaultTip in tipDefaultPercentages {
            if tipPercentage == defaultTip {
                tipControl.selectedSegmentIndex = tipDefaultPercentages.indexOf(defaultTip)!
                break   // done finding match
            } else {
                tipControl.selectedSegmentIndex = -1
            }
        }
    }
    
    func totalSwipedRightView() {
        let amount = Double(amountField.text!) ?? 0
        if amount > 0 {
            var tip = Double(tipLabel.text!) ?? 0
            var total = amount + tip
            if total % 1 != 0 {
                total = ceil(total)
            } else {
                total += 1
            }
            tip = total - amount
            
            tipPercentage = tip / amount
            tipLabel.text = String(format: "%.2f", tip)
            totalLabel.text = String(format: "%.2f", total)
            adjustTipTextAndTipControl()

            Flurry.logEvent("Total rounded up using swipe")
        }
    }
    
    func totalSwipedLeftView() {
        let amount = Double(amountField.text!) ?? 0
        if amount > 0 {
            var tip = Double(tipLabel.text!) ?? 0
            var total = amount + tip
            
            if total > amount {     // then we have room to go down
                if total % 1 != 0 {  // total has decimal place so round down (or go to amount if rounding down goes below amount)
                    total = ceil(total) - 1
                    if total < amount {
                        total = amount
                    }
                } else if (total - 1) > amount {
                    total -= 1
                } else {
                    total = amount
                }
                tip = total - amount
                tipPercentage = tip / amount
                totalLabel.text = String(format: "%.2f", total)
                if tipPercentage > 0 {
                    tipLabel.text = String(format: "%.2f", tip)
                } else {
                    tipLabel.text = " "
                }
                adjustTipTextAndTipControl()
                
                Flurry.logEvent("Total rounded down using swipe")
            }
        }
    }
}


