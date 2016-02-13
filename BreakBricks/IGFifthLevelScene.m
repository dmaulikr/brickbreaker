//
//  IGFifthLevelScene.m
//  BreakBricks
//
//  Created by Rich Rosiak on 1/25/16.
//  Copyright © 2016 Rich Rosiak. All rights reserved.
//

#import "IGFifthLevelScene.h"
#import "IGAppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "IGGameManager.h"

#import "BreakBricks-Swift.h"

@interface IGFifthLevelScene ()

@property (nonatomic, assign) BOOL wasFirstCloudReleased;
@property (nonatomic, strong) SKAction *playWindBlowingSound;

@property (nonatomic, strong) AVAudioPlayer *windAudioPlayer;
@property (nonatomic, strong) NSData *windSoundData;

@property (nonatomic, strong) IGSceneSetup *sceneSetup;

@end

static const uint32_t RAIN_CLOUD = 64; //00000000000000000000000001000000

/*
 static const uint32_t SIDE_CANNON_BALL = 0x1 << 6;  //00000000000000000000000001000000
 */

#define WIND_SOUND_FILE_NAME @"art.scnassets/windBlowing.wav"

@implementation IGFifthLevelScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        NSLog(@"Init 5th scene...");
        self.clouds = [NSMutableArray new];
    }
    
    self.sceneSetup = [IGGameManager sharedInstance].sceneSetup;
    
    //self.playWindBlowingSound = [SKAction playSoundFileNamed:@"art.scnassets/windBlowing.wav" waitForCompletion:NO];
    self.windSoundData = [[IGGameManager sharedInstance] retrieveDataForAudioFileName:WIND_SOUND_FILE_NAME]; //audio is 3 sec long, so we'd better use audio player
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gamePaused5:) name:GAME_PAUSED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameResumed5:) name:GAME_RESUMED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gamePausedComingToForeground5:) name:GAME_PAUSED_NO_ALERT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(levelEnded5:) name:LEVEL_ENDED_NOTIFICATION object:nil];
    
    [self addBackgroundClouds];
    
    return self;
}

-(void) addBackgroundClouds
{
    SKSpriteNode *cloudyBackground = [SKSpriteNode spriteNodeWithImageNamed:@"art.scnassets/cloudySkies"];
    cloudyBackground.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    cloudyBackground.zPosition = -1;
    [cloudyBackground setScale:self.sceneSetup.cloudyBackgroundScalingFactor];
    
    [self addChild:cloudyBackground];
}

-(void) didBeginContact:(SKPhysicsContact *)contact
{
    [super didBeginContact:contact];
    
    //NSLog(@"Contact happened - Now in 5th level scene!");
    //IGAppDelegate *appDelegate = (IGAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if ([self.clouds count] > 0) {
        SKSpriteNode *firstCloud = (SKSpriteNode*)[self.clouds objectAtIndex:0];
        
        if (firstCloud.position.x > self.frame.size.width + firstCloud.frame.size.width / 2) { //cloud moved past the screen
            NSLog(@"Removing cloud from array...");
            [self.clouds removeObject:firstCloud];
        }
    }
    
    if (self.numberOfVisibleBricks <= 11) {  //&& self.notTheBall.physicsBody.categoryBitMask == BRICK_CATEGORY) {
        //NSLog(@"Blow clouds!");
        
        if (!self.wasFirstCloudReleased) {
            self.wasFirstCloudReleased = YES;
            [self blowCloudIntoScene];
        }
        else if ([self.clouds count] > 0) {
            SKSpriteNode *topCloud = [self.clouds objectAtIndex:0];
            NSLog(@"Cloud position is x: %f and y: %f",  topCloud.position.x, topCloud.position.y);
            
            if (topCloud.position.x >= self.frame.size.width / 2 && [self.clouds count] <= 1) { //top cloud reached half way through screen
                [self blowCloudIntoScene];
            }
        }
    }
}

-(void) blowCloudIntoScene
{
    NSLog(@"Blowing...");
    [self runAction:[SKAction performSelector:@selector(addCloudToScene) onTarget:self]];
    //[self runAction:self.playWindBlowingSound];
    
    [self playWindAudioForData:self.windSoundData];
}

-(void) addCloudToScene
{
    NSLog(@"Adding cloud to scene...");
    SKSpriteNode *rainCloud = [SKSpriteNode spriteNodeWithImageNamed:@"art.scnassets/blue-cloud-hi.png"];
    
    rainCloud.position = CGPointMake(-(rainCloud.frame.size.width / 2), [self generateRandomHeightPosition]);
    rainCloud.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(rainCloud.frame.size.width, rainCloud.frame.size.height)];
    rainCloud.physicsBody.categoryBitMask = RAIN_CLOUD;
    rainCloud.physicsBody.friction = 0;
    rainCloud.physicsBody.linearDamping = 0;
    [rainCloud setScale:self.sceneSetup.cloudScalingFactor];
    
    //clouds don't colide with anything
    rainCloud.physicsBody.collisionBitMask = 0; //also had to specify what colides with ball
    rainCloud.zPosition = 1.0f;
    
    [self.clouds addObject:rainCloud];
    [[NSNotificationCenter defaultCenter] postNotificationName:CLOUD_CREATED object:nil];
    
    [self addChild:rainCloud];
    
    [rainCloud.physicsBody applyImpulse:CGVectorMake(800.0f, 0)]; //TODO; adjust vector force
}

-(NSData*) retrieveWindAudioFileAsData
{
    NSData *soundData = nil;
    NSString *windSoundFile = [[NSBundle mainBundle] pathForResource:WIND_SOUND_FILE_NAME ofType:nil];
    
    NSLog(@"windSoundFile full path is %@", windSoundFile);
    NSAssert(windSoundFile, @"No such file in mainBundle: %@", WIND_SOUND_FILE_NAME);
    soundData = [[NSData alloc] initWithContentsOfFile:windSoundFile];
    
    return soundData;
}

-(void) playWindAudioForData:(NSData*)audioData
{
    self.windAudioPlayer = [[IGGameManager sharedInstance] createAudioPlayerForData:audioData];
    
    if (self.windAudioPlayer) {
        self.windAudioPlayer.numberOfLoops = 0;
        [self.windAudioPlayer play];
    }
}

-(CGFloat) generateRandomHeightPosition
{
    CGFloat floor = PADDLE_Y_POSITION + 50.0f;
    CGFloat diff = self.view.frame.size.height / 2 - floor;
    return (((CGFloat) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + floor;
}

-(void) gamePaused5:(NSNotification*)notification {
    NSLog(@"Pausing audio player in 5th...");
    
    [self.windAudioPlayer pause];
}

-(void) gameResumed5:(NSNotification*)notification {
    NSLog(@"Resuming the audio player in 5th...");
    
    if (self.windAudioPlayer) {
        [self.windAudioPlayer play];
    }
}

-(void) gamePausedComingToForeground5:(NSNotification*)notification {
    NSLog(@"Pausing after coming into foreground in 5th...");
    
    [self gamePaused5:notification];
}

-(void) levelEnded5:(NSNotification*)notification {
    
    [self.windAudioPlayer stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LEVEL_ENDED_NOTIFICATION object:nil];
}

-(void) dealloc {
    NSLog(@"Deallocating the 5th scene");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GAME_PAUSED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GAME_RESUMED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GAME_PAUSED_NO_ALERT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LEVEL_ENDED_NOTIFICATION object:nil];
    
    [self removeAllActions];
    [self.windAudioPlayer stop];
    //[self removeAllChildren];
    [self.view removeFromSuperview];
    [self removeFromParent];
}

@end
