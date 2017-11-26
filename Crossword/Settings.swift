//
//  Settings.swift
//  Crossword
//
//  Created by Tyler Stickler on 11/13/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit

class Settings {
    // Settings the user can modify to their preferences
    static var musicEnabled: Bool!
    static var soundEffects: Bool!
    static var showTimer: Bool!
    static var skipFilledSquares: Bool!
    static var lockCorrect: Bool!
    static var correctAnim: Bool!
    static var launchedBefore: Bool!
    static var cheatCount = 0
    static var adsDisabled: Bool!
    static var userLevel: Int!
    // Total number of levels
    static let maxNumOfLevels = 10
}
