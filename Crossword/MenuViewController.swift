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
    // Allows saving the user preferences on the device
    let defaults = UserDefaults.standard

    // Frame to display the settings
    @IBOutlet var menuBackground: UIView!
    
    // Navigation buttons. Back goes to the game, home goes to homescreen.
    @IBOutlet var backButton: UIButton!
    @IBOutlet var homeButton: UIButton!
    
    // Switches to adjust preferences
    @IBOutlet var musicSwitch: UISwitch!
    @IBOutlet var soundEffectsSwitch: UISwitch!
    @IBOutlet var timerSwitch: UISwitch!
    @IBOutlet var skipFilledSwitch: UISwitch!
    @IBOutlet var lockCorrectSwitch: UISwitch!
    @IBOutlet var correctAnimationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up UI for user to interact with
        setUpMenuUI()
        
        // Switches are set to positions based on the settings
        setSwitches()
    }

    // Close the view and return back to the game
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
        // Flipping the switch should immediately start or stop the music
        if musicSwitch.isOn == true {
            Settings.musicEnabled = true
            MusicPlayer.musicPlayer.setVolume(1.0, fadeDuration: 1.0)
        } else {
            Settings.musicEnabled = false
            MusicPlayer.musicPlayer.setVolume(0, fadeDuration: 1.0)
        }
        
        // Save the state of the setting
        // Saving it when switch is toggled allows keeping the setting information
        // even if the app were to crash or the user closes it without exiting the
        // view.
        defaults.set(Settings.musicEnabled, forKey: "musicEnabled")
    }
    @IBAction func soundEffectsToggled(_ sender: Any) {
        if soundEffectsSwitch.isOn == true {
            Settings.soundEffects = true
        } else {
            Settings.soundEffects = false
        }
        
        // Save the state of the setting
        defaults.set(Settings.soundEffects, forKey: "soundEffects")
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
        
        // Save the state of the setting
        defaults.set(Settings.showTimer, forKey: "showTimer")
    }
    @IBAction func skipFilledToggled(_ sender: Any) {
        if skipFilledSwitch.isOn == true {
            Settings.skipFilledSquares = true
        } else {
            Settings.skipFilledSquares = false
        }
        
        // Save the state of the setting
        defaults.set(Settings.skipFilledSquares, forKey: "skipFilledSquares")
    }
    @IBAction func lockCorrectToggled(_ sender: Any) {
        if lockCorrectSwitch.isOn == true {
            Settings.lockCorrect = true
        } else {
            Settings.lockCorrect = false
        }
        
        // Save the state of the setting
        defaults.set(Settings.lockCorrect, forKey: "lockCorrect")
    }
    @IBAction func correctAnimationToggled(_ sender: Any) {
        if correctAnimationSwitch.isOn == true {
            Settings.correctAnim = true
        } else {
            Settings.correctAnim = false
        }
        
        // Save the state of the setting
        defaults.set(Settings.correctAnim, forKey: "correctAnim")
    }
    
    // Gesture recognizer control
    @IBAction func backgroundTapped(_ sender: Any) {
        backButton.sendActions(for: .touchUpInside)
    }
    
    // Gives bounds the user can tap to close the menu. These bounds are only outside of the menu
    // background. Any taps inside the bounds won't close the menu.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if menuBackground.frame.contains(touch.location(in: view)) {
            return false
        }
        return true
    }
    
    // Make our UI elements look good
    func setUpMenuUI() {
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
}
