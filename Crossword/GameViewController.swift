//
//  GameViewController.swift
//  Crossword
//
//  Created by Tyler Stickler on 10/20/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    // Used to determine which phone the user has
    let screenSize = UIScreen.main.bounds
        
    var selectedBoardSpaces = [Int]()
    var across = true
    var userLevel = 1
    var indexOfButton: Int!
    var acrossNumbers = [Int]()
    var downNumbers = [Int]()
    
    // Settings that can be modified by the user
    var musicEnabled = true
    var soundEffectsEnabled = true
    var timerEnabled = true
    var skipFilledSquares = true
    var lockCorrectAnswers = true
    var correctAnimationEnabled = true
    
    // UI colors
    let blueColor = UIColor.init(red: 96/255, green: 199/255, blue: 255/255, alpha: 1)
    let blueColorCG = UIColor.init(red: 96/255, green: 199/255, blue: 255/255, alpha: 1).cgColor

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
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var directionLabel: UILabel!
    @IBOutlet var backPhraseButton: UIButton!
    @IBOutlet var nextPhraseButton: UIButton!
    
    @IBOutlet var clueHeightConstraint: NSLayoutConstraint!
    
    // To know where the user last was
    var previousButton = 0
    var previousSpaces = [Int]()
    
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
            
            keyboardBackHeight.constant = 210
        // Sets constraints for iPhone Plus
        case 736:
            topKeysHeight.constant = iphonePlusKeysHeight
            middleKeysHeight.constant = iphonePlusKeysHeight
            bottomKeysHeight.constant = iphonePlusKeysHeight
            
            bottomRowLeading.constant = 55
            bottomRowTrailing.constant = 55
            
            keyboardBackHeight.constant = 220
            clueHeightConstraint.constant = 55
            clueLabel.font = clueLabel.font.withSize(40)
        // Sets constraints for iPhone X
        case 812:
            topKeysHeight.constant = 57
            middleKeysHeight.constant = 57
            bottomKeysHeight.constant = 57
            
            bottomRowLeading.constant = 52.5
            bottomRowTrailing.constant = 52.5
            
            keyboardBackHeight.constant = 250
            
            clueHeightConstraint.constant = 70
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
                button.titleLabel?.font = button.titleLabel?.font.withSize(10.0)
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
        // Set border width, shape, and color for the clue label and advancement buttons
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
    }
    
    func giveBoardSpacesProperties(board: [String]) {
        // Board[0] contains the letter of each square. If square should be blank, letter is "-"
        let gameBoardLetters = board[0]
        
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
        for button in boardSpaces {
            
            // Grabs the letter in the string
            letter = gameBoardLetters[gameBoardLetters.index(gameBoardLetters.startIndex, offsetBy: letterIterator)]
            
            // If the letter is a "-", square should be disables and turned black
            // Otherwise, assign the letter to the square
            if letter == "-" {
                button.isEnabled = false
                button.letter = "-"
                button.backgroundColor = .black
            } else {
                button.letter = letter
            }
            
            // Grab the number in the string
            number = gameBoardNums[gameBoardNums.index(gameBoardNums.startIndex, offsetBy: numbersIterator)]
            
            // If the number is a "-" then there should be no number in the top corner so set the label to an empty string
            // Otherwise, set the label on the square to the corresponing number grabbed
            if number == "-" {
                button.superscriptLabel.text?.append("")
            } else {
                button.setSuperScriptLabel(number: String(number))
                
                // If the next character is a number as well, append it to the space label (so we can represent 2 digit numbers)
                if gameBoardNums[gameBoardNums.index(gameBoardNums.startIndex, offsetBy: numbersIterator + 1)] != "-" {
                    button.superscriptLabel.text?.append(gameBoardNums[gameBoardNums.index(gameBoardNums.startIndex, offsetBy: numbersIterator + 1)])
                    
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
            button.across = String(daString[..<midIndex])
            button.down = String(daString[midIndex..<daString.endIndex])
            
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
        clueLabel.text = getClue(indexOfButton: indexOfButton)
        
        // Set the label for the direction
        determineDirectionText(indexOfButton: indexOfButton)
        
        // Allows us to look back one to see what the last press was
        previousButton = indexOfButton
    }

    @IBAction func eraseButtonTapped(_ sender: Any) {
        // Get current square
        let currentSquareTitle = boardSpaces[indexOfButton].title(for: .normal)
        
        // If the square has text, erase it and stay there
        if currentSquareTitle != nil && (boardSpaces[indexOfButton].lockedForCorrectAnswer == false || !lockCorrectAnswers) {
            boardSpaces[indexOfButton].setTitle(nil, for: .normal)
            
            // Erasing a correct answer should make it uncorrect again
            if boardSpaces[indexOfButton].lockedForCorrectAnswer {
                boardSpaces[indexOfButton].lockedForCorrectAnswer = false
            }
        } else {
            // Otherwise, if the square is empty see if we're at the beginning of
            // the selected phrase
            if indexOfButton == selectedBoardSpaces.min() {
                // If we're at the beginning, we are going to go back a phrase
                // when the erase button is pressed
                backPhraseButton.sendActions(for: .touchUpInside)
                
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
            if boardSpaces[indexOfButton].lockedForCorrectAnswer == false {
                boardSpaces[indexOfButton].setTitle(nil, for: .normal)
            }
        }
        
        
    }
    
    @IBAction func nextPhraseButtonTapped(_ sender: Any) {
        // Get the current space
        let currentSquare = boardSpaces[indexOfButton]
        
        // Orientation determines how we will move
        if across {
            // Gets the number associated with the square
            let acrossString = currentSquare.across
            let acrossStart = acrossString!.startIndex
            let num = Int(acrossString![acrossStart...acrossString!.index(after: acrossStart)])!
            
            // Used to tell which button to tap next
            var nextAcross = ""
            
            // Go through the across array until we find a number larger than the current square.
            // Since the array is sorted, we know that this is next largest number. Break if we've
            // found it.
            for x in acrossNumbers {
                if x > num {
                    // Depending on the string, we may need to add a 0 at the beginning
                    if x < 10 {
                        nextAcross = "0\(x)a"
                    } else {
                        nextAcross = "\(x)a"
                    }
                    break
                } else if x == acrossNumbers.max()! {
                    // If we made it all the way though without finding a larger value, we don't have
                    // anymore across values. Therefore, switch orientation and simulate a tap to go
                    // to the first down.

                    across = false
                    indexOfButton = 0
                    nextPhraseButton.sendActions(for: .touchUpInside)
                }
            }
            
            // Go through the board spaces until the desired across location is found.
            // Simulate a tap there.
            for button in boardSpaces {
                if button.across == nextAcross {
                    button.sendActions(for: .touchUpInside)
                    break
                }
            }
        } else {
            // Gets the number associated with the square
            let downString = currentSquare.down
            let downStart = downString!.startIndex
            let num = Int(downString![downStart...downString!.index(after: downStart)])!
            
            // Used to tell which button to tap next
            var nextDown = ""
            
            // Go through the down array until we find a number larger than the current square.
            // Since the array is sorted, we know that this is next largest number. Break if we've
            // found it.
            for x in downNumbers {
                if x > num {
                    // Depending on the string, we may need to add a 0 at the beginning
                    if x < 10 {
                        nextDown = "0\(x)d"
                    } else {
                        nextDown = "\(x)d"
                    }
                    break
                }
                // If we made it all the way though without finding a larger value, we don't have
                // anymore down values. Therefore, switch orientation and simulate a tap to go
                // to the first across.
                else if x == downNumbers.max()! {
                    across = true
                    indexOfButton = 0
                    nextPhraseButton.sendActions(for: .touchUpInside)
                }
            }
            
            // Go through the board spaces until the desired across location is found.
            // Simulate a tap there.
            for button in boardSpaces {
                if button.down == nextDown {
                    button.sendActions(for: .touchUpInside)
                    break
                }
            }
        }
        
        // Skip filled squares
        if boardSpaces[indexOfButton].currentTitle != nil && skipFilledSquares {
            if across {
                moveToNextAcross()
            } else {
                moveToNextDown()
            }
        }
    }
    
    // Needed to communicate between the if/else
    var jumpDown = ""
    var jumpAcross = ""
    
    @IBAction func backPhraseButtonTapped(_ sender: Any) {
        // Get the current space
        let currentSquare = boardSpaces[indexOfButton]
        
        if across {
            // Gets the number associated with the square
            let acrossString = currentSquare.across
            let acrossStart = acrossString!.startIndex
            let num = Int(acrossString![acrossStart...acrossString!.index(after: acrossStart)])!
            
            // The next number we should go to
            var nextAcross = ""
            
            // Initialize this as the max in the across array. Prevents an error in finding the lowest
            // value from the array
            var nextLowest = acrossNumbers.max()!
            
            // If request came from down square, use jump across to determine our landing spot
            if jumpAcross != "" {
                nextAcross = jumpAcross
                jumpAcross = ""
            } else {
                // If request came from across square, figure out where to go next
                // Go through the across array until we find a square who is equal to current square.
                for x in acrossNumbers {
                    // If at 1 (lowest number possible in the game) we already know to jump to down.
                    if num == 1 {
                        across = false
                        
                        // Since we're going to down, find the highest down number and set our jump to
                        // that square. Then execute the tap.
                        if downNumbers.max()! > 10 {
                            jumpDown = "\(downNumbers.max()!)d"
                        } else {
                            jumpDown = "0\(downNumbers.max()!)d"
                        }
                        backPhraseButton.sendActions(for: .touchUpInside)
                    } else if x == num {
                        // The request is to go to the next lowest across. Since we've been keeping
                        // track of the number that is one lower than x, we can set that
                        // as our next square to go to.

                        if nextLowest < 10 {
                            nextAcross = "0\(nextLowest)a"
                        } else {
                            nextAcross = "\(nextLowest)a"
                        }
                        break
                    }
                    
                    // Holds our number lower than x
                    nextLowest = x
                }
            }
            
            // Go through the board spaces until the desired across location is found.
            // Simulate a tap there.
            for button in boardSpaces {
                if button.across == nextAcross {
                    button.sendActions(for: .touchUpInside)
                    break
                }
            }
        } else {
            // Gets the number associated with the square
            let downString = currentSquare.down
            let downStart = downString!.startIndex
            let num = Int(downString![downStart...downString!.index(after: downStart)])!

            // The next number we should go to
            var nextDown = ""
            
            // Initialize this as the max in the down array. Prevents an error in finding the lowest
            // value from the array
            var nextLowest = downNumbers.max()!

            // If request came from across square, use jump down to determine our landing spot
            if jumpDown != "" {
                nextDown = jumpDown
                jumpDown = ""
            } else {
                //If request came from across square, figure out where to go next
                // Go through the down array until we find a square who is equal to current square.
                for x in downNumbers {
                    // If at 1 (lowest number possible in the game) we already know to jump to across.
                    if num == 1 {
                        across = true
                        
                        // Since we're going to across, find the highest across number and set our jump to
                        // that square. Then execute the tap.
                        if acrossNumbers.max()! > 10 {
                            jumpAcross = "\(acrossNumbers.max()!)a"
                        } else {
                            jumpAcross = "0\(acrossNumbers.max()!)a"
                        }
                        backPhraseButton.sendActions(for: .touchUpInside)
                    } else if x == num {
                        // The request is to go to the next lowest down. Since we've been keeping
                        // track of the number that is one lower than x, we can set that
                        // as our next square to go to.

                        if x < 10 {
                            nextDown = "0\(nextLowest)d"
                        } else {
                            nextDown = "\(nextLowest)d"
                        }
                        break
                    }
                    
                    // Holds our number lower than x
                    nextLowest = x
                }
            }
            
            // Go through the board spaces until the desired across location is found.
            // Simulate a tap there.
            for button in boardSpaces {
                if button.down == nextDown {
                    button.sendActions(for: .touchUpInside)
                    break
                }
            }
        }
        
        // Skip filled squares
        if boardSpaces[indexOfButton].currentTitle != nil && skipFilledSquares {
            if across {
                moveToNextAcross()
            } else {
                moveToNextDown()
            }
        }
    }
    
    
    var letter: Character!
    @IBAction func keyboardButtonPressed(_ sender: UIButton) {
        // Each key of the keyboard has a tag from 1-26. The tag tells which key was pressed.
        // Keyboard is standard qwerty and tags start at Q(1) and end at M(26)
        
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
        if !boardSpaces[indexOfButton].lockedForCorrectAnswer || !lockCorrectAnswers {
            // If the space was a correct answer but was changed, indicate that square is wrong
            if boardSpaces[indexOfButton].lockedForCorrectAnswer &&
                letter != boardSpaces[indexOfButton].letter {
                boardSpaces[indexOfButton].lockedForCorrectAnswer = false
            }
            boardSpaces[indexOfButton].setTitle(String(letter).uppercased(), for: .normal)
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
            if correctAnimationEnabled {
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
            
            if gameOver() {
                clueLabel.textColor = .white
                clueLabel.text = "Game Over"
                return
            } else {
                nextPhraseButton.sendActions(for: .touchUpInside)
            }
            // Return so we go to the first spot in the next phrase and not the second
            return
        }
        
        // If there was no correct answer, then move to the next spot in current orientation
        if across {
            moveToNextAcross()
        } else {
            moveToNextDown()
        }
    }
    
    func gameOver() -> Bool {
        
        for space in boardSpaces {
            // Each inactive space is assigned a "-" as their letter.
            // Check if all the buttons that can be tapped have non-nil values.
            // If there is still a nil value, there is an open board space, which
            // means the game is not over.
            if space.title(for: .normal) == nil && space.letter! != "-" {
                return false
            } else {
                if var spaceTitle = space.title(for: .normal) {
                    // Letters are stored lowercase while titles are displayed as uppercase.
                    // Lowercase the title so we can compare it with the stored letter.
                    spaceTitle = spaceTitle.lowercased()
                    
                    // Nothing needs to happen if the letters match or we're at a inactive square.
                    // Just continue the loop
                    if Character(spaceTitle) == space.letter! || space.letter! == "-" {
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
                if entryToChar == boardSpaces[space].letter {
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
            boardSpaces[space].lockedForCorrectAnswer = true
        }
        return true
    }
    
    func moveToNextAcross() {
        // Checks bounds before movement
        if indexOfButton < 168 {
            boardSpaces[indexOfButton + 1].sendActions(for: .touchUpInside)
        }
        
        // If we hit a disabled square or a square not part of an across go to next across phrase
        if !boardSpaces[indexOfButton].isEnabled || boardSpaces[indexOfButton].across == "00a" {
            // Gets previous location so we know where to go
            let acrossString = boardSpaces[indexOfButton - 1].across!
            let index = acrossString.index(acrossString.startIndex, offsetBy: 2)
            let i = Int(acrossString[acrossString.startIndex..<index])!
            
            // Loop through our array containing all across number. Since the array is sorted,
            // once we hit a number greater than the current one that's where we'll jump.
            // If we ever hit a spot where we loop through the whole across array, we're going
            // to flip the orientation to down and go to the first down.
            var nextAcross = ""
            for x in acrossNumbers {
                if x > i {
                    if x < 10 {
                        nextAcross = "0\(x)a"
                    } else {
                        nextAcross = "\(x)a"
                    }
                    break
                } else if x == acrossNumbers.max()! {
                    let shouldGoDown = "0\(downNumbers.min()!)d"
                    across = false
                    for button in boardSpaces {
                        if button.down == shouldGoDown {
                            button.sendActions(for: .touchUpInside)
                            break
                        }
                    }
                }
            }
            
            // Go through the board spaces until the desired across location is found.
            // Simulate a tap there.
            for button in boardSpaces {
                if button.across == nextAcross {
                    button.sendActions(for: .touchUpInside)
                    break
                }
            }
        }
        
        // Skip filled squares
        if boardSpaces[indexOfButton].currentTitle != nil && skipFilledSquares {
            moveToNextAcross()
        }
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
        if outOfBounds || !boardSpaces[indexOfButton].isEnabled || boardSpaces[indexOfButton].down == "00d" {
            let downString = boardSpaces[indexOfButton - 13].down!
            let index = downString.index(downString.startIndex, offsetBy: 2)
            let i = Int(downString[downString.startIndex..<index])!
            
            var nextDown = ""
            for x in downNumbers {
                if x > i {
                    if x < 10 {
                        nextDown = "0\(x)d"
                    } else {
                        nextDown = "\(x)d"
                    }
                    break
                } else if x == downNumbers.max()! {
                    let shouldGoAcross = "0\(acrossNumbers.min()!)d"
                    across = true
                    for button in boardSpaces {
                        if button.down == shouldGoAcross {
                            button.sendActions(for: .touchUpInside)
                            break
                        }
                    }
                }
            }
            
            // Go through the board spaces until the desired across location is found.
            // Simulate a tap there.
            for button in boardSpaces {
                if button.down == nextDown {
                    button.sendActions(for: .touchUpInside)
                    break
                }
            }
        }
        
        // Skip filled squares
        if boardSpaces[indexOfButton].currentTitle != nil && skipFilledSquares {
            moveToNextDown()
        }
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
                border.frame = CGRect(x: 0, y: 0, width: 25, height: 28)
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
            let acrossString = boardSpaces[indexOfButton].across
            let acrossStringStart = acrossString?.startIndex
            let acrossStringEnd = acrossString?.endIndex
            
            number = Int(acrossString![acrossStringStart!...acrossString!.index(after: acrossStringStart!)])!
            direction = acrossString![(acrossString?.index(before: acrossStringEnd!))!]
        } else {
            let downString = boardSpaces[indexOfButton].down
            let downStart = downString?.startIndex
            let downEnd = downString?.endIndex
            
            number = Int(downString![downStart!...downString!.index(after: downStart!)])!
            direction = downString![(downString?.index(before: downEnd!))!]
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
        if boardSpaces[indexOfButton].down == "00d" {
            across = true
        } else if boardSpaces[indexOfButton].across == "00a" {
            across = false
        }
        
        // Double tapping on a button results in flipping its orietation as long as
        // the flip is valid and the button is part of both across and down
        if indexOfButton == previousButton && across && boardSpaces[indexOfButton].down != "00d"{
            across = false
        } else if indexOfButton == previousButton && !across && boardSpaces[indexOfButton].across != "00a"{
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
        
        // Holds previous spaces to manage highlighting when user taps the same button
        previousSpaces = selectedBoardSpaces
    }
    
    func initialHighlight() {
        // Start the user on whatever 1 is available (prefers 1 across)
        for button in boardSpaces {
            // If there is no 1 across, start vertical
            if button.across == "01a" || button.down == "01d" {
                if button.down == "01d" && button.across != "01a" {
                    across = false
                }
                
                button.sendActions(for: .touchUpInside)
                break
            }
        }
    }
    
    
     /*****************************************
     *                                        *
     *               PLIST READING            *
     *                                        *
     *****************************************/
    
    // Read from plist containing clues/phrases/hints
    func getArrayFromPlist(name: String) -> (Array<Dictionary<String, String>>) {
        // Path to the plist
        let path = Bundle.main.path(forResource: name, ofType: "plist")
        
        // Array to store information from plist
        var arr: NSArray?
        
        // Set array with information from the plist
        arr = NSArray(contentsOfFile: path!)
        
        // Return the array to be filtered
        return (arr as? Array<Dictionary<String, String>>)!
    }
    
    // Gets information for the given phrase (clue, hint, # of words)
    // Returns them as an array of dictionaries
    func getClueForPhrase(phrase: String) -> (Array<[String:String]>) {
        // Gets information from the plist
        let array = getArrayFromPlist(name: "emojis")
        
        // This is the phrase we want to find
        let phrasePredicate = NSPredicate(format: "Phrase = %@", phrase)
        
        // Filter and return all info related to phrase
        return [array.filter {phrasePredicate.evaluate(with: $0)}[0]]
    }
    
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
    
    func getClue(indexOfButton: Int) -> String {
        var i = 1
        // Grabs the clue related to the selected square
        // If we are currently looking for across, get the across clue associated with the square
        if across {
            // Grab across variable to determine where in the plist we should look
            // Remember, the across string is in the form 00a, with the numbers being
            // the related across
            let across = boardSpaces[indexOfButton].across
            
            // Toss out the a, and a leading 0 if it is there
            // The plist has the number with no leading 0
            var numAcross = String(across![across!.startIndex..<across!.index((across?.startIndex)!, offsetBy: 2)])
            if numAcross[numAcross.startIndex] == "0" {
                numAcross = String(numAcross[numAcross.index(numAcross.startIndex, offsetBy: 1)])
            }
            
            // Go through the plist until we find the matching across
            while i < 17 {
                // If we find the across, set the clue label to the matching clue.
                // Since our plist is set up with Phrase/Clue/Hint/Across/Down all in the
                // same index, we can use the index where we found our across number to get
                // the corresponding clue
                if getInfoFromPlist(level: userLevel)[i]["Across"] == numAcross {
                    return getInfoFromPlist(level: userLevel)[i]["Clue"]!
                }
                i += 1
            }
        } else {
            // If we are currently looking for down, get the down clue associated with the square

            // Grab down variable to determine where in the plist we should look
            // Remember, the down string is in the form 00d, with the numbers being
            // the related down
            let down = boardSpaces[indexOfButton].down
            
            // Toss out the d, and a leading 0 if it is there
            // The plist has the number with no leading 0
            var numDown = String(down![down!.startIndex..<down!.index((down?.startIndex)!, offsetBy: 2)])
            if numDown[numDown.startIndex] == "0" {
                numDown = String(numDown[numDown.index(numDown.startIndex, offsetBy: 1)])
            }
            
            // If we find the down, set the clue label to the matching clue.
            // Since our plist is set up with Phrase/Clue/Hint/Across/Down all in the
            // same index, we can use the index where we found our down number to get
            // the corresponding clue
            while i < 17 {
                if getInfoFromPlist(level: userLevel)[i]["Down"] == numDown {
                    return getInfoFromPlist(level: userLevel)[i]["Clue"]!
                }
                i += 1
            }
        }
        
        // Nothing found (shouldn't ever happen)
        return ""
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This is the board that needs to be set up
        // board[1] contains the letters in their locations
        // board[2] contains numbers superscripts for across/down
        // board[3] contains across/down information for each individual square
        let board = [getInfoFromPlist(level: userLevel)[1]["Board"]!,
                     getInfoFromPlist(level: userLevel)[2]["Board"]!,
                     getInfoFromPlist(level: userLevel)[3]["Board"]!]
        
        // Set everything up
        fillAcrossDownArrays()
        clueAreaSetup()
        setUpBoard(board: board)
        initialHighlight()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // When the setting button is clicked, give the view information needed
        // to set the switches to their initial positions which can then be modified
        // by the user.
        if segue.identifier == "settingSegue" {
            if let menuVC = segue.destination as? MenuViewController {
                menuVC.musicEnabled = musicEnabled
                menuVC.soundEffectsEnabled = soundEffectsEnabled
                menuVC.timerEnabled = timerEnabled
                menuVC.skipFilledEnabled = skipFilledSquares
                menuVC.lockCorrectEnabled = lockCorrectAnswers
                menuVC.correctAnimationEnabled = correctAnimationEnabled
            }
        }
    }
}
