//
//  GameViewController.swift
//  Crossword
//
//  Created by Tyler Stickler on 10/20/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit
import AVFoundation

class GameViewController: UIViewController {
    // Containers for button properties
    var buttonLetterArray: [Character]!
    var buttonTitleArray = Array(repeating: "", count: 169)
    var buttonAcrossArray = Array(repeating: "", count: 169)
    var buttonDownArray = Array(repeating: "", count: 169)
    var buttonLockedForCorrect = Array(repeating: false, count: 169)
    var buttonHintAcrossEnabled = Array(repeating: false, count: 169)
    var buttonHintDownEnabled = Array(repeating: false, count: 169)
    var buttonRevealedByHelper = Array(repeating: false, count: 169)
    
    // Allows us to save board state for user to come back to
    let defaults = UserDefaults.standard
    
    // Used to determine which phone the user has
    let screenSize = UIScreen.main.bounds

    var selectedBoardSpaces = [Int]()
    var across = true
    var userLevel = 1
    var indexOfButton: Int!
    var acrossNumbers = [Int]()
    var downNumbers = [Int]()
    var acrossClues = [(Num: String, Clue: String, Hint: String, WordCt: String)]()
    var downClues = [(Num: String, Clue: String, Hint: String, WordCt: String)]()
    
    // UI colors
    let blueColor = UIColor.init(red: 96/255, green: 199/255, blue: 255/255, alpha: 1)
    let blueColorCG = UIColor.init(red: 96/255, green: 199/255, blue: 255/255, alpha: 1).cgColor
    let redColorCG = UIColor.init(red: 255/255, green: 150/255, blue: 176/255, alpha: 1).cgColor
    let orangeColorCG = UIColor.init(red: 255/255, green: 197/255, blue: 126/255, alpha: 1).cgColor
    let yellowColorCG = UIColor.init(red: 249/255, green: 255/255, blue: 140/255, alpha: 1).cgColor
    
    // Cheat Buttons
    @IBOutlet var hintButton: UIButton!
    @IBOutlet var fillSquareButton: UIButton!
    @IBOutlet weak var cheatCountLabel: UILabel!
    @IBOutlet var hintEnabledButton: UIButton!
    
    var cheatCount: Int = 1000
    
    // Iterator to prevent inifinte loop
    var checkAllDirectionFilledIterator = 0
    
    // Hides the status bar in game so there is more room for the board
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Buttons for the keyboard and gameboard
    @IBOutlet var keys: [UIButton]!
    @IBOutlet var boardSpaces: [BoardButton]!
    
    // Keyboard area constraints to manage size on different devices
    @IBOutlet var topKeysHeight: NSLayoutConstraint!
    @IBOutlet var middleKeysHeight: NSLayoutConstraint!
    @IBOutlet var bottomKeysHeight: NSLayoutConstraint!
    @IBOutlet var keyboardBackHeight: NSLayoutConstraint!
    @IBOutlet var bottomRowLeading: NSLayoutConstraint!
    @IBOutlet var bottomRowTrailing: NSLayoutConstraint!
    
    // Clue area labels and buttons
    @IBOutlet var clueLabel: UILabel!
    @IBOutlet var directionLabel: UILabel!
    @IBOutlet var backPhraseButton: UIButton!
    @IBOutlet var nextPhraseButton: UIButton!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet var clueHeightConstraint: NSLayoutConstraint!
    
    // To know where the user last was
    var previousButton = 0
    
    // Timer
    @IBOutlet weak var timerStack: UIStackView!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    
    var gameTimer: Timer!
    var secondsCounter = 0
    var minutesCounter = 0
    var hoursCounter = 0
    let formatter = NumberFormatter()
    
    /*****************************************
    *                                        *
    *                 UI SETUP               *
    *                                        *
    *****************************************/
    
    func setUpBoard(board: [String]) {
        let iphoneSEkeysHeight: CGFloat = 45
        let iphoneKeysHeight: CGFloat = 52.5
        let iphonePlusKeysHeight: CGFloat = 55
        
        switch screenSize.height {
        // Sets constraints for iPhone SE
        case 568:
            topKeysHeight.constant = iphoneSEkeysHeight
            middleKeysHeight.constant = iphoneSEkeysHeight
            bottomKeysHeight.constant = iphoneSEkeysHeight
            
            bottomRowLeading.constant = 45
            bottomRowTrailing.constant = 45
        // Sets constraints for iPhone and iPhone X
        case 667:
            topKeysHeight.constant = iphoneKeysHeight
            middleKeysHeight.constant = iphoneKeysHeight
            bottomKeysHeight.constant = iphoneKeysHeight
            
            bottomRowLeading.constant = 52.5
            bottomRowTrailing.constant = 52.5
            
            clueLabel.font = clueLabel.font.withSize(40)
            clueHeightConstraint.constant = 55
            keyboardBackHeight.constant = 175
        // Sets constraints for iPhone Plus
        case 736:
            topKeysHeight.constant = iphonePlusKeysHeight
            middleKeysHeight.constant = iphonePlusKeysHeight
            bottomKeysHeight.constant = iphonePlusKeysHeight
            
            bottomRowLeading.constant = 55
            bottomRowTrailing.constant = 55
            
            keyboardBackHeight.constant = 185
            clueHeightConstraint.constant = 70
            clueLabel.font = clueLabel.font.withSize(45)
        // Sets constraints for iPhone X
        case 812:
            topKeysHeight.constant = 57
            middleKeysHeight.constant = 57
            bottomKeysHeight.constant = 57
            
            bottomRowLeading.constant = 52.5
            bottomRowTrailing.constant = 52.5
            
            keyboardBackHeight.constant = 190
            
            clueHeightConstraint.constant = 75
            clueLabel.font = clueLabel.font.withSize(40)
        default:
            break
        }
        
        // Gives buttons a nice rounded corner
        for button in keys {
            button.layer.cornerRadius = 5
        }
        
        // Set up the board buttons
        for button in boardSpaces {
            // If we are on a smaller screen have a smaller font for letters
            if screenSize.width == 320 {
                button.titleLabel?.font = button.titleLabel?.font.withSize(9.0)
            } else {
                button.titleLabel?.font = button.titleLabel?.font.withSize(13.0)
            }
            
            // Button letters should be black
            button.setTitleColor(.black, for: .normal)
            
            // Give buttons a nice rounded corner
            button.layer.cornerRadius = 2
        }
        
        // Gives each space on the board specific properties depending on how the board is arranged
        giveBoardSpacesProperties(board: board)
    }
    
