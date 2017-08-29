//
//  ViewController.m
//  testButtonGrid
//
//  Created by Marcelo on 3/17/14.
//  Copyright (c) 2014 Marcelo Siqueira. All rights reserved.
//

#import "ViewController.h"
#import "gameButton.h"

@interface ViewController ()

@property (strong, nonatomic)GKLocalPlayer *player;
@property (strong, nonatomic)NSString *leaderboardID;
@property (nonatomic)int pointsNow;

@property (strong, nonatomic)UIActionSheet *popup;
@property (strong, nonatomic)NSMutableArray *imagesReferenceToPick;
@property (strong, nonatomic)NSMutableArray *allCardButtons;
@property (strong, nonatomic)gameButton *chosenCard1;
@property (strong, nonatomic)gameButton *chosenCard2;

- (void)chooseCard:(id)sender;
- (void)setButton:(CGFloat)xPos yPos:(CGFloat)yPos;

@end

@implementation ViewController

int totalCards = 60;
NSDate *gameStartTime = nil;
NSTimer *tryTimeout;
NSTimer *updateDisplayInterval;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //initialize userdefaults
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
    //iAd on
    self.canDisplayBannerAds = YES;
    
    //connect to game center
    self.player = nil;
    [self authenticatePlayer];
    
    //assign leaderboard
    self.leaderboardID = @"marcelo_siqueira_iMemoGame_mainboard";
    
	//will store references to the available images
    self.imagesReferenceToPick = [[NSMutableArray alloc] initWithCapacity:totalCards];
    
    //will store all cards(buttons)
    self.allCardButtons = [[NSMutableArray alloc] initWithCapacity:totalCards / 2];
    
    [self restartGame:self];
    
}

- (IBAction)restartGame:(id)sender {
    
    [updateDisplayInterval invalidate];
    gameStartTime = nil; //[NSDate date];
    [self updateTimeDisplay];
    self.timeDisplay.text = @"Time: 0 sec";
    self.pointsDisplay.text = @"Points: 1000";
    
    //reset game parameters
    self.chosenCard1 = nil;
    self.chosenCard2 = nil;
    for (gameButton *buttonNow in self.allCardButtons) buttonNow.isAlreadyMatched = NO;
    
    [self setCards];
    
}

- (IBAction)showGameCenter:(id)sender {
    
    if (self.popup) {
        
        [self.popup dismissWithClickedButtonIndex:3 animated:YES];
        return;
        
    }
    
    self.popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:
                            @"Share",
                            @"Game Center",
                            nil];
    self.popup.tag = 1;
    [self.popup showFromBarButtonItem:sender animated:YES];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    self.popup = nil;
    
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    [self share];
                    break;
                case 1:
                    [self showGameCenter2];
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void)share {
    
    NSString *text = @"\n\niMemoGame - The memory game for iOS";
    NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/app/id843762551"];
    NSArray *items = @[text, url];
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    
    [self presentViewController:vc animated:YES completion:nil];
    
}


- (void)showGameCenter2 {
    
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
    if (gameCenterController != nil) {
        
        gameCenterController.gameCenterDelegate = self;
        [self presentViewController:gameCenterController animated:YES completion:nil];
        
    }
    
}


- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)gameOver:(int)score {

    [updateDisplayInterval invalidate];
    gameStartTime = nil;
    
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        
        [self getScore:score];
        
    } else {
        
        NSLog(@"player not authenticated");
        
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over"
                                                    message:[NSString stringWithFormat:@"%@ \n%@", self.timeDisplay.text, self.pointsDisplay.text]
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    
//NSLog(@"game over");
}

