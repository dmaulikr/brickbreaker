//
//  IGLeaderBoardViewController.h
//  BreakBricks
//
//  Created by Rich Rosiak on 1/21/16.
//  Copyright © 2016 Rich Rosiak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IGLeaderBoardViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *leaderTable;

@end