    func clueAreaSetup() {
        // Set border width, shape, and color for the clue label, advancement buttons, and clue buttons
        clueLabel.layer.borderWidth = 2
        clueLabel.layer.cornerRadius = 10
        clueLabel.layer.borderColor = blueColorCG
        
        nextPhraseButton.layer.borderWidth = 1
        nextPhraseButton.layer.cornerRadius = 4
        nextPhraseButton.layer.borderColor = UIColor.white.cgColor
        nextPhraseButton.setTitleColor(blueColor, for: .normal)
        
        backPhraseButton.layer.borderWidth = 1
        backPhraseButton.layer.cornerRadius = 4
        backPhraseButton.layer.borderColor = UIColor.white.cgColor
        backPhraseButton.setTitleColor(blueColor, for: .normal)
        
        hintButton.layer.cornerRadius = 5
        hintButton.layer.backgroundColor = redColorCG
        
        fillSquareButton.layer.cornerRadius = 5
        fillSquareButton.layer.backgroundColor = orangeColorCG
        
        hintEnabledButton.layer.cornerRadius = 12.5
        hintEnabledButton.layer.borderColor = UIColor.white.cgColor
        hintEnabledButton.layer.borderWidth = 1
        
        let attributedString = NSAttributedString(string: "\(cheatCount)")
        let textRange = NSMakeRange(0, attributedString.length)
        let underlinedMessage = NSMutableAttributedString(attributedString: attributedString)
        underlinedMessage.addAttribute(NSAttributedStringKey.underlineStyle,
                                       value:NSUnderlineStyle.styleSingle.rawValue,
                                       range: textRange)
        cheatCountLabel.attributedText = underlinedMessage

        levelLabel.text = "Level \(userLevel)"
        
        if !Settings.showTimer {
            timerStack.isHidden = true
        } else {
            timerStack.isHidden = false
        }
    }
    
    func giveBoardSpacesProperties(board: [String]) {
        // Board[0] contains the letter of each square. If square should be blank, letter is "-"
        let gameBoardLetters = board[0]
        buttonLetterArray = Array(gameBoardLetters)
        
        // Board[1] contains the number of squares to indicate they are a phrase
        let gameBoardNums = board[1]
        
        // Board[2] contains down and across information for each square
        let gameBoardDA = board[2]
        
        // Each string above has different lenghts so iteration jumps are different between
        // the strings
        var letterIterator = 0
        var numbersIterator = 0
        var DAIterator = 0
        
        // Containers for object at specific index
        var letter: Character
        var number: Character
        var daString: String
        
        // Go through all the buttons and assign each one their needed information
        for i in 0...168 {
            
            // Grabs the letter in the string
            letter = buttonLetterArray[i]
            
            // If the letter is a "-", square should be disables and turned black
            // Otherwise, assign the letter to the square
            if letter == "-" {
                boardSpaces[i].isEnabled = false
                boardSpaces[i].backgroundColor = .black
            }
            
            // Grab the number in the string
            number = gameBoardNums[gameBoardNums.index(gameBoardNums.startIndex, offsetBy: numbersIterator)]
            
            // If the number is a "-" then there should be no number in the top corner so set the label to an empty string
            // Otherwise, set the label on the square to the corresponing number grabbed
            if number == "-" {
                boardSpaces[i].superscriptLabel.text?.append("")
            } else {
                boardSpaces[i].setSuperScriptLabel(number: String(number))
                
                // If the next character is a number as well, append it to the space label (so we can represent 2 digit numbers)
                if gameBoardNums[gameBoardNums.index(gameBoardNums.startIndex, offsetBy: numbersIterator + 1)] != "-" {
                    boardSpaces[i].superscriptLabel.text?.append(gameBoardNums[gameBoardNums.index(gameBoardNums.startIndex, offsetBy: numbersIterator + 1)])
                    
                    // Need serperate iterator because sometimes we need to take 2 from the string
                    numbersIterator += 1
                }
                
            }
            
            // The gameBoardDA is set up differently than the other two. Each space contains 6 characters in this format:
            // 00a00d
            // The first two numbers tell what number across it is apart of
            // The a indicates across
            // The second group of numbers tell what number down it is apart of
            // The d indicates down
            // The string looks like 00a00d00a00d01a01d etc.
            // Every button is assigned a down/across string (disabled buttons assigned 00a00d)
            
            // Grabs a string of 6 characters
            let startIndex = gameBoardDA.index(gameBoardDA.startIndex, offsetBy: DAIterator)
            let endIndex = gameBoardDA.index(gameBoardDA.startIndex, offsetBy: DAIterator+5)
            daString = String(gameBoardDA[startIndex...endIndex])
            
            // Splits in half, button's across property assigned first half and down property assigned second half
            let midIndex = daString.index(daString.startIndex, offsetBy: 3)
            buttonAcrossArray[i] = String(daString[..<midIndex])
            buttonDownArray[i] = String(daString[midIndex..<daString.endIndex])
            
            // Increase the iterators. DA iterator increases 6 since it has a greater length than the other strings
            numbersIterator += 1
            letterIterator += 1
            DAIterator += 6
        }
    }
    
    
     /*****************************************
     *                                        *
     *             Action Handling            *
     *                                        *
     *****************************************/
    
    @IBAction func boardButtonTapped(_ sender: BoardButton) {
        // Uses tag of tapped square to determine row/column that user tapped
        let square = String(sender.tag)
        var selectedRow = ""
        var selectedColumn = ""
        
        // Tags go from 101 to 1313
        // First digit with a 3 digit tag is row of square
        // First two digits with a 4 digit tag is row of square
        // Last two digits of the tag is column
        if square.count == 4 {
            // Index 0 and 1
            let startRow = square.startIndex
            let endRow = square.index(startRow, offsetBy: 1)
            
            // Index 2 and 3
            let startCol = square.index(square.startIndex, offsetBy: 2)
            let endCol = square.endIndex
            
            // First two digits
            selectedRow = String(square[startRow...endRow])
            
            // Last two digits
            selectedColumn = String(square[startCol..<endCol])
        } else {
            // Index 1 and 2
            let startCol = square.index(square.startIndex, offsetBy: 1)
            let endCol = square.endIndex
            
            // First digit
            selectedRow = String(square[square.startIndex])
            
            // Last two digits
            selectedColumn = String(square[startCol..<endCol])
        }
        
        // Convert the row and column to integers
        let row = Int(selectedRow)!
        let col = Int(selectedColumn)!
        
        // Use row and column to determine where in the outlet array the
        // selected button is
        indexOfButton = ((row - 1) * 13) + col - 1
        
        // Determines which buttons are selected and should be highlighted
        rowAndColumnDetermination(indexOfButton: indexOfButton)
        
        // Set the label for the clueLabel
        clueLabel.text = getSpotInfo(indexOfButton: indexOfButton, info: "Clue")
        
        // Set the label for the direction
        determineDirectionText(indexOfButton: indexOfButton)
        
        // Determine if hint enabled button should be shown for selected squares
        if (across && buttonHintAcrossEnabled[indexOfButton]) ||
            (!across && buttonHintDownEnabled[indexOfButton]) {
            hintEnabledButton.isHidden = false
            hintEnabledButton.isEnabled = true
            
            hintButton.backgroundColor = .gray
            hintButton.isEnabled = false
        } else {
            hintButton.backgroundColor = UIColor(cgColor: redColorCG)
            hintEnabledButton.isHidden = true
            hintEnabledButton.isEnabled = false
            
            hintButton.isEnabled = true
        }
        
        // Allows us to look back one to see what the last press was
        previousButton = indexOfButton
    }

