//
//  IG6LevelScene.swift
//  BreakBricks
//
//  Created by Rich Rosiak on 2/13/16.
//  Copyright © 2016 Rich Rosiak. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

let LIGHTNING_TRIGGER_EDGE : UInt32 = 128; //00000000000000000000000010000000

/*
const uint32_t LIGHTNING_TRIGGER_EDGE = 0x1 << 7;  //00000000000000000000000010000000
*/

let THUNDER_SOUND_FILE_NAME = "art.scnassets/thunder.wav"


@objc class IG6LevelScene : IG5LevelScene {
    
    var background : SKSpriteNode?
    var originalBckgColor : SKColor
    var ballWasAtTop : Bool = false
    var ballWasAtBottom : Bool = false
    var isEveryOtherLightning : Bool = false
    
    var thunderAudioPlayer : AVAudioPlayer?
    var thunderSoundData : NSData?
    
    //internal var LIGHTNING_TRIGGER_EDGE : UInt32 = 128;
    
    override init(size: CGSize) {
        
        self.originalBckgColor = SKColor(red: 0.067, green: 0.067, blue: 0.11, alpha: 1)
        
        super.init(size: size)
        print("Init 6th scene...")
        
        self.thunderSoundData = IGGameManager2.sharedInstance.retrieveDataForAudioFileName(THUNDER_SOUND_FILE_NAME)
        self.addLightningTriggerEdgeToScene()
        
        self.addBackgroundColorToScene()
        let darkBall : SKTexture = SKTexture(imageNamed: "ball_dark")
        self.ball.texture = darkBall
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gamePaused6:", name: GAME_PAUSED_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gameResumed6:", name: GAME_RESUMED_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gamePausedComingToForeground6:", name: GAME_PAUSED_NO_ALERT_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addRainToNewCloud:", name: CLOUD_CREATED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "levelEnded6:", name: LEVEL_ENDED_NOTIFICATION, object: nil)
        
        self.isEveryOtherLightning = true;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addBackgroundColorToScene() {
        
        self.background = SKSpriteNode.init(texture: nil, color: self.originalBckgColor, size: self.size)
        self.background!.position = CGPointMake(self.background!.size.width/2, self.background!.size.height/2);
        self.background!.zPosition = -1;
        self.addChild(self.background!)
    }
    
    func addLightningTriggerEdgeToScene() {
        
        let lightningTriggerEdge : SKNode = SKNode()
        
        lightningTriggerEdge.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(0, self.frame.size.height / 2), toPoint: CGPointMake(self.frame.size.width, self.frame.size.height / 2))
        lightningTriggerEdge.physicsBody!.categoryBitMask = LIGHTNING_TRIGGER_EDGE
        lightningTriggerEdge.physicsBody!.collisionBitMask = 0
        lightningTriggerEdge.physicsBody!.dynamic = false
        
        self.addChild(lightningTriggerEdge)
    }
    
    func addRainToNewCloud(notification : NSNotification) {
        print("Adding rain to last cloud")
    
        let rainParticlePath : String = NSBundle.mainBundle().pathForResource("RainParticle", ofType: "sks")!
        let rainParticle : SKEmitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(rainParticlePath) as! SKEmitterNode
    
        let lastCloud : SKSpriteNode = self.clouds!.lastObject as! SKSpriteNode
        rainParticle.targetNode = lastCloud;
        rainParticle.position = CGPointMake(0, -lastCloud.frame.size.height / 4); //pos. with respect to lastCloud
    
        rainParticle.particlePositionRange = CGVectorMake(lastCloud.frame.size.width, 5.0)
    
        lastCloud.addChild(rainParticle)
    }
    
    override func didBeginContact(contact : SKPhysicsContact) {
        
        super.didBeginContact(contact)
    
        if self.notTheBall.physicsBody!.categoryBitMask == BRICK_CATEGORY ||
            self.ball.position.y > self.frame.size.height - self.ball.frame.size.height {
    
                self.ballWasAtTop = true
                self.ballWasAtBottom = false
        }
        
        if self.notTheBall.physicsBody!.categoryBitMask == PADDLE_CATEGORY {

            self.ballWasAtBottom = true
            self.ballWasAtTop = false
        }
    
        if self.notTheBall.physicsBody!.categoryBitMask == LIGHTNING_TRIGGER_EDGE && (self.ballWasAtTop || !self.ballWasAtBottom) {
            
            print("Scene 6 - ball passed through lightning trigger")
            self.produceLightningEffect()
            self.isEveryOtherLightning = !self.isEveryOtherLightning;
            
            if self.isEveryOtherLightning { //only sound thunder every other lightning action
                self.playThunderAudioForData(self.thunderSoundData!)
            }
        }
    }
    
    func produceLightningEffect() {
    
        let changeBackgroundColor : SKAction = SKAction.colorizeWithColor(SKColor.grayColor(), colorBlendFactor:1, duration:0.2)
        let revertToOriginalBackground : SKAction = SKAction.colorizeWithColor(self.originalBckgColor, colorBlendFactor: 1, duration: 0)
        
        //lightning effect
        self.background!.runAction(SKAction.repeatAction(SKAction.sequence([changeBackgroundColor, revertToOriginalBackground]), count:2))
    }
    
    func playThunderAudioForData(audioData : NSData) {
        
        self.thunderAudioPlayer = IGGameManager2.sharedInstance.createAudioPlayerForData(audioData)
    
        if self.thunderAudioPlayer != nil {
            self.thunderAudioPlayer!.numberOfLoops = 0;
            self.thunderAudioPlayer!.play()
        }
    }
    
    func gamePaused6(notification : NSNotification) {
        
        print("Pausing audio player in 6th...")
        
        self.thunderAudioPlayer!.pause()
    }
    
    func gameResumed6(notification : NSNotification) {
    
        print("Resuming the audio player in 6th...")
    
        if self.thunderAudioPlayer != nil {
            self.thunderAudioPlayer!.play()
        }
    }
    
    func gamePausedComingToForeground6(notification : NSNotification) {
    
        print("Pausing after coming into foreground in 6th...")
    
        self.gamePaused6(notification)
    }
    
    func levelEnded6(notification : NSNotification) {
    
        self.thunderAudioPlayer!.stop()
        NSNotificationCenter.defaultCenter().removeObserver(self,  name: LEVEL_ENDED_NOTIFICATION, object: nil)
    }
    
    deinit {
        print("Deiniting the 6th scene")
        
        self.removeAllActions()
        if self.thunderAudioPlayer != nil {
            self.thunderAudioPlayer!.stop()
        }
        self.removeObservers()
        if self.view != nil {
            self.view!.removeFromSuperview()
        }
        self.removeFromParent()
    }
    
    func removeObservers() {
    
        NSNotificationCenter.defaultCenter().removeObserver(self, name: GAME_PAUSED_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: GAME_RESUMED_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: GAME_PAUSED_NO_ALERT_NOTIFICATION, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CLOUD_CREATED, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: LEVEL_ENDED_NOTIFICATION, object: nil)
    }
}