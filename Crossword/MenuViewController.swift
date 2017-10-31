//
//  MenuViewController.swift
//  Crossword
//
//  Created by Tyler Stickler on 10/25/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    @IBOutlet var menuBackground: UIView!
    
    var musicEnabled: Bool!
    var soundEffectsEnabled: Bool!
    var timerEnabled: Bool!
    var skipFilledEnabled: Bool!
    var lockCorrectEnabled: Bool!
    var correctAnimationEnabled: Bool!
    
    @IBOutlet var musicSwitch: UISwitch!
    @IBOutlet var soundEffectsSwitch: UISwitch!
    @IBOutlet var timerSwitch: UISwitch!
    @IBOutlet var skipFilledSwitch: UISwitch!
    @IBOutlet var lockCorrectSwitch: UISwitch!
    @IBOutlet var correctAnimationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuBackground.layer.cornerRadius = 15
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setSwitches()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        if let parentGame = presentingViewController as? GameViewController {
            parentGame.musicEnabled = musicEnabled
            parentGame.soundEffectsEnabled = soundEffectsEnabled
            parentGame.timerEnabled = timerEnabled
            parentGame.skipFilledSquares = skipFilledEnabled
            parentGame.lockCorrectAnswers = lockCorrectEnabled
            parentGame.correctAnimationEnabled = correctAnimationEnabled
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    func setSwitches() {
        musicSwitch.setOn(musicEnabled, animated: false)
        soundEffectsSwitch.setOn(soundEffectsEnabled, animated: false)
        timerSwitch.setOn(timerEnabled, animated: false)
        skipFilledSwitch.setOn(skipFilledEnabled, animated: false)
        lockCorrectSwitch.setOn(lockCorrectEnabled, animated: false)
        correctAnimationSwitch.setOn(correctAnimationEnabled, animated: false)
    }
    
    @IBAction func musicSwitchToggled(_ sender: Any) {
        if musicSwitch.isOn == true {
            musicEnabled = true
        } else {
            musicEnabled = false
        }
    }
    @IBAction func soundEffectsToggled(_ sender: Any) {
        if soundEffectsSwitch.isOn == true {
            soundEffectsEnabled = true
        } else {
            soundEffectsEnabled = false
        }
    }
    @IBAction func timerToggled(_ sender: Any) {
        if timerSwitch.isOn == true {
            timerEnabled = true
        } else {
            timerEnabled = false
        }
    }
    @IBAction func skipFilledToggled(_ sender: Any) {
        if skipFilledSwitch.isOn == true {
            skipFilledEnabled = true
        } else {
            skipFilledEnabled = false
        }
    }
    @IBAction func lockCorrectToggled(_ sender: Any) {
        if lockCorrectSwitch.isOn == true {
            lockCorrectEnabled = true
        } else {
            lockCorrectEnabled = false
        }
    }
    @IBAction func correctAnimationToggled(_ sender: Any) {
        if correctAnimationSwitch.isOn == true {
            correctAnimationEnabled = true
        } else {
            correctAnimationEnabled = false
        }
    }
}