    var erasing = false
    @IBAction func eraseButtonTapped(_ sender: Any) {
        // Get current square
        let currentSquareTitle = boardSpaces[indexOfButton].title(for: .normal)
        
        // If the square has text, erase it and stay there
        if currentSquareTitle != nil && (buttonLockedForCorrect[indexOfButton] == false || !Settings.lockCorrect && !buttonRevealedByHelper[indexOfButton]) {
            boardSpaces[indexOfButton].setTitle(nil, for: .normal)
            buttonTitleArray[indexOfButton] = ""
            defaults.set(buttonTitleArray, forKey: "buttonTitles")
            
            // Erasing a correct answer should make it uncorrect again
            if buttonLockedForCorrect[indexOfButton] {
                buttonLockedForCorrect[indexOfButton] = false
            }
        } else {
            // Otherwise, if the square is empty see if we're at the beginning of
            // the selected phrase
            if indexOfButton == selectedBoardSpaces.min() {
                // If we're at the beginning, we are going to go back a phrase
                // when the erase button is pressed. We also need to allow erasing
                // since skip filled squares will affect our jump back a phrase. If
                // we don't, the selector will stay at the same square.
                erasing = true
                backPhraseButton.sendActions(for: .touchUpInside)
                erasing = false
                
                // And the selected square should be the last one of the phrase
                indexOfButton = selectedBoardSpaces.max()!
                
                // Then simulate a tap there
                boardButtonTapped(boardSpaces[indexOfButton])
                
            } else {
                // If we aren't at the beginning of a phrase, just move a square
                // back if across or 13 back if down
                if across {
                    boardButtonTapped(boardSpaces[indexOfButton - 1])
                } else {
                    boardButtonTapped(boardSpaces[indexOfButton - 13])
                }
            }
            
            // Erase the selected square
            if buttonLockedForCorrect[indexOfButton] == false || !Settings.lockCorrect && !buttonRevealedByHelper[indexOfButton] {
                boardSpaces[indexOfButton].setTitle(nil, for: .normal)
                buttonTitleArray[indexOfButton] = ""
                defaults.set(buttonTitleArray, forKey: "buttonTitles")

                // If it was locked, we need to unlock it since it is being erased
                if buttonLockedForCorrect[indexOfButton] == true {
                    buttonLockedForCorrect[indexOfButton] = false
                }
            }
        }
    }
    
    
    @IBAction func nextPhraseButtonTapped(_ sender: Any) {
        // Container for candidates that are available to move to
        var moveCandidates = [Int]()
        
        if across {
            // Generate possible candidates for move
            // Looks at the current square to get its across number
            let acrossString = buttonAcrossArray[indexOfButton]
            let acrossStart = acrossString.startIndex
            let num = Int(acrossString[acrossStart...acrossString.index(after: acrossStart)])!
            
            // Candidate for forward movement are any number in across numbers that
            // is greater than the current across value.
            for potentialCandidate in acrossNumbers {
                if potentialCandidate > num {
                    moveCandidates.append(potentialCandidate)
                }
            }
            
            // TEST CANDIDATE
            if !moveCandidates.isEmpty {
                // Start looking at the minimum candidate (first number after current square)
                let candidate = moveCandidates.min()!
                
                // If our candidate is < 10, we need to 0 in the front for comparing,
                // otherwise there is no leading 0.
                var stringToLook = ""
                if candidate < 10 {
                    stringToLook = "0\(candidate)a"
                } else {
                    stringToLook = "\(candidate)a"
                }
                
                // Evaluate the current candidate
                test: for i in 0...168 {
                    // Found the candidate
                    if buttonAcrossArray[i] == stringToLook {
                        // Move to candidate
                        boardButtonTapped(boardSpaces[i])
                        
                        // Sometimes, stop when we hit the first candidate
                        // This occurs when the first letter is not filled, the user
                        // has turned off skip filled squares, or when all squares
                        // have been filled (but aren't all correct)
                        if boardSpaces[i].currentTitle == nil || !Settings.skipFilledSquares || allSquaresFilled() {
                            break
                        }
                        
                        // Move foward through the selected phrase until an empty spot is found
                        for x in selectedBoardSpaces.min()!...selectedBoardSpaces.max()! {
                            if(boardSpaces[x].currentTitle == nil) {
                                boardButtonTapped(boardSpaces[x])
                                break test
                            }
                        }
                        
                        // If our candidate was unsuccessful (all squares filled), start over
                        nextPhraseButton.sendActions(for: .touchUpInside)
                        return
                    }
                }
            } else {
                // If our across candidates were empty, switch to down
                across = false
                
                // Find a blank landing spot (00a00d) so we can evaluate
                // all possibilites
                indexOfButton = 0
                while boardSpaces[indexOfButton].isEnabled {
                    indexOfButton! += 1
                }
                
                // Start over checking down this time
                nextPhraseButton.sendActions(for: .touchUpInside)
                return
            }
        } else if !across {
            // Generate possible candidates for move
            // Looks at the current square to get its down number
            let downString = buttonDownArray[indexOfButton]
            let downStart = downString.startIndex
            let num = Int(downString[downStart...downString.index(after: downStart)])!
            
            // Candidate for forward movement are any number in down numbers that
            // is greater than the current down value.
            for i in downNumbers {
                if i > num {
                    moveCandidates.append(i)
                }
            }

            // TEST CANDIDATE
            if !moveCandidates.isEmpty {
                // Start looking at the minimum candidate (first number after current square)
                let candidate = moveCandidates.min()!
                
                // If our candidate is < 10, we need to 0 in the front for comparing,
                // otherwise there is no leading 0.
                var stringToLook = ""
                if candidate < 10 {
                    stringToLook = "0\(candidate)d"
                } else {
                    stringToLook = "\(candidate)d"
                }
                
                // Evaluate the current candidate
                test: for i in 0...168 {
                    // Found the candidate
                    if buttonDownArray[i] == stringToLook {
                        boardButtonTapped(boardSpaces[i])
                        
                        // Sometimes, stop when we hit the first candidate
                        // This occurs when the first letter is not filled, the user
                        // has turned off skip filled squares, or when all squares
                        // have been filled (but aren't all correct)
                        if boardSpaces[i].currentTitle == nil || !Settings.skipFilledSquares || allSquaresFilled() {
                            break
                        }
                        
                        // Move foward through the selected phrase until an empty spot is found
                        // Uses stride to allow iterating by 13 each loop
                        for x in stride(from: selectedBoardSpaces.min()!, to: selectedBoardSpaces.max()!, by: 13) {
                            if(boardSpaces[x].currentTitle == nil) {
                                boardButtonTapped(boardSpaces[x])
                                break test
                            }
                        }
                        
                        // If our candidate was unsuccessful (all squares filled), start over
                        nextPhraseButton.sendActions(for: .touchUpInside)
                        return
                    }
                }
            } else {
                // If our down candidates were empty, switch to across
                across = true
                
                // Find a blank landing spot (00a00d) so we can evaluate
                // all possibilites
                indexOfButton = 0
                while boardSpaces[indexOfButton].isEnabled {
                    indexOfButton! += 1
                }
                
                // Start over checking across this time
                nextPhraseButton.sendActions(for: .touchUpInside)
                return
            }
        }
    }
    
