//
//  MainMenuViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/7/10.
//  Copyright 2010 Manbolo. All rights reserved.
//
#import "MainMenuViewController.h"

#import <GameKit/GameKit.h>
#import <QuartzCore/QuartzCore.h>

#import "CMButton+Meon.h"
#import "GameManager.h"
#import "SimpleAudioEngine.h"
#import "UIDevice+Helper.h"
#import "UIImage+Meon.h"
#import "UIView+AutoLayout.h"
#import "UIView+Helper.h"
#import "UIView+Motion.h"
#import "UIViewController+Helper.h"

@implementation MainMenuViewController

- (void)loadView {

    CGRect frame = [UIViewController fullscreenFrame];
    UIImageView *view = [[UIImageView alloc] initWithFrame:frame];
    view.opaque = YES;
    view.userInteractionEnabled = YES;
    self.view = view;

    //-- create the logo
    UIImageView *titleView = [self addImageView:CGPointZero
                                         parent:self.view
                               defaultImageName:@"banner-meon-logo"
                           highlightedImageName:nil
                               autoresizingMask:0];
    titleView.y = -30;
    titleView.scale = 2.0 / 3;
    [titleView alignWithHorizontalCenterOf:self.view];
    [titleView addParallaxEffect:10];

    
    UIImageView *meonsView = [self addImageView:CGPointZero
                                         parent:self.view
                               defaultImageName:@"meons"
                           highlightedImageName:nil
                               autoresizingMask:0];
    [meonsView alignWithBottomSideOf:self.view];
    meonsView.x -= 8;
    meonsView.y += 8;
    [meonsView addParallaxEffect:10];

    [self addButtons];


    self.trophiesButton = [self addButton:(CGPoint){240, 106}
                                     parent:self.view
                                      title:@"Game Center"
                                     action:@selector(showAchievements:)
                           defaultImageName:@"trophies-ios7"
                       highlightedImageName:nil
                           autoresizingMask:0];

    UIButton *rateButton = [self addButton:CGPointZero
                                      parent:self.view
                                       title:@"Game Center"
                                      action:@selector(rate:)
                            defaultImageName:@"manbolo-url"
                        highlightedImageName:nil
                            autoresizingMask:0];
    [rateButton alignWithBottomSideOf:self.view];
    [rateButton alignWithRightSideOf:self.view];

    self.trophiesButton.x = self.view.width;
}


- (void)addButtons {

    UIView *containerView = [[UIView alloc] init];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:containerView];

    [containerView equalWidth:300];
    [containerView equalHeight:300];
    [containerView centerHorizontallyInSuperview];
    [containerView centerVerticallyInSuperviewConstant:50];
    CGFloat yStart = 10;

    CGFloat yOffset = (self.view.height > 480) ? 82 : 74;

    CMButton *classicButton = [CMButton buttonWithStyle:CMButtonMeonStyleNormal];
    classicButton.translatesAutoresizingMaskIntoConstraints = NO;
    [classicButton setTitle:NSLocalizedString(@"L_ClassicGame", ) forState:UIControlStateNormal];
    [classicButton addTarget:self action:@selector(playClassic:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:classicButton];
    [classicButton setLeftSpaceInSuperview:12];
    [classicButton setTopSpaceInSuperview:yStart];

    CMButton *timeattackButton = [CMButton buttonWithStyle:CMButtonMeonStyleNormal];
    timeattackButton.translatesAutoresizingMaskIntoConstraints = NO;
    [timeattackButton setTitle:NSLocalizedString(@"L_Timeattack", ) forState:UIControlStateNormal];
    [timeattackButton addTarget:self action:@selector(playTimeAttack:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:timeattackButton];
    [timeattackButton setLeftSpaceInSuperview:41];
    [timeattackButton setTopSpaceInSuperview:yStart + yOffset];

    CMButton *highscoresButton = [CMButton buttonWithStyle:CMButtonMeonStyleNormal];
    highscoresButton.translatesAutoresizingMaskIntoConstraints = NO;
    [highscoresButton setTitle:NSLocalizedString(@"L_Highscores", ) forState:UIControlStateNormal];
    [highscoresButton addTarget:self action:@selector(showScores:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:highscoresButton];
    [highscoresButton setLeftSpaceInSuperview:84];
    [highscoresButton setTopSpaceInSuperview:yStart + (2 * yOffset)];

    CGFloat yButton = (self.view.height > 480) ? 244 : 230;
    CMButton *optionButton = [CMButton buttonWithStyle:CMButtonMeonStyleNoBackground];
    optionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [optionButton setTitle:NSLocalizedString(@"L_Options", ) forState:UIControlStateNormal];
    [optionButton addTarget:self action:@selector(showOptions:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:optionButton];
    [optionButton setLeftSpaceInSuperview:136];
    [optionButton setTopSpaceInSuperview:yButton];

    for (UIView *view in @[classicButton, timeattackButton, highscoresButton, optionButton]) {
        [view addParallaxEffect:15];
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self.trophiesButton.x = self.view.width;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateSpashScreenImage];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateSpashScreenImage];
}


- (void)updateSpashScreenImage {
    UIImageView *anImageView = (UIImageView *)self.view;
    anImageView.image = [UIImage splashScreenImageWidth:self.view.width height:self.view.height];
}


#pragma mark - MainMenuViewControllerDelegate

- (IBAction)playClassic:(id)sender {
    [self.delegate mainMenuDidSelectPlayClassic:self];
}


- (IBAction)playTimeAttack:(id)sender {
    [self.delegate mainMenuDidSelectTimeAttack:self];
}


- (IBAction)showScores:(id)sender {
    [self.delegate mainMenuDidSelectShowScores:self];
}


- (IBAction)showOptions:(id)sender {
    [self.delegate mainMenuDidSelectShowOptions:self];
}


- (IBAction)buyFullVersion:(id)sender {
    [self.delegate mainMenuDidSelectBuyFullVersion:self];
}


- (IBAction)rate:(id)sender {
    [self.delegate mainMenuDidSelectRate:self];
}


- (IBAction)showEditor:(id)sender {
    [self.delegate mainMenuDidSelectEditor:self];
}


- (void)addTrophiesAnimation {
    self.trophiesButton.x = self.view.width;

    [UIView beginAnimations:@"trophies" context:NULL];

    self.trophiesButton.x = self.view.width - self.trophiesButton.width;

    [UIView commitAnimations];
}


#pragma mark - GameCenter
- (IBAction)showAchievements:(id)sender {
    [self.delegate mainMenuDidSelectShowAchievements:self];
}


- (void)transitionAnimationDidStopFrom:(NSString *)from to:(NSString *)to {
    [self addTrophiesAnimation];
}


@end
