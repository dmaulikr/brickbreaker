//
//  IGGameManager.h
//  BreakBricks
//
//  Created by Rich Rosiak on 1/29/16.
//  Copyright © 2016 Rich Rosiak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "BreakBricks-Swift.h"

/*
 Singleton class
 */
@interface IGGameManager : NSObject

+ (IGGameManager*) sharedInstance;

@property (nonatomic, strong) IGSceneSetup *sceneSetup;

-(AVAudioPlayer*) createAudioPlayerForData:(NSData*)audioData;

-(NSData*) retrieveDataForAudioFileName:(NSString*)audioFile;

-(void) setupSceneForFrameHeight:(NSInteger)frameHeight;

@end