    @IBAction func backPhraseButtonTapped(_ sender: Any) {
        // Container for candidates that are available to move to
        var moveCandidates = [Int]()
        
        if across {
            // Generate possible candidates for move
            // Looks at the current square to get its across number
            let acrossString = buttonAcrossArray[indexOfButton]
            let acrossStart = acrossString.startIndex
            var num = Int(acrossString[acrossStart...acrossString.index(after: acrossStart)])!
            
            // If we're starting from a blank landing spot, all values should be candidates
            if num == 0 {
                num = acrossNumbers.max()! + 1
            }
            
            // Candidate for backward movement are any number in across numbers that
            // is smaller than the current across value.
            for potentialCandidate in acrossNumbers {
                if potentialCandidate < num {
                    moveCandidates.append(potentialCandidate)
                }
            }
            
            // TEST CANDIDATE
            if !moveCandidates.isEmpty {
                // Start looking at the maximum candidate (first number before current square)
                let candidate = moveCandidates.max()!
                
                // If our candidate is < 10, we need to 0 in the front for comparing,
                // otherwise there is no leading 0.
                var stringToLook = ""
                if candidate < 10 {
                    stringToLook = "0\(candidate)a"
                } else {
                    stringToLook = "\(candidate)a"
                }
                
                // Evaluate our current candidate
                test: for i in 0...168 {
                    // Foud the candidate
                    if buttonAcrossArray[i] == stringToLook {
                        // Move to candidate
                        boardButtonTapped(boardSpaces[i])
                        
                        // Sometimes, stop when we hit the first candidate
                        // This occurs when the first letter is not filled, the user
                        // has turned off skip filled squares, when all squares
                        // have been filled (but aren't all correct), or when
                        // we are erasing
                        if boardSpaces[i].currentTitle == nil || !Settings.skipFilledSquares || allSquaresFilled() || erasing {
                            break
                        }
                        
                        // Move foward through the selected phrase until an empty spot is found
                        for x in selectedBoardSpaces.min()!...selectedBoardSpaces.max()! {
                            if(boardSpaces[x].currentTitle == nil) {
                                boardButtonTapped(boardSpaces[x])
                                break test
                            }
                        }
                        
                        // If our candidate was unsuccessful (all squares filled), start over
                        backPhraseButton.sendActions(for: .touchUpInside)
                        return
                    }
                }
            } else {
                // If our across candidates were empty, switch to down
                across = false
                
                // Find a blank landing spot (00a00d) so we can evaluate
                // all possibilites
                indexOfButton = 0
                while boardSpaces[indexOfButton].isEnabled {
                    indexOfButton! += 1
                }
                
                // Start over checking down this time
                backPhraseButton.sendActions(for: .touchUpInside)
                return
            }
        } else if !across {
            // Generate possible candidates for move
            // Looks at the current square to get its across number
            let downString = buttonDownArray[indexOfButton]
            let downStart = downString.startIndex
            var num = Int(downString[downStart...downString.index(after: downStart)])!
            
            // If we're starting from a blank landing spot, all values should be candidates
            if num == 0 {
                num = downNumbers.max()! + 1
            }
            
            // Candidate for backward movement is any number in down numbers that
            // is smaller than the current down value.
            for potentialCandidate in downNumbers {
                if potentialCandidate < num {
                    moveCandidates.append(potentialCandidate)
                }
            }
            
            // TEST CANDIDATE
            if !moveCandidates.isEmpty {
                // Start looking at the maximum candidate (first number before current square)
                let candidate = moveCandidates.max()!
                
                // If our candidate is < 10, we need to 0 in the front for comparing,
                // otherwise there is no leading 0.
                var stringToLook = ""
                if candidate < 10 {
                    stringToLook = "0\(candidate)d"
                } else {
                    stringToLook = "\(candidate)d"
                }
                
                // Evaluate our current candidate
                for i in 0...168 {
                    if buttonDownArray[i] == stringToLook {
                        // Move to candidate
                        boardButtonTapped(boardSpaces[i])
                        
                        // Sometimes, stop when we hit the first candidate
                        // This occurs when the first letter is not filled, the user
                        // has turned off skip filled squares, when all squares
                        // have been filled (but aren't all correct), or when
                        // we are erasing
                        if boardSpaces[i].currentTitle == nil || !Settings.skipFilledSquares || allSquaresFilled() || erasing {
                            break
                        }
                        
                        // Move foward through the selected phrase until an empty spot is found
                        test: for x in stride(from: selectedBoardSpaces.min()!, to: selectedBoardSpaces.max()!, by: 13) {
                            if(boardSpaces[x].currentTitle == nil) {
                                boardButtonTapped(boardSpaces[x])
                                break test
                            }
                        }
                        
                        // If our candidate was unsuccessful (all squares filled), start over
                        backPhraseButton.sendActions(for: .touchUpInside)
                        return
                    }
                }
            } else {
                // If our down candidates were empty, switch to across
                across = true
                
                // Find a blank landing spot (00a00d) so we can evaluate
                // all possibilites
                indexOfButton = 0
                while boardSpaces[indexOfButton].isEnabled {
                    indexOfButton! += 1
                }
                
                // Start over checking across this time
                backPhraseButton.sendActions(for: .touchUpInside)
                return
            }
        }
    }

    @IBAction func hintButtonTapped(_ sender: Any) {
        if cheatCount == 0 {
            return
        }
        
        performSegue(withIdentifier: "hintSegue", sender: self)
        
        for index in selectedBoardSpaces {
            if across {
                buttonHintAcrossEnabled[index] = true
                boardSpaces[index].showHintLabel()

                if !buttonRevealedByHelper[index] {
                }
            } else {
                buttonHintDownEnabled[index] = true
                boardSpaces[index].showHintLabel()

                if !buttonRevealedByHelper[index] {
                }
            }
        }
        
        hintEnabledButton.isEnabled = true
        hintEnabledButton.isHidden = false
        hintButton.backgroundColor = .gray
        
        // Remove a cheat and set the label
        cheatCount -= 1
        
        if cheatCount == 0 {
            fillSquareButton.backgroundColor = .gray
            hintButton.backgroundColor = .gray
        }
        
        let stringToUnderline = NSAttributedString(string: "\(cheatCount)")
        let textRange = NSMakeRange(0, stringToUnderline.length)
        let underlinedCount = NSMutableAttributedString(attributedString: stringToUnderline)
        underlinedCount.addAttribute(NSAttributedStringKey.underlineStyle,
                                     value:NSUnderlineStyle.styleSingle.rawValue,
                                     range: textRange)
        cheatCountLabel.attributedText = underlinedCount
        
        hintButton.isEnabled = false
    }
    
