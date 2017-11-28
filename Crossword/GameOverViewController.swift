//
//  GameOverViewController.swift
//  Crossword
//
//  Created by Tyler Stickler on 11/16/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit

class GameOverViewController: UIViewController {
    // UI elements
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var viewBackground: UIView!
    
    var gameOver: Bool!
    var hours: Int!
    var minutes: Int!
    var seconds: Int!
    var numberWrong: Int!
    
    // Should always end up being 1 but this is safer
    var indexOfPresenter: Int!
    
    @IBAction func topButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
        // Top button does two things based on how the user presented the view
        // If the user has presented the view through getting all correct answers,
        // the top button should allow the user to move to the next level.
        // If the user has presented the view with any wrong answers, the top button
        // is used to display which letters are wrong on the board.
        if gameOver == true {
            if let parentVC = self.presentingViewController?.childViewControllers[indexOfPresenter] as? GameViewController {
                Settings.userLevel! += 1
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
                MusicPlayer.homeMusicPlayer.setVolume(1.0, fadeDuration: 1.0)
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
                
                viewBackground.layer.borderColor = UIColor.green.cgColor
                titleLabel.text = "Nice Job!"
                
                if hours > 0 {
                    messageLabel.text = "You finished in \(hours!) hours, \(minutes!) minutes, and \(seconds!) seconds and gained a hint!"
                } else if parentVC.minutesCounter > 0 {
                    messageLabel.text = "You finished in \(minutes!) minutes and \(seconds!) seconds and gained a hint!"
                } else {
                    messageLabel.text = "You finished in \(seconds!) seconds and gained a hint!"
                }
                
                if Settings.userLevel == Settings.maxNumOfLevels {
                    topButton.isHidden = true
                    titleLabel.text = "That's all for now!"
                    messageLabel.text = "Stay tuned for more levels coming soon!"
                    Settings.userLevel = 1
                } else {
                    topButton.setTitle("Next Level", for: .normal)
                    topButton.layer.backgroundColor = UIColor.green.cgColor
                    topButton.setTitleColor(.black, for: .normal)
                    topButton.layer.borderWidth = 1
                    topButton.layer.cornerRadius = 5
                }
                
                bottomButton.layer.backgroundColor = UIColor.lightGray.cgColor
                bottomButton.setTitleColor(.black, for: .normal)
                bottomButton.layer.borderWidth = 1
                bottomButton.layer.cornerRadius = 5
                bottomButton.setTitle("Home", for: .normal)
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
            }
        }
    }
}