- (void)setCards {
    
    //remove previous cards
    for (UIView *subView in self.view.subviews)
    {
        
        if ([subView isKindOfClass:[gameButton class]])
        {
            [subView removeFromSuperview];
        }
        
    }
    
    int gridCollums = 10;
    int gridRows = 6;
    CGFloat buttonWidth = 90.0;
    CGFloat buttonHeight = 90.0;
    CGFloat startX = 40.0;
    CGFloat startY = -10.0;
    CGFloat xPos = 0.0;
    CGFloat yPos = 0.0;
    CGFloat gridGap = 5.0;
    
    //load references for images to be picked
    for (int i = 1; i <= 30; i++) {
        
        [self.imagesReferenceToPick addObject:[NSString stringWithFormat:@"%d", i]];
        [self.imagesReferenceToPick addObject:[NSString stringWithFormat:@"%d", i]];
        
    }
    
    //create and position cards(buttons)
    for (int i = 0; i <= (gridCollums - 1); i++) {
        
        for (int j = 1; j <= gridRows; j++) {
            
            xPos = startX + (i * (buttonWidth + gridGap));
            yPos = startY + (j * (buttonHeight + gridGap));
            
            [self setButton:xPos yPos:yPos];

        }
        
    }
    
}

- (void)setButton:(CGFloat)xPos yPos:(CGFloat)yPos {
    
    //pick random image from store
    int randomPosInArray = arc4random_uniform([self.imagesReferenceToPick count]);
    NSString *randomlyExtractedIndex = [self.imagesReferenceToPick objectAtIndex:randomPosInArray];
    [self.imagesReferenceToPick removeObjectAtIndex:randomPosInArray];
    NSString *randomImageNameString = [NSString stringWithFormat:@"card%@.png", randomlyExtractedIndex];
    UIImage *imageNow = [UIImage imageNamed: randomImageNameString];
    
    gameButton *button = [[gameButton alloc] initWithId:randomlyExtractedIndex];
    
    [button addTarget:self
            action:@selector(chooseCard:)
            forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:imageNow forState:UIControlStateNormal];
    [button setBackgroundImage:imageNow forState:UIControlStateDisabled];
    button.frame = CGRectMake(xPos, yPos, 90.0, 90.0);
    
    [self.allCardButtons addObject:button];
    [self.view addSubview:button];
//button.cardCoverView.alpha = 0.5f;
}

- (void)chooseCard:(gameButton *)sender {
    
    //if first try set game timer
    if (!gameStartTime) {

        gameStartTime = [NSDate date];
        updateDisplayInterval = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimeDisplay) userInfo:nil repeats:YES];
        
    }
    
    //if (tryTimeout) [tryTimeout fire];

    //uncover and disable the selected card
    [sender setEnabled:NO];
    [sender.cardCoverView setHidden:YES];
    
    //first card try
    if (!self.chosenCard1) {
        
        self.chosenCard1 = sender;
        
    } else { //second card try
        
        self.chosenCard2 = sender;

        //process result after opening the second card
        [self processChosenCards:self.chosenCard1 card2:self.chosenCard2];
        
    }
    
}

- (void)processChosenCards:(gameButton *)card1 card2:(gameButton *)card2 {
    
    [self disableButtons:YES];
    
    BOOL cardsDoMatch = [card1.cardIndex isEqualToString:card2.cardIndex];

    if (cardsDoMatch) {
        
        //register cards as matched
        card1.isAlreadyMatched = YES;
        card2.isAlreadyMatched = YES;
        
        [self disableButtons:NO]; //and check if game has ended
        
    } else {
        
        //close unmatched cards after a while
        tryTimeout = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(finishMissingTry) userInfo:nil repeats:NO];
        
    }
    
    //reset tries
    self.chosenCard1 = nil;
    self.chosenCard2 = nil;
    
}

//after an unmatched try
- (void)finishMissingTry {

    //close only the unmatched cards
    for (gameButton *buttonNow in self.allCardButtons) {
        
        if ([buttonNow.cardCoverView isHidden] && !buttonNow.isAlreadyMatched) {
            
            [buttonNow.cardCoverView setHidden:NO];
            
        }
        
    }
    
    //reactivate (closed) cards
    [self disableButtons:NO];
    
}

//enable or disable unmatched cards and check if game has ended
- (void)disableButtons:(BOOL)buttonMode {
    
    int matchesCounter = 0;
    
    for (gameButton *buttonNow in self.allCardButtons) {
        
        if (!buttonNow.isAlreadyMatched) {
            
            [buttonNow setEnabled:!buttonMode];
            
        } else {
            
            matchesCounter++;
            
        }
        
    }

    if (buttonMode == NO && matchesCounter == totalCards) [self gameOver:self.pointsNow];
//if (buttonMode == NO && matchesCounter == 4) [self gameOver:self.pointsNow];
}