    @IBAction func fillSquareButtonTapped(_ sender: Any) {
        if cheatCount == 0  || buttonRevealedByHelper[indexOfButton] {
            return
        }
        
        // A square revealed by a cheat should never be able to be erased or changed
        buttonRevealedByHelper[indexOfButton] = true
        buttonLockedForCorrect[indexOfButton] = true
        
        // Set the title equal to the correct answer
        // Set the background to indicate a cheat was used at that square
        boardSpaces[indexOfButton].setTitle(String(buttonLetterArray[indexOfButton]).uppercased(), for: .normal)
        buttonTitleArray[indexOfButton] = String(buttonLetterArray[indexOfButton]).uppercased()
        defaults.set(buttonTitleArray, forKey: "buttonTitles")

        boardSpaces[indexOfButton].backgroundColor = UIColor.init(cgColor: orangeColorCG)
        
        // Remove a cheat and set the label
        cheatCount -= 1
        
        if cheatCount == 0 {
            fillSquareButton.backgroundColor = .gray
            hintButton.backgroundColor = .gray
        }
        
        let stringToUnderline = NSAttributedString(string: "\(cheatCount)")
        let textRange = NSMakeRange(0, stringToUnderline.length)
        let underlinedCount = NSMutableAttributedString(attributedString: stringToUnderline)
        underlinedCount.addAttribute(NSAttributedStringKey.underlineStyle,
                                       value:NSUnderlineStyle.styleSingle.rawValue,
                                       range: textRange)
        cheatCountLabel.attributedText = underlinedCount

        if correctAnswerEntered() {
            if Settings.correctAnim {
                highlightCorrectAnswer()
            }
        }
        
        if allSquaresFilled() {
            // See if the user has entered all the right answers
            if gameOver() {
                clueLabel.textColor = .white
                clueLabel.text = "Game Over"
                return
            } else {
                // If the user isn't right, tell them how many wrong
                clueLabel.textColor = .white
                clueLabel.text = "\(countWrong()) wrong"
                return
            }
        }
        
        // Move after cheat use
        if across {
            moveToNextAcross()
        } else {
            moveToNextDown()
        }
    }
    
    
    
    @IBAction func keyboardButtonPressed(_ sender: UIButton) {
        // Each key of the keyboard has a tag from 1-26. The tag tells which key was pressed.
        // Keyboard is standard qwerty and tags start at Q(1) and end at M(26)
        var letter: Character!
        
        switch sender.tag {
        case 1:
            letter = "q"
        case 2:
            letter = "w"
        case 3:
            letter = "e"
        case 4:
            letter = "r"
        case 5:
            letter = "t"
        case 6:
            letter = "y"
        case 7:
            letter = "u"
        case 8:
            letter = "i"
        case 9:
            letter = "o"
        case 10:
            letter = "p"
        case 11:
            letter = "a"
        case 12:
            letter = "s"
        case 13:
            letter = "d"
        case 14:
            letter = "f"
        case 15:
            letter = "g"
        case 16:
            letter = "h"
        case 17:
            letter = "j"
        case 18:
            letter = "k"
        case 19:
            letter = "l"
        case 20:
            letter = "z"
        case 21:
            letter = "x"
        case 22:
            letter = "c"
        case 23:
            letter = "v"
        case 24:
            letter = "b"
        case 25:
            letter = "n"
        case 26:
            letter = "m"
        default:
            letter = nil
        }
        
        // Sets the board space to display the uppercase letter if the space isn't locked
        if !buttonLockedForCorrect[indexOfButton] || !Settings.lockCorrect && !buttonRevealedByHelper[indexOfButton]{
            // If the space was a correct answer but was changed, indicate that square is wrong
            if buttonLockedForCorrect[indexOfButton] &&
                letter != buttonLetterArray[indexOfButton] {
                buttonLockedForCorrect[indexOfButton] = false
            }
            boardSpaces[indexOfButton].setTitle(String(letter).uppercased(), for: .normal)
            buttonTitleArray[indexOfButton] = String(letter).uppercased()
            defaults.set(buttonTitleArray, forKey: "buttonTitles")
        } else {
            // If the space is locked, lets just move to the next square
            if across {
                moveToNextAcross()
            } else {
                moveToNextDown()
            }
            return
        }
        
        // After each key press we should check if there is a correct answer. If there is,
        // check if the user has entered all the right answers. If they have, end the game.
        // Otherwise, skip to the next square.
        if correctAnswerEntered() {
            if Settings.correctAnim {
                highlightCorrectAnswer()
                
                // We also need to check if correct answer was entered at an intersection.
                // This occurs when one letter of across is left and one letter of down is left.
                // If the correct answer is entered, then we need to highlight both the across
                // and down spaces.
                // So send a press for the current button to flip orientation, then check if
                // that was is correct and highlight if it is.
                boardSpaces[indexOfButton].sendActions(for: .touchUpInside)
                if correctAnswerEntered() {
                    highlightCorrectAnswer()
                }
                
                // Then we'll flip back to our original orientation
                boardSpaces[indexOfButton].sendActions(for: .touchUpInside)
            }
            
            // See if all the squares have been filled
            if allSquaresFilled() {
                // If all squares are filled, see if the user is right
                if gameOver(){
                    clueLabel.textColor = .white
                    clueLabel.text = "Game Over"
                    return
                } else {
                    // If the user isn't right, tell them how many wrong
                    clueLabel.textColor = .white
                    clueLabel.text = "\(countWrong()) wrong"
                    return
                }
            } else {
                nextPhraseButton.sendActions(for: .touchUpInside)
            }
            // Return so we go to the first spot in the next phrase and not the second
            return
        } else if allSquaresFilled() {
            // If the user isn't right, tell them how many wrong
            clueLabel.textColor = .white
            clueLabel.text = "\(countWrong()) wrong"
            return
        } else {
            // This checks the other direction at an intersection but the original
            // direction is not completely correct.
            // Useful when user has all but one letter and is going
            // through at a different direction and fills the last correct
            // space.
            
            // Flip the direction
            boardSpaces[indexOfButton].sendActions(for: .touchUpInside)
            
            // See if that direction is correct and highlight if it is
            if correctAnswerEntered() {
                highlightCorrectAnswer()
            }
            
            // Go back to the original direction
            boardSpaces[indexOfButton].sendActions(for: .touchUpInside)
        }
        
        // If there was no correct answer, then move to the next spot in current orientation
        if across {
            moveToNextAcross()
        } else {
            moveToNextDown()
        }
    }
    
    func gameOver() -> Bool {
        for i in 0...168 {
            // Each inactive space is assigned a "-" as their letter.
            // Check if all the buttons that can be tapped have non-nil values.
            // If there is still a nil value, there is an open board space, which
            // means the game is not over.
            if boardSpaces[i].title(for: .normal) == nil && buttonLetterArray[i] != "-" {
                return false
            } else {
                if var spaceTitle = boardSpaces[i].title(for: .normal) {
                    // Letters are stored lowercase while titles are displayed as uppercase.
                    // Lowercase the title so we can compare it with the stored letter.
                    spaceTitle = spaceTitle.lowercased()
                    
                    // Nothing needs to happen if the letters match or we're at a inactive square.
                    // Just continue the loop
                    if Character(spaceTitle) == buttonLetterArray[i] || buttonLetterArray[i] == "-" {
                        /* nothing needs to happen */
                    } else {
                        // If the user entered a wrong answer, then the game is not over
                        return false
                    }
                }

            }
        }
        
        // If we made it all the way through the board spaces without returning false
        // then the user has finished the game.
        return true
    }
    
    func correctAnswerEntered() -> Bool {
        // Checks the selected spaces with their assigned letters, if it determines that
        // they are all correct returns true, otherwise returns false.
        for space in selectedBoardSpaces {
            if let userEntry = boardSpaces[space].title(for: .normal)?.lowercased() {
                let entryToChar = Character(userEntry.lowercased())
                if entryToChar == buttonLetterArray[space] {
                    /* nothing needs to happen */
                } else {
                    return false
                }
            } else {
                return false
            }
        }
        
        // Disallow changing of letters after correct answer entered
        for space in selectedBoardSpaces {
            buttonLockedForCorrect[space] = true
        }
        return true
    }
    
