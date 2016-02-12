//
//  IGPlayerViewController.m
//  BreakBricks
//
//  Created by Rich Rosiak on 1/11/16.
//  Copyright © 2016 Rich Rosiak. All rights reserved.
//

#import "IGPlayerViewController.h"
#import "IGAppDelegate.h"

@interface IGPlayerViewController ()

@property (nonatomic, strong) UITextField *playerNameField;
@property (nonatomic, strong) UITableView *playersTable;
@property (nonatomic, strong) NSMutableArray *players;

@end

NSString *PLAYERS_KEY = @"brickBreakerPlayers";
NSString *PLAYER_POINTS_KEY_SUFFIX = @"_totalPoints";
NSString *PLAYER_MAXPOINTS_KEY_SUFFIX = @"_maxPoints";
NSString *PLAYER_LIVES_KEY_SUFFIX = @"_remainingLives";
NSString *PLAYER_LEVEL_KEY_SUFFIX = @"_currentLevel";

@implementation IGPlayerViewController

-(void) viewDidLoad
{
    self.view.backgroundColor = [UIColor blueColor];
    
    //Add label
    UILabel *playerName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 160.0f, CGRectGetMinY(self.view.frame) + 75, 150.0f, 35.0f)];
    playerName.text = @"Player Name:";
    playerName.font = [UIFont systemFontOfSize:25.0f];
    playerName.textColor = [UIColor whiteColor];
    [self.view addSubview:playerName];
    
    //Add player's name
    self.playerNameField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame), CGRectGetMinY(self.view.frame) + 75, self.view.frame.size.width/2 - 20, 25.0f)];
    //playerNameField.center = self.view.center;
    self.playerNameField.borderStyle = UITextBorderStyleRoundedRect;
    self.playerNameField.textColor = [UIColor blackColor];
    self.playerNameField.font = [UIFont systemFontOfSize:17.0];
    self.playerNameField.placeholder = @"Enter player name here";
    //playerNameField.backgroundColor = [UIColor whiteColor];
    //playerNameField.autocorrectionType = UITextAutocorrectionTypeYes;
    self.playerNameField.keyboardType = UIKeyboardTypeDefault;
    self.playerNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.playerNameField.delegate = self; //self.delegate;
    [self.view addSubview:self.playerNameField];
    
    //Add Save button
    UIButton *savePlayerButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 65, CGRectGetMinY(self.view.frame) + 120, 130.0f, 40.0f)];
    savePlayerButton.titleLabel.font = [UIFont systemFontOfSize:25.0f];
    [savePlayerButton addTarget:self action:@selector(savePlayer:) forControlEvents:UIControlEventTouchUpInside];
    [savePlayerButton setTitle:@"Save Player" forState:UIControlStateNormal];
    [savePlayerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    savePlayerButton.userInteractionEnabled = YES;
    [self.view addSubview:savePlayerButton];
    
    //Add Back button
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.view.frame) + 20.0f, CGRectGetMinY(self.view.frame) + 20.0f, 80.0f, 40.0f)];
    backButton.titleLabel.font = [UIFont systemFontOfSize:20.0f];
    [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backButton.userInteractionEnabled = YES;
    [self.view addSubview:backButton];
    
    //Add table view
    self.playersTable = [[UITableView alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame) - 120, CGRectGetMinY(self.view.frame) + 180, 240.0f, 300.0f) style:UITableViewStylePlain];
    
    self.playersTable.dataSource = self;
    self.playersTable.delegate = self;
    [self.view addSubview:self.playersTable];
    
    self.players = [[[NSUserDefaults standardUserDefaults] objectForKey:PLAYERS_KEY] mutableCopy];
    if (!self.players) {
        self.players = [NSMutableArray new];
    }
    
    [self registerForKeyboardNotifications]; //may not need this
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self deRegisterForKeyboardNotifications];
}

-(void) savePlayer:(id)sender
{
    if (![self isPlayerValid:self.playerNameField.text])
    {
        return; //nothing to save
    }
    
    NSLog(@"Saving player %@: ", self.playerNameField.text);
    
    [self.players addObject:self.playerNameField.text];
    [[NSUserDefaults standardUserDefaults] setObject:self.players forKey:PLAYERS_KEY];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"%@%@",self.playerNameField.text, PLAYER_POINTS_KEY_SUFFIX]];
    [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:[NSString stringWithFormat:@"%@%@",self.playerNameField.text, PLAYER_LIVES_KEY_SUFFIX]];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[NSString stringWithFormat:@"%@%@",self.playerNameField.text, PLAYER_MAXPOINTS_KEY_SUFFIX]];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.playersTable reloadData];
    
    [self.view endEditing:YES]; //hides keyboard
    self.playerNameField.text = nil;
}

-(BOOL) isPlayerValid:(NSString*)playerName
{
    if (!playerName || [playerName isEqualToString:@""])
    {
        return NO;
    }
    
    if ([self.players containsObject:playerName])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Duplicate player"
                                                        message:@"Another player already has this name. Please pick a different name."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return NO;
    }
    
    return YES;
}

-(void) goBack:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Set up the cell...
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:20];
    cell.textLabel.text = [self.players objectAtIndex:[indexPath row]]; //[NSString  stringWithFormat:@"Cell Row #%ld", (long)[indexPath row]];
    
    return cell;

}

// Swipe to delete.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSString *playerToDelete = [self.players objectAtIndex:indexPath.row];
        NSLog(@"Deleting player %@ with his points, max points, levels and lives", playerToDelete);
        [self.players removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.players forKey:PLAYERS_KEY]; //after players' array has been adjusted
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",playerToDelete, PLAYER_POINTS_KEY_SUFFIX]];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",playerToDelete, PLAYER_MAXPOINTS_KEY_SUFFIX]];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",playerToDelete, PLAYER_LIVES_KEY_SUFFIX]];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",playerToDelete, PLAYER_LEVEL_KEY_SUFFIX]];
    }
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // handle table view selection
    NSString *gamePlayer = [self.players objectAtIndex:[indexPath row]];
    NSLog(@"Selected table row %ld - will start game as player: %@", (long)[indexPath row], gamePlayer);
    
    IGAppDelegate *appDelegate = (IGAppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.currentPlayer = gamePlayer;
    appDelegate.currentLevel = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@%@",gamePlayer, PLAYER_LEVEL_KEY_SUFFIX]];
    
    [self performSegueWithIdentifier:@"startGameSegue" sender:self];
}

-(void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void) deRegisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void) keyboardWasShown:(NSNotificationCenter*)aNotification
{
    NSLog(@"Keyboard was shown");
}

-(void) keyboardWillHide:(NSNotificationCenter*)aNotification
{
    NSLog(@"Keyboard will hide");
}

@end
