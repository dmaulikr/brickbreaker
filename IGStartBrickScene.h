//
//  IGStartBrickScene.h
//  BreakBricks
//
//  Created by Rich Rosiak on 1/5/16.
//  Copyright © 2016 Rich Rosiak. All rights reserved.
//

//#import <SceneKit/SceneKit.h>
#import <SpriteKit/SpriteKit.h>

extern const uint32_t BALL_CATEGORY;
extern const uint32_t EDGE_CATEGORY;
extern const uint32_t BRICK_CATEGORY;
extern const uint32_t PADDLE_CATEGORY;
extern const uint32_t SIDE_CANNON_BALL_CATEGORY;

extern const CGFloat PADDLE_Y_POSITION;

extern NSString *GAME_PAUSED_NOTIFICATION;
extern NSString *GAME_RESUMED_NOTIFICATION;
extern NSString *GAME_PAUSED_NO_ALERT_NOTIFICATION;
extern NSString *CLOUD_CREATED;
extern NSString *LEVEL_ENDED_NOTIFICATION;

@interface IGStartBrickScene : SKScene <SKPhysicsContactDelegate>

@property (nonatomic, assign) NSUInteger numberOfVisibleBricks;
@property (nonatomic, strong) SKSpriteNode *ball;
@property (nonatomic, strong) SKNode *notTheBall;

@end
