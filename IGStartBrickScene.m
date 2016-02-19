//
//  IGStartBrickScene.m
//  BreakBricks
//
//  Created by Rich Rosiak on 1/5/16.
//  Copyright © 2016 Rich Rosiak. All rights reserved.
//

#import "IGStartBrickScene.h"
#import "IGGameOverScene.h"
#import "IGNextLevelScene.h"
#import "IGAppDelegate.h"
#import "IGPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
//#import "IGSixthLevelScene.h"
#import "IGGameManager.h"

//#import "BreakBricks-Swift.h"

@interface IGStartBrickScene ()

@property (nonatomic, strong) SKSpriteNode *paddle;
@property (nonatomic, strong) SKSpriteNode *pauseBtn;
@property (nonatomic, strong) SKLabelNode *pointsCountLabel;

@property (nonatomic, strong) SKAction *playPaddleSound;
@property (nonatomic, strong) SKAction *playBrickHitSound;

@property (nonatomic, strong) NSMutableArray *hitBricks;
@property (nonatomic, assign) BOOL isGamePaused;
@property (nonatomic, assign) BOOL isBallStarted;

@property (nonatomic, strong) SKEmitterNode *explosionParticle;
@property (nonatomic, strong) IGSceneSetup *sceneSetup;

@end

const uint32_t BALL_CATEGORY        = 1;  //00000000000000000000000000000001
const uint32_t BRICK_CATEGORY       = 2;  //00000000000000000000000000000010
const uint32_t PADDLE_CATEGORY      = 4;  //00000000000000000000000000000100
const uint32_t EDGE_CATEGORY        = 8;  //00000000000000000000000000001000
static const uint32_t BOTTOM_EDGE_CATEGORY = 16; //00000000000000000000000000010000
const uint32_t SIDE_CANNON_BALL_CATEGORY     = 32; //00000000000000000000000000100000

/*
const uint32_t BALL_CATEGORY                = 0x1;       //00000000000000000000000000000001
const uint32_t BRICK_CATEGORY               = 0x1 << 1;  //00000000000000000000000000000010
 static const uint32_t PADDLE_CATEGORY      = 0x1 << 2;  //00000000000000000000000000000100
 static const uint32_t EDGE_CATEGORY        = 0x1 << 3;  //00000000000000000000000000001000
 static const uint32_t BOTTOM_EDGE_CATEGORY = 0x1 << 4;  //00000000000000000000000000010000
 static const uint32_t SIDE_CANNON_BALL     = 0x1 << 5;  //00000000000000000000000000100000
 */

const CGFloat PADDLE_Y_POSITION = 100.0f;
NSString *GAME_PAUSED_NOTIFICATION = @"GamePausedNotification";
NSString *GAME_RESUMED_NOTIFICATION = @"GameResumedNotification";
NSString *GAME_PAUSED_NO_ALERT_NOTIFICATION = @"GamePausedNoAlertNotification";
NSString *CLOUD_CREATED = @"newCloudCreated";
NSString *LEVEL_ENDED_NOTIFICATION = @"LevelEndedNotification";

@implementation IGStartBrickScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        IGAppDelegate *appDelegate = (IGAppDelegate*)[[UIApplication sharedApplication] delegate];
        NSLog(@"Currently on level %ld", (unsigned long)appDelegate.currentLevel);
        
        self.sceneSetup = [IGGameManager sharedInstance].sceneSetup;
        
        //self.backgroundColor = [SKColor whiteColor];
        if (appDelegate.currentLevel < 5) {
            [self addBackgroundBrickPile];
        }
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody.categoryBitMask = EDGE_CATEGORY;
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        [self addBallToSceneWithSize:size];
        [self addPlayerToSceneWithSize:size];
        [self addBricksToSceneWithSize:size];
        [self addBottomEdgeToSceneWithSize:size];
        [self addPauseBtnToScene];
        [self addHeartToScene];
        [self addLivesCountToScene];
        [self addPointsCountToScene];
        
        self.playPaddleSound = [SKAction playSoundFileNamed:@"blip.caf" waitForCompletion:NO];
        self.playBrickHitSound = [SKAction playSoundFileNamed:@"brickhit.caf" waitForCompletion:NO];
        //self.playCannonSound = [SKAction playSoundFileNamed:@"firecannon.wav" waitForCompletion:NO];
        
        self.hitBricks = [NSMutableArray new];
        self.isGamePaused = NO;
        
        [self registerAppTransitionObservers];
    }
    return self;
}

