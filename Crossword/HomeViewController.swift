//
//  HomeViewController.swift
//  Crossword
//
//  Created by Tyler Stickler on 11/5/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController {
    @IBAction func unwindSegue(_ sender: UIStoryboardSegue) {
        // Gives a nice animation when unwinding to the homescreen
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.navigationController?.view.layer.add(transition, forKey: nil)
        _ = self.navigationController?.popToRootViewController(animated: false)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Allows storing and reading from the disk
    let defaults = UserDefaults.standard
    
    // Falling objects
    var labels = [UILabel]()
    var emojisToChoose = [String]()
    var animator: UIDynamicAnimator!
    var timer: Timer!
    
    // The level we should go to
    var levelNumber = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()

        animator = UIDynamicAnimator(referenceView: self.view)
        emojisToChoose = ["😄", "😇", "😂", "🤣", "🙂", "🙃", "😍", "😘", "😋", "😜",
                          "🤪", "🤩", "😎", "🤓", "😏", "😭", "😤", "😢", "😡", "🤬",
                          "🤯", "😱", "😓", "😰", "🤫", "🙄", "😬", "😴", "🤤", "🤮",
                          "🤕", "🤠", "😈", "💩", "👻", "👽", "💀", "👾", "😸", "😹",
                          "🎃", "🤖", "🙀", "🙌🏻", "✌🏻", "💪🏻", "👄", "💍", "👀", "🧔🏻",
                          "🎅🏻", "🧟‍♂️", "🧜🏻‍♀️", "🧞‍♂️", "🧚🏻‍♀️", "🙅🏼‍♀️", "🤷🏻‍♂️", "🧖🏼‍♀️", "👑", "🕶",
                          "🐶", "🐼", "🐸", "🐷", "🙈", "🙉", "🙊", "🦆", "🐥", "🐝",
                          "🦄", "🦋", "🐢", "🦖", "🦕", "🦑", "🐙", "🐠", "🐬", "🐳",
                          "🐊", "🦈", "🦓", "🦏", "🐘", "🦒", "🐄", "🐓", "🐉", "🎄",
                          "🍃", "🍀", "🌹", "🌸", "🌝", "🌙", "🌎", "☄️", "⚡️", "🌟",
                          "🌈", "🔥", "⛈", "☃️", "💧", "💦", "☔️", "🍎", "🍊", "🍌",
                          "🍉", "🍓", "🍒", "🍍", "🍆", "🌽", "🍔", "🥓", "🍕", "🍟",
                          "🌮", "🍬", "🍭", "🎂", "🍩", "⚽️", "🏀", "🏈", "⚾️", "🥇",
                          "🎨", "🎤", "🎷", "🎳", "🚗", "✈️", "🚀", "🗽", "🏝", "📱",
                          "📸", "☎️", "💡", "💵", "💎", "💣", "🔮", "🔑", "✉️", "❤️",
                          "💔", "💘", "⚠️", "🌀", "🃏", "🤞🏻", "👏🏼", "👌🏻", "👉🏼", "👍🏻"]

        // When timer fires, will create a new label to be dropped from the view
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        timer.fire()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Start playing music
        MusicPlayer.start(musicTitle: "home", ext: "mp3")

        if !Settings.musicEnabled {
            // Music is always playing but only if it's enabled should the volume be > 0
            MusicPlayer.musicPlayer.volume = 0
        }
        
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Gives a nice animation to the next view
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.navigationController?.view.layer.add(transition, forKey: nil)

    }
    
    @objc func update() {
        // Create the emoji and add it to a label
        let emoji = emojisToChoose[Int(arc4random_uniform(160))]
        let label = UILabel()
        
        // Choose a random location at the top of the screen for the emoji to fall
        var xLocation = CGFloat(arc4random_uniform(UInt32(UIScreen.main.bounds.width)))
        if xLocation + 50 > UIScreen.main.bounds.width {
            xLocation -= 30
        }
        label.frame = CGRect(x: xLocation, y: -50, width: 40, height: 40)
        label.text = emoji
        label.font = UIFont(name: "Arial", size: 35)
        
        // Give labels a random rotation between -pi/4 and pi/4
        var rotation = Double(arc4random_uniform(77)) / 100
        let posNeg = arc4random_uniform(2)
        if posNeg == 0 {
            rotation = -rotation
        }
        label.transform = CGAffineTransform(rotationAngle: CGFloat(rotation))

        // Add the label to the behind the rest of the view
        view.addSubview(label)
        view.sendSubview(toBack: label)
        
        labels.append(label)
        
        // Remove any labels that are out of screen range
        for (index, lab) in labels.enumerated() {
            if lab.center.y - 20 > UIScreen.main.bounds.height {
                lab.removeFromSuperview()
                labels.remove(at: index)
            }
        }
        
        // Begin animation for the label
        animate(label: label)
    }
    
    func animate(label: UILabel) {
        // Set the push animation
        // Choose a random magnitude between .15 and .35 to vary speeds
        let push = UIPushBehavior(items: [label], mode: .instantaneous)
        push.setAngle(.pi/2.0, magnitude: CGFloat(Double(arc4random_uniform(16)) + 25) / 100)
        
        // Begin animation
        animator?.addBehavior(push)
    }
    
    func loadSettings() {
        // Determine if this is the first time the user has used the app
        Settings.launchedBefore = defaults.bool(forKey: "launchedBefore")
        
        // If the user hasn't used the app, set to their preferred settings
        if Settings.launchedBefore {
            Settings.launchedBefore = defaults.bool(forKey: "firstTime")
            Settings.musicEnabled = defaults.bool(forKey: "musicEnabled")
            Settings.soundEffects = defaults.bool(forKey: "soundEffects")
            Settings.showTimer = defaults.bool(forKey: "showTimer")
            Settings.skipFilledSquares = defaults.bool(forKey: "skipFilledSquares")
            Settings.lockCorrect = defaults.bool(forKey: "lockCorrect")
            Settings.correctAnim = defaults.bool(forKey: "correctAnim")
        } else {
            // If this is the user's first time, start all the settings as enabled.
            // This must happen because loading from defaults when there is no key associated
            // with the setting, it will just return false.
            // If the user decides they don't like a setting, they can change it later
            defaults.set(true, forKey: "launchedBefore")
            
            defaults.set(true, forKey: "musicEnabled")
            defaults.set(true, forKey: "soundEffects")
            defaults.set(true, forKey: "showTimer")
            defaults.set(true, forKey: "skipFilledSquares")
            defaults.set(true, forKey: "lockCorrect")
            defaults.set(true, forKey: "correctAnim")
            
            Settings.musicEnabled = true
            Settings.soundEffects = true
            Settings.showTimer   = true
            Settings.skipFilledSquares = true
            Settings.lockCorrect = true
            Settings.correctAnim = true
        }
    }
}
