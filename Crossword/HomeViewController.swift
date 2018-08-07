//
//  HomeViewController.swift
//  Crossword
//
//  Created by Tyler Stickler on 11/5/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, CAAnimationDelegate {
    @IBOutlet var homeTitleImage: UIImageView!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var dailyButton: LevelButton!
    
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

    @IBAction func dailyButtonTapped(_ sender: Any) {
        // Go to the daily level
        // Try to match date with one from firebase for today's puzzle
        for i in 0..<Settings.dailies.count {
            if Settings.dailies[i]["Date"]!["d"]! == Settings.today {
                Settings.userLevel = 1000 + i
                MusicPlayer.homeMusicPlayer.setVolume(0, fadeDuration: 1.0)
                performSegue(withIdentifier: "gameSegue", sender: self)
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        // No status bar allows for more board room
        return true
    }
    
    // Allows storing and reading from the disk
    let defaults = UserDefaults.standard
    
    // Falling objects
    var labels = [UILabel]()
    var animators = [UIDynamicAnimator]()
    var emojisToChoose = [String]()
    var timer: Timer!
    
    var notificationsInfo: Dictionary<String, Any>!
    
    // Home screen music enabling/disabling button
    @IBOutlet var muteButton: UIButton!
    
    // Banner ad
    @IBOutlet var bannerAd: GADBannerView!
    @IBOutlet var bannerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var cover: UIView!
    @IBOutlet var internetLabel: UILabel!
    @IBOutlet var wheel: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start these off hidden, they'll be animated in later
        homeTitleImage.alpha = 0
        playButton.alpha = 0
        muteButton.alpha = 0
        dailyButton.alpha = 0
        homeTitleImage.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        
        // Start playing music
        MusicPlayer.start(musicTitle: "home", ext: "mp3")
        
        // Load the user selected settings
        // If its the first time, loads default settings
        loadSettings()
        
        if !ReachabilityTest.isConnectedToNetwork() && !Settings.gatheredData {
            wheel.startAnimating()
            cover.isHidden = false
            internetLabel.text = "Internet connection required to retreive necessary files."
        } else {
            wheel.startAnimating()
            cover.isHidden = false
            internetLabel.text = "Retrieving Necessary Files..."
        }
        
        // Loads master from firebase
        Settings.ref = Database.database().reference()
        Settings.ref.keepSynced(true)
        
        // Wrapping read inside a write block forces reading from the database prior to cache
        if ReachabilityTest.isConnectedToNetwork() {
            // Wrapping the read in a write block allows us to grab the most
            // recent data from firebase before looking at the cache
            Settings.ref.child("a").setValue("b") { (error, afb) in
                self.readFromFirebase()
            }
        
        } else {
            // If there is no internet, just perform read which will grab from cache
            readFromFirebase()
        }
        
        /* Removing the free hints for 1.1
        if !defaults.bool(forKey: "freeHintsFor1.1"){
            performSegue(withIdentifier: "notificationSegue", sender: self)
            defaults.set(true, forKey: "freeHintsFor1.1")
            defaults.set(Settings.cheatCount, forKey: "cheatCount")
        }
        */
        
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
        
        // Gets todays date in format yyyy-mm-dd
        // Will be compared with dailies pulled from firebase
        getTodaysDate()
        if Settings.highestDailyComplete == Settings.today {
            dailyButton.setLevelStatus("complete", "daily")
        }
        
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
            request.testDevices = [kGADSimulatorID, "fed0f7a57321fadf217b2e53c6dac938", "845b935a0aad6fa7bbc613bea329c30a"]
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
        Settings.ref.removeAllObservers()
        
        // Remove the labels
        for lab in labels {
            lab.text = nil
            lab.removeFromSuperview()
        }
        
        // Stop falling animation
        timer.invalidate()
        for anim in animators {
            anim.removeAllBehaviors()
        }
        
        // Gives a nice animation to the next view
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.navigationController?.view.layer.add(transition, forKey: nil)
    }
    
    func animateLoadIn() {
        UIView.animate(withDuration: 2.0,
                       delay: 0.3,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: {
                        self.homeTitleImage.alpha = 1.0
                        self.homeTitleImage.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: {
            //Code to run after animating
            (value: Bool) in
            
            UIView.animate(withDuration: 1.0, animations: {
                self.playButton.alpha = 1.0
                self.muteButton.alpha = 1.0
                self.dailyButton.alpha = 1.0
            })
        })
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
            MusicPlayer.homeMusicPlayer.setVolume(0.1, fadeDuration: 1.0)
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
        
        let anim: UIDynamicAnimator = UIDynamicAnimator(referenceView: self.view)
        animators.append(anim)
        
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
        
        // Begin animation for the label
        animate(label: label, anim: anim)

        // Remove any labels that are out of screen range
        removeEmojis()
    }
    
    func animate(label: UILabel, anim: UIDynamicAnimator) {
        // Set the push animation
        // Choose a random magnitude between .15 and .35 to vary speeds
        var magnitude = Double(arc4random_uniform(16) + 25) / 100
        if UIDevice.current.model == "iPad" {
            // Increase the speed for falling on a bigger screen
            magnitude = Double(arc4random_uniform(16) + 35) / 100
        }
        let push = UIPushBehavior(items: [label], mode: .instantaneous)
        push.setAngle(.pi/2.0, magnitude: CGFloat(magnitude))
        
        // Begin animation
        anim.addBehavior(push)
    }
    
    func removeEmojis() {
        // Set the label text to nil and remove from super view
        for lab in labels {
            if lab.center.y - 40 > UIScreen.main.bounds.height {
                lab.text = nil
                lab.removeFromSuperview()
            }
        }
        
        // Remove animation from labels that have left the view
        let bounds = CGRect(x: 0.0,y: 0.0,width: view.bounds.width,height: view.bounds.height + 2000)
        for i in 0..<animators.count {
            if !animators[i].items(in: bounds).isEmpty && animators[i].items(in: bounds)[0].center.y - 40 > view.bounds.height {
                animators[i].removeAllBehaviors()
            }
        }
        
        // Keep our arrays a manageable size and remove emojis/animations that have left the screen
        // Therefore, our loops won't be giant if the user keeps app at the homescreen
        if animators.count > 100 {
            animators.removeSubrange(0...25)
            labels.removeSubrange(0...25)
        }
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
            Settings.lockCorrect = true//defaults.bool(forKey: "lockCorrect")
            Settings.correctAnim = defaults.bool(forKey: "correctAnim")
            Settings.adsDisabled = defaults.bool(forKey: "adsDisabled")
            Settings.cheatCount = defaults.integer(forKey: "cheatCount")
            Settings.userLevel = defaults.integer(forKey: "userLevel")
            Settings.gatheredData = defaults.bool(forKey: "gatheredData")
            Settings.highestDailyComplete = defaults.string(forKey: "highestDailyComplete")
            Settings.dailiesCompleted = defaults.integer(forKey: "dailiesCompleted")
            
            // Updated cheat count to gems
            // Should only occur once, the first time app is loaded
            if (!defaults.bool(forKey: "updatedToGems")) {
                Settings.cheatCount *= 10
                defaults.set(Settings.cheatCount, forKey: "cheatCount")
                defaults.set(true, forKey: "updatedToGems")
            }
        } else {
            // If this is the user's first time, start all the settings as enabled.
            // This must happen because loading from defaults when there is no key associated
            // with the setting, it will just return false.
            // If the user decides they don't like a setting, they can change it later
            defaults.set(true, forKey: "launchedBefore")
            defaults.set(false, forKey: "gatheredData")
            defaults.set(true, forKey: "musicEnabled")
            defaults.set(true, forKey: "soundEffects")
            defaults.set(true, forKey: "showTimer")
            defaults.set(true, forKey: "skipFilledSquares")
            defaults.set(true, forKey: "lockCorrect")
            defaults.set(true, forKey: "correctAnim")
            defaults.set(true, forKey: "updatedToGems")
            defaults.set(1, forKey: "notificationNum")
            
            defaults.set(false, forKey: "adsDisabled")
                        
            Settings.cheatCount = 100
            defaults.set(Settings.cheatCount, forKey: "cheatCount")
            
            Settings.userLevel = 1
            defaults.set(Settings.userLevel, forKey: "userLevel")
            
            defaults.set("", forKey: "highestDailyComplete")
            defaults.set(0, forKey: "dailiesCompleted")
            
            Settings.musicEnabled = true
            Settings.soundEffects = true
            Settings.showTimer   = true
            Settings.skipFilledSquares = true
            Settings.lockCorrect = true
            Settings.correctAnim = true
            Settings.adsDisabled = false
            Settings.gatheredData = false
        }
        
        // Create a unique identifier for the user
        var identifier = defaults.string(forKey: "uniqueID")
        if identifier == nil {
            identifier = "i-"
            for _ in 0..<12 {
                // Determine if letter or number should be added to the identifier
                let number = arc4random_uniform(2)
                
                // Case 0: append a number 0-9 to identifier
                // Case 1: append a letter A-Z to identifier
                if number == 0 {
                    let num = arc4random_uniform(9) + 1
                    identifier?.append("\(num)")
                } else {
                    let startingValue = Int(("A" as UnicodeScalar).value) // 65
                    let c = Character(UnicodeScalar(Int(arc4random_uniform(26)) + startingValue)!)
                    identifier?.append(c)
                }
                
                // Add a - after every 4 characters in the identifier
                if identifier?.count == 6 || identifier?.count == 11  {
                    identifier?.append("-")
                }
            }
            defaults.set(identifier!, forKey: "uniqueID")
        }
        Settings.uniqueID = identifier!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // When the setting button is clicked, give the view information needed
        // to set the switches to their initial positions which can then be modified
        // by the user.
        if segue.identifier == "notificationSegue" {
            if let notifVC = segue.destination as? NotificationViewController {
                notifVC.notificationsInfo = notificationsInfo
            }
        }
    }
    
    func readFromFirebase() {
        Settings.ref.child("cheats").child(Settings.uniqueID).observeSingleEvent(of: .value, with: { (snap) in
            let cheatValue = snap.value as? String
            
            // Allows remote changing the cheat count from the database
            // Prefixing a 'u' onto a value in the database means it should be updated
            if cheatValue != nil && cheatValue![cheatValue!.startIndex] == "u" {
                // Grab the actual cheat count
                let startIndex = cheatValue!.index(cheatValue!.startIndex, offsetBy: 2)
                let endIndex = cheatValue!.endIndex
                let range = startIndex..<endIndex
                
                // Record the new cheat count
                Settings.cheatCount = Int(String(cheatValue![range]))!
                self.defaults.set(Settings.cheatCount, forKey: "cheatCount")
            }
            
            // Write back to the database the current user cheat count
            Settings.ref.child("userStats").child("cheats").child(Settings.uniqueID).setValue("\(Settings.cheatCount)")
        })
        
        Settings.ref.child("toRead").observe(.value, with: { (snap) in
            // Everything from the firebase
            let everything = snap.value as! Dictionary<String, Any>
            
            // Just the clues
            let clues = everything["master"] as! Array<Dictionary<String, String>>
            
            // Just the new levels
            let newLevels = everything["newLevels"] as! Array<String>
            let determineNewLevels = newLevels[0].lowercased()
            if determineNewLevels == "none" || determineNewLevels == "0" {
                Settings.newLevels = []
            } else {
                for level in newLevels {
                    let integerLevel = Int(level)
                    if let lev = integerLevel {
                        Settings.newLevels.append(lev)
                    }
                }
            }
            
            // Handles popping up the notificaiton view controller
            // Using a number, we can determine if the user has seen a popup before or not
            self.notificationsInfo = everything["notificationPopup"] as! Dictionary<String, Any>
            let notificationNumber = self.notificationsInfo["popupNum"] as! Int
            if notificationNumber > self.defaults.integer(forKey: "notificationNum") {
                self.performSegue(withIdentifier: "notificationSegue", sender: self)
            }
            self.defaults.set(notificationNumber, forKey: "notificationNum")
            
            // Just the levels
            // Accessed as levels[level-1]["Across"/"Down"/"Board"]["Property"]
            let levels = everything["levels"] as! Array<Dictionary<String, Dictionary<String, String>>>
            Settings.maxNumOfLevels = levels.count
            
            let dailies = everything["dailies"] as! Array<Dictionary<String, Dictionary<String, String>>>
            
            // Create master array
            for element in clues {
                Settings.master.append(element)
            }
            
            // Create levels array
            for level in levels {
                Settings.levels.append(level)
            }
            
            // Create dailies array
            for daily in dailies {
                Settings.dailies.append(daily)
            }
            
            // Write back to the database the current user cheat count
            Settings.ref.child("userStats").child("completedLevels").child(Settings.uniqueID).setValue(Settings.completedLevels.count)
            
            self.wheel.hidesWhenStopped = true
            self.wheel.stopAnimating()
            self.internetLabel.text = ""
            self.defaults.set(true, forKey: "gatheredData")
            
            UIView.animate(withDuration:0.25, animations: {
                self.cover.alpha = 0
            })
            
            self.animateLoadIn()
        })
    }
    
    func getTodaysDate() {
        // Sets todays date
        let date = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        Settings.today = formatter.string(from: date)
    }
}
