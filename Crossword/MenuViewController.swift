//
//  MenuViewController.swift
//  Crossword
//
//  Created by Tyler Stickler on 10/25/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit
import AVFoundation

class MenuViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet var menuBackground: UIView!
    
    @IBOutlet var backButton: UIButton!
    @IBOutlet var homeButton: UIButton!
    
    @IBOutlet var musicSwitch: UISwitch!
    @IBOutlet var soundEffectsSwitch: UISwitch!
    @IBOutlet var timerSwitch: UISwitch!
    @IBOutlet var skipFilledSwitch: UISwitch!
    @IBOutlet var lockCorrectSwitch: UISwitch!
    @IBOutlet var correctAnimationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuBackground.layer.cornerRadius = 15
        menuBackground.layer.borderWidth = 3
        menuBackground.layer.borderColor = UIColor.init(red: 96/255, green: 199/255, blue: 255/255, alpha: 1).cgColor
        
        backButton.layer.borderWidth = 1
        backButton.layer.cornerRadius = 3
        backButton.layer.borderColor = UIColor.init(red: 96/255, green: 199/255, blue: 255/255, alpha: 1).cgColor
        
        homeButton.layer.borderWidth = 1
        homeButton.layer.cornerRadius = 3
        homeButton.layer.borderColor = UIColor.init(red: 96/255, green: 199/255, blue: 255/255, alpha: 1).cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setSwitches()
        
    }

    // Returns selected information back to parent view
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Sets initial state of switches on loading
    func setSwitches() {
        musicSwitch.setOn(Settings.musicEnabled, animated: false)
        soundEffectsSwitch.setOn(Settings.soundEffects, animated: false)
        timerSwitch.setOn(Settings.showTimer, animated: false)
        skipFilledSwitch.setOn(Settings.skipFilledSquares, animated: false)
        lockCorrectSwitch.setOn(Settings.lockCorrect, animated: false)
        correctAnimationSwitch.setOn(Settings.correctAnim, animated: false)
    }
    
    // Switch toggling
    @IBAction func musicSwitchToggled(_ sender: Any) {
        if musicSwitch.isOn == true {
            Settings.musicEnabled = true
            MusicPlayer.musicPlayer.setVolume(1.0, fadeDuration: 1.0)
        } else {
            Settings.musicEnabled = false
            MusicPlayer.musicPlayer.setVolume(0, fadeDuration: 1.0)
        }
    }
    @IBAction func soundEffectsToggled(_ sender: Any) {
        if soundEffectsSwitch.isOn == true {
            Settings.soundEffects = true
        } else {
            Settings.soundEffects = false
        }
    }
    @IBAction func timerToggled(_ sender: Any) {
        if timerSwitch.isOn == true {
            Settings.showTimer = true
            if let parentVC = presentingViewController as? GameViewController {
                parentVC.timerStack.isHidden = false
            }
        } else {
            Settings.showTimer = false
            if let parentVC = presentingViewController as? GameViewController {
                parentVC.timerStack.isHidden = true
            }
        }
    }
    @IBAction func skipFilledToggled(_ sender: Any) {
        if skipFilledSwitch.isOn == true {
            Settings.skipFilledSquares = true
        } else {
            Settings.skipFilledSquares = false
        }
    }
    @IBAction func lockCorrectToggled(_ sender: Any) {
        if lockCorrectSwitch.isOn == true {
            Settings.lockCorrect = true
        } else {
            Settings.lockCorrect = false
        }
    }
    @IBAction func correctAnimationToggled(_ sender: Any) {
        if correctAnimationSwitch.isOn == true {
            Settings.correctAnim = true
        } else {
            Settings.correctAnim = false
        }
    }
    
    // Gesture recognizers
    @IBAction func backgroundTapped(_ sender: Any) {
        backButton.sendActions(for: .touchUpInside)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if menuBackground.frame.contains(touch.location(in: view)) {
            return false
        }
        return true
    }
}
