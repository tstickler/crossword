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
    
    @IBAction func topButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
        if gameOver == true {
            if let parentVC = self.presentingViewController?.childViewControllers[1] as? GameViewController {
                // Working on moving to the next level
                parentVC.defaults.set(parentVC.userLevel + 1, forKey: "userLevel")
                parentVC.defaults.set(Array(repeating: "", count: 169), forKey: "buttonTitles")
                parentVC.defaults.set(Array(repeating: false, count: 169), forKey: "lockedCorrect")
                parentVC.defaults.set(Array(repeating: false, count: 169), forKey: "hintAcross")
                parentVC.defaults.set(Array(repeating: false, count: 169), forKey: "hintDown")
                parentVC.defaults.set(Array(repeating: false, count: 169), forKey: "revealed")
                parentVC.defaults.set(0, forKey: "seconds")
                parentVC.defaults.set(0, forKey: "minutes")
                parentVC.defaults.set(0, forKey: "hours")
                
                dismiss(animated: true, completion: nil)
            }
        } else {
            if let parentVC = self.presentingViewController?.childViewControllers[1] as? GameViewController {
                parentVC.highlightWrongAnswers()
            }
        }
    }
    
    @IBAction func bottomButtonTapped(_ sender: Any) {
        if gameOver == true {
            performSegue(withIdentifier: "unwindSegue", sender: self)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewBackground.layer.cornerRadius = 15
        viewBackground.layer.borderWidth = 3
        
        if let parentVC = self.presentingViewController?.childViewControllers[1] as? GameViewController {
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
}
