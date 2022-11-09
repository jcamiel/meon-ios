//
//  PlayiPadViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 6/14/11.
//  Copyright 2011 Manbolo. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "AchievementViewController.h"
#import "AchievementsiPadViewController.h"
#import "CMGotoViewController.h"
#import "GameOverViewController.h"
#import "GotoiPadViewController.h"
#import "GroundViewController.h"
#import "SolveriPadViewController.h"
#import "TutorialViewController.h"

@protocol PlayiPadViewControllerDelegate;
@class GameManager, SloganAnimator, TapToContinueAnimator, HintsAnimator, SolverAnimator;
@class CMBitmapNumberView, StartAnimator, CompletedAnimator, CompletedGameAnimator;
@class CMShareViewController;

@interface PlayiPadViewController : UIViewController<GroundViewControllerDelegate,
                                                     AchievementViewControllerDelegate,
                                                     SolveriPadViewControllerDelegate,
                                                     TutorialViewControllerDelegate,
                                                     ModaliPadViewControllerDelegate,
                                                     CMGotoViewControllerDelegate,
                                                     GameOverViewControllerDelegate>

@property (nonatomic, strong) CMBitmapNumberView *levelView;
@property (nonatomic, strong) GroundViewController *groundViewController;
@property (nonatomic, strong) AchievementViewController *achievementViewController;
@property (nonatomic, strong) GameManager *gameManager;
@property (nonatomic, strong) SolverAnimator *solverAnimator;
@property (nonatomic, strong) StartAnimator *startAnimator;
@property (nonatomic, strong) CompletedAnimator *completedAnimator;
@property (nonatomic, strong) CompletedGameAnimator *completedGameAnimator;
@property (nonatomic, strong) UIImageView *levelTxtView;
@property (nonatomic, strong) UIImageView *logoView;
@property (nonatomic, strong) UIButton *gotoButton;
@property (nonatomic, strong) UIButton *solverButton;
@property (nonatomic, strong) UIButton *hintsButton;
@property (nonatomic, strong) UIButton *tweetButton;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UIButton *buyButton;
@property (nonatomic, strong) UIButton *achievementButton;
@property (nonatomic, strong) GotoiPadViewController *gotoController;
@property (nonatomic, weak) id<PlayiPadViewControllerDelegate> delegate;
@property (nonatomic, assign, getter = isTweetButtonEnabled) BOOL tweetButtonEnabled;
@property (nonatomic, strong) TutorialViewController *tutorialViewController;
@property (nonatomic, strong) UIView *bannerView;
@property (nonatomic, strong) CMBitmapNumberView *solverCountView;
@property (nonatomic, strong) CMBitmapNumberView *counterView;
@property (nonatomic, strong) GameOverViewController *gameOverViewController;
@property (nonatomic, strong) CMBitmapNumberView *scoreView;
@property (nonatomic, strong) CMShareViewController *shareViewController;



- (void)addMeonHeader;
- (void)setButtonsVisible:(BOOL) visible animated:(BOOL)animated;
- (void)setBannerViewVisibleAnimated:(BOOL)animated;
- (void)createGroundViewController;
- (void)layoutButtonsAnimated:(BOOL)animated;
- (void)setGroundViewVisibleAnimated:(BOOL)animated;


@end


@protocol PlayiPadViewControllerDelegate
- (void)playiPadDidTapMenu:(PlayiPadViewController *)controller;
- (void)playiPadDidFinishGame:(PlayiPadViewController *)controller;
- (void)playiPadDidSelectBuy:(PlayiPadViewController *)controller;
@end