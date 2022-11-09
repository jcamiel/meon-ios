//
//  MainMenuViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/7/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GameKit/GameKit.h>

@class GameManager;
@protocol MainMenuViewControllerDelegate;

@interface MainMenuViewController : UIViewController

@property (nonatomic, weak) id<MainMenuViewControllerDelegate> delegate;
@property (nonatomic, strong) GameManager *gameManager;
@property (nonatomic, strong) UIButton *trophiesButton;

- (IBAction)playClassic:(id)sender;
- (IBAction)playTimeAttack:(id)sender;
- (IBAction)showScores:(id)sender;
- (IBAction)showOptions:(id)sender;
- (IBAction)buyFullVersion:(id)sender;
- (IBAction)showAchievements:(id)sender;
- (IBAction)rate:(id)sender;
- (IBAction)showEditor:(id)sender;

@end



@protocol MainMenuViewControllerDelegate

- (void)mainMenuDidSelectPlayClassic:(MainMenuViewController*)controller;
- (void)mainMenuDidSelectTimeAttack:(MainMenuViewController*)controller;
- (void)mainMenuDidSelectShowScores:(MainMenuViewController*)controller;
- (void)mainMenuDidSelectShowOptions:(MainMenuViewController*)controller;
- (void)mainMenuDidSelectBuyFullVersion:(MainMenuViewController*)controller;
- (void)mainMenuDidSelectShowAchievements:(MainMenuViewController*)controller;
- (void)mainMenuDidSelectRate:(MainMenuViewController*)controller;
- (void)mainMenuDidSelectEditor:(MainMenuViewController*)controller;

@end

