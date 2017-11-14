//
//  MusicPlayer.swift
//  Crossword
//
//  Created by Tyler Stickler on 11/13/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import AVFoundation

class MusicPlayer: NSObject, AVAudioPlayerDelegate {
    static var musicPlayer = AVAudioPlayer()
    
    private override init() {}
    
    static func start(musicTitle: String, ext: String) {
        // Find our music file
        let path = Bundle.main.path(forResource: musicTitle, ofType: ext)!
        let url = URL(fileURLWithPath: path)
        
        do {
            // Play the music
            MusicPlayer.musicPlayer = try AVAudioPlayer(contentsOf: url)
            MusicPlayer.musicPlayer.numberOfLoops = -1
            MusicPlayer.musicPlayer.volume = 0
            MusicPlayer.musicPlayer.prepareToPlay()
            MusicPlayer.musicPlayer.play()
            MusicPlayer.musicPlayer.setVolume(1, fadeDuration: 2.0)
        } catch {
            print(error)
        }
    }
}