-(void) addBackgroundBrickPile
{
    SKSpriteNode *brickPileBackground = [SKSpriteNode spriteNodeWithImageNamed:@"art.scnassets/brickPile.jpg"];
    brickPileBackground.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    brickPileBackground.zPosition = -1;
    [brickPileBackground setScale:self.sceneSetup.firstSceneBackgroundScalingFactor];
    
    [self addChild:brickPileBackground];
}

-(void) didMoveToView:(SKView *)view
{
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(recognizeSwipeDown:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [[self view] addGestureRecognizer:recognizer];
}

-(void) recognizeSwipeDown:(UISwipeGestureRecognizer*)sender
{
    NSLog(@"Swiping down...");
    [self.ball.physicsBody applyImpulse:CGVectorMake(5.0f, -12.0f)];
}

-(void) addBallToSceneWithSize:(CGSize)size
{
    SKTexture *grayBall = [SKTexture textureWithImageNamed:@"ball"];
    //self.ball = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
    self.ball = [SKSpriteNode spriteNodeWithTexture:grayBall];
    
    self.ball.position = CGPointMake(size.width/2, size.height - size.height * 0.3f);
    
    self.ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.ball.frame.size.height/2];
    self.ball.physicsBody.friction = 0;
    self.ball.physicsBody.linearDamping = 0;
    self.ball.physicsBody.restitution = 1.0f;
    self.ball.physicsBody.categoryBitMask = BALL_CATEGORY;
    [self.ball setScale:self.sceneSetup.ballScalingFactor];
    
    //alert me when ball taouches either brick, paddle, bottom (invisible) edge or side cannon ball, etc...
    self.ball.physicsBody.contactTestBitMask = BRICK_CATEGORY | PADDLE_CATEGORY | BOTTOM_EDGE_CATEGORY | 128 | EDGE_CATEGORY | SIDE_CANNON_BALL_CATEGORY;
    
    //collisionBitMask - decides which object bounce off of; by default everything colides with every other physics body
    self.ball.physicsBody.collisionBitMask = EDGE_CATEGORY | BRICK_CATEGORY | PADDLE_CATEGORY | SIDE_CANNON_BALL_CATEGORY; //result - ball goes right through the clouds
    
    [self addChild:self.ball];
}

