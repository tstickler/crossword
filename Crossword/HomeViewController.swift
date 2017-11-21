//
//  HomeViewController.swift
//  Crossword
//
//  Created by Tyler Stickler on 11/5/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit
import AVFoundation
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
    
    // The level we should go to
    var levelNumber = 1
    
    // Home screen music enabling/disabling button
    @IBOutlet var muteButton: UIButton!
    
    @IBOutlet var bannerAd: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Banner ad
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID, "fed0f7a57321fadf217b2e53c6dac938"]
        bannerAd.adSize = kGADAdSizeSmartBannerPortrait
        bannerAd.adUnitID = "ca-app-pub-1164601417724423/6161128687"
        bannerAd.rootViewController = self
        bannerAd.load(request)
        
        loadSettings()
                
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

        // When timer fires, will create a new label to be dropped from the view
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Start playing music
        MusicPlayer.start(musicTitle: "home", ext: "mp3")
        
        if !Settings.musicEnabled {
            // Music is always playing but only if it's enabled should the volume be > 0
            MusicPlayer.homeMusicPlayer.volume = 0
            muteButton.setBackgroundImage(UIImage(named: "no_music-1.png"), for: .normal)
        } else {
            muteButton.setBackgroundImage(UIImage(named: "music-1.png"), for: .normal)
        }
        
        // Don't need the navigation bar
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Fade out the home music
        MusicPlayer.homeMusicPlayer.setVolume(0, fadeDuration: 1.0)
        
        // Gives a nice animation to the next view
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.navigationController?.view.layer.add(transition, forKey: nil)
    }

    @IBAction func muteButtonTapped(_ sender: Any) {
        var image: UIImage
        
        if Settings.musicEnabled {
            // If tapping when music is enabled, disable it
            Settings.musicEnabled = false
            Settings.soundEffects = false
            
            // Set the image of the button to muted music
            image = UIImage(named: "no_music-1.png")!
            
            // Actually mute the music
            MusicPlayer.homeMusicPlayer.setVolume(0, fadeDuration: 1.0)
        } else {
            // If tapping when music is disabled, enable it
            Settings.musicEnabled = true
            Settings.soundEffects = true
            
            // Set the image of the button to unmuted music
            image = UIImage(named: "music-1.png")!
            
            // Play the music
            MusicPlayer.homeMusicPlayer.setVolume(0.15, fadeDuration: 1.0)
        }
        
        // Save the user settings
        defaults.set(Settings.musicEnabled, forKey: "musicEnabled")
        defaults.set(Settings.soundEffects, forKey: "soundEffects")
        muteButton.setBackgroundImage(image, for: .normal)
    }
    
    
    @objc func update() {
        // Create the emoji and add it to a label
        let emoji = emojisToChoose[Int(arc4random_uniform(160))]
        let label = UILabel()
        labels.append(label)
        
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
        
        
        // Remove any labels that are out of screen range
        for (index, lab) in labels.enumerated() {
            if lab.center.y - 40 > UIScreen.main.bounds.height {
                lab.text = nil
                labels.remove(at: index)
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
