//
//  ViewController.swift
//  Crossword
//
//  Created by Tyler Stickler on 10/20/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    var selectedBoardSpaces = [Int]()
    var across = true
    var userLevel = 1


    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet var keys: [UIButton]!
    @IBOutlet var boardSpaces: [BoardButton]!
    
    @IBOutlet var topKeysHeight: NSLayoutConstraint!
    @IBOutlet var middleKeysHeight: NSLayoutConstraint!
    @IBOutlet var bottomKeysHeight: NSLayoutConstraint!
    @IBOutlet var keyboardBackHeight: NSLayoutConstraint!
    @IBOutlet var bottomRowLeading: NSLayoutConstraint!
    @IBOutlet var bottomRowTrailing: NSLayoutConstraint!
    
    @IBOutlet var clueLabel: UILabel!
    
    var previousButton = 0
    var previousSpaces = [Int]()
    
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
        let indexOfButton = ((row - 1) * 13) + col - 1
        
        print("ROW: \(row) // COL: \(col) // INDEX: \(indexOfButton) // LETTER: \(sender.letter!)")
        
        //
        rowAndColumnDetermination(indexOfButton: indexOfButton)
        
        // Allows us to look back one to see what the last press was
        previousButton = indexOfButton
    }
    
    /* UI SETUP */
    let screenSize = UIScreen.main.bounds
    let iphoneSEkeysHeight: CGFloat = 45
    let iphoneKeysHeight: CGFloat = 52.5
    let iphonePlusKeysHeight: CGFloat = 58.5
    
    func setUpBoard(board: [String]) {
        switch screenSize.width {
        // Sets constraints for iPhone SE
        case 320:
            topKeysHeight.constant = iphoneSEkeysHeight
            middleKeysHeight.constant = iphoneSEkeysHeight
            bottomKeysHeight.constant = iphoneSEkeysHeight
            
            bottomRowLeading.constant = iphoneSEkeysHeight
            bottomRowTrailing.constant = iphoneSEkeysHeight
        // Sets constraints for iPhone
        case 375:
            topKeysHeight.constant = iphoneKeysHeight
            middleKeysHeight.constant = iphoneKeysHeight
            bottomKeysHeight.constant = iphoneKeysHeight
            
            keyboardBackHeight.constant = 210
        // Sets constraints for iPhone Plus
        case 414:
            topKeysHeight.constant = iphonePlusKeysHeight
            middleKeysHeight.constant = iphonePlusKeysHeight
            bottomKeysHeight.constant = iphonePlusKeysHeight
            
            keyboardBackHeight.constant = 240
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
            button.layer.cornerRadius = 4
        }
        
        giveBoardSpacesProperties(board: board)
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
            // 01a003d
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
        }
        
        else {
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
        
        // Set the label of the
        clueLabel.text = getClue(indexOfButton: indexOfButton)
        
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
                if getLevelFromPlist(level: userLevel)[i]["Across"] == numAcross {
                    return getLevelFromPlist(level: userLevel)[i]["Clue"]!
                }
                i += 1
            }
        }
            // If we are currently looking for down, get the down clue associated with the square
        else {
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
                if getLevelFromPlist(level: userLevel)[i]["Down"] == numDown {
                    return getLevelFromPlist(level: userLevel)[i]["Clue"]!
                }
                i += 1
            }
        }
        
        // Nothing found (shouldn't ever happen)
        return ""
    }
    
    
    /* HIGHLIGHTING SELECTION */
    func highlight(selectedSpaces: [Int], atSquare: Int, prevSquare: Int) {
        
        // Sets the border for the spaces
        for i in selectedSpaces {
            // CAShapeLayer allows us to put the border outside of the button, giving the button more space
            let border = CAShapeLayer()
            
            // Give the layer a name so we can remove it when it shouldn't be highlighted
            border.name = "BORDER"
            
            // Sets the properties of the border
            border.frame = boardSpaces[i].bounds
            border.lineWidth = 2.5
            border.path = UIBezierPath(roundedRect: border.bounds, cornerRadius:3).cgPath
            border.fillColor = UIColor.clear.cgColor
            border.strokeColor = UIColor.init(red: 96/255, green: 199/255, blue: 255/255, alpha: 1).cgColor            
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
            boardSpaces[atSquare].layer.zPosition = 1
        }
    }
    
    
    /* PLIST READING */
    
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
    
    func getLevelFromPlist(level: Int) -> (Array<Dictionary<String, String>>) {
        let name = "level_\(level)"
        
        // Path to the plist
        let path = Bundle.main.path(forResource: name, ofType: "plist")
        
        // Array to store information from plist
        var arr: NSArray?
        
        // Set array with information from the plist
        arr = NSArray(contentsOfFile: path!)
        
        // Return the array to be filtered
        return (arr as? Array<Dictionary<String, String>>)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This is the board that needs to be set up
        let board = [getLevelFromPlist(level: userLevel)[1]["Board"]!,
                     getLevelFromPlist(level: userLevel)[2]["Board"]!,
                     getLevelFromPlist(level: userLevel)[3]["Board"]!]
        
        setUpBoard(board: board)
    }
}
