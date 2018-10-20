//
//  ClueCell.swift
//  Crossword
//
//  Created by Tyler Stickler on 9/19/18.
//  Copyright © 2018 tstick. All rights reserved.
//

import UIKit

class ClueCell: UITableViewCell {

    @IBOutlet var number: UILabel!
    @IBOutlet var clue: UILabel!
    
    func setNumber(_ num: String) {
        number.text = num
    }
    
    func setClue(_ emojis: String) {
        clue.text = emojis
    }
}
