//
//  BoardButton.swift
//  Crossword
//
//  Created by Tyler Stickler on 10/26/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit

class BoardButton: UIButton {
    var superscriptLabel = UILabel()
    var hintLabel = UILabel()
        
    var numberConstraints = [NSLayoutConstraint]()
    var hintConstraints = [NSLayoutConstraint]()
    
    // Adds an ! for the button if it should show the user a hint
    func showHintLabel() {
        self.addSubview(hintLabel)
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        hintLabel.text = "!"
        hintLabel.textColor = UIColor.init(red: 255/255, green: 150/255, blue: 176/255, alpha: 1)
        
        hintLabel.font = hintLabel.font.withSize(16)
        // Put the ! on the top right corner
        hintConstraints.append(NSLayoutConstraint(item: self.hintLabel, attribute: .trailing, relatedBy: .equal, toItem: self,
                                                  attribute: .trailing, multiplier: 1.0, constant: -2))
        
        hintConstraints.append(NSLayoutConstraint(item: self.hintLabel, attribute: .top, relatedBy: .equal, toItem: self,
                                                  attribute: .top, multiplier: 1.0, constant: 1))
        
        NSLayoutConstraint.activate(hintConstraints)
        self.layoutIfNeeded()
    }
    
    // Adds number superscript to idicate beginning of phrase
    func setSuperScriptLabel(number: String) {
        self.addSubview(superscriptLabel)
        superscriptLabel.translatesAutoresizingMaskIntoConstraints = false
        superscriptLabel.text = number
        if UIScreen.main.bounds.height < 813 {
            superscriptLabel.font = superscriptLabel.font.withSize(8)
        } else {
            superscriptLabel.font = superscriptLabel.font.withSize(10)
        }
        
        // Put the number on the top  left corner
        numberConstraints.append(NSLayoutConstraint(item: self.superscriptLabel, attribute: .leading, relatedBy: .equal, toItem: self,
                                                    attribute: .leading, multiplier: 1.0, constant: 1))

        numberConstraints.append(NSLayoutConstraint(item: self.superscriptLabel, attribute: .top, relatedBy: .equal, toItem: self,
                                                    attribute: .top, multiplier: 1.0, constant: 1))

        NSLayoutConstraint.activate(numberConstraints)
    }
    
    func setTitleWithOutAnimation(title: String?) {
        // Removes animation when setting button titles
        UIView.setAnimationsEnabled(false)
        
        setTitle(title, for: .normal)
        
        layoutIfNeeded()
        UIView.setAnimationsEnabled(true)
    }
}
