//
//  IGGameManager.m
//  BreakBricks
//
//  Created by Joanna Rosiak on 1/29/16.
//  Copyright © 2016 Rich Rosiak. All rights reserved.
//

#import "IGGameManager.h"

@implementation IGGameManager

+ (IGGameManager*) sharedInstance {
    static dispatch_once_t once;
    static IGGameManager *managerInstance;
    dispatch_once(&once, ^{
        managerInstance = [[IGGameManager alloc] init];
    });
    
    return managerInstance;
}

-(AVAudioPlayer*) createAudioPlayerForData:(NSData*)audioData {
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    NSError *error;
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
    
    if (!error) {
        return audioPlayer;
    }
    else {
        NSLog(@"Error occurred playing audio data file %@", error.description);
    }
    
    if (!audioPlayer) {
        NSLog(@"Error - Could not init audio player!");
        return nil;
    }
    
    return nil;
}

-(NSData*) retrieveDataForAudioFileName:(NSString*)audioFile
{
    NSData *soundData = nil;
    NSString *soundFile = [[NSBundle mainBundle] pathForResource:audioFile ofType:nil];
    
    NSLog(@"windSoundFile full path is %@", soundFile);
    NSAssert(soundFile, @"No such file in mainBundle: %@", audioFile);
    soundData = [[NSData alloc] initWithContentsOfFile:soundFile];
    
    return soundData;
}

-(CGFloat) provideScaleFactorForHeight:(NSInteger)frameHeight {
    
    NSLog(@"The frame heght is %ld", (long)frameHeight);
    
    switch (frameHeight) {
        case 480: //iPhone 4 or less
            return 0.4f;
            break;
        case 568: //iPhone 5
            return 0.5f;
            break;
        case 667: //iPhone 6
            return 0.7f;
            break;
        default:
            return 1.0f;
            break;
    }
}

@end
