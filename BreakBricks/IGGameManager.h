//
//  IGGameManager.h
//  BreakBricks
//
//  Created by Joanna Rosiak on 1/29/16.
//  Copyright © 2016 Rich Rosiak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/*
 Singleton class
 */
@interface IGGameManager : NSObject

+ (IGGameManager*) sharedInstance;

-(AVAudioPlayer*) createAudioPlayerForData:(NSData*)audioData;

-(NSData*) retrieveDataForAudioFileName:(NSString*)audioFile;

-(CGFloat) provideScaleFactorForHeight:(NSInteger)frameHeight;

@end
