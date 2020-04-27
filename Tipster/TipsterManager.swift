//
//  TipsterManager.swift
//  Tipster
//
//  Created by Lee Cooper on 4/22/20.
//  Copyright © 2020 Lee Cooper. All rights reserved.
//

import Foundation

protocol TipsterManagerDelegate {
    func didUpdateNumbers(tip: String, tipPercentage: String, tipSegment: Int, total: String, people: Int, split: String)
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
    
    //MARK: - Changes in values
    mutating func amountUpdated(to amountValue: Double) {
        amount = amountValue
        tip = amount * tipPercentage
        total = amount + tip
        split = total / Double(people)
        
        updateNumbersOnUI()
    }
    
    mutating func tipRoundUp() {
        if amount > 0 {
            if tip.truncatingRemainder(dividingBy: 1) != 0 {
                tip = ceil(tip)
            } else {
                tip += 1
            }
            tipPercentage = tip / amount
            total = amount + tip
            split = total / Double(people)

            updateNumbersOnUI()
        }
    }
    
    mutating func tipRoundDown() {
        if amount > 0 {
            if tip.truncatingRemainder(dividingBy: 1) != 0 {
                tip = ceil(tip) - 1
            } else if tipPercentage > 0 {
                tip -= 1
            }
            tipPercentage = tip / amount
            total = amount + tip
            split = total / Double(people)

            updateNumbersOnUI()
        }
    }
    
    mutating func totalRoundUp() {
        if amount > 0 {
            if total.truncatingRemainder(dividingBy: 1) != 0 {
                total = ceil(total)
            } else {
                total += 1
            }
            tip = total - amount
            tipPercentage = tip / amount
            split = total / Double(people)
            
            updateNumbersOnUI()
        }
    }
    
    mutating func totalRoundDown() {
        if amount > 0 {
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
                split = total / Double(people)
                
                updateNumbersOnUI()
            }
        }
    }
    
    mutating func tipValueSelected(segment arrayElement: Int) {
        tipPercentage = tipDefaultPercentages[arrayElement]
        tip = amount * tipPercentage
        total = amount + tip
        split = total / Double(people)

        updateNumbersOnUI()
    }
    
    mutating func peopleIncremented() {
        if people < K.maxPeople {
            people += 1
        }
        split = total / Double(people)
        
        updateNumbersOnUI()
    }
    
    mutating func peopleDecremented() {
        people -= 1
        split = total / Double(people)
        
        updateNumbersOnUI()
    }
    
    mutating func splitRoundUp() {
        if amount > 0 {
            if split.truncatingRemainder(dividingBy: 1) != 0 {
                split = ceil(split)
            } else {
                split += 1
            }
            total = split * Double(people)
            tip = total - amount
            tipPercentage = tip / amount
            
            updateNumbersOnUI()
        }
    }
    
    mutating func splitRoundDown() {
        if amount > 0 {
            if (split * Double(people)) > amount {    // then we have room to go down
                if split.truncatingRemainder(dividingBy: 1) != 0 {  // split has decimal place so round down (or go to amount if rounding down goes below amount)
                    let potentialSplit = ceil(split) - 1
                    if (potentialSplit * Double(people)) >= amount {
                        split = potentialSplit
                    } else { // go to zero tip
                        split = amount / Double(people)
                    }
                } else if ((split - 1) * Double(people)) >= amount {
                    split -= 1
                } else { // calc zero tip use case
                    split = amount / Double(people)
                }
                total = split * Double(people)
                tip = total - amount
                tipPercentage = tip / amount
                
                updateNumbersOnUI()
            }
        }
    }
    
    //MARK: - Misc methods
    func calculateTipPercentageString() -> String {
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
    
    //MARK: - Update UI
    func updateNumbersOnUI() {
        var tipSegment = -1
        switch tipPercentage {
        case K.lowTipPercentage:
            tipSegment = 0
        case K.midTipPercentage:
            tipSegment = 1
        case K.highTipPercentage:
            tipSegment = 2
        default:
            tipSegment = -1
        }
        delegate?.didUpdateNumbers(
            tip: String(format: "%.2f", tip),
            tipPercentage: calculateTipPercentageString(),
            tipSegment: Int(tipSegment),
            total: String(format: "%.2f", total),
            people: people,
            split: String(format: "%.2f", split)
        )
    }
    
}

