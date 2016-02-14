//
//  GameViewController.m
//  BreakBricks
//
//  Created by Rich Rosiak on 1/5/16.
//  Copyright (c) 2016 Rich Rosiak. All rights reserved.
//

#import "IGGameViewController.h"
#import "IGStartBrickScene.h"
#import "IGAppDelegate.h"
#import "IGFifthLevelScene.h"
#import "IGPlayerViewController.h"
//#import "IGSixthLevelScene.h"
#import "IGGameManager.h"

#import "BreakBricks-Swift.h"

@implementation IGGameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    IGAppDelegate *appDelegate = (IGAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"Entering game as player %@ on level %ld", appDelegate.currentPlayer, (long)appDelegate.currentLevel);
    
    if (appDelegate.currentLevel == 0)
    {
        appDelegate.currentLevel = 1;
    }
    
    NSLog(@"Will set up scene for device height: %f", self.view.frame.size.height);
    [[IGGameManager sharedInstance] setupSceneForFrameHeight:self.view.frame.size.height];
    
    appDelegate.currentLevel = 6; //debugging - to be removed when done
    //[[NSUserDefaults standardUserDefaults] setInteger:3 forKey:[NSString stringWithFormat:@"%@%@", appDelegate.currentPlayer, PLAYER_LIVES_KEY_SUFFIX]]; //for debugging - to be removed when done

    // create a new scene
    /*SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/ship.scn"];

    // create and add a camera to the scene
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    [scene.rootNode addChildNode:cameraNode];
    
    // place the camera
    cameraNode.position = SCNVector3Make(0, 0, 15);
    
    // create and add a light to the scene
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.position = SCNVector3Make(0, 10, 10);
    [scene.rootNode addChildNode:lightNode];
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor darkGrayColor];
    [scene.rootNode addChildNode:ambientLightNode];
    
    // retrieve the ship node
    SCNNode *ship = [scene.rootNode childNodeWithName:@"ship" recursively:YES];
    
    // animate the 3d object
    [ship runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // set the scene to the view
    scnView.scene = scene;
    
    // allows the user to manipulate the camera
    scnView.allowsCameraControl = YES;
        
    // show statistics such as fps and timing information
    scnView.showsStatistics = YES;

    // configure the view
    scnView.backgroundColor = [UIColor blackColor];
    
    // add a tap gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    NSMutableArray *gestureRecognizers = [NSMutableArray array];
    [gestureRecognizers addObject:tapGesture];
    [gestureRecognizers addObjectsFromArray:scnView.gestureRecognizers];
    scnView.gestureRecognizers = gestureRecognizers;*/
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gamePaused:)
                                                 name:GAME_PAUSED_NOTIFICATION
                                               object:nil];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    //skView.showsFPS = YES;
    //skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene *gameScene;
    
    switch (appDelegate.currentLevel) {
        case 1:
        case 2:
        case 3:
        case 4:
            gameScene = [IGStartBrickScene sceneWithSize:skView.bounds.size];
            break;
        case 5:
            gameScene = [IGFifthLevelScene sceneWithSize:skView.bounds.size];
            break;
        case 6:
            gameScene = [IG6LevelScene sceneWithSize:skView.bounds.size];
            break;
        case 7:
            gameScene = [IGSeventhLevelScene sceneWithSize:skView.bounds.size];
            break;
        default:
            gameScene = [IGSeventhLevelScene sceneWithSize:skView.bounds.size]; //currently max level to play
            break;
    }
    
    gameScene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:gameScene];
}

-(void) gamePaused:(NSNotification*)notification
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Game Paused"
                                                                   message:@"What would you like to do next?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Continue in the game." style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    
    UIAlertAction *goBackAction = [UIAlertAction actionWithTitle:@"Go back to main menu." style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                            [self.navigationController popToRootViewControllerAnimated:YES];
                                                        }];
    [alert addAction:goBackAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GAME_PAUSED_NOTIFICATION object:nil];
}

/*
- (void) handleTap:(UIGestureRecognizer*)gestureRecognize
{
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // check what nodes are tapped
    CGPoint p = [gestureRecognize locationInView:scnView];
    NSArray *hitResults = [scnView hitTest:p options:nil];
    
    // check that we clicked on at least one object
    if([hitResults count] > 0){
        // retrieved the first clicked object
        SCNHitTestResult *result = [hitResults objectAtIndex:0];
        
        // get its material
        SCNMaterial *material = result.node.geometry.firstMaterial;
        
        // highlight it
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.5];
        
        // on completion - unhighlight
        [SCNTransaction setCompletionBlock:^{
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            
            material.emission.contents = [UIColor blackColor];
            
            [SCNTransaction commit];
        }];
        
        material.emission.contents = [UIColor redColor];
        
        [SCNTransaction commit];
    }
}
 */

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
