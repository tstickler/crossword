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
    static let maxNumOfLevels = 24
    static var completedLevels = [Int]()
    static var uncompletedLevels = [Int]()
    static var lockedLevels = [Int]()
    static let newLevels = [19,20,21,22,23,24]
}
