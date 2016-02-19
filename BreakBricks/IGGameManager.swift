//
//  IGGameManager.swift
//  BreakBricks
//
//  Created by Joanna Rosiak on 2/13/16.
//  Copyright © 2016 Rich Rosiak. All rights reserved.
//

import Foundation
import AVFoundation

/*
This is a singleton class
*/
@objc class IGGameManager2 : NSObject {
    
    var sceneSetup2 : IGSceneSetup!
    
    //Singleton
    static let sharedInstance = IGGameManager2() //in Swift this guarantees thread safety
    private override init() {} //prevents other classes from using the default init() to avoid using singleton
    
    func createAudioPlayerForData(audioData : NSData) -> AVAudioPlayer? {
        
        var audioPlayer : AVAudioPlayer?
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        catch let error as NSError {
            print("Error setting av session category: ", error.description)
            return nil
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch let error as NSError {
            print("Error setting av session to active: ", error.description)
            return nil
        }
        
        do {
            try audioPlayer = AVAudioPlayer(data: audioData)
        }
        catch let error as NSError {
            print("Error initing av audio player: ", error.description)
            return nil
        }
        
        return audioPlayer!
    }
    
    func retrieveDataForAudioFileName(audioFile : String) -> NSData? {
        
        var soundData : NSData?
        
        let soundFile: String? = NSBundle.mainBundle().pathForResource(audioFile, ofType: nil)!
        print("windSoundFile full path is ", soundFile)
        assert((soundFile != nil), "No such file in mainBundle")
        
        if soundFile == nil {
            return soundData
        }
        
        soundData = NSData(contentsOfFile: soundFile!)
        
        return soundData
    }
    
    func setupSceneForFrameHeight(frameHeight : NSInteger) {
        
        print("The frame heght is ", frameHeight)
        
        switch frameHeight {
            
        case 480: //iPhone 4 or less
            self.sceneSetup2.cloudScalingFactor = 0.4
            self.sceneSetup2.firstSceneBackgroundScalingFactor = 0.6
            self.sceneSetup2.cloudyBackgroundScalingFactor = 0.6
            self.sceneSetup2.brickImageName = "art.scnassets/redBrick"
            self.sceneSetup2.ballSpeedScalingFactor = 0.7
            self.sceneSetup2.tankBackScalingFactor = 0.4
            break;
        case 568: //iPhone 5
            self.sceneSetup2.cloudScalingFactor = 0.5
            self.sceneSetup2.firstSceneBackgroundScalingFactor = 0.7
            self.sceneSetup2.cloudyBackgroundScalingFactor = 0.7
            self.sceneSetup2.brickImageName = "art.scnassets/redBrick"
            self.sceneSetup2.ballSpeedScalingFactor = 1.0
            self.sceneSetup2.tankBackScalingFactor = 0.5
            break;
        case 667: //iPhone 6
            self.sceneSetup2.cloudScalingFactor = 0.7
            self.sceneSetup2.firstSceneBackgroundScalingFactor = 0.8
            self.sceneSetup2.cloudyBackgroundScalingFactor = 0.9
            self.sceneSetup2.brickImageName = "art.scnassets/redBrick"
            self.sceneSetup2.ballSpeedScalingFactor = 1.3
            self.sceneSetup2.tankBackScalingFactor = 0.5
            break;
        case 763: //iPhone 6 Plus
            self.sceneSetup2.cloudScalingFactor = 0.8
            self.sceneSetup2.firstSceneBackgroundScalingFactor = 0.9
            self.sceneSetup2.cloudyBackgroundScalingFactor = 1.1
            self.sceneSetup2.brickImageName = "art.scnassets/redBrick"
            self.sceneSetup2.ballSpeedScalingFactor = 1.5
            self.sceneSetup2.tankBackScalingFactor = 0.6
            break;
        case 1024: //iPad
            self.sceneSetup2.cloudScalingFactor = 1.0
            self.sceneSetup2.firstSceneBackgroundScalingFactor = 1.3
            self.sceneSetup2.cloudyBackgroundScalingFactor = 1.6
            self.sceneSetup2.brickImageName = "art.scnassets/redBrick_iPad"
            self.sceneSetup2.ballScalingFactor = 2.0
            self.sceneSetup2.paddleScalingFactor = 2.0
            self.sceneSetup2.ballSpeedScalingFactor = 2.0
            self.sceneSetup2.tankBackgroundImageName = "art.scnassets/tanks_back_iPad.jpg"
            self.sceneSetup2.tankBackScalingFactor = 0.6
            break;
        default:
            self.sceneSetup2.cloudScalingFactor = 1.0
            self.sceneSetup2.firstSceneBackgroundScalingFactor = 1.3
            self.sceneSetup2.cloudyBackgroundScalingFactor = 1.6
            self.sceneSetup2.brickImageName = "art.scnassets/redBrick_iPad"
            self.sceneSetup2.ballScalingFactor = 2.0
            self.sceneSetup2.paddleScalingFactor = 2.0
            self.sceneSetup2.ballSpeedScalingFactor = 2.0
            self.sceneSetup2.tankBackgroundImageName = "art.scnassets/tanks_back_iPad.jpg"
            self.sceneSetup2.tankBackScalingFactor = 0.7
            break;
        }
    }
}
