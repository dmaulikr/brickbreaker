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

-(void) setupSceneForFrameHeight:(NSInteger)frameHeight {
    
    NSLog(@"The frame heght is %ld", (long)frameHeight);
    
    self.sceneSetup = [IGSceneSetup new];
    
    switch (frameHeight) {
        case 480: //iPhone 4 or less
            self.sceneSetup.cloudScalingFactor = 0.4f;
            self.sceneSetup.firstSceneBackgroundScalingFactor = 0.6f;
            self.sceneSetup.cloudyBackgroundScalingFactor = 0.6f;
            self.sceneSetup.brickImageName = @"art.scnassets/redBrick";
            self.sceneSetup.ballSpeedScalingFactor = 0.7f;
            self.sceneSetup.tankBackScalingFactor = 0.4f;
            break;
        case 568: //iPhone 5
            self.sceneSetup.cloudScalingFactor = 0.5f;
            self.sceneSetup.firstSceneBackgroundScalingFactor = 0.7f;
            self.sceneSetup.cloudyBackgroundScalingFactor = 0.7f;
            self.sceneSetup.brickImageName = @"art.scnassets/redBrick";
            self.sceneSetup.ballSpeedScalingFactor = 1.0f;
            self.sceneSetup.tankBackScalingFactor = 0.5f;
            break;
        case 667: //iPhone 6
            self.sceneSetup.cloudScalingFactor = 0.7f;
            self.sceneSetup.firstSceneBackgroundScalingFactor = 0.8f;
            self.sceneSetup.cloudyBackgroundScalingFactor = 0.9f;
            self.sceneSetup.brickImageName = @"art.scnassets/redBrick";
            self.sceneSetup.ballSpeedScalingFactor = 1.3f;
            self.sceneSetup.tankBackScalingFactor = 0.5f;
            break;
        case 763: //iPhone 6 Plus
            self.sceneSetup.cloudScalingFactor = 0.8f;
            self.sceneSetup.firstSceneBackgroundScalingFactor = 0.9f;
            self.sceneSetup.cloudyBackgroundScalingFactor = 1.1f;
            self.sceneSetup.brickImageName = @"art.scnassets/redBrick";
            self.sceneSetup.ballSpeedScalingFactor = 1.5f;
            self.sceneSetup.tankBackScalingFactor = 0.6f;
            break;
        case 1024: //iPad
            self.sceneSetup.cloudScalingFactor = 1.0f;
            self.sceneSetup.firstSceneBackgroundScalingFactor = 1.3f;
            self.sceneSetup.cloudyBackgroundScalingFactor = 1.6f;
            self.sceneSetup.brickImageName = @"art.scnassets/redBrick_iPad";
            self.sceneSetup.ballScalingFactor = 2.0f;
            self.sceneSetup.paddleScalingFactor = 2.0f;
            self.sceneSetup.ballSpeedScalingFactor = 2.0f;
            self.sceneSetup.tankBackgroundImageName = @"art.scnassets/tanks_back_iPad.jpg";
            self.sceneSetup.tankBackScalingFactor = 0.6f;
            break;
        default:
            self.sceneSetup.cloudScalingFactor = 1.0f;
            self.sceneSetup.firstSceneBackgroundScalingFactor = 1.3f;
            self.sceneSetup.cloudyBackgroundScalingFactor = 1.6f;
            self.sceneSetup.brickImageName = @"art.scnassets/redBrick_iPad";
            self.sceneSetup.ballScalingFactor = 2.0f;
            self.sceneSetup.paddleScalingFactor = 2.0f;
            self.sceneSetup.ballSpeedScalingFactor = 2.0f;
            self.sceneSetup.tankBackgroundImageName = @"art.scnassets/tanks_back_iPad.jpg";
            self.sceneSetup.tankBackScalingFactor = 0.7f;
            break;
    }
}

@end
