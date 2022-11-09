//
//  PlayViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/2/10.
//  Copyright 2010 Manbolo. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

#import "AchievementViewController.h"
#import "CMShareViewController.h"
#import "GameOverViewController.h"
#import "SolverViewController.h"
#import "THLabel.h"
#import "TapToContinueAnimator.h"
#import "TutorialViewController.h"
#import "CMGotoViewController.h"


@class GameManager, GroundView, CMBitmapNumberView, Sprite;
@class GameOverViewController, AchievementViewController, SolverAnimator, SloganAnimator;
@class StartAnimator, CompletedAnimator, HintsAnimator;
@protocol PlayViewControllerDelegate, GotoViewControllerDelegate;

@interface PlayViewController : UIViewController<TutorialViewControllerDelegate,
                                                 CMGotoViewControllerDelegate,
                                                 GameOverViewControllerDelegate,
                                                 AchievementViewControllerDelegate,
                                                 SolverViewControllerDelegate>


@property (nonatomic, strong) CMBitmapNumberView *solverCountView;
@property (nonatomic, strong) IBOutlet UIButton *buyButton;
@property (nonatomic, strong) IBOutlet UIImageView *pointsView;
@property (nonatomic, strong) IBOutlet UIImageView *levelTxtView;
@property (nonatomic, strong) THLabel *scoreLabel;
@property (nonatomic, strong) GameManager *gameManager;
@property (nonatomic, strong) IBOutlet GroundView *groundView;
@property (nonatomic, strong) CMBitmapNumberView *levelView;
@property (nonatomic, weak) id<PlayViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet CMBitmapNumberView *counterView;
@property (nonatomic, strong) TutorialViewController *tutorialViewController;
@property (nonatomic, strong) IBOutlet UIButton *gotoButton;
@property (nonatomic, strong) IBOutlet UIButton *hintsButton;
@property (nonatomic, strong) IBOutlet UIButton *solverButton;
@property (nonatomic, strong) GameOverViewController *gameOverViewController;
@property (nonatomic, strong) AchievementViewController *achievementViewController;
@property (nonatomic, strong) IBOutlet UIButton *tweetButton;
@property (nonatomic, strong) UIImageView *rasterizedGroundView;
@property (nonatomic, strong) CMShareViewController *shareViewController;
@property (nonatomic, assign, readonly) CGFloat groundViewScale;


- (IBAction)back:(id)sender;
- (IBAction)forward:(id)sender;
- (IBAction)last:(id)sender;
- (IBAction)menu:(id)sender;
- (IBAction)hints:(id)sender;
- (IBAction)goTo:(id)sender;
- (IBAction)showSolution:(id)sender;
- (IBAction)buy:(id)sender;
- (void)loadLevel:(NSUInteger)level;


@end


@protocol PlayViewControllerDelegate
- (void)playDidSelectMenu:(PlayViewController *)controller;
- (void)playDidFinishGame:(PlayViewController *)controller;
- (void)playDidSelectBuy:(PlayViewController *)controller;
- (void)playDidFinishWorldLevel:(PlayViewController *)controller;
@end
