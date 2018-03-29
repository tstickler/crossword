//
//  InfoViewController.swift
//  Crossword
//
//  Created by Tyler Stickler on 11/18/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet var infoBackground: UIView!
    @IBOutlet var versionLabel: UILabel!
    
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // The version of the app
        versionLabel.text = "Version \(version)"
        
        // Gives the background border a nice color/shape
        infoBackground.layer.cornerRadius = 15
        infoBackground.layer.borderWidth = 3
        infoBackground.layer.borderColor = UIColor.white.cgColor
    }
    
    @IBAction func restorePurchasesTapped(_ sender: Any) {
        // Pass view controller to allow UIAlert inidicating success of restore
        InAppPurchase.shared.restorePurchases(in: self)
    }
    
    // Gesture recognizer control
    @IBAction func backgroundTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func facebookButtonTapped(_ sender: Any) {
        // URL to try and open facebook page in the App if the user has it
        var url = NSURL(string:"fb://profile/392793574475365/")! as URL
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        else {
            // If the user doesn't have the facebook app, open in safari
            url = NSURL(string:"http://www.facebook.com/CrossmojiApp/")! as URL
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
    @IBAction func instagramButtonTapped(_ sender: Any) {
        var url = NSURL(string:"instagram://user?username=crossmoji")! as URL
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        else {
            // If the user doesn't have the facebook app, open in safari
            url = NSURL(string:"http://www.instagram.com/crossmoji/")! as URL
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func mailButtonTapped(_ sender: Any) {
        let email = "crossmoji.app@gmail.com"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if infoBackground.frame.contains(touch.location(in: view)) {
            return false
        }
        return true
    }
}
