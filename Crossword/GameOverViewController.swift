//
//  GameOverViewController.swift
//  Crossword
//
//  Created by Tyler Stickler on 11/16/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit
import StoreKit

class GameOverViewController: UIViewController {
    // UI elements
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet var gemCountWon: UILabel!
    @IBOutlet var gem: UILabel!
    
    var gameOver: Bool!
    var hours: Int!
    var minutes: Int!
    var seconds: Int!
    var numberWrong: Int!
    var levelOffset: Int!
    
    // Should always end up being 1 but this is safer
    var indexOfPresenter: Int!
    
    // Lets us assign completed/uncompleted/locked levels
    let defaults = UserDefaults.standard
    
    @IBAction func topButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
        // Top button does two things based on how the user presented the view
        // If the user has presented the view through getting all correct answers,
        // the top button should allow the user to move to the next level.
        // If the user has presented the view with any wrong answers, the top button
        // is used to display which letters are wrong on the board.
        if gameOver == true {
            if let parentVC = self.presentingViewController?.childViewControllers[indexOfPresenter] as? GameViewController {
                
                // Prompt the user to leave a review in the app store
                // Only display after 4, 8, 16, or 20 completed levels
                if Settings.completedLevels.count == 4 ||
                    Settings.completedLevels.count == 8 ||
                    Settings.completedLevels.count == 16 ||
                    Settings.completedLevels.count == 20 {
                    SKStoreReviewController.requestReview()
                }
                
                // Find the next level to go to
                // Should be the next sequential, uncompleted level
                // If there are no levels > the current level, find the min
                // uncompleted level and go there
                Settings.userLevel = determineNextLevel()
                parentVC.newLevel()
            }
        } else {
            if let parentVC = self.presentingViewController?.childViewControllers[indexOfPresenter] as? GameViewController {
                parentVC.highlightWrongAnswers()
            }
        }
    }
    
    @IBAction func bottomButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
        // Bottom button does two things based on how the user presented the view
        // If the user has presented the view through getting all correct answers,
        // the bottom button should allow the user to move to the home screen.
        // If the user has presented the view with any wrong answers, the bottom button
        // is used to dismiss the view and return to the game with no hint showing which
        // letters were incorrect.

        if gameOver == true {
            // Fade out the game music
            MusicPlayer.gameMusicPlayer.setVolume(0, fadeDuration: 1.0)

            // Fade in the home music
            if Settings.musicEnabled {
                MusicPlayer.homeMusicPlayer.setVolume(0.1, fadeDuration: 1.0)
            }
            
            // unwind to home screen
            performSegue(withIdentifier: "unwindSegue", sender: self)
        } 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Determines how the UI elements should be set up
        setUpUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Settings.userLevel < 200 {
            levelOffset = 0
        } else if Settings.userLevel >= 200 && Settings.userLevel < 400 {
            levelOffset = 200
        } else if Settings.userLevel >= 400 && Settings.userLevel < 600 {
            levelOffset = 400
        } else {
            levelOffset = 0
        }
        
        // Should be 1 (the top view on the navigation stack)
        indexOfPresenter = (self.presentingViewController?.childViewControllers.count)! - 1
    }
    
    func setUpUI() {
        // Gives the background a nice shape
        viewBackground.layer.cornerRadius = 15
        viewBackground.layer.borderWidth = 3
        
        if let parentVC = self.presentingViewController?.childViewControllers[indexOfPresenter] as? GameViewController {
            if parentVC.gameOver() {
                // If we came through a game over, set the view accordingly
                gameOver = true
                hours = parentVC.hoursCounter
                minutes = parentVC.minutesCounter
                seconds = parentVC.secondsCounter
                gemCountWon.isHidden = false
                gem.isHidden = false
                
                var hoursPlural = "hours"
                var minutesPlural = "minutes"
                var secondsPlural = "seconds"
                var newLevelText = ""
                
                // Determines if hours/mins/seconds should be plural
                if hours == 1 {
                    hoursPlural = "hour"
                }

                if minutes == 1 {
                    minutesPlural = "minute"
                }

                if seconds == 1 {
                    secondsPlural = "second"
                }
                
                
                viewBackground.layer.borderColor = UIColor.green.cgColor
                
                let random = arc4random_uniform(5)
                switch random {
                case 0:
                    titleLabel.text = "Nice Job!"
                case 1:
                    titleLabel.text = "Well Done!"
                case 2:
                    titleLabel.text = "Congrats!"
                case 3:
                    titleLabel.text = "Excellent!"
                case 4:
                    titleLabel.text = "Good Work!"
                default:
                    titleLabel.text = "Nice Job!"
                }
                
                // Determines if we should tell the user a new level was unlocked
                // If there are no levels to unlock, then we don't want to tell
                // the user they unlocked a level
                // If the user completed a daily level, new level isn't unlocked
                if !Settings.lockedLevels.isEmpty && Settings.userLevel < 1000 {
                    newLevelText = " and unlocked a new level!"
                } else if Settings.userLevel >= 1000 {
                    newLevelText = " and earned 20 Gems!"
                } else {
                    newLevelText = "!"
                }
                
                // Report to the user how well they did
                // Alert a new level opened if there were levels available
                if hours > 0 {
                    messageLabel.text = "You finished in \(hours!) \(hoursPlural), \(minutes!) \(minutesPlural), and \(seconds!) \(secondsPlural)\(newLevelText)"
                } else if parentVC.minutesCounter > 0 {
                    messageLabel.text = "You finished in \(minutes!) \(minutesPlural) and \(seconds!) \(secondsPlural)\(newLevelText)"
                } else {
                    messageLabel.text = "You finished in \(seconds!) \(secondsPlural)\(newLevelText)"
                }
                
                bottomButton.layer.backgroundColor = UIColor.lightGray.cgColor
                bottomButton.setTitleColor(.black, for: .normal)
                bottomButton.layer.borderWidth = 1
                bottomButton.layer.cornerRadius = 5
                bottomButton.setTitle("Home", for: .normal)
                
                // Modify our level arrays
                for i in 0..<Settings.uncompletedLevels.count {
                    // Go until we find the current level in uncompleted
                    // levels
                    if Settings.uncompletedLevels[i] == Settings.userLevel - levelOffset {
                        
                        // Put the level into the completed levels and remove from
                        // uncompleted levels
                        Settings.completedLevels.append(Settings.userLevel - levelOffset)
                        Settings.uncompletedLevels.remove(at: i)
                        
                        // Move a locked level into the uncompleted levels
                        if !Settings.lockedLevels.isEmpty {
                            Settings.uncompletedLevels.append(Settings.lockedLevels[0])
                            Settings.lockedLevels.remove(at: 0)
                        }
                        
                        var completedKey: String!
                        var uncompletedKey: String!
                        var lockedKey: String!
                        switch levelOffset {
                        case 0:
                            completedKey = "completedLevels"
                            uncompletedKey = "uncompletedLevels"
                            lockedKey = "lockedLevels"
                        case 200:
                            completedKey = "completedLevels_18"
                            uncompletedKey = "uncompletedLevels_18"
                            lockedKey = "lockedLevels_18"
                        case 400:
                            completedKey = "completedLevels_23"
                            uncompletedKey = "uncompletedLevels_23"
                            lockedKey = "lockedLevels_23"
                        default:
                            completedKey = "completedLevels"
                            uncompletedKey = "uncompletedLevels"
                            lockedKey = "lockedLevels"
                        }

                        // Save the state of the level arrays
                        defaults.set(Settings.completedLevels, forKey: completedKey)
                        defaults.set(Settings.uncompletedLevels, forKey: uncompletedKey)
                        defaults.set(Settings.lockedLevels, forKey: lockedKey)
                        
                        // User gets another cheat for completing the level
                        // Only needs to happen when the level is completed the first time
                        Settings.cheatCount += 10
                        gemCountWon.text = "+10"
                        parentVC.cheatCountLabel.text = "\(Settings.cheatCount)"
                        parentVC.animateGemChange(10, true)
                        defaults.set(Settings.cheatCount, forKey: "cheatCount")
                        
                        break
                    }
                }
                
                // If the user has completed all the levels, then tell them
                // that there will be more levels coming
                if Settings.completedLevels.count == Settings.maxNumOfLevels &&
                    Settings.userLevel < 1000 {
                    topButton.isHidden = true
                    titleLabel.text = "That's all for now!"
                    messageLabel.text = "Stay tuned for more levels coming soon!"
                } else if Settings.userLevel >= 1000 {
                    Settings.dailiesCompleted = Settings.dailiesCompleted + 1
                    Settings.highestDailyComplete = Settings.today
                    topButton.isHidden = true
                    bottomButton.backgroundColor = .green
                    Settings.cheatCount += 20
                    gemCountWon.text = "+20"
                    parentVC.cheatCountLabel.text = "\(Settings.cheatCount)"
                    parentVC.animateGemChange(20, true)
                    defaults.set(Settings.cheatCount, forKey: "cheatCount")
                    defaults.set(Settings.today, forKey: "highestDailyComplete")
                    defaults.set(Settings.dailiesCompleted, forKey: "dailiesCompleted")
                } else {
                    topButton.setTitle("Next Level", for: .normal)
                    topButton.layer.backgroundColor = UIColor.green.cgColor
                    topButton.setTitleColor(.black, for: .normal)
                    topButton.layer.borderWidth = 1
                    topButton.layer.cornerRadius = 5
                }
            } else {
                // If we came through a full board with at least 1 wrong letter, set the view accordingly
                gameOver = false
                numberWrong = parentVC.countWrong()
                viewBackground.layer.borderColor = UIColor.red.cgColor
                titleLabel.text = "Oops!"
                
                topButton.layer.backgroundColor = UIColor.red.cgColor
                topButton.setTitleColor(.white, for: .normal)
                topButton.layer.borderWidth = 1
                topButton.layer.cornerRadius = 5
                if numberWrong == 1 {
                    messageLabel.text = "The puzzle is full but it looks like you've made an error."
                    topButton.setTitle("Show \(numberWrong!) error", for: .normal)
                } else {
                    messageLabel.text = "The puzzle is full but it looks like you've made a few errors."
                    topButton.setTitle("Show \(numberWrong!) errors", for: .normal)
                }
                
                bottomButton.layer.backgroundColor = UIColor.lightGray.cgColor
                bottomButton.setTitleColor(.black, for: .normal)
                bottomButton.layer.borderWidth = 1
                bottomButton.layer.cornerRadius = 5
                bottomButton.setTitle("Continue", for: .normal)
                gemCountWon.isHidden = true
                gem.isHidden = true
            }
        }
    }
    
    func determineNextLevel() -> Int {
        // Determine what level to go the next
        var nextLevel = Settings.userLevel + 1
        
        // Potential levels to go to
        var potentialNextLevels = [Int]()
        
        // Find the next available level greater than current level
        for level in Settings.uncompletedLevels {
            if level  + levelOffset > Settings.userLevel {
                potentialNextLevels.append(level)
            }
        }
        
        // If no greater level was found, get all the levels less than current
        // level
        if potentialNextLevels.isEmpty {
            for level in Settings.uncompletedLevels {
                if level + levelOffset < Settings.userLevel {
                    potentialNextLevels.append(level)
                }
            }
        }
        
        // Go to the lowest found potential level
        nextLevel = potentialNextLevels.min()!
        
        return nextLevel + levelOffset
    }
}
