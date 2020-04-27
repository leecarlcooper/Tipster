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
        
        // have to set selected text color starting in iOS 13
        tipControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        
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
            tipsterManager.tipValueSelected(segment: tipControl.selectedSegmentIndex)
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
        
//        calculateTip(nil)
    }
    
    // Dismiss keyboard when screen is tapped (and presumably subtotal amount is entered)
    @IBAction func screenTapped(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    //MARK: - Swipe detection related methods
    @objc func tipSwipedRightView() {
        view.endEditing(true)
        tipsterManager.tipRoundUp()
    }
    
    @objc func tipSwipedLeftView() {
        view.endEditing(true)
        tipsterManager.tipRoundDown()
    }
    
    @objc func totalSwipedRightView() {
        view.endEditing(true)
        tipsterManager.totalRoundUp()
    }
    
    @objc func totalSwipedLeftView() {
        view.endEditing(true)
        tipsterManager.totalRoundDown()
    }
    
    @objc func splitSwipedRightView() {
        tipsterManager.splitRoundUp()
    }
    
    @objc func splitSwipedLeftView() {
        tipsterManager.splitRoundDown()
    }
    
    @IBAction func tipControlValueChanges(_ sender: AnyObject) {
        view.endEditing(true)
        tipsterManager.tipValueSelected(segment: tipControl.selectedSegmentIndex)
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
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

//MARK: - TipsterManagerDelegate

extension ViewController: TipsterManagerDelegate {
    
    func didUpdateNumbers(tip: String, tipPercentage: String, tipSegment: Int, total: String, people: Int, split: String) {
        tipTitleLabel.text = "Tip (" + tipPercentage + "%)"
        if tip == "0.00" {
            tipLabel.text = " "
        } else {
            tipLabel.text = tip
        }
        if total == "0.00" {
            totalLabel.text = " "
        } else {
            totalLabel.text = total
        }
        tipControl.selectedSegmentIndex = tipSegment
        if (people > 1) {
            peopleCount.text = String(people)
            splitTitleLabel.text = "Split"
            splitLabel.text = split
        }
        
        //MARK: - TODO
        //        // enable/disable the tip control as appropriate
        //        for defaultTip in tipsterManager.tipDefaultPercentages {
        //            if tipsterManager.tipPercentage == defaultTip {
        //                tipControl.selectedSegmentIndex = tipsterManager.tipDefaultPercentages.firstIndex(of: defaultTip)!
        //                break   // done finding match
        //            } else {
        //                tipControl.selectedSegmentIndex = -1
        //            }
    }
    
}