    func moveToNextAcross() {
        // Checks bounds before movement
        if indexOfButton < 168 {
            boardSpaces[indexOfButton + 1].sendActions(for: .touchUpInside)
        } else {
            across = false
            nextPhraseButton.sendActions(for: .touchUpInside)
            return
        }
        
        // If we hit a disabled square or a square not part of an across go to next across phrase
        if !boardSpaces[indexOfButton].isEnabled || buttonAcrossArray[indexOfButton] == "00a" {
            boardSpaces[indexOfButton - 1].sendActions(for: .touchUpInside)
            nextPhraseButton.sendActions(for: .touchUpInside)
        }
        
        // Skip filled squares
        if boardSpaces[indexOfButton].currentTitle != nil && Settings.skipFilledSquares {
            // We need to check and make sure all the across squares aren't filled
            // If they are, and we try to move to the next across, we get an infinite loop
            // Use of an iterator to see if we've gone through every single button helps
            // us decide if we've evaluated all possible across squares to move to. If we
            // have checked every square we need to go to the next available down. We also
            // check all squares filled as well because even if the iterator has checked
            // to see if we can't do anymore across, it'll just oscilate between across
            // and down checking.
            if gameOver() || allSquaresFilled() {
                return
            }
            
            // Do the iterator checking
            checkAllDirectionFilledIterator += 1
            if checkAllDirectionFilledIterator > 168 {
                indexOfButton = 0
                checkAllDirectionFilledIterator = 0
                across = false
                moveToNextDown()
                return
            }
            
            moveToNextAcross()
        }
        
        // Reset the iterator if we've made a successful move
        checkAllDirectionFilledIterator = 0
    }
    
    func moveToNextDown() {
        // Bounds check
        var outOfBounds = false
        if indexOfButton + 13 > 168 {
            outOfBounds = true
        }
        
        if !outOfBounds {
            boardSpaces[indexOfButton + 13].sendActions(for: .touchUpInside)
            across = false
        }
        
        // Loop through our array containing all down number. Since the array is sorted,
        // once we hit a number greater than the current one that's where we'll jump.
        // If we ever hit a spot where we loop through the whole down array, we're going
        // to flip the orientation to across and go to the first across.
        if outOfBounds || !boardSpaces[indexOfButton].isEnabled || buttonDownArray[indexOfButton] == "00d" {
            boardSpaces[indexOfButton - 13].sendActions(for: .touchUpInside)
            nextPhraseButton.sendActions(for: .touchUpInside)
        }
        
        // Skip filled squares
        if boardSpaces[indexOfButton].currentTitle != nil && Settings.skipFilledSquares {
            // We need to check and make sure all the down squares aren't filled
            // If they are, and we try to move to the next down, we get an infinite loop
            // Use of an iterator to see if we've gone through every single button helps
            // us decide if we've evaluated all possible across squares to move to. If we
            // have checked every square we need to go to the next available across. We also
            // check all squares filled as well because even if the iterator has checked
            // to see if we can't do anymore across, it'll just oscilate between across
            // and down checking.
            if gameOver() || allSquaresFilled() {
                return
            }
            
            // Do the iterator checking
            checkAllDirectionFilledIterator += 1
            if checkAllDirectionFilledIterator > 168 {
                indexOfButton = 0
                checkAllDirectionFilledIterator = 0
                across = true
                moveToNextAcross()
                return
            }

            moveToNextDown()
        }
        
        // Reset the iterator if we've made a successful move
        checkAllDirectionFilledIterator = 0
    }
    
    func getSpotInfo(indexOfButton: Int, info: String) -> String {
        var i = 0
        // Grabs the clue related to the selected square
        // If we are currently looking for across, get the across clue associated with the square
        if across {
            // Grab across variable to determine where in the plist we should look
            // Remember, the across string is in the form 00a, with the numbers being
            // the related across
            let across = buttonAcrossArray[indexOfButton]
            
            // Toss out the a, and a leading 0 if it is there
            // The plist has the number with no leading 0
            var numAcross = String(across[across.startIndex..<across.index((across.startIndex), offsetBy: 2)])
            if numAcross[numAcross.startIndex] == "0" {
                numAcross = String(numAcross[numAcross.index(numAcross.startIndex, offsetBy: 1)])
            }
            
            // Go through the plist until we find the matching across
            while i < acrossClues.count {
                // If we find the across, set the clue label to the matching clue.
                // Since our plist is set up with Phrase/Clue/Hint/Across/Down all in the
                // same index, we can use the index where we found our across number to get
                // the corresponding clue
                if acrossClues[i].Num == numAcross {
                    switch info {
                        case "Clue":
                            return acrossClues[i].Clue
                        case "Hint":
                            return acrossClues[i].Hint
                        case "WordCt":
                            return acrossClues[i].WordCt
                        case "Num":
                            return acrossClues[i].Num
                        default:
                            return ""
                    }
                }
                i += 1
            }
        } else {
            // If we are currently looking for down, get the down clue associated with the square
            
            // Grab down variable to determine where in the plist we should look
            // Remember, the down string is in the form 00d, with the numbers being
            // the related down
            let down = buttonDownArray[indexOfButton]
            
            // Toss out the d, and a leading 0 if it is there
            // The plist has the number with no leading 0
            var numDown = String(down[down.startIndex..<down.index((down.startIndex), offsetBy: 2)])
            if numDown[numDown.startIndex] == "0" {
                numDown = String(numDown[numDown.index(numDown.startIndex, offsetBy: 1)])
            }
            
            // If we find the down, set the clue label to the matching clue.
            // Since our plist is set up with Phrase/Clue/Hint/Across/Down all in the
            // same index, we can use the index where we found our down number to get
            // the corresponding clue
            while i < downClues.count {
                if downClues[i].Num == numDown {
                    switch info {
                    case "Clue":
                        return downClues[i].Clue
                    case "Hint":
                        return downClues[i].Hint
                    case "WordCt":
                        return downClues[i].WordCt
                    case "Num":
                        return downClues[i].Num
                    default:
                        return ""
                    }
                }
                i += 1
            }
        }
        
        // Nothing found (shouldn't ever happen)
        return ""
    }
    
    // Checks if all the available spaces have been answered
    func allSquaresFilled() -> Bool {
        for button in boardSpaces {
            if !button.isEnabled || button.currentTitle != nil {
                /* Don't need to do anything, keep loop going */
            } else {
                return false
            }
        }
        return true
    }
    
    func countWrong() -> Int {
        var numberWrongCounter = 0
        
        // Loop through the board spaces and find how many errors the user made
        for i in 0...168 {
            if var spaceTitle = boardSpaces[i].title(for: .normal) {
                // Letters are stored lowercase while titles are displayed as uppercase.
                // Lowercase the title so we can compare it with the stored letter.
                spaceTitle = spaceTitle.lowercased()
                    
                // Nothing needs to happen if the letters match or we're at a inactive square.
                // Just continue the loop
                if Character(spaceTitle) == buttonLetterArray[i] || buttonLetterArray[i] == "-" {
                    /* nothing needs to happen */
                } else {
                    // If the user entered a wrong answer, increase our counter
                    numberWrongCounter += 1
                }
            }
        }
        
        return numberWrongCounter
    }
    
