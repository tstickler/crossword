//
//  GameOverViewController.swift
//  Crossword
//
//  Created by Tyler Stickler on 11/16/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit

class GameOverViewController: UIViewController {
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

        if gameOver == true {
            if let parentVC = self.presentingViewController?.childViewControllers[indexOfPresenter] as? GameViewController {
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

        MusicPlayer.gameMusicPlayer.setVolume(0, fadeDuration: 1.0)
        if gameOver == true {
            if Settings.musicEnabled {
                MusicPlayer.homeMusicPlayer.setVolume(1.0, fadeDuration: 1.0)
            }
            performSegue(withIdentifier: "unwindSegue", sender: self)
        } 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        viewBackground.layer.cornerRadius = 15
        viewBackground.layer.borderWidth = 3
        
        if let parentVC = self.presentingViewController?.childViewControllers[indexOfPresenter] as? GameViewController {
            if parentVC.gameOver() {
                gameOver = true
                hours = parentVC.hoursCounter
                minutes = parentVC.minutesCounter
                seconds = parentVC.secondsCounter
                
                viewBackground.layer.borderColor = UIColor.green.cgColor
                titleLabel.text = "Nice Job!"
                
                if hours > 0 {
                    messageLabel.text = "You finished in \(hours!) hours, \(minutes!) minutes, and \(seconds!) seconds!"
                } else if parentVC.minutesCounter > 0 {
                    messageLabel.text = "You finished in \(minutes!) minutes and \(seconds!) seconds!"
                } else {
                    messageLabel.text = "You finished in \(seconds!) seconds!"
                }
                
                topButton.setTitle("Next Level", for: .normal)
                topButton.layer.backgroundColor = UIColor.green.cgColor
                topButton.setTitleColor(.black, for: .normal)
                topButton.layer.borderWidth = 1
                topButton.layer.cornerRadius = 5
                
                bottomButton.layer.backgroundColor = UIColor.lightGray.cgColor
                bottomButton.setTitleColor(.black, for: .normal)
                bottomButton.layer.borderWidth = 1
                bottomButton.layer.cornerRadius = 5
                bottomButton.setTitle("Home", for: .normal)
            } else {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Should be 1 (the top view on the navigation stack)
        indexOfPresenter = (self.presentingViewController?.childViewControllers.count)! - 1
    }
}