-(void) giveBallInitialImpulse {
    IGAppDelegate *appDelegate = (IGAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    CGFloat horizontalPull = [self randomFloatBetween:8.0 and:14.0];
    NSLog(@"Horizontal pull will be %f", horizontalPull);
    CGFloat downwardPull = (appDelegate.currentLevel < 3) ? -5.0f : -12.0f; //faster ball from level 3
    downwardPull = downwardPull * self.sceneSetup.ballSpeedScalingFactor;
    
    [self.ball.physicsBody applyImpulse:CGVectorMake(horizontalPull, downwardPull)];
}

-(CGFloat) randomFloatBetween:(CGFloat)floor and:(CGFloat)ceiling
{
    int multiplier = ((arc4random() % 2) > 0) ? 1 : -1; //will randomly make the return value either positive or negative
    NSLog(@"multiplier is %d", multiplier); //rand int between 0 and 1
    CGFloat diff = ceiling - floor;
    return ((((CGFloat) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + floor) * multiplier;
}

-(void) didBeginContact:(SKPhysicsContact *)contact
{
    //NSLog(@"Contact happened - start scene!");
    
    //self.notTheBall;
    
    if (contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask)
    {
        self.notTheBall = contact.bodyA.node;
    }
    else
    {
        self.notTheBall = contact.bodyB.node;
    }
    
    if (self.notTheBall.physicsBody.categoryBitMask == BRICK_CATEGORY)
    {
        //NSLog(@"Hit a brick");
        
        [self runAction:self.playBrickHitSound];
        
        IGAppDelegate *appDelegate = (IGAppDelegate*)[[UIApplication sharedApplication] delegate];
        [self addPointsForPlayer:(20 * appDelegate.currentLevel)];
        
        if (appDelegate.currentLevel < 4) {
            
            //crash debug
            [self causeExplosionForHitBrick:self.notTheBall];
            self.numberOfVisibleBricks--;
            [self.notTheBall removeFromParent];
        }
        else //from level 4 each brick must be hit 2 times
        {
            if ([self.hitBricks containsObject:self.notTheBall])
            {
                //crash debug
                [self causeExplosionForHitBrick:self.notTheBall];
                
                self.numberOfVisibleBricks--;
                [self.notTheBall removeFromParent];
            }
            else
            {
                //[self causeExplosionForHitBrick:self.notTheBall]; //debugging
                
                SKAction *changeColor = [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration:0.1];
                [self.notTheBall runAction:changeColor];
                [self.hitBricks addObject:self.notTheBall];
                //NSLog(@"Added brick to array; the array now has %ld", [self.hitBricks count]);
            }
        }
    }
    
    if (self.notTheBall.physicsBody.categoryBitMask == PADDLE_CATEGORY)
    {
        //NSLog(@"Hit paddle");
        [self runAction:self.playPaddleSound];
    }
    
    if (self.notTheBall.physicsBody.categoryBitMask == BOTTOM_EDGE_CATEGORY && self.numberOfVisibleBricks > 0)
    {
        NSLog(@"***** GAME OVER!! *****");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:LEVEL_ENDED_NOTIFICATION object:self];
        
        [self removeObservers];
        [self.explosionParticle removeFromParent];
        
        IGGameOverScene *gameover = [IGGameOverScene sceneWithSize:self.size];
        [self.view presentScene:gameover transition:[SKTransition doorsCloseHorizontalWithDuration:1.0f]];
    }
    
    //check if level completed
    if (self.numberOfVisibleBricks == 0) {
        NSLog(@"***** LEVEL COMPLETED!! *****");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:LEVEL_ENDED_NOTIFICATION object:self];
        
        [self removeObservers];
        [self.explosionParticle removeFromParent];
        
        IGNextLevelScene *success = [IGNextLevelScene sceneWithSize:self.size];
        [self.view presentScene:success transition:[SKTransition doorsOpenHorizontalWithDuration:1.0f]];
    }
}

-(void) causeExplosionForHitBrick:(SKNode*)brickNode {
    if (self.explosionParticle) {
        //NSLog(@"Will remove an existing explosion particle emitter from scene...");
        [self.explosionParticle removeFromParent];
    }
    
    //NSLog(@"Explosion coming... brick's position x: %f, y: %f", brickNode.position.x, brickNode.position.y);
    NSString *explosionParticlePath = [[NSBundle mainBundle] pathForResource:@"ExplosionParticle" ofType:@"sks"];
    self.explosionParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:explosionParticlePath];
    
    self.explosionParticle.targetNode = self.scene; //brickNode;
    self.explosionParticle.position = brickNode.position; //CGPointMake(0, 0); //pos. with respect to brick
    
    self.explosionParticle.particlePositionRange = CGVectorMake(0, 0); //(brickNode.frame.size.width, 5.0f);
    
    [self addChild:self.explosionParticle];
}

-(void) addPointsForPlayer:(NSInteger)pointsEarned
{
    NSLog(@"Player earned %ld points", (long)pointsEarned);
    
    NSString *currentPlayer = ((IGAppDelegate*)[[UIApplication sharedApplication] delegate]).currentPlayer;
    NSInteger currentPoints = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@%@", currentPlayer, PLAYER_POINTS_KEY_SUFFIX]];
    
    NSInteger newTotal = currentPoints + pointsEarned;
    self.pointsCountLabel.text = [NSString stringWithFormat:@"%ld",(long)newTotal];
    
    [[NSUserDefaults standardUserDefaults] setInteger:newTotal
                                               forKey:[NSString stringWithFormat:@"%@%@", currentPlayer, PLAYER_POINTS_KEY_SUFFIX]];
    
    [self setMaxPoints:newTotal forPlayer:currentPlayer];
}

