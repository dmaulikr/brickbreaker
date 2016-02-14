//
//  IGSixthLevelScene.m
//  BreakBricks
//
//  Created by Rich Rosiak on 1/29/16.
//  Copyright © 2016 Rich Rosiak. All rights reserved.
//

#import "IGSixthLevelScene.h"
#import "IGStartBrickScene.h"
#import "IGGameManager.h"

@interface IGSixthLevelScene ()

@property (nonatomic, strong) SKSpriteNode *background;
@property (nonatomic, strong) SKColor *originalBckgColor;
@property (nonatomic, assign) BOOL ballWasAtTop;
@property (nonatomic, assign) BOOL ballWasAtBottom;
@property (nonatomic, assign) BOOL isEveryOtherLightning;

@property (nonatomic, strong) AVAudioPlayer *thunderAudioPlayer;
@property (nonatomic, strong) NSData *thunderSoundData;

@end

const uint32_t LIGHTNING_TRIGGER_EDGE = 128; //00000000000000000000000010000000

/*
const uint32_t LIGHTNING_TRIGGER_EDGE = 0x1 << 7;  //00000000000000000000000010000000
 */

#define THUNDER_SOUND_FILE_NAME @"art.scnassets/thunder.wav"


@implementation IGSixthLevelScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        NSLog(@"Init 6th scene...");
    }
    
    self.originalBckgColor = [SKColor colorWithRed:0.067 green:0.067 blue:0.11 alpha:1];
    self.thunderSoundData = [[IGGameManager sharedInstance] retrieveDataForAudioFileName:THUNDER_SOUND_FILE_NAME];
    
    [self addLightningTriggerEdgeToScene];
    [self addBackgroundColorToScene];
    SKTexture *darkBall = [SKTexture textureWithImageNamed:@"ball_dark"];
    self.ball.texture = darkBall;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gamePaused6:) name:GAME_PAUSED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameResumed6:) name:GAME_RESUMED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gamePausedComingToForeground6:) name:GAME_PAUSED_NO_ALERT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addRainToNewCloud:) name:CLOUD_CREATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(levelEnded6:) name:LEVEL_ENDED_NOTIFICATION object:nil];
    
    self.isEveryOtherLightning = YES;
    return self;
}

-(void) addBackgroundColorToScene {
    self.background = [SKSpriteNode spriteNodeWithColor:self.originalBckgColor size:self.size];
    self.background.position = CGPointMake(self.background.size.width/2, self.background.size.height/2);
    self.background.zPosition = -1;
    [self addChild:self.background];
}

-(void) addLightningTriggerEdgeToScene
{
    SKNode *lightningTriggerEdge = [SKNode node];
    lightningTriggerEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0, self.frame.size.height / 2) toPoint:CGPointMake(self.frame.size.width, self.frame.size.height / 2)];
    lightningTriggerEdge.physicsBody.categoryBitMask = LIGHTNING_TRIGGER_EDGE;
    lightningTriggerEdge.physicsBody.collisionBitMask = 0;
    lightningTriggerEdge.physicsBody.dynamic = NO;
    
    [self addChild:lightningTriggerEdge];
}

-(void) addRainToNewCloud:(NSNotification*)notification {
    NSLog(@"Adding rain to last cloud");
    
    NSString *rainParticlePath = [[NSBundle mainBundle] pathForResource:@"RainParticle" ofType:@"sks"];
    
    SKEmitterNode *rainParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:rainParticlePath];
    
    SKSpriteNode *lastCloud = [self.clouds lastObject];
    rainParticle.targetNode = lastCloud;
    rainParticle.position = CGPointMake(0, -lastCloud.frame.size.height / 4); //pos. with respect to lastCloud
    
    rainParticle.particlePositionRange = CGVectorMake(lastCloud.frame.size.width, 5.0f);
    
    [lastCloud addChild:rainParticle];
}

-(void) didBeginContact:(SKPhysicsContact *)contact
{
    [super didBeginContact:contact];
    
    if (self.notTheBall.physicsBody.categoryBitMask == BRICK_CATEGORY ||
        self.ball.position.y > self.frame.size.height - self.ball.frame.size.height) {
        self.ballWasAtTop = YES;
        self.ballWasAtBottom = NO;
    }
    
    if (self.notTheBall.physicsBody.categoryBitMask == PADDLE_CATEGORY) {
        self.ballWasAtBottom = YES;
        self.ballWasAtTop = NO;
    }
    
    if (self.notTheBall.physicsBody.categoryBitMask == LIGHTNING_TRIGGER_EDGE && (self.ballWasAtTop || !self.ballWasAtBottom)) {
        NSLog(@"Scene 6 - ball passed through lightning trigger");
        [self produceLightningEffect];
        self.isEveryOtherLightning = !self.isEveryOtherLightning;
        
        if (self.isEveryOtherLightning) { //only sound thunder every other lightning action
            [self playThunderAudioForData:self.thunderSoundData];
        }
    }
}

-(void) produceLightningEffect {
    SKAction *changeBackgroundColor = [SKAction colorizeWithColor:[SKColor grayColor] colorBlendFactor:1 duration:0.2];
    SKAction *revertToOriginalBackground = [SKAction colorizeWithColor:self.originalBckgColor colorBlendFactor:1 duration:0];
    
    //lightning effect
    [self.background runAction:[SKAction repeatAction:[SKAction sequence:@[changeBackgroundColor, revertToOriginalBackground]] count:2]];
}

-(void) playThunderAudioForData:(NSData*)audioData
{
    self.thunderAudioPlayer = [[IGGameManager sharedInstance] createAudioPlayerForData:audioData];
    
    if (self.thunderAudioPlayer) {
        self.thunderAudioPlayer.numberOfLoops = 0;
        [self.thunderAudioPlayer play];
    }
}

-(void) gamePaused6:(NSNotification*)notification {
    NSLog(@"Pausing audio player in 6th...");
    
    [self.thunderAudioPlayer pause];
}

-(void) gameResumed6:(NSNotification*)notification {
    NSLog(@"Resuming the audio player in 6th...");
    
    if (self.thunderAudioPlayer) {
        [self.thunderAudioPlayer play];
    }
}

-(void) gamePausedComingToForeground6:(NSNotification*)notification {
    NSLog(@"Pausing after coming into foreground in 6th...");
    
    [self gamePaused6:notification];
}

-(void) levelEnded6:(NSNotification*)notification {
    
    [self.thunderAudioPlayer stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LEVEL_ENDED_NOTIFICATION object:nil];
}

-(void) dealloc {
    NSLog(@"Deallocating the 6th scene");
    
    [self removeAllActions];
    [self.thunderAudioPlayer stop];
    [self removeObservers];
    [self.view removeFromSuperview];
    [self removeFromParent];
}

-(void) removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GAME_PAUSED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GAME_RESUMED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GAME_PAUSED_NO_ALERT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CLOUD_CREATED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LEVEL_ENDED_NOTIFICATION object:nil];
}

@end