     /*****************************************
     *                                        *
     *               Highlighting             *
     *                                        *
     *****************************************/
    func highlight(selectedSpaces: [Int], atSquare: Int, prevSquare: Int) {
        
        // Sets the border for the spaces
        for i in selectedSpaces {
            // CAShapeLayer allows us to put the border outside of the button, giving the button more space
            let border = CAShapeLayer()
            
            // Give the layer a name so we can remove it when it shouldn't be highlighted
            border.name = "BORDER"
            
            // Sets the properties of the border
            switch screenSize.height{
            case 568:
                border.frame = CGRect(x: 0, y: 0, width: 21, height: 21)
            case 667:
                border.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
            case 736:
                border.frame = CGRect(x: 0, y: 0, width: 29, height: 30)
            case 812:
                border.frame = CGRect(x: 0, y: 0, width: 25, height: 28.3)
            default:
                border.frame = boardSpaces[i].bounds
            }
            border.lineWidth = 2.5
            border.path = UIBezierPath(roundedRect: border.bounds, cornerRadius:3).cgPath
            border.fillColor = UIColor.clear.cgColor
            border.strokeColor = blueColorCG
            self.boardSpaces[i].layer.addSublayer(border)
        }
        
        // Gives the selected button a pulsing animation
        if atSquare != prevSquare {
            let pulse = CABasicAnimation(keyPath: "transform.scale")
            pulse.duration = 1.2
            pulse.autoreverses = true
            pulse.repeatCount = .infinity
            pulse.fromValue = 1
            pulse.toValue = 1.25
            self.boardSpaces[atSquare].layer.add(pulse, forKey: "")
            boardSpaces[atSquare].layer.zPosition = 1000
            
            // Make sure that the pulsing button always grows above the others
            for space in boardSpaces {
                if space != boardSpaces[atSquare] {
                    space.layer.zPosition = 0
                }
            }
        }
    }
    
    func highlightCorrectAnswer() {
        // Sets the border for the spaces
        for i in selectedBoardSpaces {
            // CAShapeLayer allows us to put the border outside of the button, giving the button more space
            let border = CAShapeLayer()
            
            // Sets the properties of the border
            switch screenSize.height{
            case 568:
                border.frame = CGRect(x: 0, y: 0, width: 21, height: 21)
            case 667:
                border.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
            case 736:
                border.frame = CGRect(x: 0, y: 0, width: 29, height: 30)
            case 812:
                border.frame = CGRect(x: 0, y: 0, width: 25, height: 28)
            default:
                border.frame = boardSpaces[i].bounds
            }

            // Width is 0 since we don't want a border left over after the animation
            border.lineWidth = 0
            border.path = UIBezierPath(roundedRect: border.bounds, cornerRadius:3).cgPath
            border.fillColor = UIColor.clear.cgColor
            border.strokeColor = UIColor.green.cgColor
            
            self.boardSpaces[i].layer.addSublayer(border)
            
            // Animation to be played on the border. Grows quickly then shrinks.
            let animation = CABasicAnimation(keyPath: "lineWidth")
            animation.duration = 0.45
            animation.fromValue = 0
            animation.toValue = 4
            animation.autoreverses = true
            border.add(animation, forKey: "")
            border.zPosition = 1000
        }
    }
    
    func determineDirectionText(indexOfButton: Int) {
        // This text is displayed in the clue bar. Extra indicator of where the user is and what
        // direction they are currently inputting text for.
        // eg Displays "1↓" for one down
        
        var number: Int
        var direction: Character
        
        // Grabs information from the current square. Current orientation determines which info
        // should be grabbed.
        if across {
            let acrossString = buttonAcrossArray[indexOfButton]
            let acrossStringStart = acrossString.startIndex
            let acrossStringEnd = acrossString.endIndex
            
            number = Int(acrossString[acrossStringStart...acrossString.index(after: acrossStringStart)])!
            direction = acrossString[(acrossString.index(before: acrossStringEnd))]
        } else {
            let downString = buttonDownArray[indexOfButton]
            let downStart = downString.startIndex
            let downEnd = downString.endIndex
            
            number = Int(downString[downStart...downString.index(after: downStart)])!
            direction = downString[(downString.index(before: downEnd))]
        }
        
        // Start creating our label with the number of the across or down
        var directionLabelText = String(number)
        
        // Append the arrow to string we're going to set
        if direction == "a" {
            directionLabelText.append("→")
        } else {
            directionLabelText.append("↓")
        }
        
        // Set the label
        directionLabel.text = directionLabelText
    }
    
    func rowAndColumnDetermination(indexOfButton: Int) {
        var i = indexOfButton
        
        // Remove border from old selection
        for button in boardSpaces {
            for layer in button.layer.sublayers! {
                if layer.name == "BORDER" {
                    layer.removeFromSuperlayer()
                }
            }
        }
        
        // Empty array containing previous board spaces
        selectedBoardSpaces.removeAll(keepingCapacity: false)
        
        // Sets the initial highlight based on what path it is included in
        // If there is no down then automatically switch to across
        // If there is no across, automatically switch to down
        if buttonDownArray[indexOfButton] == "00d" {
            across = true
        } else if buttonAcrossArray[indexOfButton] == "00a" {
            across = false
        }
        
        // Double tapping on a button results in flipping its orietation as long as
        // the flip is valid and the button is part of both across and down
        if indexOfButton == previousButton && across && buttonDownArray[indexOfButton] != "00d"{
            across = false
        } else if indexOfButton == previousButton && !across && buttonAcrossArray[indexOfButton] != "00a"{
            across = true
        }
        
        // Here we determine which buttons should be included in highlighting
        // If our current orientation is across, then only highlight rows
        if across {
            // Used to check if we hit the end or beginning of a row
            var atBeginningOfRow: Bool
            var atEndOfRow: Bool
            
            // Since everything is layed out in an array with 13 squares each,
            // the first square in the row will always equal 0 when modulo'd
            // with 13. This way we can see if we should stop picking squares
            // in the left direction
            if i % 13 == 0 {
                atBeginningOfRow = true
            } else {
                atBeginningOfRow = false
            }
            
            // Likewise, each end of the row + 1 will be 0 when modulo'd with
            // 13. This way we can determine if we should stop picking squares
            // in the right direction
            if (i + 1) % 13 == 0 {
                atEndOfRow = true
            } else {
                atEndOfRow = false
            }
            
            // Start at the selected square and work to the left to find other
            // squares that should be highlighted. Stops when we hit the beginning
            // of the row or a disabled button
            while !atBeginningOfRow && boardSpaces[i].isEnabled {
                selectedBoardSpaces.append(i)
                if i % 13 == 0 {
                    atBeginningOfRow = true
                }
                i -= 1
            }
            
            // Start at the selected square and work to the right to find other
            // squares that should be highlighted. Stops when we hit the end
            // of the row or a disabled button
            i = indexOfButton
            while !atEndOfRow && boardSpaces[i].isEnabled {
                selectedBoardSpaces.append(i)
                if (i + 1) % 13 == 0 {
                    atEndOfRow = true
                }
                i += 1
            }
        } else {
            // Used to check if we hit the top or bottom of a column
            var topOfColumn: Bool
            var bottomOfColumn: Bool
            
            // To determine if we hit the top, decrease our index by 13.
            // If it is negative, then there are no further squares to
            // continue going up.
            if (i - 13) < 0 {
                topOfColumn = true
            } else {
                topOfColumn = false
            }
            
            // To determine if we hit the bottom, increase our index by 13.
            // If it is over 169 (total number of squares), then there are
            // no further squares to continue going down.
            if (i + 13) > 168 {
                bottomOfColumn = true
            } else {
                bottomOfColumn = false
            }
            
            // Start at the selected square and work to the top to find other
            // squares that should be highlighted. Stops when we hit the top
            // of the column or a disabled button
            while !topOfColumn && boardSpaces[i].isEnabled {
                selectedBoardSpaces.append(i)
                i -= 13
                if i < 0 {
                    topOfColumn = true
                }
            }
            
            // Start at the selected square and work to the bottom to find other
            // squares that should be highlighted. Stops when we hit the bottom
            // of the column or a disabled button
            i = indexOfButton
            while !bottomOfColumn && boardSpaces[i].isEnabled {
                selectedBoardSpaces.append(i)
                i += 13
                if i > 168 {
                    bottomOfColumn = true
                }
            }
        }
        
        // Highlight the row or column selected
        if indexOfButton != previousButton {
            self.boardSpaces[previousButton].layer.removeAllAnimations()
        }
        
        // Converts the board spaces to a set to make all entries unique, then back to an array
        selectedBoardSpaces = Array(Set(selectedBoardSpaces))
        
        // Handles highlighting the needed selected squares
        highlight(selectedSpaces: selectedBoardSpaces, atSquare: indexOfButton, prevSquare: previousButton)
    }
    
