//
//  HomeViewController.swift
//  Crossword
//
//  Created by Tyler Stickler on 11/5/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
    @IBOutlet var levelOneButton: UIButton!
    @IBOutlet var levelTwoButton: UIButton!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // When the setting button is clicked, give the view information needed
        // to set the switches to their initial positions which can then be modified
        // by the user.
        if segue.identifier == "level1Segue" {
            if let gameVC = segue.destination as? GameViewController {
                gameVC.userLevel = 1
            }
        }
        
        if segue.identifier == "level2Segue" {
            if let gameVC = segue.destination as? GameViewController {
                gameVC.userLevel = 2
            }
        }

    }
}
