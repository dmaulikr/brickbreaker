//
//  AppDelegate.h
//  BreakBricks
//
//  Created by Rich Rosiak on 1/5/16.
//  Copyright © 2016 Rich Rosiak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, assign) NSUInteger currentLevel;

@property (nonatomic, strong) NSString *currentPlayer;


@end

