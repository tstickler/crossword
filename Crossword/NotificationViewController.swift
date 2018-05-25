//
//  NotificationViewController.swift
//  Crossword
//
//  Created by Tyler Stickler on 12/8/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController, UIGestureRecognizerDelegate {
    var notificationsInfo: Dictionary<String, Any>!
    
    @IBOutlet var emoji: UILabel!
    @IBOutlet var background: UIView!
    @IBOutlet var notificationLabel: UILabel!
    @IBOutlet var okayButton: UIButton!
    @IBAction func okayButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        background.layer.borderColor = UIColor.init(red: 255/255, green: 150/255, blue: 176/255, alpha: 1).cgColor
        background.layer.borderWidth = 3
        background.layer.cornerRadius = 20
        
        okayButton.layer.borderColor = UIColor.white.cgColor
        okayButton.layer.borderWidth = 2
        okayButton.layer.cornerRadius = 5
        
        notificationLabel.text = notificationsInfo["message"] as? String
        emoji.text = notificationsInfo["emoji"] as? String
        Settings.cheatCount += notificationsInfo["award"] as! Int
    }
    
    // Gesture recognizer control
    @IBAction func backgroundTapped(_ sender: Any) {
        okayButton.sendActions(for: .touchUpInside)
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
