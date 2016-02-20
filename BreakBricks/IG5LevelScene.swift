//
//  IG5LevelScene.swift
//  BreakBricks
//
//  Created by Rich Rosiak on 2/19/16.
//  Copyright © 2016 Rich Rosiak. All rights reserved.
//

import Foundation
import AVFoundation

let RAIN_CLOUD : UInt32 = 64; //00000000000000000000000001000000

let WIND_SOUND_FILE_NAME : String = "art.scnassets/windBlowing.wav"

@objc class IG5LevelScene : IGStartBrickScene {
    
    var clouds : NSMutableArray?
    
    var wasFirstCloudReleased : Bool = false
    var playWindBlowingSound : SKAction?
    
    var windAudioPlayer : AVAudioPlayer?
    var windSoundData : NSData?
    
    var sceneSetup : IGSceneSetup?
    
    override init(size: CGSize) {
        
        super.init(size: size)
        print("Init 5th scene...")
        
        self.clouds = NSMutableArray()
        
        self.sceneSetup = IGGameManager2.sharedInstance.sceneSetup2
        
        self.windSoundData = IGGameManager2.sharedInstance.retrieveDataForAudioFileName(WIND_SOUND_FILE_NAME) //audio is 3 sec long, so we'd better use audio player
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gamePaused5:", name: GAME_PAUSED_NOTIFICATION, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gameResumed5:", name: GAME_RESUMED_NOTIFICATION, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gamePausedComingToForeground5:", name: GAME_PAUSED_NO_ALERT_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "levelEnded5:", name: LEVEL_ENDED_NOTIFICATION, object: nil)
        
        self.addBackgroundClouds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addBackgroundClouds() {
    
        let cloudyBackground : SKSpriteNode = SKSpriteNode(imageNamed: "art.scnassets/cloudySkies")
        cloudyBackground.position = CGPointMake(self.size.width / 2, self.size.height / 2)
        cloudyBackground.zPosition = -1
        cloudyBackground.setScale(self.sceneSetup!.cloudyBackgroundScalingFactor)
        
        self.addChild(cloudyBackground)
    }
    
    override func didBeginContact(contact : SKPhysicsContact) {
        
        super.didBeginContact(contact)
        
        if self.clouds!.count > 0 {
    
            let firstCloud : SKSpriteNode = self.clouds!.objectAtIndex(0) as! SKSpriteNode
            
            if firstCloud.position.x > self.frame.size.width + firstCloud.frame.size.width / 2 { //cloud moved past the screen
                
                print("Removing cloud from array...")
                self.clouds!.removeObject(firstCloud)
            }
        }
        
        if self.numberOfVisibleBricks <= 11 {  //&& self.notTheBall.physicsBody.categoryBitMask == BRICK_CATEGORY) {
            //print("Blow clouds!")
            
            if (!self.wasFirstCloudReleased) {
                
                self.wasFirstCloudReleased = true
                self.blowCloudIntoScene()
            }
            else if self.clouds!.count > 0 {
                
                let topCloud : SKSpriteNode = self.clouds!.objectAtIndex(0) as! SKSpriteNode
                print("Cloud position is x: ", topCloud.position.x, " and y: ", topCloud.position.y)
                
                if topCloud.position.x >= self.frame.size.width / 2 && self.clouds!.count <= 1 { //top cloud reached half way through screen
                    self.blowCloudIntoScene()
                }
            }
        }
    }
    
    func blowCloudIntoScene() {
        
        print("Blowing...")
        self.runAction(SKAction.performSelector("addCloudToScene", onTarget: self))
    
        self.playWindAudioForData(self.windSoundData!)
    }
    
    func addCloudToScene() {
        
        print("Adding cloud to scene...")
        let rainCloud : SKSpriteNode = SKSpriteNode(imageNamed: "art.scnassets/blue-cloud-hi.png")
        
        rainCloud.position = CGPointMake(-(rainCloud.frame.size.width / 2), self.generateRandomHeightPosition());
        rainCloud.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(rainCloud.frame.size.width, rainCloud.frame.size.height))
        rainCloud.physicsBody!.categoryBitMask = RAIN_CLOUD;
        rainCloud.physicsBody!.friction = 0;
        rainCloud.physicsBody!.linearDamping = 0;
        rainCloud.setScale(self.sceneSetup!.cloudScalingFactor)
        
        //clouds don't colide with anything
        rainCloud.physicsBody!.collisionBitMask = 0; //also had to specify what colides with ball
        rainCloud.zPosition = 1.0
        
        self.clouds!.addObject(rainCloud)
        NSNotificationCenter.defaultCenter().postNotificationName(CLOUD_CREATED, object: nil)
        
        self.addChild(rainCloud)
        
        rainCloud.physicsBody!.applyImpulse(CGVectorMake(800.0, 0)) //TODO; adjust vector force
    }
    
    func retrieveWindAudioFileAsData() -> NSData {

        var soundData : NSData?
        let windSoundFile = NSBundle.mainBundle().pathForResource(WIND_SOUND_FILE_NAME, ofType: nil)
    
        print("windSoundFile full path is ", windSoundFile)
        //assert(windSoundFile != nil, "No such file in mainBundle: ", WIND_SOUND_FILE_NAME)
        soundData = NSData.init(contentsOfFile: windSoundFile!)
        
        return soundData!
    }
    
    func playWindAudioForData(audioData : NSData) {

        self.windAudioPlayer = IGGameManager2.sharedInstance.createAudioPlayerForData(audioData)
        
        if (self.windAudioPlayer != nil) {
            self.windAudioPlayer!.numberOfLoops = 0
            self.windAudioPlayer!.play()
        }
    }
    
    
    func generateRandomHeightPosition() -> CGFloat {

        let floor : CGFloat = PADDLE_Y_POSITION + 50.0
        let diff : CGFloat = self.view!.frame.size.height / 2 - floor;
        return ((CGFloat(arc4random()) / CGFloat(UINT32_MAX)) * diff) + floor
    }
    
    func gamePaused5(notification : NSNotification) {
        print("Pausing audio player in 5th...")
        
        self.windAudioPlayer!.pause()
    }
    
    func gameResumed5(notification : NSNotification) {
        print("Resuming the audio player in 5th...")
        
        if self.windAudioPlayer != nil {
            self.windAudioPlayer!.play()
        }
    }
    
    func gamePausedComingToForeground5(notification : NSNotification) {
        print("Pausing after coming into foreground in 5th...")
        
        self.gamePaused5(notification)
    }
    
    func levelEnded5(notification : NSNotification) {
        
        self.windAudioPlayer!.stop()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: LEVEL_ENDED_NOTIFICATION, object: nil)
    }
    
    deinit {
        print("Deallocating the 5th scene")
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: GAME_PAUSED_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,  name: GAME_RESUMED_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: GAME_PAUSED_NO_ALERT_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: LEVEL_ENDED_NOTIFICATION, object: nil)
        
        self.removeAllActions()
        
        if self.windAudioPlayer != nil {
            self.windAudioPlayer!.stop()
        }
        //self.removeAllChildren()
        
        if self.view != nil {
            self.view!.removeFromSuperview()
        }
        self.removeFromParent()
    }
}