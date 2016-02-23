//
//  IGAdvanceToNextLevel.swift
//  BreakBricks
//
//  Created by Joanna Rosiak on 2/20/16.
//  Copyright © 2016 Rich Rosiak. All rights reserved.
//

import Foundation
import SpriteKit

@objc class AdvanceToNextLevelScene : SKScene {
    
    var newLevel : UInt = 0
    
    override init(size: CGSize) {
        
        super.init(size: size)
        print("Initing advance to next level scene")
        
        let appDelegate = UIApplication.sharedApplication().delegate as! IGAppDelegate
        
        appDelegate.currentLevel++;
        
        NSUserDefaults.standardUserDefaults().setInteger((Int)(appDelegate.currentLevel), forKey: appDelegate.currentPlayer + PLAYER_LEVEL_KEY_SUFFIX)
        
        //self.newLevel = appDelegate.currentLevel For debugging only
        
        self.backgroundColor = SKColor(white: 1, alpha: 1) //whiteColor
        
        let playSuccessSound = SKAction.playSoundFileNamed("levelSuccess.wav", waitForCompletion: false)
        self.runAction(playSuccessSound)
        
        let successLabel : SKLabelNode = SKLabelNode(fontNamed: "Futura Medium")
        successLabel.text = "SUCCESS!"
        
        successLabel.fontColor = SKColor(colorLiteralRed: 0, green: 0, blue: 1, alpha: 1) //blueColor
        successLabel.fontSize = 40
        successLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        self.addChild(successLabel)
        
        let playAgain = SKLabelNode(fontNamed:"Futura Medium")
        playAgain.text = "Tap to advance to level " + String(appDelegate.currentLevel)
        
        playAgain.fontColor = SKColor(colorLiteralRed: 0, green: 0, blue: 1, alpha: 1) //blueColor
        playAgain.fontSize = 20
        playAgain.position = CGPointMake(-300.0, CGRectGetMidY(self.frame) - 60.0)
        
        let moveLabel = SKAction.moveToX(CGRectGetMidX(self.frame), duration:1.0)
        playAgain.runAction(moveLabel)
        
        self.addChild(playAgain)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! IGAppDelegate
        
        var gameScene : SKScene!
        
        switch (appDelegate.currentLevel) {
        case 1, 2, 3, 4:
            gameScene = IGStartBrickScene(size:self.size)
            break
        case 5:
            gameScene = IG5LevelScene(size:self.size)
            break
        case 6:
            gameScene = IG6LevelScene(size:self.size)
            break
        case 7:
            gameScene = IGSeventhLevelScene(size:self.size)
            break
        default:
            gameScene = IGSeventhLevelScene(size:self.size) //currently max level to play
            break
        }
        
        self.view!.presentScene(gameScene, transition: SKTransition.doorsOpenHorizontalWithDuration(2.0))
        
        /*if (self.newLevel < 5)
        {
        IGStartBrickScene *playAgainScene = [IGStartBrickScene sceneWithSize:self.size];
        [self.view presentScene:playAgainScene transition:[SKTransition doorsOpenHorizontalWithDuration:2.0f]];
        }
        
        if (self.newLevel == 5)
        {
        IGFifthLevelScene *playAgainScene = [IGFifthLevelScene sceneWithSize:self.size];
        [self.view presentScene:playAgainScene transition:[SKTransition doorsOpenHorizontalWithDuration:2.0f]];
        }*/
    }
    
    /*override func touchesBegan(touches : NSSet, event : UIEvent) {
        
    
    
    }*/
}
