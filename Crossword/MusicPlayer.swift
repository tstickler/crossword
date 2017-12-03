//
//  MusicPlayer.swift
//  Crossword
//
//  Created by Tyler Stickler on 11/13/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import AVFoundation
import AudioToolbox

class MusicPlayer: NSObject, AVAudioPlayerDelegate {
    // 3 music players allow for better concurrent music/sound effects/fade
    static var homeMusicPlayer = AVAudioPlayer()
    static var gameMusicPlayer = AVAudioPlayer()
    static var endOfGameMusicPlayer = AVAudioPlayer()
    
    private override init() {}
    
    static func start(musicTitle: String, ext: String) {
        // Find our music file
        let path = Bundle.main.path(forResource: musicTitle, ofType: ext)!
        let url = URL(fileURLWithPath: path)
        
        var musicPlayer = AVAudioPlayer()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Play the music
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer.numberOfLoops = -1
            musicPlayer.volume = 0
            musicPlayer.prepareToPlay()
            musicPlayer.play()
            musicPlayer.setVolume(0.25, fadeDuration: 1.0)
            
            // Choose the player to play on based on the song sent
            if musicTitle == "home" {
                homeMusicPlayer = musicPlayer
            } else if musicTitle == "game" {
                gameMusicPlayer = musicPlayer
            } else if musicTitle == "gameOver" || musicTitle == "errors" || musicTitle == "correct" {
                // These sound effects don't repeat
                musicPlayer.numberOfLoops = 0
                musicPlayer.volume = 0.3
                endOfGameMusicPlayer = musicPlayer
            }
        } catch {
            print(error)
        }
    }
    
    static func playSoundEffect(of sound: String, ext: String) {
        if let soundURL = Bundle.main.url(forResource: sound, withExtension: ext) {
            var soundID: SystemSoundID = 0
            
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundID)
            
            AudioServicesPlaySystemSound(soundID)
        }
    }
}
