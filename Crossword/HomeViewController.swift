//
//  HomeViewController.swift
//  Crossword
//
//  Created by Tyler Stickler on 11/5/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    @IBAction func unwindSegue(_ sender: UIStoryboardSegue) {
        // Unwind segue allows jumping from the menu or game over view controllers
        // all the way back to home.
        
        // Gives a nice animation
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.navigationController?.view.layer.add(transition, forKey: nil)
        _ = self.navigationController?.popToRootViewController(animated: false)
    }

    override var prefersStatusBarHidden: Bool {
        // No status bar allows for more board room
        return true
    }
    
    // Allows storing and reading from the disk
    let defaults = UserDefaults.standard
    
    // Falling objects
    var labels = [UILabel]()
    var emojisToChoose = [String]()
    var animator: UIDynamicAnimator!
    var timer: Timer!
    
    // Home screen music enabling/disabling button
    @IBOutlet var muteButton: UIButton!
    
    // Banner ad
    @IBOutlet var bannerAd: GADBannerView!
    @IBOutlet var bannerHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start playing music
        MusicPlayer.start(musicTitle: "home", ext: "mp3")
        
        // Load the user selected settings
        // If its the first time, loads default settings
        loadSettings()
        
        /* Removing the free hints for 1.1
        if !defaults.bool(forKey: "freeHintsFor1.1"){
            performSegue(withIdentifier: "notificationSegue", sender: self)
            defaults.set(true, forKey: "freeHintsFor1.1")
            defaults.set(Settings.cheatCount, forKey: "cheatCount")
        }
        */
                        
        animator = UIDynamicAnimator(referenceView: self.view)
        
        // Possible emojis that will randomly fall from the top (160 to choose from)
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // When timer fires, will create a new label to be dropped from the view
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        
        if !Settings.musicEnabled {
            // Music is always playing but only if it's enabled should the volume be > 0
            MusicPlayer.homeMusicPlayer.volume = 0
            muteButton.setBackgroundImage(UIImage(named: "no_music.png"), for: .normal)
        } else {
            muteButton.setBackgroundImage(UIImage(named: "music.png"), for: .normal)
        }
        
        // Don't need the navigation bar
        self.navigationController?.isNavigationBarHidden = true
        
        // Display ads if the user hasn't paid to turn them off
        if !Settings.adsDisabled {
            // Banner ad
            bannerAd.isHidden = false
            bannerHeightConstraint.constant = 50

            let request = GADRequest()
            request.testDevices = [kGADSimulatorID, "fed0f7a57321fadf217b2e53c6dac938"]
            bannerAd.adSize = kGADAdSizeSmartBannerPortrait
            bannerAd.adUnitID = "ca-app-pub-1164601417724423/6161128687"
            bannerAd.rootViewController = self
            bannerAd.load(request)
        } else {
            // If the user has turned off ads through IAP, hide the banner
            // The banner height at 0 allows for the information button
            // to be in its proper location
            bannerAd.isHidden = true
            bannerHeightConstraint.constant = 0
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove the labels
        for lab in labels {
            lab.text = nil
            lab.removeFromSuperview()
        }
        
        // Stop falling animation
        timer.invalidate()
        animator.removeAllBehaviors()
                
        // Gives a nice animation to the next view
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.navigationController?.view.layer.add(transition, forKey: nil)
    }

    @IBAction func muteButtonTapped(_ sender: Any) {
        var musicButtonImage: UIImage
        
        if Settings.musicEnabled {
            // If tapping when music is enabled, disable it
            Settings.musicEnabled = false
            Settings.soundEffects = false
            
            // Set the image of the button to muted music
            musicButtonImage = UIImage(named: "no_music.png")!
            
            // Actually mute the music
            MusicPlayer.homeMusicPlayer.setVolume(0, fadeDuration: 1.0)
        } else {
            // If tapping when music is disabled, enable it
            Settings.musicEnabled = true
            Settings.soundEffects = true
            
            // Set the image of the button to unmuted music
            musicButtonImage = UIImage(named: "music.png")!
            
            // Play the music
            MusicPlayer.homeMusicPlayer.setVolume(0.25, fadeDuration: 1.0)
        }
        
        // Save the user settings
        defaults.set(Settings.musicEnabled, forKey: "musicEnabled")
        defaults.set(Settings.soundEffects, forKey: "soundEffects")
        muteButton.setBackgroundImage(musicButtonImage, for: .normal)
    }
    
    
    @objc func update() {
        // Create the emoji and add it to a label
        let emoji = emojisToChoose[Int(arc4random_uniform(160))]
        let label = UILabel()
        labels.append(label)
        
        // Choose a random location at the top of the screen for the emoji to fall
        var xLocation = CGFloat(arc4random_uniform(UInt32(UIScreen.main.bounds.width)))
        if xLocation + 50 > UIScreen.main.bounds.width {
            xLocation -= 40
        }
        label.frame = CGRect(x: xLocation, y: -50, width: 40, height: 50)
        label.text = emoji
        label.font = UIFont(name: "EmojiOne", size: 40)

        
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
        
        // Remove any labels that are out of screen range
        for lab in labels {
            if lab.center.y - 40 > UIScreen.main.bounds.height {
                lab.text = nil
                lab.removeFromSuperview()
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
        
        // If the user has used the app, set to their preferred settings
        if Settings.launchedBefore {
            Settings.launchedBefore = defaults.bool(forKey: "launchedBefore")
            Settings.musicEnabled = defaults.bool(forKey: "musicEnabled")
            Settings.soundEffects = defaults.bool(forKey: "soundEffects")
            Settings.showTimer = defaults.bool(forKey: "showTimer")
            Settings.skipFilledSquares = defaults.bool(forKey: "skipFilledSquares")
            Settings.lockCorrect = defaults.bool(forKey: "lockCorrect")
            Settings.correctAnim = defaults.bool(forKey: "correctAnim")
            Settings.adsDisabled = defaults.bool(forKey: "adsDisabled")
            Settings.cheatCount = defaults.integer(forKey: "cheatCount")
            Settings.userLevel = defaults.integer(forKey: "userLevel")
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
            
            defaults.set(false, forKey: "adsDisabled")
                        
            Settings.cheatCount = 10
            defaults.set(Settings.cheatCount, forKey: "cheatCount")
            
            Settings.userLevel = 1
            defaults.set(Settings.userLevel, forKey: "userLevel")
            
            Settings.musicEnabled = true
            Settings.soundEffects = true
            Settings.showTimer   = true
            Settings.skipFilledSquares = true
            Settings.lockCorrect = true
            Settings.correctAnim = true
            Settings.adsDisabled = false
            
        }
    }
}
