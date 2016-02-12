//
//  IGLeaderBoardViewController.m
//  BreakBricks
//
//  Created by Rich Rosiak on 1/21/16.
//  Copyright © 2016 Rich Rosiak. All rights reserved.
//

#import "IGLeaderBoardViewController.h"
#import "IGPlayerViewController.h"
#import "IGPlayer.h"

@interface IGLeaderBoardViewController()

@property (nonatomic, strong) NSArray *players;
@property (nonatomic, strong) NSMutableArray *sortedPlayers;

@end

@implementation IGLeaderBoardViewController

-(void) viewDidLoad
{
    self.leaderTable.dataSource = self;
    self.leaderTable.delegate = self;
    
    [self sortPlayersByMaxScore];
}

-(void) sortPlayersByMaxScore
{
    self.players = [[NSUserDefaults standardUserDefaults] objectForKey:PLAYERS_KEY];
    self.sortedPlayers = [NSMutableArray new];
    
    for (NSString *playerName in self.players)
    {
        IGPlayer *playerObj = [IGPlayer new];
        playerObj.name = playerName;
        playerObj.maxPoints = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@%@", playerName, PLAYER_MAXPOINTS_KEY_SUFFIX]];
        
        [self.sortedPlayers addObject:playerObj];
    }
    
    self.sortedPlayers = (NSMutableArray*)[self.sortedPlayers sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                            IGPlayer *player1 = (IGPlayer*)obj1;
                            IGPlayer *player2 = (IGPlayer*)obj2;
        
                            if (player1.maxPoints < player2.maxPoints)
                            {
                                return (NSComparisonResult)NSOrderedDescending; //this will make sure it'll sort in a descending order
                            }
        
                            if (player1.maxPoints > player2.maxPoints )
                            {
                                return  (NSComparisonResult)NSOrderedAscending;
                            }
        
                            return (NSComparisonResult)NSOrderedSame;
                        }];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // return number of rows
    return [self.players count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    // Set up the cell...
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:20];
    IGPlayer *playerObj = [self.sortedPlayers objectAtIndex:indexPath.row];
    cell.textLabel.text = playerObj.name;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",(long)playerObj.maxPoints];
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // handle table view selection
}

- (IBAction)cancelLeaderBoard:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
