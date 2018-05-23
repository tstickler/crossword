//
//  LevelButton.swift
//  Crossword
//
//  Created by Tyler Stickler on 12/5/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit

class LevelButton: UIButton {
    var levelStatus = UIImageView()
    
    var levelStatusConstraints = [NSLayoutConstraint]()

    var statusInsetConstant: CGFloat!
    
    func setLevelStatus(_ status: String) {
        self.addSubview(levelStatus)
        
        levelStatus.layer.opacity = 0.85
        levelStatus.image = UIImage(named: "\(status).png")
        levelStatus.contentMode = .scaleAspectFit
        levelStatus.translatesAutoresizingMaskIntoConstraints = false

        if UIScreen.main.bounds.height == 568 {
            statusInsetConstant = 10.0
        } else {
            statusInsetConstant = 15.0
        }
        
        self.isEnabled = true
        
        levelStatusConstraints.append(NSLayoutConstraint(item: self.levelStatus, attribute: .leading, relatedBy: .equal, toItem: self,
                                                        attribute: .leading, multiplier: 1.0, constant: statusInsetConstant))
        
        levelStatusConstraints.append(NSLayoutConstraint(item: self.levelStatus, attribute: .trailing, relatedBy: .equal, toItem: self,
                                                        attribute: .trailing, multiplier: 1.0, constant: -statusInsetConstant))
                
        levelStatusConstraints.append(NSLayoutConstraint(item: self.levelStatus, attribute: .centerY, relatedBy: .equal, toItem: self,
                                                         attribute: .centerY, multiplier: 1.0, constant: 0))
        
        levelStatusConstraints.append(NSLayoutConstraint(item: self.levelStatus, attribute: .height, relatedBy: .equal, toItem: self.levelStatus,
                                                        attribute: .height, multiplier: 1.0, constant: 0))


        
        NSLayoutConstraint.activate(levelStatusConstraints)
    }
    
    func setNewIndicator() {
        let newIndicator = UIImageView()
        var newIndicatorConstraints = [NSLayoutConstraint]()
        var insetConstant: CGFloat
        
        newIndicator.image = UIImage(named: "new_indicator.png")
        newIndicator.contentMode = .scaleAspectFit
        newIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(newIndicator)
        
        if UIScreen.main.bounds.height == 568 {
            insetConstant = 40.0
        } else {
            insetConstant = 50.0
        }
        
        newIndicatorConstraints.append(NSLayoutConstraint(item: newIndicator, attribute: .leading, relatedBy: .equal, toItem: self,
                                                         attribute: .leading, multiplier: 1.0, constant: insetConstant))
        
        newIndicatorConstraints.append(NSLayoutConstraint(item: newIndicator, attribute: .trailing, relatedBy: .equal, toItem: self,
                                                          attribute: .trailing, multiplier: 1.0, constant: 10))

        newIndicatorConstraints.append(NSLayoutConstraint(item: newIndicator, attribute: .centerY, relatedBy: .equal, toItem: self,
                                                          attribute: .top, multiplier: 1.0, constant: 0))
        
        newIndicatorConstraints.append(NSLayoutConstraint(item: newIndicator, attribute: .height, relatedBy: .equal, toItem: newIndicator,
                                                         attribute: .height, multiplier: 1.0, constant: 0))
        
        NSLayoutConstraint.activate(newIndicatorConstraints)
    }
    
    func removeNewIndicator() {
        
    }
}

