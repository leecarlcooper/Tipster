//
//  TipsterManager.swift
//  Tipster
//
//  Created by Lee Cooper on 4/22/20.
//  Copyright © 2020 Lee Cooper. All rights reserved.
//

import Foundation

protocol TipsterManagerDelegate {
    func didUpdateNumbers(tip: String, tipPercentage: String, total: String, people: Int, split: String)
}

struct TipsterManager {
    var delegate: TipsterManagerDelegate?
    
    //MARK: - TODO: updated based on constants
    let tipTitles = ["Tip (15%)", "Tip (18%)", "Tip (20%)"]
    let tipDefaultPercentages = [K.lowTipPercentage, K.midTipPercentage, K.highTipPercentage]
    
    var amount = 0.0
    var tip = 0.0
    var tipPercentage = 15.0
    var defaultTipPercentage = 15.0
    var total = 0.0
    var people = 1
    var split = 0.0
    
    mutating func splitRoundUp() {
        print("manager: split round up")
        
        if amount > 0 {
            if split.truncatingRemainder(dividingBy: 1) != 0 {
                split = ceil(split)
            } else {
                split += 1
            }
            
            // recalc total, tip, tipPercentage
            total = split * Double(people)
            tip = total - amount
            tipPercentage = tip / amount
            
            delegate?.didUpdateNumbers(
                tip: String(format: "%.1f", tip),
                tipPercentage: String(format: "%.1f", tipPercentage),
                total: String(format: "%.1f", total),
                people: people,
                split: String(format: "%.1f", split)
            )
        }
    }
    
}


//let amount = Double(amountField.text!) ?? 0
//if amount > 0 {
//    var split = Double(splitLabel.text!) ?? 0
//    if split.truncatingRemainder(dividingBy: 1) != 0 {
//        split = ceil(split)
//    } else {
//        split += 1
//    }
//    // recalc total and tip and tip % based on new split
//    let newTotal = split * Double(tipsterManager.people)
//    let tip = newTotal - amount
//    tipsterManager.tipPercentage = tip / amount
//    if tipsterManager.tipPercentage > 0 {
//        tipLabel.text = String(format: "%.2f", tip)
//    } else {
//        tipLabel.text = " "
//    }
//    totalLabel.text = String(format: "%.2f", newTotal)
//    splitLabel.text = String(format: "%.2f", split)
//    adjustTipTextAndTipControl()
