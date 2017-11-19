//
//  HintViewController.swift
//  Crossword
//
//  Created by Tyler Stickler on 11/12/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit

class HintViewController: UIViewController, UIGestureRecognizerDelegate {
    // UI elements
    @IBOutlet var hintBackground: UIView!
    @IBOutlet var emojiLabel: UILabel!
    @IBOutlet var clueNumberLabel: UILabel!
    @IBOutlet var wordCountLabel: UILabel!
    @IBOutlet var hintLabel: UILabel!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var letterCountLabel: UILabel!
    
    var emoji: String!
    var clueNumber: String!
    var wordCount: String!
    var hint: String!
    var letterCount: String!
    var screenSize = UIScreen.main.bounds
    
    @IBAction func backButtonTapped(_ sender: Any) {
        // Return to presenting view
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()

        // Displays the hint information to the user
        emojiLabel.text = emoji
        clueNumberLabel.text = clueNumber
        hintLabel.text = hint
        letterCountLabel.text = ("Letters: \(letterCount!)")
        
        if wordCount != "abv." {
            wordCountLabel.text = ("Words: \(wordCount!)")
        } else {
            wordCountLabel.text = wordCount
        }
    }
    
    func setUpUI() {
        // Size of the emoji label should depend on screen size
        switch screenSize.height {
        case 568:
            emojiLabel.font = emojiLabel.font.withSize(40)
        case 667, 812:
            emojiLabel.font = emojiLabel.font.withSize(50)
        case 736:
            emojiLabel.font = emojiLabel.font.withSize(55)
        default:
            emojiLabel.font = emojiLabel.font.withSize(50)
        }
        
        // Gives the background border a nice color/shape
        hintBackground.layer.cornerRadius = 15
        hintBackground.layer.borderWidth = 3
        hintBackground.layer.borderColor = UIColor.init(red: 255/255, green: 150/255, blue: 176/255, alpha: 1).cgColor
        
        // Gives the button a nice color/shape
        backButton.layer.borderWidth = 1
        backButton.layer.cornerRadius = 3
        backButton.layer.borderColor = UIColor.init(red: 255/255, green: 150/255, blue: 176/255, alpha: 1).cgColor
    }
    
    // Gesture recognizers
    @IBAction func backgroundTapped(_ sender: Any) {
        backButton.sendActions(for: .touchUpInside)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if hintBackground.frame.contains(touch.location(in: view)) {
            return false
        }
        return true
    }
}
