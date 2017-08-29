//
//  ViewController.h
//  testButtonGrid
//
//  Created by Marcelo on 3/17/14.
//  Copyright (c) 2014 Marcelo Siqueira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <iAd/iAd.h>

@interface ViewController : UIViewController <GKGameCenterControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIButton *restartButton;
@property (weak, nonatomic) IBOutlet UILabel *timeDisplay;
@property (weak, nonatomic) IBOutlet UILabel *pointsDisplay;

@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) int scoreValueNow;

- (IBAction)restartGame:(id)sender;
- (IBAction)showGameCenter:(id)sender;

@end