- (void)updateTimeDisplay {
    
    //if (!gameStartTime) gameStartTime = [NSDate date];
    
    NSDate *gameEndTime = [NSDate date];
    NSTimeInterval gameTime = [gameEndTime timeIntervalSinceDate:gameStartTime];
    self.timeDisplay.text = [NSString stringWithFormat:@"Time: %d sec", (int)gameTime];
    
    self.pointsNow = 1000 - (int)gameTime;
    self.pointsNow = self.pointsNow > 0 ? self.pointsNow : 0;
    self.pointsDisplay.text = [NSString stringWithFormat:@"Points: %d", self.pointsNow];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setPlayer:(GKLocalPlayer *)player {
    
    _player = player;
    NSString *playerName;
    
    if (_player) {
        
        playerName = _player.alias;
        
    } else {
        
        playerName = @"Anonymous";
        
    }
    
    //self.playerLabel.text = [NSString stringWithFormat:@"Player: %@", playerName];
    
}

- (void)authenticatePlayer {

    __weak GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    localPlayer.authenticateHandler = ^(UIViewController *authenticateViewController, NSError *error) {
        
        if (authenticateViewController != nil) {
            
            [self presentViewController:authenticateViewController animated:YES completion:nil];
            
        } else if (localPlayer.isAuthenticated) {
            
            self.player = localPlayer;
            
        } else {
            
            //disable game center
            self.player = nil;
            
        }
        
    };
    
}

- (void)reportScore:(int64_t)score forLeaderboard:(NSString *)leaderboardID {
    
    GKScore *gameCenterScore = [[GKScore alloc] initWithLeaderboardIdentifier:leaderboardID];
    gameCenterScore.value = score;
    gameCenterScore.context = 0;
    
    NSArray *scoresArray = [[NSArray alloc] initWithObjects:gameCenterScore, nil];
NSLog(@"report sent: %@", [scoresArray description]);
    [GKScore reportScores:scoresArray withCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Error reporting score: %@", error);
        }
    }];

}

- (void)getScore:(int)gameScore {
    
    //scores unsent due to errors
    __block int accumulatedScoreTosend = (int)[self.userDefaults integerForKey:@"scoreToSend"];
    
    //add unsent scores to present score
    gameScore += accumulatedScoreTosend;
    
    GKLeaderboard *board = [[GKLeaderboard alloc] initWithPlayerIDs:@[self.player.playerID]];
    board.timeScope = GKLeaderboardTimeScopeAllTime;
    board.identifier = self.leaderboardID;
NSLog(@"on getScore: %@", [board description]);
    [board loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
        
        //score not sent
        if (error) {
            
            //save total unsent scores in userDefaults
            [self.userDefaults setInteger:gameScore forKey:@"scoreToSend"];
            
            NSLog(@"Error loading leaderbord - score saved: %d", gameScore);
            
        } else { //score sent to game center
            
            NSString *playerId = [NSString stringWithFormat:@"%@", self.player.playerID];

            //find player in leaderboard
            for (int i = 0; i < [scores count]; i++) {
                
                GKScore *scoreNow = scores[i];
                NSString *foundPlayerId = [NSString stringWithFormat:@"%@", scoreNow.playerID];

                if ([foundPlayerId isEqualToString:playerId]) {
                    
                    //get present score
                    self.scoreValueNow = (int)scoreNow.value;
                    break;
                    
                } else {
                    
                    self.scoreValueNow = 0;
                    
                }
                
            }
            
            //add all unsent scores
            int totalScoreNow = self.scoreValueNow + gameScore;
            
            //update game center
            [self reportScore:totalScoreNow forLeaderboard:self.leaderboardID];
            
            //reset unsent scores
            [self.userDefaults setInteger:0 forKey:@"scoreToSend"];
NSLog(@"Updated score: %d / unsent: %ld", totalScoreNow, (long)[self.userDefaults integerForKey:@"scoreToSend"]);
        }
        
    }];
    
}

@end













































