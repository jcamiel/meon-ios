//
//  MainMenuiPadViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/17/12.
//  Copyright (c) 2012 Manbolo. All rights reserved.
//
#import "MainMenuiPadViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "AchievementsiPadViewController.h"
#import "HighscoresiPadViewController.h"
#import "NSString+Constant.h"
#import "OptionsiPadViewController.h"
#import "TimeAttackiPadViewController.h"
#import "UIDevice+Helper.h"
#import "UIView+Helper.h"
#import "UIView+Motion.h"
#import "UIViewController+Helper.h"


@interface MainMenuiPadViewController ()

@property (nonatomic, strong) NSMutableSet *dimmedViews;
@property (nonatomic, strong) NSMutableArray *zoomedButtons;
@property (nonatomic, strong) UIButton *buyFullButton;
@end

@implementation MainMenuiPadViewController


- (void)dealloc {
    DebugLog(@"dealloc");

    [self unregisterFromForegroundNotification];

    for(UIButton *button in _zoomedButtons) {
        [button.layer removeAllAnimations];
    }
}


- (void)loadView {
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    UIViewController *rootViewController = keyWindow.rootViewController;
    CGRect frame = rootViewController.view.bounds;
    CGRect viewFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);

    UIView *aView = [[UIView alloc] initWithFrame:viewFrame];
    aView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    aView.backgroundColor = [UIColor clearColor];
    self.view = aView;

    self.dimmedViews = [NSMutableSet set];
}


- (void)addButtons {
    // Create a container view for buttons.
    CGRect frame = (CGRect){{0, 0}, {624, 228}};
    UIView *containerView = [[UIView alloc] initWithFrame:frame];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                     UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleBottomMargin;
    containerView.backgroundColor = [UIColor clearColor];
    [containerView alignWithHorizontalCenterOf:self.view];
    containerView.y = 500;
    [self.view addSubview:containerView];


    // Create buttons.
    UIButton *playButton = [self addButton:(CGPoint){0, 0}
                                      parent:containerView
                                       title:@"Play Classic"
                                      action:@selector(playClassic:)
                            defaultImageName:@"Common/playclassic.png"
                        highlightedImageName:@"Common/playclassic-on.png"
                            autoresizingMask:0];

    UIButton *timeAttackButton = [self addButton:(CGPoint){333, 0}
                                            parent:containerView
                                             title:@"Time Attack"
                                            action:@selector(playTimeAttack:)
                                  defaultImageName:@"Common/timeattack.png"
                              highlightedImageName:@"Common/timeattack-on.png"
                                  autoresizingMask:0];


    UIButton *highscoresButton = [self addButton:(CGPoint){0, 128}
                                            parent:containerView
                                             title:@"Highscores"
                                            action:@selector(showHighscores:)
                                  defaultImageName:@"Common/highscores.png"
                              highlightedImageName:@"Common/highscores-on.png"
                                  autoresizingMask:0];

    UIButton *optionsButton = [self addButton:(CGPoint){408, 153}
                                         parent:containerView
                                          title:@"Options"
                                         action:@selector(showOptions:)
                               defaultImageName:@"Common/options.png"
                           highlightedImageName:@"Common/options-on.png"
                               autoresizingMask:0];

    // Add parallax effect
    [playButton addParallaxEffect:20];
    [timeAttackButton addParallaxEffect:20];
    [highscoresButton addParallaxEffect:20];
    [optionsButton addParallaxEffect:20];


    self.zoomedButtons = [NSMutableArray arrayWithObjects:playButton, timeAttackButton,
                          highscoresButton, optionsButton, nil];
    for(UIButton * button in _zoomedButtons) {
        button.scale = 0.001;
    }


    NSString *imageName = [[UIDevice currentDevice] isSystemVersionGreaterOrEqualThan:@"7.0"] ?
                          @"Common/trophies-ios7.png" : @"Common/trophies.png";

    UIButton *achievementButton = [self addButton:CGPointZero
                                             parent:self.view
                                              title:@"Achievements"
                                             action:@selector(showAchievements:)
                                   defaultImageName:imageName
                               highlightedImageName:nil
                                   autoresizingMask:UIViewAutoresizingFlexibleLeftMargin |
                                   UIViewAutoresizingFlexibleTopMargin];
    [achievementButton alignWithRightSideOf:self.view];
    [achievementButton alignWithBottomSideOf:self.view offset:20];


    UIButton *rateButton = [self addButton:CGPointZero
                                      parent:self.view
                                       title:@"Rate us"
                                      action:@selector(rate:)
                            defaultImageName:@"Common/manbolo-url.png"
                        highlightedImageName:nil
                            autoresizingMask:UIViewAutoresizingFlexibleRightMargin |
                            UIViewAutoresizingFlexibleTopMargin];
    [rateButton alignWithLeftSideOf:self.view offset:20];
    [rateButton alignWithBottomSideOf:self.view offset:20];

#if defined (LITE)
    self.buyFullButton = [self addButton:CGPointZero
                                    parent:self.view
                                     title:@"Buy Full"
                                    action:@selector(buyFull:)
                          defaultImageName:@"Common/buyfull.png"
                      highlightedImageName:nil
                          autoresizingMask:UIViewAutoresizingFlexibleRightMargin |
                          UIViewAutoresizingFlexibleTopMargin];
    [_buyFullButton alignWithLeftSideOf:self.view offset:20];
    [_buyFullButton alignWithBottomSideOf:self.view offset:160];
    [self addBuyButtonAnimation:_buyFullButton];
#endif


#if defined (LITE)

    NSArray *buttons = @[playButton, timeAttackButton,
                         highscoresButton, optionsButton, rateButton, achievementButton, _buyFullButton];
#else
    NSArray *buttons = @[playButton, timeAttackButton,
                         highscoresButton, optionsButton, rateButton, achievementButton];
#endif
    [_dimmedViews addObjectsFromArray:buttons];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    [self addButtons];

    //-- add the banner
    UIImage *frontImage = [UIImage imageNamed:@"Common/banner-meon-front.png"];
    UIImage *logoImage = [UIImage imageNamed:@"Common/banner-meon-logo.png"];
    UIImage *backImage = [UIImage imageNamed:@"Common/banner-meon-back.png"];

    // the container view
    CGFloat x = floor((self.view.frame.size.width - logoImage.size.width) / 2);
    CGFloat y = 80;
    CGFloat width = logoImage.size.width;
    CGFloat height = logoImage.size.height;
    CGRect logoFrame = (CGRect){{x, y}, {width, height}};

    UIView *containerView = [[UIView alloc] initWithFrame:logoFrame];
    containerView.backgroundColor = [UIColor clearColor];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                     UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleBottomMargin;

    UIImageView *meonView = [[UIImageView alloc] initWithImage:backImage];
    meonView.frame = (CGRect){{839, 88}, {backImage.size.width, backImage.size.height}};
    [containerView addSubview:meonView];
    [_dimmedViews addObject:meonView];

    UIImageView *logoView = [[UIImageView alloc] initWithImage:logoImage];
    logoView.contentMode = UIViewContentModeScaleToFill;
    self.logoView = logoView;
    [containerView addSubview:logoView];

    UIImageView *frontView = [[UIImageView alloc] initWithImage:frontImage];
    frontView.frame = (CGRect){{106, 78}, {frontImage.size.width, frontImage.size.height}};
    [containerView addSubview:frontView];
    [_dimmedViews addObject:frontView];

    [self.view addSubview:containerView];
    [containerView addParallaxEffect:20];

    // add the lite image
#if defined (LITE)
    UIImageView *liteView = [self addImageView:(CGPoint){750, 72}
                                        parent:containerView
                              defaultImageName:@"lite.png"
                          highlightedImageName:nil
                              autoresizingMask:0];
    [_dimmedViews addObject:liteView];
#endif

    [self registerToForegroundNotification];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


#pragma mark - Rotations


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    DebugLog(@"shouldAutorotateToInterfaceOrientation: %@",
             [NSString stringFromUIInterfaceOrientation:interfaceOrientation]);

    return YES;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    DebugLog(@"willRotateToInterfaceOrientation->%@ duration:%.2f",
             [NSString stringFromUIInterfaceOrientation:toInterfaceOrientation], duration);

    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    DebugLog(@"didRotateFromInterfaceOrientation->%@",
             [NSString stringFromUIInterfaceOrientation:fromInterfaceOrientation]);

    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    DebugLog(@"currentOrientation: %@", [NSString stringFromUIInterfaceOrientation:self.interfaceOrientation]);
}


