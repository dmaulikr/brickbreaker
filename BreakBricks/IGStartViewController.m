//
//  IGStartViewController.m
//  BreakBricks
//
//  Created by Rich Rosiak on 1/21/16.
//  Copyright © 2016 Rich Rosiak. All rights reserved.
//

#import "IGStartViewController.h"

@implementation IGStartViewController

-(void) viewDidLoad
{
    self.navigationController.navigationBar.hidden = YES;
}

- (IBAction)selectPlayer:(id)sender
{
    [self performSegueWithIdentifier:@"SelectPlayerSegue" sender:self];
}

- (IBAction)showLeaderBoard:(id)sender
{
    [self performSegueWithIdentifier:@"LeaderBoardSegue" sender:self];
}

@end
