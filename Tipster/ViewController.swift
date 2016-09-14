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
    @IBOutlet weak var splitTitleLabel: UILabel!
    @IBOutlet weak var splitLabel: UILabel!
    @IBOutlet weak var tipControl: UISegmentedControl!
    @IBOutlet var tipSwipeView: UIView!
    @IBOutlet var totalSwipeView: UIView!
    @IBOutlet weak var splitSwipeView: UIView!
    @IBOutlet weak var peopleCount: UILabel!
    @IBOutlet weak var incrementButton: UIButton!
    @IBOutlet weak var decrementButton: UIButton!
    @IBOutlet weak var bottomPanelView: UIView!
    
    let tipSwipeRightRec = UISwipeGestureRecognizer()
    let tipSwipeLeftRec = UISwipeGestureRecognizer()
    let totalSwipeRightRec = UISwipeGestureRecognizer()
    let totalSwipeLeftRec = UISwipeGestureRecognizer()
    let splitSwipeRightRec = UISwipeGestureRecognizer()
    let splitSwipeLeftRec = UISwipeGestureRecognizer()
    
    let tipTitles = ["Tip (15%)", "Tip (18%)", "Tip (20%)"]
    let tipDefaultPercentages = [0.15, 0.18, 0.20]
    var tipPercentage: Double = 0.0
    
    var numberOfPeople = 1
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    //Changing Status Bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        //LightContent
        return UIStatusBarStyle.LightContent
        
        //Default
        //return UIStatusBarStyle.Default
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Flurry.startSession("JJGPHNJFH7C655XH7PR6")
        Flurry.logEvent("Launched application")
        
        // brief launch image special effect
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        var redIconView, grayBackgroundView : UIImageView
        grayBackgroundView  = UIImageView(frame:CGRectMake(0, 0, screenSize.width, screenSize.height));
        grayBackgroundView.backgroundColor = UIColorFromHex(0xF4F4F4, alpha: 1.0)
        redIconView  = UIImageView(frame:CGRectMake(screenSize.width / 2 - 30, screenSize.height / 2 - 30, 60, 60));
        redIconView.image = UIImage(named:"RedIcon")
        self.view.addSubview(grayBackgroundView)
        self.view.addSubview(redIconView)
        // at the risk of violating the HIG...
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            UIView.animateWithDuration(0.25, animations: {
                redIconView.alpha = 0.0
            })
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            UIView.animateWithDuration(0.25, animations: {
                grayBackgroundView.alpha = 0.0
            })        }
        
        // Customize nav bar
//        #00A698
//        navigationController!.navigationBar.barTintColor = UIColor(red: 48/255, green: 172/255, blue: 179/255, alpha: 1)
        navigationController!.navigationBar.barTintColor = UIColorFromHex(0x00A698, alpha: 1.0)
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        // set panel color programmatically to try to match color of nav bar
        bottomPanelView.backgroundColor = UIColorFromHex(0x00A698, alpha: 1.0)
        tipControl.tintColor = UIColorFromHex(0x00A698, alpha: 1.0)
        tipLabel.textColor = UIColorFromHex(0x00A698, alpha: 1.0)
        totalLabel.textColor = UIColorFromHex(0x00A698, alpha: 1.0)
        
        // open view with keypad open for entering bill/check amount