- (void)transitionAnimationDidStopFrom:(NSString *)from to:(NSString *)to {
    DebugLog(@"transitionAnimationDidStopFrom from %@ to %@", from, to);

    // add some delay when transitionning from app start
    CFTimeInterval offset = [from isEqualToString:@"applicationDidFinishLaunching"] ?
                            1 : 0;

    for(UIButton *button in _zoomedButtons) {
        CAAnimation *animation = [self zoomAnimationOnView:button
                                                withOffset:offset];
        [button.layer addAnimation:animation forKey:@"zoom"];
        offset += 0.2;
    }
}


#pragma mark - Actions

- (IBAction)playClassic:(id)sender {
    [self.delegate mainMenuiPadDidSelectPlayClassic:self];
}


- (IBAction)playTimeAttack:(id)sender {
    TimeAttackiPadViewController *timeattackViewController = [[TimeAttackiPadViewController alloc]
                                                              init];

    timeattackViewController.delegate = self;
    timeattackViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    timeattackViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    [self presentViewController:timeattackViewController animated:YES completion:nil];
}


- (IBAction)showHighscores:(id)sender {
    HighscoresiPadViewController *highscoresViewController = [[HighscoresiPadViewController alloc] init];
    highscoresViewController.delegate = self;
    highscoresViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    highscoresViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    highscoresViewController.boardStore = self.gameManager.boardStore;

    [self presentViewController:highscoresViewController animated:YES completion:nil];
}