    func initialHighlight() {
        // Start the user on whatever 1 is available (prefers 1 across)
        for i in 0...168 {
            // If there is no 1 across, start vertical
            if buttonAcrossArray[i] == "01a" || buttonDownArray[i] == "01d" {
                if buttonDownArray[i] == "01d" && buttonAcrossArray[i] != "01a" {
                    across = false
                }
                
                boardSpaces[i].sendActions(for: .touchUpInside)
                break
            }
        }
    }
    
    
     /*****************************************
     *                                        *
     *               PLIST READING            *
     *                                        *
     *****************************************/
    
    func getInfoFromPlist(level: Int) -> (Array<Dictionary<String, String>>) {
        let levelName = "level_\(level)"
        
        // Path to the plist
        let path = Bundle.main.path(forResource: levelName, ofType: "plist")
        
        // Array to store information from plist
        var storedInfoArray: NSArray?
        
        // Set array with information from the plist
        storedInfoArray = NSArray(contentsOfFile: path!)
        
        // Return the array to be filtered
        return (storedInfoArray as? Array<Dictionary<String, String>>)!
    }
    
    func fillAcrossDownArrays() {
        // Grab across and down numbers from the plist and append them to the array
        for i in 1..<getInfoFromPlist(level: userLevel).count {
            let ac = getInfoFromPlist(level: userLevel)[i]["Across"]!
            let down = getInfoFromPlist(level: userLevel)[i]["Down"]!
            if ac != "" {
                acrossNumbers.append(Int(ac)!)
            }
            if down != "" {
                downNumbers.append(Int(down)!)
            }
        }
        
        // Sort the arrays from lowest to highest
        acrossNumbers.sort()
        downNumbers.sort()
    }
    
    // Gets the important information from the level plist. These arrays allow
    // for faster access to the information since we don't need to keep reading
    // from the plist
    func makeClueArrays() {
        for i in 1..<getInfoFromPlist(level: userLevel).count{
            if getInfoFromPlist(level: userLevel)[i]["Across"]! != "" {
                acrossClues.append((getInfoFromPlist(level: userLevel)[i]["Across"]!,
                                getInfoFromPlist(level: userLevel)[i]["Clue"]!,
                                getInfoFromPlist(level: userLevel)[i]["Hint"]!,
                                getInfoFromPlist(level: userLevel)[i]["# of words"]!))
            }
            if getInfoFromPlist(level: userLevel)[i]["Down"]! != "" {
                downClues.append((getInfoFromPlist(level: userLevel)[i]["Down"]!,
                                getInfoFromPlist(level: userLevel)[i]["Clue"]!,
                                getInfoFromPlist(level: userLevel)[i]["Hint"]!,
                                getInfoFromPlist(level: userLevel)[i]["# of words"]!))
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaults.set(1, forKey: "userLevel")

        readFromDefaults()
        
        // This is the board that needs to be set up
        // board[1] contains the letters in their locations
        // board[2] contains numbers superscripts for across/down
        // board[3] contains across/down information for each individual square
        let board = [getInfoFromPlist(level: userLevel)[1]["Board"]!,
                     getInfoFromPlist(level: userLevel)[2]["Board"]!,
                     getInfoFromPlist(level: userLevel)[3]["Board"]!]
        
        
        // Set everything up
        fillAcrossDownArrays()
        makeClueArrays()
        setUpBoard(board: board)
        clueAreaSetup()
        startTimer()
        
        
        // MUSIC
        MusicPlayer.start(musicTitle: "game", ext: "mp3")
        if !Settings.musicEnabled {
            MusicPlayer.musicPlayer.volume = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initialHighlight()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // When the setting button is clicked, give the view information needed
        // to set the switches to their initial positions which can then be modified
        // by the user.

        if segue.identifier == "hintSegue" {
            if let hintVC = segue.destination as? HintViewController {
                hintVC.emoji = getSpotInfo(indexOfButton: indexOfButton, info: "Clue")
                hintVC.wordCount = getSpotInfo(indexOfButton: indexOfButton, info: "WordCt")
                hintVC.hint = getSpotInfo(indexOfButton: indexOfButton, info: "Hint")
                hintVC.clueNumber = directionLabel.text!
                hintVC.screenSize = screenSize
            }
        }
    }
    
    func startTimer() {
        formatter.minimumIntegerDigits = 2
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimerLabel), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimerLabel() {        
        secondsCounter += 1
        if secondsCounter == 60 {
            secondsCounter = 0
            minutesCounter += 1
        }
        
        if minutesCounter == 60 {
            minutesCounter = 0
            hoursCounter += 1
        }
        
        let secs = formatter.string(for: secondsCounter)
        let mins = formatter.string(for: minutesCounter)
        
        secondsLabel.text = ":\(secs!)"
        minutesLabel.text = ":\(mins!)"
        hoursLabel.text = "\(hoursCounter)"
    }
    
    func readFromDefaults() {
        if let savedAnswers = defaults.array(forKey: "buttonTitles") {
            buttonTitleArray = (savedAnswers as? [String])!
            for i in 0...168 {
                if buttonTitleArray[i] != "" {
                    boardSpaces[i].setTitle(buttonTitleArray[i], for: .normal)
                }
            }
        } else {
            buttonTitleArray = Array(repeating: "", count: 169)
        }
        
        userLevel = defaults.integer(forKey: "userLevel")
        if userLevel == 0 {
            userLevel = 1
        }
    }
}
