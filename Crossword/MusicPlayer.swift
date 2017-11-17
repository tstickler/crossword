//
//  MusicPlayer.swift
//  Crossword
//
//  Created by Tyler Stickler on 11/13/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import AVFoundation

class MusicPlayer: NSObject, AVAudioPlayerDelegate {
    // 3 music players allow for better concurrent music/sound effects/fade
    static var homeMusicPlayer = AVAudioPlayer()
    static var gameMusicPlayer = AVAudioPlayer()
    static var soundEffectPlayer = AVAudioPlayer()
    
    private override init() {}
    
    static func start(musicTitle: String, ext: String) {
        // Find our music file
        let path = Bundle.main.path(forResource: musicTitle, ofType: ext)!
        let url = URL(fileURLWithPath: path)
        var musicPlayer = AVAudioPlayer()
        
        do {
            // Play the music
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer.numberOfLoops = -1
            musicPlayer.volume = 0
            musicPlayer.prepareToPlay()
            musicPlayer.play()
            musicPlayer.setVolume(1, fadeDuration: 1.0)
            
            // Choose the player to play on based on the song sent
            if musicTitle == "home" {
                homeMusicPlayer = musicPlayer
            } else if musicTitle == "game" {
                gameMusicPlayer = musicPlayer
            }
        } catch {
            print(error)
        }
    }
}
