//
//  LockedViewController.swift
//  Crossword
//
//  Created by Tyler Stickler on 12/8/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit

class LockedViewController: UIViewController, UIGestureRecognizerDelegate {
    var selectedLockedLevel: Int!
    var countNeededToUnlock: Int!
    
    @IBOutlet var backButton: UIButton!
    @IBOutlet var background: UIView!
    @IBOutlet var lockedLabel: UILabel!
    @IBAction func okayButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the selected locked level
        let indexOfPresenter = (self.presentingViewController?.childViewControllers.count)! - 1
        if let parentVC = self.presentingViewController?.childViewControllers[indexOfPresenter] as? LevelsViewController {
            selectedLockedLevel = parentVC.selectedLevel
        }
        
        // Find out how many levels are needed before that level unlocks
        var countNeededToUnlock = 1
        for level in Settings.lockedLevels {
            if level < selectedLockedLevel {
                countNeededToUnlock += 1
            }
        }
        
        // Set the label properly
        if countNeededToUnlock == 1 {
            lockedLabel.text = "Level \(selectedLockedLevel!) is locked! Complete \(countNeededToUnlock) other level to unlock this level."
        } else {
            lockedLabel.text = "Level \(selectedLockedLevel!) is locked! Complete \(countNeededToUnlock) other levels to unlock this level."
        }

        background.layer.borderColor = UIColor.red.cgColor
        background.layer.borderWidth = 3
        background.layer.cornerRadius = 20
        
        backButton.layer.borderColor = UIColor.white.cgColor
        backButton.layer.borderWidth = 2
        backButton.layer.cornerRadius = 5
        
    }
    
    // Gesture recognizer control
    @IBAction func backgroundTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Gives bounds the user can tap to close the menu. These bounds are only outside of the menu
    // background. Any taps inside the bounds won't close the menu.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if background.frame.contains(touch.location(in: view)) {
            return false
        }
        return true
    }
}
