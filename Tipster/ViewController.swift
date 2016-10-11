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
    
    func UIColorFromHex(_ rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Flurry.startSession("JJGPHNJFH7C655XH7PR6")
        Flurry.logEvent("Launched application")
        
        // brief launch image special effect
        let screenSize: CGRect = UIScreen.main.bounds
        var redIconView, grayBackgroundView : UIImageView
        grayBackgroundView  = UIImageView(frame:CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height));
        grayBackgroundView.backgroundColor = UIColorFromHex(0xF4F4F4, alpha: 1.0)
        redIconView  = UIImageView(frame:CGRect(x: screenSize.width / 2 - 30, y: screenSize.height / 2 - 30, width: 60, height: 60));
        redIconView.image = UIImage(named:"RedIcon")
        self.view.addSubview(grayBackgroundView)
        self.view.addSubview(redIconView)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            UIView.animate(withDuration: 0.25, animations: {
                redIconView.alpha = 0.0
            })
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            UIView.animate(withDuration: 0.25, animations: {
                grayBackgroundView.alpha = 0.0
            })        }
        
        // customize nav bar
        navigationController!.navigationBar.barTintColor = UIColorFromHex(0x00A698, alpha: 1.0)
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController!.navigationBar.tintColor = UIColor.white
        
        // set panel color programmatically to try to match color of nav bar
        bottomPanelView.backgroundColor = UIColorFromHex(0x00A698, alpha: 1.0)
        tipControl.tintColor = UIColorFromHex(0x00A698, alpha: 1.0)
        tipLabel.textColor = UIColorFromHex(0x00A698, alpha: 1.0)
        totalLabel.textColor = UIColorFromHex(0x00A698, alpha: 1.0)
        
        // setup up swipe detection
        tipSwipeRightRec.direction = UISwipeGestureRecognizerDirection.right
        tipSwipeRightRec.addTarget(self, action: #selector(ViewController.tipSwipedRightView))
        tipSwipeView.addGestureRecognizer(tipSwipeRightRec)
        tipSwipeLeftRec.direction = UISwipeGestureRecognizerDirection.left
        tipSwipeLeftRec.addTarget(self, action: #selector(ViewController.tipSwipedLeftView))
        tipSwipeView.addGestureRecognizer(tipSwipeLeftRec)
        tipSwipeView.isUserInteractionEnabled = true
        
        totalSwipeRightRec.direction = UISwipeGestureRecognizerDirection.right
        totalSwipeRightRec.addTarget(self, action: #selector(ViewController.totalSwipedRightView))
        totalSwipeView.addGestureRecognizer(totalSwipeRightRec)
        totalSwipeLeftRec.direction = UISwipeGestureRecognizerDirection.left
        totalSwipeLeftRec.addTarget(self, action: #selector(ViewController.totalSwipedLeftView))
        totalSwipeView.addGestureRecognizer(totalSwipeLeftRec)
        totalSwipeView.isUserInteractionEnabled = true
        
        splitSwipeRightRec.direction = UISwipeGestureRecognizerDirection.right
        splitSwipeRightRec.addTarget(self, action: #selector(ViewController.splitSwipedRightView))
        splitSwipeView.addGestureRecognizer(splitSwipeRightRec)
        splitSwipeLeftRec.direction = UISwipeGestureRecognizerDirection.left
        splitSwipeLeftRec.addTarget(self, action: #selector(ViewController.splitSwipedLeftView))
        splitSwipeView.addGestureRecognizer(splitSwipeLeftRec)
        splitSwipeView.isUserInteractionEnabled = true
        
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "loadDefault")
        defaults.synchronize()
        
        decrementButton.isHidden = true
        decrementButton.adjustsImageWhenHighlighted = false
        incrementButton.adjustsImageWhenHighlighted = false
        splitTitleLabel.isHidden = true
        splitLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let defaults = UserDefaults.standard
        let loadDefault = defaults.bool(forKey: "loadDefault")
        
        // recalculate tipTitleLabel and tipLabel each time (in case there is a default or default change)
        // do not recalculate if simply going to the settings page and not making a change
        if loadDefault {
            tipControl.selectedSegmentIndex = defaults.integer(forKey: "tipDefault")
            tipPercentage = tipDefaultPercentages[tipControl.selectedSegmentIndex]
            calculateTip(nil)
            defaults.set(false, forKey: "loadDefault")
            defaults.synchronize()
        }
    }
    
    @IBAction func screenTapped(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func tipControlValueChanges(_ sender: AnyObject) {
        tipPercentage = tipDefaultPercentages[tipControl.selectedSegmentIndex]
        calculateTip(nil)
        
        view.endEditing(true)
        
        Flurry.logEvent("Tip changed using tipControl to index: " + String(tipControl.selectedSegmentIndex) + "; 0=15%; 1=18%; 2=20%")
    }
    
    @IBAction func incrementPeopleCount(_ sender: AnyObject) {
        if numberOfPeople < 16 {
            numberOfPeople += 1
            if numberOfPeople == 2 {
                decrementButton.isHidden = false
                // change image from whitecirclplus to whitecirclefilled
                if let image = UIImage(named: "WhiteCircleFilled") {
                    incrementButton.setImage(image, for: UIControlState())
                }
                // show split and split amount
                splitTitleLabel.isHidden = false
                splitLabel.isHidden = false
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
    
    @IBAction func decrementPeopleCount(_ sender: AnyObject) {
        if numberOfPeople > 1 {
            numberOfPeople -= 1
            peopleCount.text = String(numberOfPeople)
            if numberOfPeople == 1 {
                peopleCount.text = " "
                decrementButton.isHidden = true
                // change image from whitecirclplus to whitecirclefilled
                if let image = UIImage(named: "WhiteCirclePlus") {
                    incrementButton.setImage(image, for: UIControlState())
                }
                // hide split and split amount
                splitTitleLabel.isHidden = true
                splitLabel.isHidden = true
            }
            // recalc split
            let total = Double(totalLabel.text!) ?? 0
            if total > 0 {
                calculateSplit(total)
            }
            Flurry.logEvent("People decrement to: " + String(numberOfPeople))
        }
    }
    
    @IBAction func calculateTip(_ sender: AnyObject?) {
        let amount = Double(amountField.text!) ?? 0
        let tip = tipPercentage * amount
        let total = amount + tip
        let split = total / Double(numberOfPeople)
        
        if amount == 0 {
            tipLabel.text = " "
            totalLabel.text = " "
            splitLabel.text = " "
            self.view.viewWithTag(1)?.isHidden = true
            self.view.viewWithTag(2)?.isHidden = true
            self.view.viewWithTag(3)?.isHidden = true
            if tipControl.selectedSegmentIndex != -1 {
                tipTitleLabel.text = tipTitles[tipControl.selectedSegmentIndex]
            }
        } else {
            tipLabel.text = String(format: "%.2f", tip)
            totalLabel.text = String(format: "%.2f", total)
            splitLabel.text = String(format: "%.2f", split)
            self.view.viewWithTag(1)?.isHidden = false
            self.view.viewWithTag(2)?.isHidden = false
            calculateSplit(total)
            tipTitleLabel.text = "Tip (" + calculateTipPercentageString() + "%)"
        }
    }
    
    fileprivate func calculateSplit(_ total: Double) {
        let split = total / Double(numberOfPeople)
        splitLabel.text = String(format: "%.2f", split)
        self.view.viewWithTag(3)?.isHidden = false
    }
    
    func calculateTipPercentageString() -> String {
        let amount = Double(amountField.text!) ?? 0
        if tipPercentage > 0 {
            var tipPercentageString: String
            let tipPercentageRounded = round(tipPercentage*100*10)/10 // round to 10th decimal place
            if (tipPercentageRounded.truncatingRemainder(dividingBy: 1)) == 0 {
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
        view.endEditing(true)
        let amount = Double(amountField.text!) ?? 0
        if amount > 0 {
            var tip = Double(tipLabel.text!) ?? 0
            if tip.truncatingRemainder(dividingBy: 1) != 0 {
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
        view.endEditing(true)
        let amount = Double(amountField.text!) ?? 0
        if amount > 0 {
            var tip = Double(tipLabel.text!) ?? 0
            if tip.truncatingRemainder(dividingBy: 1) != 0 {
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
                tipControl.selectedSegmentIndex = tipDefaultPercentages.index(of: defaultTip)!
                break   // done finding match
            } else {
                tipControl.selectedSegmentIndex = -1
            }
        }
    }
    
    func totalSwipedRightView() {
        view.endEditing(true)
        let amount = Double(amountField.text!) ?? 0
        if amount > 0 {
            var tip = Double(tipLabel.text!) ?? 0
            var total = amount + tip
            if total.truncatingRemainder(dividingBy: 1) != 0 {
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
        view.endEditing(true)
        let amount = Double(amountField.text!) ?? 0
        if amount > 0 {
            var tip = Double(tipLabel.text!) ?? 0
            var total = amount + tip
            
            if total > amount {     // then we have room to go down
                if total.truncatingRemainder(dividingBy: 1) != 0 {  // total has decimal place so round down (or go to amount if rounding down goes below amount)
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
            if split.truncatingRemainder(dividingBy: 1) != 0 {
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
                if split.truncatingRemainder(dividingBy: 1) != 0 {  // split has decimal place so round down (or go to amount if rounding down goes below amount)
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
