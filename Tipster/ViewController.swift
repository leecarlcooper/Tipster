//
//  ViewController.swift
//  Tipster
//
//  Created by Lee Cooper on 8/7/16.
//  Copyright © 2016 Lee Cooper. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    var tipsterManager = TipsterManager()
    
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
        
        tipsterManager.delegate = self
        
        //MARK: - TODO: Migrate to Google Analytics
        // Setup basic app analytics with Flurry
        Flurry.startSession("JJGPHNJFH7C655XH7PR6")
        Flurry.logEvent("Launched application")
        
        // Brief launch image special effect
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
        
        // Customize nav bar
        navigationController!.navigationBar.barTintColor = UIColorFromHex(0x00A698, alpha: 1.0)
        navigationController!.navigationBar.titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.foregroundColor.rawValue: UIColor.white])
        navigationController!.navigationBar.tintColor = UIColor.white
        
        // Set panel color programmatically to try to match color of nav bar
        bottomPanelView.backgroundColor = UIColorFromHex(0x00A698, alpha: 1.0)
        tipControl.tintColor = UIColorFromHex(0x00A698, alpha: 1.0)
        tipLabel.textColor = UIColorFromHex(0x00A698, alpha: 1.0)
        totalLabel.textColor = UIColorFromHex(0x00A698, alpha: 1.0)
        
        setUpSwipeDetection()
        
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "loadDefault")
        defaults.synchronize()
        
        // Hide Split initially when People = 1
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
        
        // Recalculate tipTitleLabel and tipLabel each time (in case there is a default or default change)
        // do not recalculate if simply going to the settings page and not making a change
        if loadDefault {
            tipControl.selectedSegmentIndex = defaults.integer(forKey: "tipDefault")
            tipsterManager.tipPercentage = tipsterManager.tipDefaultPercentages[tipControl.selectedSegmentIndex]
            calculateTip(nil)
            defaults.set(false, forKey: "loadDefault")
            defaults.synchronize()
        }
    }
    
    func setUpSwipeDetection() {
        
        tipSwipeRightRec.direction = UISwipeGestureRecognizer.Direction.right
        tipSwipeRightRec.addTarget(self, action: #selector(ViewController.tipSwipedRightView))
        tipSwipeView.addGestureRecognizer(tipSwipeRightRec)
        tipSwipeLeftRec.direction = UISwipeGestureRecognizer.Direction.left
        tipSwipeLeftRec.addTarget(self, action: #selector(ViewController.tipSwipedLeftView))
        tipSwipeView.addGestureRecognizer(tipSwipeLeftRec)
        tipSwipeView.isUserInteractionEnabled = true
        
        totalSwipeRightRec.direction = UISwipeGestureRecognizer.Direction.right
        totalSwipeRightRec.addTarget(self, action: #selector(ViewController.totalSwipedRightView))
        totalSwipeView.addGestureRecognizer(totalSwipeRightRec)
        totalSwipeLeftRec.direction = UISwipeGestureRecognizer.Direction.left
        totalSwipeLeftRec.addTarget(self, action: #selector(ViewController.totalSwipedLeftView))
        totalSwipeView.addGestureRecognizer(totalSwipeLeftRec)
        totalSwipeView.isUserInteractionEnabled = true
        
        splitSwipeRightRec.direction = UISwipeGestureRecognizer.Direction.right
        splitSwipeRightRec.addTarget(self, action: #selector(ViewController.splitSwipedRightView))
        splitSwipeView.addGestureRecognizer(splitSwipeRightRec)
        splitSwipeLeftRec.direction = UISwipeGestureRecognizer.Direction.left
        splitSwipeLeftRec.addTarget(self, action: #selector(ViewController.splitSwipedLeftView))
        splitSwipeView.addGestureRecognizer(splitSwipeLeftRec)
        splitSwipeView.isUserInteractionEnabled = true
    }
    
    @IBAction func amountChanged(_ sender: UITextField) {        
        let amountValue = Double(amountField.text!) ?? 0
        tipsterManager.amountUpdated(to: amountValue)
        
        calculateTip(nil)
    }
    
    // Dismiss keyboard when screen is tapped (and presumably subtotal amount is entered)
    @IBAction func screenTapped(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    //MARK: - Swipe detection related methods
    //MARK: - Update model
    @objc func tipSwipedRightView() {
        view.endEditing(true)
        let amount = Double(amountField.text!) ?? 0
        if amount > 0 {
            var tip = Double(tipLabel.text!) ?? 0
            if tip.truncatingRemainder(dividingBy: 1) != 0 {
                tip = ceil(tip)
            } else {
                tip += 1
            }
            tipsterManager.tipPercentage = tip / amount
            tipLabel.text = String(format: "%.2f", tip)
            let total = amount + tip
            totalLabel.text = String(format: "%.2f", total)
            adjustTipTextAndTipControl()
            calculateSplit(total)
        }
    }
    
    //MARK: - Update model
    @objc func tipSwipedLeftView() {
        view.endEditing(true)
        let amount = Double(amountField.text!) ?? 0
        if amount > 0 {
            var tip = Double(tipLabel.text!) ?? 0
            if tip.truncatingRemainder(dividingBy: 1) != 0 {
                tip = ceil(tip) - 1
            } else if tipsterManager.tipPercentage > 0 {
                tip -= 1
            }
            
            tipsterManager.tipPercentage = tip / amount
            let total = amount + tip
            totalLabel.text = String(format: "%.2f", total)
            
            if tipsterManager.tipPercentage > 0 {
                tipLabel.text = String(format: "%.2f", tip)
            } else {
                tipLabel.text = " "
            }
            adjustTipTextAndTipControl()
            calculateSplit(total)
        }
    }
    
    //MARK: - Update model
    @objc func totalSwipedRightView() {
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
            
            tipsterManager.tipPercentage = tip / amount
            tipLabel.text = String(format: "%.2f", tip)
            totalLabel.text = String(format: "%.2f", total)
            adjustTipTextAndTipControl()
            calculateSplit(total)
        }
    }
    
    //MARK: - Update model
    @objc func totalSwipedLeftView() {
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
                tipsterManager.tipPercentage = tip / amount
                totalLabel.text = String(format: "%.2f", total)
                if tipsterManager.tipPercentage > 0 {
                    tipLabel.text = String(format: "%.2f", tip)
                } else {
                    tipLabel.text = " "
                }
                adjustTipTextAndTipControl()
                calculateSplit(total)
            }
        }
    }
    
    @objc func splitSwipedRightView() {
        tipsterManager.splitRoundUp()
    }
    
    @objc func splitSwipedLeftView() {
        tipsterManager.splitRoundDown()
    }
    
    //MARK: - update Model
    @IBAction func tipControlValueChanges(_ sender: AnyObject) {
        tipsterManager.tipPercentage = tipsterManager.tipDefaultPercentages[tipControl.selectedSegmentIndex]
        calculateTip(nil)
        
        view.endEditing(true)
    }
    
    //MARK: - People Count Change
    @IBAction func incrementPeopleCount(_ sender: AnyObject) {
        tipsterManager.peopleIncremented()
        
        if decrementButton.isHidden == true {
            decrementButton.isHidden = false
            // change people plus button to people count
            if let image = UIImage(named: "WhiteCircleFilled") {
                incrementButton.setImage(image, for: UIControl.State())
            }
            // show split and split amount if more than one person
            splitTitleLabel.isHidden = false
            splitLabel.isHidden = false
        }
    }
    
    @IBAction func decrementPeopleCount(_ sender: AnyObject) {
        tipsterManager.peopleDecremented()
        
        if tipsterManager.people == 1 {
            peopleCount.text = " "
            decrementButton.isHidden = true
            // change image from whitecirclplus to whitecirclefilled
            if let image = UIImage(named: "WhiteCirclePlus") {
                incrementButton.setImage(image, for: UIControl.State())
            }
            // hide split and split amount
            splitTitleLabel.isHidden = true
            splitLabel.isHidden = true
        }
    }
    
    //MARK: - TODO: abstract all the calculation to Model
    func calculateTip(_ sender: AnyObject?) {
        let amount = Double(amountField.text!) ?? 0
        let tip = tipsterManager.tipPercentage * amount
        let total = amount + tip
        let split = total / Double(tipsterManager.people)
        
        if amount == 0 {
            tipLabel.text = " "
            totalLabel.text = " "
            splitLabel.text = " "
            self.view.viewWithTag(1)?.isHidden = true
            self.view.viewWithTag(2)?.isHidden = true
            self.view.viewWithTag(3)?.isHidden = true
            if tipControl.selectedSegmentIndex != -1 {
                tipTitleLabel.text = tipsterManager.tipTitles[tipControl.selectedSegmentIndex]
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
        let split = total / Double(tipsterManager.people)
        splitLabel.text = String(format: "%.2f", split)
        self.view.viewWithTag(3)?.isHidden = false
    }
    
    func calculateTipPercentageString() -> String {
        let amount = Double(amountField.text!) ?? 0
        if tipsterManager.tipPercentage > 0 {
            var tipPercentageString: String
            let tipPercentageRounded = round(tipsterManager.tipPercentage*100*10)/10 // round to 10th decimal place
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
    
    //MARK: - TODO: extract out routine to adjust tip segment control as various values are being adjusted
    func adjustTipTextAndTipControl() {
        // recalc the Tip title %
        tipTitleLabel.text = "Tip (" + calculateTipPercentageString() + "%)"
        
        // enable/disable the tip control as appropriate
        for defaultTip in tipsterManager.tipDefaultPercentages {
            if tipsterManager.tipPercentage == defaultTip {
                tipControl.selectedSegmentIndex = tipsterManager.tipDefaultPercentages.firstIndex(of: defaultTip)!
                break   // done finding match
            } else {
                tipControl.selectedSegmentIndex = -1
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

//MARK: - TipsterManagerDelegate

extension ViewController: TipsterManagerDelegate {
    
    func didUpdateNumbers(tip: String, tipPercentage: String, total: String, people: Int, split: String) {
        tipTitleLabel.text = "Tip (" + tipPercentage + "%)"
        if tip == "0.00" {
            tipLabel.text = " "
        } else {
            tipLabel.text = tip
        }
        totalLabel.text = total
        if (people > 1) {
            peopleCount.text = String(people)
            splitTitleLabel.text = "Split"
            splitLabel.text = split
        }
        
        //                if tipsterManager.tipPercentage > 0 {
        //                    tipLabel.text = String(format: "%.2f", tip)
        //                } else {
        //                    tipLabel.text = " "
        //                }
        //                adjustTipTextAndTipControl()

        
    }
    
}
