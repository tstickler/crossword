//
//  CodeViewController.swift
//  Crossword
//
//  Created by Tyler Stickler on 7/24/18.
//  Copyright © 2018 tstick. All rights reserved.
//

import UIKit
import GoogleMobileAds

class CodeViewController: UIViewController, CAAnimationDelegate, UIGestureRecognizerDelegate, GADRewardBasedVideoAdDelegate {

    
    // Allows storing and reading from the disk
    let defaults = UserDefaults.standard
    
    // UI elements
    @IBOutlet var codeEntryView: UIView!
    @IBOutlet var codeLabel: UILabel!
    @IBOutlet var submitBtn: UIButton!
    var code = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        GADRewardBasedVideoAd.sharedInstance().delegate = self
        
        // Set the frame of the view
        codeEntryView.layer.cornerRadius = 15
        codeEntryView.layer.borderColor = UIColor.init(red: 73/255, green: 222/255, blue: 124/255, alpha: 1).cgColor
        codeEntryView.layer.borderWidth = 3
        
        // Label border is only on the bottom
        codeLabel.layer.addBorder(edge: UIRectEdge.bottom, color: .white, thickness: 1)
    }
    
    @IBAction func codeSubmitTapped(_ sender: Any) {
        // Reset the text on the label
        codeLabel.text = ""
        
        if handleCode() {
            // Correct code entered
            UIView.transition(with: codeLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
                // User is shown a message
                self.codeLabel.textColor = .white
            }, completion: {
                    (Void) in
                // Fade out the message
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                        UIView.transition(with: self.codeLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
                            self.codeLabel.font = UIFont.init(name: "EmojiOneColor", size: 38)
                            self.codeLabel.text = ""
                        }, completion: nil)
                    })
            })
        } else {
            // User is shown a message
            UIView.transition(with: codeLabel, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.codeLabel.textColor = .white
                self.codeLabel.font = UIFont.init(name: "Geeza Pro", size: 24)
                self.codeLabel.text = "Incorrect code."
                self.codeLabel.textColor = .red
            }, completion: {
                    (Void) in
                // Fade out the message
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        UIView.transition(with: self.codeLabel, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            self.codeLabel.font = UIFont.init(name: "EmojiOneColor", size: 38)
                            self.codeLabel.text = ""
                            self.codeLabel.textColor = .white
                        }, completion: nil)
                    })
            })
            
            // Shake submit button when incorrect
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.08
            animation.repeatCount = 6
            animation.autoreverses = true
            animation.fromValue = NSValue(cgPoint: CGPoint(x: submitBtn.center.x - 10, y: submitBtn.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: submitBtn.center.x + 10, y: submitBtn.center.y))
            animation.delegate = self
            
            submitBtn.layer.add(animation, forKey: "position")
        }
        
        // Reset the entered code
        code = ""
    }
    
    @IBAction func watchAdTapped(_ sender: Any) {
        if GADRewardBasedVideoAd.sharedInstance().isReady {
            GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
        }
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        let awarded = 10
        codeLabel.font = UIFont.init(name: "Geeza Pro", size: 24)
        codeLabel.text = "\(awarded) Gems awarded!"
        Settings.cheatCount += awarded
        defaults.set(Settings.cheatCount, forKey: "cheatCount")
        
        UIView.transition(with: codeLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
            // User is shown a message
            self.codeLabel.textColor = .white
        })
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),
                                                    withAdUnitID: "ca-app-pub-1164601417724423/5486191208")
        // Fade out the message
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            UIView.transition(with: self.codeLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.codeLabel.font = UIFont.init(name: "EmojiOneColor", size: 38)
                self.codeLabel.text = ""
            }, completion: nil)
        })
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        // Core Animation start should set the submit button to red
        submitBtn.setTitleColor(.red, for: .normal)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        // Core Animation end should set the submit button to white
        submitBtn.setTitleColor(.white, for: .normal)
    }
    
    @IBAction func codeKeyTapped(_ sender: UIButton) {
        // Only accept input up to 6 emojis
        if (codeLabel.text?.count)! >= 6 {
            return
        }
        
        // Handle the tapped emoji
        // Each emoji maps to a different number 1-9
        // Tapping emoji builds a letter code which is evaluated
        switch sender.tag {
        case 50:
            codeLabel.text = codeLabel.text! + "😂"
            code += "1"
        case 51:
            codeLabel.text = codeLabel.text! + "😡"
            code += "2"
        case 52:
            codeLabel.text = codeLabel.text! + "👽"
            code += "3"
        case 53:
            codeLabel.text = codeLabel.text! + "😍"
            code += "4"
        case 54:
            codeLabel.text = codeLabel.text! + "🍕"
            code += "5"
        case 55:
            codeLabel.text = codeLabel.text! + "💩"
            code += "6"
        case 56:
            codeLabel.text = codeLabel.text! + "🌮"
            code += "7"
        case 57:
            codeLabel.text = codeLabel.text! + "🐬"
            code += "8"
        case 58:
            codeLabel.text = codeLabel.text! + "🌭"
            code += "9"
        default:
            break
        }
    }
    
    func handleCode() -> Bool {
        /*
         * 😂  😡  👽  😍  🍕  💩  🌮  🐬  🌭
         *  1   2   3   4   5    6   7   8   9
         * Emojis correspond to the letters in this order
         *
         */
        switch code {
        case "176548":
            // 😂🌮💩🍕😍🐬
            if !defaults.bool(forKey: "businessCardRedeemed") {
                handleCorrect(50)
                defaults.set(true, forKey: "businessCardRedeemed")
            } else {
                handleIncorrect()
            }
            return true
        case "912413":
            // 🌭😂😡😍😂👽
            if !defaults.bool(forKey: "freeThree") {
                handleCorrect(30)
                defaults.set(true, forKey: "freeThree")
            } else {
                handleIncorrect()
            }
            return true
        case "793528":
            // 🌮🌭👽🍕😡🐬
            if !defaults.bool(forKey: "facebookAd") {
                handleCorrect(100)
                defaults.set(true, forKey: "facebookAd")
            } else {
                handleIncorrect()
            }
            return true
        default:
            break
        }
        
        return false
    }
    
    func handleCorrect(_ awarded: Int) {
        // Text for correct code
        codeLabel.font = UIFont.init(name: "Geeza Pro", size: 24)
        codeLabel.text = "\(awarded) Gems awarded!"
        Settings.cheatCount += awarded
        defaults.set(Settings.cheatCount, forKey: "cheatCount")
    }
    
    func handleIncorrect() {
        // Text for code already redeemed
        codeLabel.font = UIFont.init(name: "Geeza Pro", size: 20)
        codeLabel.text = "Code already redeemed."
    }
    
    // Gesture recognizer control
    @IBAction func backgroundTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if codeEntryView.frame.contains(touch.location(in: view)) {
            return false
        }
        return true
    }
}

extension CALayer {
    // Only draw border on specific part of a view
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: self.frame.height - thickness, width: self.frame.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height)
            break
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        self.addSublayer(border)
    }
    
}