-(void) setMaxPoints:(NSInteger)newTotal forPlayer:(NSString*)playerName
{
    NSString *maxPointsKey = [NSString stringWithFormat:@"%@%@", playerName, PLAYER_MAXPOINTS_KEY_SUFFIX];
    NSInteger currentMax = [[NSUserDefaults standardUserDefaults] integerForKey:maxPointsKey];
    
    if (newTotal > currentMax)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:newTotal forKey:maxPointsKey];
    }
}

-(void) addPlayerToSceneWithSize:(CGSize)size
{
    self.paddle = [SKSpriteNode spriteNodeWithImageNamed:@"art.scnassets/paddle_slim"];
    self.paddle.position = CGPointMake(size.width/2, PADDLE_Y_POSITION);
    self.paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.paddle.frame.size];
    self.paddle.physicsBody.dynamic = NO;
    self.paddle.physicsBody.categoryBitMask = PADDLE_CATEGORY;
    [self.paddle setScale:self.sceneSetup.paddleScalingFactor];
    
    [self addChild:self.paddle];
}

-(void) addBricksToSceneWithSize:(CGSize)size
{
    IGAppDelegate *appDelegate = (IGAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    int brickRows = (appDelegate.currentLevel < 2) ? 2 : 3;
    int verticalSpacer = 7;
    
    for (int k = 0; k < brickRows; k++)
    {
        for (int i = 0; i < 4; i++)
        {
            SKSpriteNode *brick = [SKSpriteNode spriteNodeWithImageNamed:self.sceneSetup.brickImageName];
            brick.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:brick.frame.size];
            brick.physicsBody.dynamic = NO;
            brick.physicsBody.categoryBitMask = BRICK_CATEGORY;
            
            int yPos = size.height - (brick.frame.size.height * (k + 1) + (verticalSpacer * k));
            //NSLog(@"Brick y pos is %d with height %f", yPos, size.height);
            
            int xPos = size.width/5 * (i + 1);
        
            brick.position = CGPointMake(xPos, yPos);
        
            [self addChild:brick];
            self.numberOfVisibleBricks++;
        }
    }
}

-(void) addBottomEdgeToSceneWithSize:(CGSize)size
{
    SKNode *bottomEdge = [SKNode node];
    bottomEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0, 1) toPoint:CGPointMake(size.width, 1)];
    bottomEdge.physicsBody.categoryBitMask = BOTTOM_EDGE_CATEGORY;
    
    [self addChild:bottomEdge];
}

-(void) addPauseBtnToScene
{
    self.pauseBtn = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"art.scnassets/pauseButton_sm.png"]];
    self.pauseBtn.position = CGPointMake(20.0f + self.pauseBtn.frame.size.width / 2, 20.0f + self.pauseBtn.frame.size.height / 2);
    self.pauseBtn.name = @"pauseButton";
    self.pauseBtn.zPosition = 1.0;
    
    [self addChild:self.pauseBtn];
}

-(void) addHeartToScene
{
    SKSpriteNode *heart = [SKSpriteNode spriteNodeWithImageNamed:@"art.scnassets/heart_sm.png"];
    heart.position = CGPointMake(self.frame.size.width - 40.0f - heart.frame.size.width / 2, 20.0f + heart.frame.size.height / 2);
    
    [self addChild:heart];
}

-(void) addLivesCountToScene
{
    SKLabelNode *livesCountLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
    
    NSString *currentPlayer = ((IGAppDelegate*)[[UIApplication sharedApplication] delegate]).currentPlayer;
    NSInteger currentLives = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@%@", currentPlayer, PLAYER_LIVES_KEY_SUFFIX]];
    
    livesCountLabel.text = [NSString stringWithFormat:@"%ld", (long)currentLives];
    
    livesCountLabel.fontColor = [SKColor blueColor];
    livesCountLabel.fontSize = 35;
    livesCountLabel.position = CGPointMake(self.frame.size.width - 30.0f, 30.0f);
    
    [self addChild:livesCountLabel];
}

