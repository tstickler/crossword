//
//  LevelsViewController.swift
//  Crossword
//
//  Created by Tyler Stickler on 12/5/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit
import Firebase

class LevelsViewController: UIViewController {
    override var prefersStatusBarHidden: Bool {
        // No status bar allows for more board room
        return true
    }
    
    @IBOutlet var levelButtons: [LevelButton]!
    @IBOutlet var backLevels: UIButton!
    @IBOutlet var nextLevels: UIButton!
        
    @IBOutlet var firstStackCenterX: NSLayoutConstraint!
    @IBOutlet var firstStackWidth: NSLayoutConstraint!
    @IBOutlet var secondStackLeading: NSLayoutConstraint!
    @IBOutlet var secondStackWidth: NSLayoutConstraint!
    
    // Banner ad
    @IBOutlet var bannerAd: GADBannerView!
    @IBOutlet var bannerHeightConstraint: NSLayoutConstraint!
    
    // Allows storing and reading from the disk
    let defaults = UserDefaults.standard
    
    // Falling objects
    var labels = [UILabel]()
    var emojisToChoose = [String]()
    var animator: UIDynamicAnimator!
    var timer: Timer!
    
    var pageNum: Int!
    var maxNumOfPages = 2
    
    @IBAction func levelButtonTapped(_ sender: UIButton) {
        
        for level in Settings.lockedLevels {
            // GIVE A NOTIFICATION OF LOCKED LEVEL HERE
            if sender.tag == level {
                return
            }
        }
        
        // Go to the selected level
        Settings.userLevel = sender.tag
        performSegue(withIdentifier: "gameSegue", sender: self)
        
        // Fade out the home music
        MusicPlayer.homeMusicPlayer.setVolume(0, fadeDuration: 1.0)
    }
    
    @IBAction func nextLevelsTapped(_ sender: Any) {
        // Move the stacks left
        firstStackCenterX.constant += -view.frame.width
        
        // pageNum determines what arrows should be shown
        pageNum! += 1
        backLevels.isHidden = false
        if pageNum == maxNumOfPages {
            nextLevels.isHidden = true
        }
        
        // Animate the switch between level pages
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func previousLevelsTapped(_ sender: Any) {
        // Move the stacks right
        firstStackCenterX.constant += view.frame.width
        
        // pageNum determines what arrows should be shown
        pageNum! -= 1
        nextLevels.isHidden = false
        if pageNum == 1 {
            backLevels.isHidden = true
        }
        
        // Animate the switch between level pages
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch UIScreen.main.bounds.height {
        case 568:
            firstStackWidth.constant = 220
            secondStackWidth.constant = 220
        case 667:
            firstStackWidth.constant = 260
            secondStackWidth.constant = 260
        case 736:
            firstStackWidth.constant = 280
            secondStackWidth.constant = 260
        case 812:
            firstStackWidth.constant = 260
            secondStackWidth.constant = 260
        default:
            firstStackWidth.constant = 280
        }
        
        
        pageNum = 1
        backLevels.isHidden = true
        
        secondStackLeading.constant = view.frame.width
        
        setUpLevelStatusArrays()
        print(Settings.completedLevels)
        print(Settings.uncompletedLevels)
        print(Settings.lockedLevels)
        
        for i in 1...Settings.maxNumOfLevels {
            levelButtons[i - 1].setBackgroundImage(UIImage(named: "num_\(i)"), for: .normal)
            levelButtons[i - 1].layer.backgroundColor = UIColor.clear.cgColor
            levelButtons[i - 1].setTitle(nil, for: .normal)
        }

        
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
        
        // Display ads if the user hasn't paid to turn them off
        if !Settings.adsDisabled {
            // Banner ad
            bannerAd.isHidden = false
            bannerHeightConstraint.constant = 50
            
            let request = GADRequest()
            request.testDevices = [kGADSimulatorID, "fed0f7a57321fadf217b2e53c6dac938"]
            bannerAd.adSize = kGADAdSizeSmartBannerPortrait
            bannerAd.adUnitID = "ca-app-pub-1164601417724423/6884757223"
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
    
    func setUpLevelStatusArrays() {
        if let completeLevels = defaults.array(forKey: "completedLevels") {
            Settings.completedLevels = completeLevels as! [Int]
        } else {
            Settings.completedLevels = []
        }
        
        if let uncompleteLevels = defaults.array(forKey: "uncompletedLevels") {
            Settings.uncompletedLevels = uncompleteLevels as! [Int]
        } else {
            Settings.uncompletedLevels = []
        }
        
        if let lockedLevels = defaults.array(forKey: "lockedLevels") {
            Settings.lockedLevels = lockedLevels as! [Int]
        } else {
            Settings.lockedLevels = [1,2,3,4,5,6,7,8,9,10,11,12,
                                     13,14,15,16,17,18,19,20,21,22,23,24]
        }
        
        // Set back to < 12 before launch
        while Settings.uncompletedLevels.count < 14 && !Settings.lockedLevels.isEmpty {
            let num = Settings.lockedLevels[0]
            Settings.uncompletedLevels.append(num)
            Settings.lockedLevels.remove(at: 0)
        }
        
        for i in 0..<Settings.lockedLevels.count {
            levelButtons[Settings.lockedLevels[i] - 1].setLevelStatus("locked")
        }
        
        for i in 0..<Settings.completedLevels.count {
            levelButtons[Settings.completedLevels[i] - 1].setLevelStatus("complete")
        }
        
        defaults.set(Settings.completedLevels, forKey: "completedLevels")
        defaults.set(Settings.uncompletedLevels, forKey: "uncompletedLevels")
        defaults.set(Settings.lockedLevels, forKey: "lockedLevels")
    }
}