- (IBAction)showAchievements:(id)sender {
    AchievementsiPadViewController * achievementsViewController = [[AchievementsiPadViewController alloc]
                                                                   init];

    NSArray *achievements = [self.gameManager.gameCenterManager.achievements.allValues
                             sortedArrayUsingSelector:@selector(compare:)];

    achievementsViewController.achievements = achievements;
    achievementsViewController.delegate = self;
    achievementsViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    achievementsViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    [self presentViewController:achievementsViewController animated:YES completion:nil];
}


- (IBAction)showOptions:(id)sender {
    OptionsiPadViewController *optionsViewController = [[OptionsiPadViewController alloc]
                                                        init];

    optionsViewController.useDoneButton = YES;
    optionsViewController.delegate = self;
    optionsViewController.gameManager = self.gameManager;
    optionsViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    optionsViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    [self presentViewController:optionsViewController animated:YES completion:nil];
}


- (void)modaliPadViewControllerCancel:(ModaliPadViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)rate:(id)sender {
    [[UIApplication sharedApplication] openURL:self.gameManager.reviewsURL];

    // reset maximum level
    //self.gameManager.levelMaximum = 0;
}


- (IBAction)buyFull:(id)sender {
    [self.delegate mainMenuiPadDidSelectBuyFullVersion:self];
}


- (void)dismissViewController {
    NSTimeInterval duration = 0.3;
    CGRect frameSrc = self.logoView.frame;
    CGFloat widthSrc = frameSrc.size.width;
    CGFloat heightSrc = frameSrc.size.height;
    CGFloat widthDst = widthSrc * 0.8;
    CGFloat heightDst = heightSrc * 0.8;


    CGRect logoRect = (CGRect){{-250, -10}, {widthDst, heightDst}};
    CGRect dstRect = [self.view convertRect:logoRect toView:self.logoView];
    CGFloat xDst = dstRect.origin.x;
    CGFloat yDst = dstRect.origin.y;

    UIView *containerView = self.logoView.superview;
    containerView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleBottomMargin;

    [UIView animateWithDuration:duration
                     animations:^{
         CGRect frameDst = (CGRect){{xDst, yDst}, {widthDst, heightDst}};
         self.logoView.frame = frameDst;
         for(UIView *view in _dimmedViews) {
             view.alpha = 0;
         }
     }
                     completion:^(BOOL finished){
         [self.delegate mainMenuiPadDismissAnimationDidFinish:self];
     }
    ];
}


#pragma mark - TimeAttackiPadViewControllerDelegate

- (void)timeAttackiPadDidSelectPlayFlash:(TimeAttackiPadViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate mainMenuiPadDidSelectPlayFlash:self];
}


- (void)timeAttackiPadDidSelectPlayMedium:(TimeAttackiPadViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate mainMenuiPadDidSelectPlayMedium:self];
}


- (void)timeAttackiPadDidSelectPlayMarathon:(TimeAttackiPadViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate mainMenuiPadDidSelectPlayMarathon:self];
}


#pragma mark - animation

- (CAAnimation *)zoomAnimationOnView:(UIView *) view withOffset:(CFTimeInterval)offset {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                      animationWithKeyPath:@"transform.scale"];

    NSArray *values = @[@0.001f,
                        @1.2f,
                        @1.0f];


    NSArray *times = @[@0.0f,
                       @0.8f,
                       @1.0f];

    NSArray *timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn ]];
    animation.duration = 0.4;
    animation.values = values;
    animation.keyTimes = times;
    animation.removedOnCompletion = NO;
    animation.timingFunctions = timingFunctions;
    animation.fillMode = kCAFillModeForwards;
    animation.beginTime = CACurrentMediaTime() + offset;
    animation.delegate = self;
    [animation setValue:view forKey:@"view"];

    return animation;
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    UIView *view = [anim valueForKey:@"view"];
    view.scale = 1.0;
    [view.layer removeAllAnimations];
}


- (void)addBuyButtonAnimation:(UIView *)button {

    [button.layer removeAllAnimations];

    CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                      animationWithKeyPath:@"transform.scale"];

    NSArray *values = @[@1.0f,
                        @1.1f,
                        @1.0f,
                        @1.0f];

    NSArray *times = @[@0.0f,
                       @0.1f,
                       @0.2f,
                       @1.00f];

    NSArray *functions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                           [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                           [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];

    [animation setDuration:2.5];
    [animation setValues:values];
    [animation setKeyTimes:times];
    [animation setTimingFunctions:functions];
    animation.repeatCount = HUGE_VAL;

    [button.layer addAnimation:animation forKey:@"zoom"];
}


#pragma mark - Enter Foreground managment

- (void)registerToForegroundNotification {
    if (&UIApplicationWillEnterForegroundNotification) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
}


- (void)unregisterFromForegroundNotification {
    if (&UIApplicationWillEnterForegroundNotification) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationWillEnterForegroundNotification
                                                      object:nil];
    }
}


- (void)willEnterForeground:(NSNotification *)theNotification {
    [self addBuyButtonAnimation:_buyFullButton];
}


@end
