//
//  MenuViewController.swift
//  Crossword
//
//  Created by Tyler Stickler on 10/25/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    @IBOutlet var menuBackground: UIView!
    
    @IBOutlet var musicSwitch: UISwitch!
    @IBOutlet var soundEffectsSwitch: UISwitch!
    @IBOutlet var timerSwitch: UISwitch!
    @IBOutlet var skipFilledSwitch: UISwitch!
    @IBOutlet var lockCorrectSwitch: UISwitch!
    @IBOutlet var correctAnimationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuBackground.layer.cornerRadius = 15
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
