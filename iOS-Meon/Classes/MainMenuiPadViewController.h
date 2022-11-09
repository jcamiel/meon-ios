//
//  MainMenuiPadViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/17/12.
//  Copyright (c) 2012 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OptionsiPadViewController.h"
#import "ModaliPadViewController.h"
#import "GameManager.h"
#import "TimeAttackiPadViewController.h"
@protocol MainMenuiPadViewControllerDelegate;


@interface MainMenuiPadViewController : UIViewController<ModaliPadViewControllerDelegate,
                                        TimeAttackiPadViewControllerDelegate>

- (void)dismissViewController;

@property(nonatomic, weak) id<MainMenuiPadViewControllerDelegate> delegate;
@property(nonatomic, strong) UIView *logoView;
@property(nonatomic, strong) GameManager *gameManager;

- (IBAction)playClassic:(id)sender;
- (IBAction)playTimeAttack:(id)sender;
- (IBAction)showHighscores:(id)sender;
- (IBAction)showOptions:(id)sender;
- (IBAction)rate:(id)sender;


@end


@protocol MainMenuiPadViewControllerDelegate

- (void)mainMenuiPadDidSelectPlayClassic:(MainMenuiPadViewController*)controller;
- (void)mainMenuiPadDismissAnimationDidFinish:(MainMenuiPadViewController*)controller;
- (void)mainMenuiPadDidSelectPlayFlash:(MainMenuiPadViewController*)controller;
- (void)mainMenuiPadDidSelectPlayMedium:(MainMenuiPadViewController*)controller;
- (void)mainMenuiPadDidSelectPlayMarathon:(MainMenuiPadViewController*)controller;
- (void)mainMenuiPadDidSelectBuyFullVersion:(MainMenuiPadViewController*)controller;

@end