-(void) addPointsCountToScene
{
    self.pointsCountLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura Medium"];
    
    self.pointsCountLabel.fontColor = [SKColor greenColor];
    self.pointsCountLabel.fontSize = 30;
    self.pointsCountLabel.position = CGPointMake(CGRectGetMidX(self.frame), 30.0f);
    
    NSString *currentPlayer = ((IGAppDelegate*)[[UIApplication sharedApplication] delegate]).currentPlayer;
    NSInteger currentPoints = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@%@", currentPlayer, PLAYER_POINTS_KEY_SUFFIX]];
    
    self.pointsCountLabel.text = [NSString stringWithFormat:@"%ld",(long)currentPoints];
    
    [self addChild:self.pointsCountLabel];
}

-(void) touchesMoved:(NSSet*)touches withEvent:(UIEvent *)event
{
    if (!self.isGamePaused) {
        for (UITouch *touche in touches)
        {
            CGPoint location = [touche locationInNode:self];
            CGPoint  newPosition = CGPointMake(location.x, 100);
            
            if (newPosition.x < self.paddle.frame.size.width/2)
            {
                newPosition.x = self.paddle.frame.size.width/2;
            }
            
            if (newPosition.x > self.frame.size.width - self.paddle.frame.size.width/2)
            {
                newPosition.x = self.frame.size.width - self.paddle.frame.size.width/2;
            }
            
            self.paddle.position = newPosition;
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if (!self.isBallStarted) {
        NSLog(@"Velocity before starting is dx: %f and dy: %f", self.ball.physicsBody.velocity.dx, self.ball.physicsBody.velocity.dy);
        [self giveBallInitialImpulse];
        self.isBallStarted = YES;
        NSLog(@"Now the velocity after starting is dx: %f and dy: %f", self.ball.physicsBody.velocity.dx, self.ball.physicsBody.velocity.dy);
    }
    
    if ([node.name isEqualToString:@"pauseButton"])
    {
        if (!self.isGamePaused) //pausing game
        {
            self.pauseBtn.texture = [SKTexture textureWithImageNamed:@"art.scnassets/playButton_sm.png"];
            
            NSLog(@"Game paused...");
            self.isGamePaused = YES;
            
            self.paused = YES;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:GAME_PAUSED_NOTIFICATION object:self]; //alert menu will pop
        }
        else //re-starting game
        {
            self.paused = NO;
            
            self.pauseBtn.texture = [SKTexture textureWithImageNamed:@"art.scnassets/pauseButton_sm.png"];
            
            NSLog(@"Game re-started...");
            self.isGamePaused = NO;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:GAME_RESUMED_NOTIFICATION object:nil];
        }
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    //NSLog(@"Update called with current time %f", currentTime);
}

-(void)registerAppTransitionObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:NULL];
}

-(void) applicationWillResignActive:(NSNotification*)notification
{
    NSLog(@"App will resign active");
    if (!self.isGamePaused)
    {
        self.paused = YES;
        self.isGamePaused = YES;
        self.pauseBtn.texture = [SKTexture textureWithImageNamed:@"art.scnassets/playButton_sm.png"];
    }
}

-(void) applicationDidEnterBackground:(NSNotification*)notification
{
    NSLog(@"App did enter background");
    
    self.view.paused = YES;
    
    //just in case I have this later: stop background music
    //just in case I have this later: - turned AVAudioSession off
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

-(void) applicationWillEnterForeground:(NSNotification*)notification
{
    NSLog(@"App will enter foreground");
    self.view.paused = NO;
    
    //TODO: refactor this so there is 1 method that does this
    self.paused = YES;
    self.isGamePaused = YES;
    self.pauseBtn.texture = [SKTexture textureWithImageNamed:@"art.scnassets/playButton_sm.png"];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GAME_PAUSED_NO_ALERT_NOTIFICATION object:self];
}

-(void) removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void) dealloc {
    NSLog(@"Deallocating the start scene");
    
    [self removeAllActions];
    //[self removeAllChildren];
    [self.view removeFromSuperview];
    [self removeFromParent];
}

-(id) retrieveSceneSetup
{
    return self.sceneSetup;
}

@end
