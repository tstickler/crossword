//
//  PurchasesViewController.swift
//  Crossword
//
//  Created by Tyler Stickler on 11/23/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit
import StoreKit

class PurchasesViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet var purchaseButtons: [UIButton]!
    var parentView: GameViewController!
    var timer: Timer!
    
    @IBAction func purchaseButtonTapped(_ sender: UIButton) {
        // Determine which purchase the user would like to make based on the button tags
        switch sender.tag {
        case 1:
            // Remove ads
            InAppPurchase.shared.purchaseProduct(product: .RemoveAds, in: self)
            break
        case 3:
            // 3 Hints
            InAppPurchase.shared.purchaseProduct(product: .ThreeHints, in: self)
            break
        case 10:
            // 10 Hints
            InAppPurchase.shared.purchaseProduct(product: .TenHints, in: self)
            break
        case 30:
            // 30 Hints
            InAppPurchase.shared.purchaseProduct(product: .ThirtyHints, in: self)
            break
        case 75:
            // 75 Hints
            InAppPurchase.shared.purchaseProduct(product: .SeventyfiveHints, in: self)
            break
        case 200:
            // 200 Hints
            InAppPurchase.shared.purchaseProduct(product: .TwohundredHints, in: self)
            break
        default:
            print("Unknown sender")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Timer will be updating the cheat count label. This allows us to change it after the user
        // purchases more cheats
        let indexOfPresenter = (self.presentingViewController?.childViewControllers.count)! - 1
        if let parentVC = self.presentingViewController?.childViewControllers[indexOfPresenter] as? GameViewController  {
            parentView = parentVC
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        }
        
        // Make the UI look nice
        viewBackground.layer.cornerRadius = 15
        viewBackground.layer.borderColor = UIColor.init(red: 0, green: 122/255, blue: 1, alpha: 1).cgColor
        viewBackground.layer.borderWidth = 3
        
        for button in purchaseButtons {
            button.layer.cornerRadius = 7
        }        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    @objc func update() {
        // If the user made a purchase, reflect it by updating the label
        if parentView.cheatCountLabel.text != String(Settings.cheatCount) {
            parentView.cheatCountLabel.text = String(Settings.cheatCount)
        }
    }
    
    // Gesture recognizers
    @IBAction func backgroundTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if viewBackground.frame.contains(touch.location(in: view)) {
            return false
        }
        return true
    }
}