//        amountField.keyboardAppearance = UIKeyboardAppearance.Dark
//        amountField.delegate = self
//        amountField.becomeFirstResponder()
        
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
    
        
        splitSwipeRightRec.direction = UISwipeGestureRecognizerDirection.Right
        splitSwipeRightRec.addTarget(self, action: #selector(ViewController.splitSwipedRightView))
        splitSwipeView.addGestureRecognizer(splitSwipeRightRec)
        splitSwipeLeftRec.direction = UISwipeGestureRecognizerDirection.Left
        splitSwipeLeftRec.addTarget(self, action: #selector(ViewController.splitSwipedLeftView))
        splitSwipeView.addGestureRecognizer(splitSwipeLeftRec)
        splitSwipeView.userInteractionEnabled = true
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey: "loadDefault")
        defaults.synchronize()
        
        decrementButton.hidden = true
        decrementButton.adjustsImageWhenHighlighted = false
        incrementButton.adjustsImageWhenHighlighted = false
        splitTitleLabel.hidden = true
        splitLabel.hidden = true
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
    
    @IBAction func screenTapped(sender: AnyObject) {
        // dismiss keyboard
        view.endEditing(true)
    }
    
    @IBAction func tipControlValueChanges(sender: AnyObject) {
        tipPercentage = tipDefaultPercentages[tipControl.selectedSegmentIndex]
        calculateTip(nil)
        
        // dismiss keyboard
        view.endEditing(true)
        
        Flurry.logEvent("Tip changed using tipControl to index: " + String(tipControl.selectedSegmentIndex) + "; 0=15%; 1=18%; 2=20%")
    }
    
    @IBAction func incrementPeopleCount(sender: AnyObject) {
        if numberOfPeople < 16 {
            numberOfPeople += 1
            if numberOfPeople == 2 {
                decrementButton.hidden = false
                // change image from whitecirclplus to whitecirclefilled
                if let image = UIImage(named: "WhiteCircleFilled") {
                    incrementButton.setImage(image, forState: .Normal)
                }
                // show split and split amount
                splitTitleLabel.hidden = false
                splitLabel.hidden = false
            }
            peopleCount.text = String(numberOfPeople)
            // recalc split
            let total = Double(totalLabel.text!) ?? 0
            if total > 0 {
                calculateSplit(total)
            }
            Flurry.logEvent("People increment to: " + String(numberOfPeople))
        }
    }
    
    @IBAction func decrementPeopleCount(sender: AnyObject) {
        if numberOfPeople > 1 {
            numberOfPeople -= 1
            peopleCount.text = String(numberOfPeople)
            if numberOfPeople == 1 {
                peopleCount.text = " "
                decrementButton.hidden = true
                // change image from whitecirclplus to whitecirclefilled
                if let image = UIImage(named: "WhiteCirclePlus") {
                    incrementButton.setImage(image, forState: .Normal)
                }
                // hide split and split amount
                splitTitleLabel.hidden = true
                splitLabel.hidden = true
            }
            // recalc split
            let total = Double(totalLabel.text!) ?? 0
            if total > 0 {
                calculateSplit(total)
            }
            Flurry.logEvent("People decrement to: " + String(numberOfPeople))
        }
    }
    
    @IBAction func calculateTip(sender: AnyObject?) {
        let amount = Double(amountField.text!) ?? 0
        let tip = tipPercentage * amount
        let total = amount + tip
        let split = total / Double(numberOfPeople)
        
        if amount == 0 {
            tipLabel.text = " "
            totalLabel.text = " "
            splitLabel.text = " "
            self.view.viewWithTag(1)?.hidden = true
            self.view.viewWithTag(2)?.hidden = true
            self.view.viewWithTag(3)?.hidden = true
            if tipControl.selectedSegmentIndex != -1 {
                tipTitleLabel.text = tipTitles[tipControl.selectedSegmentIndex]
            }
        } else {
            tipLabel.text = String(format: "%.2f", tip)
            totalLabel.text = String(format: "%.2f", total)
            splitLabel.text = String(format: "%.2f", split)
            self.view.viewWithTag(1)?.hidden = false
            self.view.viewWithTag(2)?.hidden = false
            calculateSplit(total)
            tipTitleLabel.text = "Tip (" + calculateTipPercentageString() + "%)"
        }
    }
    
    private func calculateSplit(total: Double) {
        let split = total / Double(numberOfPeople)
        splitLabel.text = String(format: "%.2f", split)
        self.view.viewWithTag(3)?.hidden = false
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
        // dismiss keyboard
        view.endEditing(true)
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
            calculateSplit(total)
            
            Flurry.logEvent("Tip rounded up using swipe")
        }
    }

    func tipSwipedLeftView() {
        // dismiss keyboard
        view.endEditing(true)
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
            calculateSplit(total)

            Flurry.logEvent("Tip rounded down using swipe")
        }
    }
    
    func adjustTipTextAndTipControl() {
        // recalc the Tip title %
        tipTitleLabel.text = "Tip (" + calculateTipPercentageString() + "%)"
        
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
        // dismiss keyboard
        view.endEditing(true)
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
            calculateSplit(total)

            Flurry.logEvent("Total rounded up using swipe")
        }
    }
    
    func totalSwipedLeftView() {
        // dismiss keyboard
        view.endEditing(true)
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
                calculateSplit(total)
                
                Flurry.logEvent("Total rounded down using swipe")
            }
        }
    }

    func splitSwipedRightView() {
        let amount = Double(amountField.text!) ?? 0
        if amount > 0 {
            var split = Double(splitLabel.text!) ?? 0
            if split % 1 != 0 {
                split = ceil(split)
            } else {
                split += 1
            }
            // recalc total and tip and tip % based on new split
            let newTotal = split * Double(numberOfPeople)
            let tip = newTotal - amount
            tipPercentage = tip / amount
            if tipPercentage > 0 {
                tipLabel.text = String(format: "%.2f", tip)
            } else {
                tipLabel.text = " "
            }
            totalLabel.text = String(format: "%.2f", newTotal)
            splitLabel.text = String(format: "%.2f", split)
            adjustTipTextAndTipControl()
            Flurry.logEvent("split rounded up using swipe")
        }
    }
    
    func splitSwipedLeftView() {
        let amount = Double(amountField.text!) ?? 0
        if amount > 0 {
            var split = Double(splitLabel.text!) ?? 0
            
            if (split * Double(numberOfPeople)) > amount {     // then we have room to go down
                if split % 1 != 0 {  // split has decimal place so round down (or go to amount if rounding down goes below amount)
                    if (split * Double(numberOfPeople)) > amount { // room to go down
                        let potentialSplit = ceil(split) - 1
                        if (potentialSplit * Double(numberOfPeople)) >= amount {
                            split = potentialSplit
                        } else { // go to zero tip
                            split = amount / Double(numberOfPeople)
                        }
                    }
                } else if ((split - 1) * Double(numberOfPeople)) >= amount {
                    split -= 1
                } else { // calc zero tip use case
                    split = amount / Double(numberOfPeople)
                }
                
                // recalc total and tip and tip % based on new split
                let newTotal = split * Double(numberOfPeople)
                let tip = newTotal - amount
                tipPercentage = tip / amount
                if tipPercentage > 0 {
                    tipLabel.text = String(format: "%.2f", tip)
                } else {
                    tipLabel.text = " "
                }
                totalLabel.text = String(format: "%.2f", newTotal)
                splitLabel.text = String(format: "%.2f", split)
                adjustTipTextAndTipControl()
                Flurry.logEvent("split rounded down using swipe")
            }
        }
    }


}


