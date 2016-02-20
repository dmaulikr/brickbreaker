//
//  IGGameOverScene.m
//  BreakBricks
//
//  Created by Rich Rosiak on 1/6/16.
//  Copyright © 2016 Rich Rosiak. All rights reserved.
//

#import "IGGameOverScene.h"
#import "IGStartBrickScene.h"
#import "IGAppDelegate.h"
#import "IGPlayerViewController.h"
//#import "IGFifthLevelScene.h"
//#import "IGSixthLevelScene.h"

#import "BreakBricks-Swift.h"

@implementation IGGameOverScene

-(instancetype) initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        //IGAppDelegate *appDelegate = (IGAppDelegate*)[[UIApplication sharedApplication] delegate];
        //appDelegate.currentLevel = 1;
        
        self.backgroundColor = [SKColor blackColor];
        
        NSInteger currentLives = [self adjustLives];
        
        SKAction *playGameoverSound = [SKAction playSoundFileNamed:@"gameover.caf" waitForCompletion:NO];
        [self runAction:playGameoverSound];
        
        SKLabelNode *gameoverLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
        gameoverLabel.text = @"GAME OVER!";
        
        gameoverLabel.fontColor = [SKColor whiteColor];
        gameoverLabel.fontSize = 40;
        gameoverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        
        [self addChild:gameoverLabel];
        
        SKLabelNode *playAgain = [SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
        playAgain.text = [NSString stringWithFormat:@"Tap to play again"];
        
        playAgain.fontColor = [SKColor whiteColor];
        playAgain.fontSize = 20;
        playAgain.position = CGPointMake(-300.0f, CGRectGetMidY(self.frame) - 60.0f);
        
        SKAction *moveLabel = [SKAction moveToX:CGRectGetMidX(self.frame) duration:1.0f];
        
        [self addChild:playAgain];
        [playAgain runAction:moveLabel];
        
        SKLabelNode *remainingLives = [SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
        remainingLives.text = [NSString stringWithFormat:@"Lives remaining: %ld", (long)currentLives];
        
        remainingLives.fontColor = [SKColor whiteColor];
        remainingLives.fontSize = 20;
        remainingLives.position = CGPointMake(-300.0f, CGRectGetMidY(self.frame) - 60.0f - playAgain.frame.size.height);
        
        SKAction *moveLivesLabel = [SKAction moveToX:CGRectGetMidX(self.frame) duration:1.0f];
        
        [self addChild:remainingLives];
        
        //[self runAction:[SKAction waitForDuration:1]];
        [remainingLives runAction:moveLivesLabel];
    }
    
    return self;
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent *)event
{
    IGAppDelegate *appDelegate = (IGAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"Game over will choose next scene based on current level %ld", (long)appDelegate.currentLevel);
    
    SKScene *gameScene;
    
    switch (appDelegate.currentLevel) {
        case 1:
        case 2:
        case 3:
        case 4:
            gameScene = [IGStartBrickScene sceneWithSize:self.size];
            break;
        case 5:
            gameScene = [IG5LevelScene sceneWithSize:self.size];
            break;
        case 6:
            gameScene = [IG6LevelScene sceneWithSize:self.size];
            break;
        case 7:
            gameScene = [IGSeventhLevelScene sceneWithSize:self.size];
            break;
        default:
            gameScene = [IGSeventhLevelScene sceneWithSize:self.size]; //highest level
            break;
    }
    
    [self.view presentScene:gameScene transition:[SKTransition doorsOpenHorizontalWithDuration:2.0f]];
}

-(NSInteger) adjustLives
{
    NSString *currentPlayer = ((IGAppDelegate*)[[UIApplication sharedApplication] delegate]).currentPlayer;
    NSInteger currentLives = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@%@", currentPlayer, PLAYER_LIVES_KEY_SUFFIX]];
    
    NSInteger livesAfterAdjustment = 0;
    
    NSLog(@"Remaining lives for %@: %ld. Will decrement by 1", currentPlayer, (long)currentLives);
    currentLives--;
    
    if (currentLives == 0) {
        ((IGAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLevel = 1; //back to starting level
        livesAfterAdjustment = 3;
        
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"%@%@", currentPlayer, PLAYER_POINTS_KEY_SUFFIX]]; //points back to 0
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:[NSString stringWithFormat:@"%@%@", currentPlayer, PLAYER_LEVEL_KEY_SUFFIX]]; //back to level 1
    }
    else
    {
        livesAfterAdjustment = currentLives;
    }
    
    NSLog(@"Will adjust lives in user defaults to %ld", (long)livesAfterAdjustment);
    [[NSUserDefaults standardUserDefaults] setInteger:livesAfterAdjustment forKey:[NSString stringWithFormat:@"%@%@", currentPlayer, PLAYER_LIVES_KEY_SUFFIX]];
    
    return currentLives;
}

-(void) dealloc {
    //
}

@end
