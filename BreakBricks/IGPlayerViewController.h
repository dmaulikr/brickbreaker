//
//  IGPlayerViewController.h
//  BreakBricks
//
//  Created by Rich Rosiak on 1/11/16.
//  Copyright © 2016 Rich Rosiak. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *PLAYERS_KEY;
extern NSString *PLAYER_POINTS_KEY_SUFFIX;
extern NSString *PLAYER_MAXPOINTS_KEY_SUFFIX;
extern NSString *PLAYER_LIVES_KEY_SUFFIX;
extern NSString *PLAYER_LEVEL_KEY_SUFFIX;

@interface IGPlayerViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@end
