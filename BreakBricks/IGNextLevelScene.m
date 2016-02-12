//
//  IGNextLevelScene.m
//  BreakBricks
//
//  Created by Rich Rosiak on 1/6/16.
//  Copyright © 2016 Rich Rosiak. All rights reserved.
//

#import "IGNextLevelScene.h"
#import "IGStartBrickScene.h"
#import "IGAppDelegate.h"
#import "IGFifthLevelScene.h"
#import "IGSixthLevelScene.h"
#import "IGPlayerViewController.h"

#import "BreakBricks-Swift.h"

@interface IGNextLevelScene()

@property (nonatomic, assign) NSUInteger newLevel;

@end

@implementation IGNextLevelScene

-(instancetype) initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        IGAppDelegate *appDelegate = (IGAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        appDelegate.currentLevel++;
        [[NSUserDefaults standardUserDefaults] setInteger:appDelegate.currentLevel forKey:[NSString stringWithFormat:@"%@%@",appDelegate.currentPlayer, PLAYER_LEVEL_KEY_SUFFIX]];
        
        self.newLevel = appDelegate.currentLevel;
        
        self.backgroundColor = [SKColor whiteColor];
        
        SKAction *playSuccessSound = [SKAction playSoundFileNamed:@"levelSuccess.wav" waitForCompletion:NO];
        [self runAction:playSuccessSound];
        
        SKLabelNode *successLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
        successLabel.text = @"SUCCESS!";
        
        successLabel.fontColor = [SKColor blueColor];
        successLabel.fontSize = 40;
        successLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        
        [self addChild:successLabel];
        
        SKLabelNode *playAgain = [SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
        playAgain.text = [NSString stringWithFormat:@"Tap to advance to level %lu", (unsigned long)appDelegate.currentLevel];
        
        playAgain.fontColor = [SKColor blueColor];
        playAgain.fontSize = 20;
        playAgain.position = CGPointMake(-300.0f, CGRectGetMidY(self.frame) - 60.0f);
        
        SKAction *moveLabel = [SKAction moveToX:CGRectGetMidX(self.frame) duration:1.0f];
        [playAgain runAction:moveLabel];
        
        [self addChild:playAgain];
    }
    
    return self;
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent *)event
{
    IGAppDelegate *appDelegate = (IGAppDelegate*)[[UIApplication sharedApplication] delegate];
    SKScene *gameScene;
    
    switch (appDelegate.currentLevel) {
        case 1:
        case 2:
        case 3:
        case 4:
            gameScene = [IGStartBrickScene sceneWithSize:self.size];
            break;
        case 5:
            gameScene = [IGFifthLevelScene sceneWithSize:self.size];
            break;
        case 6:
            gameScene = [IGSixthLevelScene sceneWithSize:self.size];
            break;
        case 7:
            gameScene = [IGSeventhLevelScene sceneWithSize:self.size];
            break;
        default:
            gameScene = [IGSeventhLevelScene sceneWithSize:self.size]; //currently max level to play
            break;
    }
    
    [self.view presentScene:gameScene transition:[SKTransition doorsOpenHorizontalWithDuration:2.0f]];
    
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


@end
