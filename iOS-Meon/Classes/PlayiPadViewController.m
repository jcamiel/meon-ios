//
//  PlayiPadViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 6/14/11.
//  Copyright 2011 Manbolo. All rights reserved.
//
#import "PlayiPadViewController.h"

#import <Twitter/Twitter.h>

#import "AchievementViewController.h"
#import "CMBitmapNumberView.h"
#import "CMShareViewController.h"
#import "CompletedAnimator.h"
#import "CompletedGameAnimator.h"
#import "GameManager.h"
#import "GameOverViewController.h"
#import "GotoViewController.h"
#import "GotoiPadViewController.h"
#import "GroundView.h"
#import "GroundViewController.h"
#import "HintsAnimator.h"
#import "Level.h"
#import "MKStoreManager.h"
#import "NSString+Constant.h"
#import "SimpleAudioEngine.h"
#import "SloganAnimator.h"
#import "SolverAnimator.h"
#import "SolveriPadViewController.h"
#import "StartAnimator.h"
#import "TapToContinueAnimator.h"
#import "TutorialViewController.h"
#import "UIColor+Helper.h"
#import "UIDevice+Helper.h"
#import "UIView+Helper.h"
#import "UIView+Motion.h"
#import "UIViewController+Helper.h"

#define kRateAlertView 10
#define kLeftTimeAttackAlertView 11
#define kUseSolver 12
#define kReceiveNewLevelFromiCloud 13

@interface PlayiPadViewController ()

@property (nonatomic, strong) SloganAnimator *sloganAnimator;
@property (nonatomic, strong) TapToContinueAnimator *tapToContinueAnimator;
@property (nonatomic, strong) HintsAnimator *hintsAnimator;
@property (nonatomic, strong) NSTimer *counterTimer;
@property (nonatomic, strong) UIAlertView *iCloudAlertView;

@end

#pragma mark - PlayiPadViewController implementation

@implementation PlayiPadViewController {
    BOOL _mustAnimatedRotation;
}



#pragma mark - alloc / init

- (void)dealloc {
    DebugLog(@"dealloc PlayiPadViewController");

    [self unregisterFromForegroundNotification];
    [self unregisterFromiCloudNotification];

    [_completedAnimator setAnimatorDidStopSelector:NULL withDelegate:nil];
    [_sloganAnimator setAnimatorDidStopSelector:NULL withDelegate:nil];
    [_tapToContinueAnimator setAnimatorDidStopSelector:NULL withDelegate:nil];
    [_solverAnimator setAnimatorDidStopSelector:NULL withDelegate:nil];
    [_hintsAnimator setAnimatorDidStopSelector:NULL withDelegate:nil];
    [_startAnimator setAnimatorDidStopSelector:NULL withDelegate:nil];
    [_completedGameAnimator setAnimatorDidStopSelector:NULL withDelegate:nil];

    [_counterTimer invalidate];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
    self.logoView = nil;
    self.gotoButton = nil;
    self.tweetButton = nil;
}


#pragma mark - View lifecycle

- (void)transitionAnimationDidStopFrom:(NSString *)from to:(NSString *)to {
    if ([from isEqualToString:@"applicationDidFinishLaunching"]) {
        [self setGroundViewVisibleAnimated:NO];
        [self layoutButtonsAnimated:NO];
        [self layoutTimeAttackCounterViewAnimated:NO];
        [self setButtonsVisible:YES animated:NO];
        [self setBannerViewVisibleAnimated:NO];
    }

    [self addMeonHeader];


    // In Timeattack mode, start the counter
    if (_gameManager.mode != kGameModeClassic) {
        [_startAnimator start];
        [self startCounter];
    }
    else {
        // Sync with iCloud
        if (_gameManager.level < _gameManager.levelMaximumiCloud) {
            DebugLog(@"Level in iCloud %lu is greater than current level %lu",
                     _gameManager.levelMaximumiCloud, _gameManager.level);
            [self didReceiveNewLevelFromiCloud:nil];
        }
        // first, we test if the level is already ended
        if ([_gameManager.currentLevel isCompleted]) {
            [_tapToContinueAnimator start];
            _groundViewController.touchesInteractionEnabled = NO;
            return;
        }
        if(_gameManager.level < [_gameManager numberOfSectionForTutorial]) {
            _groundViewController.touchesInteractionEnabled = NO;
            [self addTutorialView];
        }
    }
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    DebugLog(@"loadView");

    // on iOS 6 and superior, rotataion is handled in viewWillLayoutSubviews
    // and at this moment, we'll never have access to animationDuration. So, our fisrt
    // assomption is that the first call happens after loadView and the rotation should not be animated
    // and then, subsequent call are consequence of a TRUE user rotation and should be animated
    _mustAnimatedRotation = NO;

    UIColor *backgroundColor = [UIColor colorWithHexCode:0x292831];

    CGRect frame = [UIViewController fullscreenFrame];

    self.view = [[UIView alloc] initWithFrame:frame];

    self.view.backgroundColor = backgroundColor;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;


    //-- add background
    UIImageView *backgroundView = [self addImageView:CGPointZero
                                              parent:self.view
                                    defaultImageName:@"Default-Portrait.png"
                                highlightedImageName:nil
                                    autoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [backgroundView alignWithRightSideOf:self.view];


    self.logoView = [self addImageView:CGPointZero
                                parent:self.view
                      defaultImageName:@"Common/header_meon.png"
                  highlightedImageName:nil
                      autoresizingMask:0];
    [_logoView space:0 fromTopSideOf:self.view];



    // register to notifications
    [self registerToForegroundNotification];
    [self registerToiCloudNotification];

    //-- create animators
    self.sloganAnimator = [SloganAnimator animator];
    _sloganAnimator.superLayer = _groundViewController.view.layer;
    _sloganAnimator.isUsingSuperSuperLayerWidth = YES;
    [_sloganAnimator setAnimatorDidStopSelector:@selector(endLevelAnimationDidStop)
                                   withDelegate:self];

    if ((_gameManager.mode == kGameModeTimeAttackFlash) ||
        (_gameManager.mode == kGameModeTimeAttackMarathon) ||
        (_gameManager.mode == kGameModeTimeAttackMedium)) {

        [self addTimeAttackCounterView];

        _startAnimator = [[StartAnimator alloc] init];
        _startAnimator.superLayer = _groundViewController.view.layer;
        _startAnimator.yCenter = 300.0;

        self.completedAnimator = [CompletedAnimator animator];
        _completedAnimator.sloganImage = [UIImage imageNamed:@"Common/gameover.png"];
        _completedAnimator.superLayer = _groundViewController.view.layer;
        _completedAnimator.groundView = _groundViewController.groundView;
        _completedAnimator.counterView = _counterView;
        _completedAnimator.ySlogan = 100.0;
    }
    else {
        self.tapToContinueAnimator = [TapToContinueAnimator animator];
        _tapToContinueAnimator.superLayer = _groundViewController.view.layer;
        _tapToContinueAnimator.marginBottom = 100;

        self.hintsAnimator = [HintsAnimator animator];
    }

    //-- start music
    if (_gameManager.hasAudioBeenInitialized) {
        SimpleAudioEngine *audioEngine = [SimpleAudioEngine sharedEngine];
        NSString * path = [_gameManager musicPathForControllerName:@"Play"];
        [audioEngine playBackgroundMusic:path];
    }

    // add the counter in time attack mode
    // add the miniscore in classic mode
    self.tweetButtonEnabled = (_gameManager.mode == kGameModeClassic) &&
                              (NSClassFromString(@"TWTweetComposeViewController"));

    if (_gameManager.mode == kGameModeClassic) {
        [self addScoreView];
        [self addClassicButtons];
        [self addSolverCountView];
        [self setButtonsVisible:NO animated:NO];
    }
    else {
    }

    [self addMenuButton];

    [self addLevelTxtView];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.levelTxtView = nil;
    self.solverButton = nil;
    self.hintsButton = nil;
}


#pragma mark - Rotation handling

- (void)viewWillLayoutSubviews {
    // on iOS 6 and superior, rotation is handled in viewWillLayoutSubviews
    // and at this moment, we'll never have access to animationDuration. So, our fisrt
    // assomption is that the first call happens after loadView and the rotation should not be animated
    // and then, subsequent call are consequence of a TRUE user rotation and should be animated

    UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    DebugLog(@"viewWillLayoutSubviews view=(%.0f,%.0f,%.0f,%.0f) statusBarOrientation=%ld",
             self.view.bounds.origin.x,
             self.view.bounds.origin.y,
             self.view.bounds.size.width,
             self.view.bounds.size.height,
             toInterfaceOrientation);
    [self rotateInterfaceTo:toInterfaceOrientation animated:_mustAnimatedRotation];
    _mustAnimatedRotation = YES;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    DebugLog(@"shouldAutorotateToInterfaceOrientation: %@",
             [NSString stringFromUIInterfaceOrientation:interfaceOrientation]);

    return YES;
}


- (void)rotateInterfaceTo:(UIInterfaceOrientation)toInterfaceOrientation animated:(BOOL)isAnimated {
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        _groundViewController.view.y = 175;
    }
    else {
        _groundViewController.view.y = 100;
    }

    BOOL isPortrait = UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
    [self layoutButtonsAnimated:isAnimated isPortrait:isPortrait];
    [self layoutTimeAttackCounterViewAnimated:isAnimated isPortrait:isPortrait];
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    DebugLog(@"willRotateToInterfaceOrientation->%@ duration:%.2f",
             [NSString stringFromUIInterfaceOrientation:toInterfaceOrientation], duration);

    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

    if ([[UIDevice currentDevice] isSystemVersionGreaterOrEqualThan:@"6"]) {
        DebugLog(@"iOS >= 6.0, rotation is handled in viewWillLayoutSubviews");
    }

    BOOL isAnimated = (duration > 0.01);
    [self rotateInterfaceTo:toInterfaceOrientation animated:isAnimated];

    // Dismiss our share view controller if any.
    [_shareViewController dismissShareView];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    DebugLog(@"didRotateFromInterfaceOrientation->%@",
             [NSString stringFromUIInterfaceOrientation:fromInterfaceOrientation]);

    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    DebugLog(@"currentOrientation: %@", [NSString stringFromUIInterfaceOrientation:self.interfaceOrientation]);



    // stop / restart tapToContinue animation to relayout it
    if (_tapToContinueAnimator.isRunning) {
        [_tapToContinueAnimator stop];
        [_tapToContinueAnimator start];
    }
}


#pragma mark - Ground ViewController

- (void)createGroundViewController {
    if (_groundViewController) {return; }

    //-- step 0 - load a level, we will know the cell width
    [_gameManager loadLevel];

    //-- step 1 - create groud view contoller, controller is positionned offscreen
    self.groundViewController = [[GroundViewController alloc] init];

    _groundViewController.level = _gameManager.currentLevel;
    CGFloat x = floor((self.view.width - _groundViewController.view.width) / 2);
    CGFloat y = self.view.frame.size.height;
    CGRect frame = (CGRect){{x, y},
                            {_groundViewController.view.frame.size.width,
                             _groundViewController.view.frame.size.height}};
    _groundViewController.view.frame = frame;

    _groundViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                                  UIViewAutoresizingFlexibleRightMargin;

    _groundViewController.delegate = self;
    [self.view insertSubview:_groundViewController.view belowSubview:_logoView];

    _hintsAnimator.hintsSprites = _gameManager.currentLevel.hintsSprites;
    _tapToContinueAnimator.superLayer = _groundViewController.view.layer;
    _sloganAnimator.superLayer = _groundViewController.view.layer;
    _startAnimator.superLayer = _groundViewController.view.layer;
    _completedAnimator.superLayer = _groundViewController.view.layer;
    _completedAnimator.groundView = _groundViewController.groundView;
    if (!_counterView.superview) {
        [_groundViewController.view addSubview:_counterView];
        [self layoutTimeAttackCounterViewAnimated:NO];
    }

    // Add parallax effect.
    [_groundViewController.view addParallaxEffect:15];
}


#pragma mark - Load level

- (void)loadLevel:(NSUInteger)level {
    //-- remove any animation
    [_tapToContinueAnimator stop];
    _groundViewController.touchesInteractionEnabled = YES,

#if defined(LITE)
    level = MIN(level, 31);
#else
    level = MIN(level, 120);
#endif

    _gameManager.level = level;

    [_gameManager loadLevel];

    //-- set the hints
    _hintsAnimator.hintsSprites = _gameManager.currentLevel.hintsSprites;

    [self layoutLevelTxtView];

    [_groundViewController.groundView setNeedsDisplay];

    // -- achievements
    [self displayAchievements];

    //-- tutorial
    if (_gameManager.mode == kGameModeClassic) {
        [_tutorialViewController loadFirstPage];
        _tutorialViewController.view.hidden = NO;
        if ((_gameManager.level < [_gameManager numberOfSectionForTutorial]) &&
            (![_gameManager.currentLevel isCompleted])) {
            _groundViewController.touchesInteractionEnabled = NO;
            [self addTutorialView];
        }
        else {
            [self removeTutorialView];
        }
    }
}


#pragma mark - Touch Managment

- (BOOL)isTouchesInteractionEnabled {
    // if tutorial is visible, can't do anything
    // if animation running don't do anything
    if ((_tutorialViewController && !_tutorialViewController.view.hidden) ||
        _sloganAnimator.isRunning ||
        _startAnimator.isRunning ||
        _tapToContinueAnimator.isRunning ||
        _completedAnimator.isRunning ||
        _solverAnimator.isRunning ||
        _completedGameAnimator.isRunning) {
        return NO;
    }
    else {
        return YES;
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // click on view while tutorial is shown
    if (_tutorialViewController && !_tutorialViewController.view.hidden) {
        [_tutorialViewController nextPage];
        return;
    }

    // click on view while click-to-continue is shown
    if (_tapToContinueAnimator.isRunning) {
        [_tapToContinueAnimator stop];
        _groundViewController.touchesInteractionEnabled = YES;
        [self forward:nil];
    }
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}


#pragma mark - GroundViewController protocol

- (void)groundViewLevelDidCompleted:(GroundViewController *)controller {
    [_gameManager didSolveNewLevel:_gameManager.level];
    [_hintsAnimator stop];
    [_sloganAnimator start];

    [self displayAchievements];

    _groundViewController.touchesInteractionEnabled = NO;
}


- (void)endLevelAnimationDidStop {

    BOOL pauseBetweenLevels = [[NSUserDefaults standardUserDefaults]
                               boolForKey:@"pauseBetweenLevels"];
    if (pauseBetweenLevels && (_gameManager.mode == kGameModeClassic)) {
        [_tapToContinueAnimator start];
    }
    else {
        [self forward:nil];
    }
}


#pragma mark - Subviews


- (void)addScoreView {
    UIImageView *ptsView = [self addImageView:CGPointZero
                                       parent:self.view
                             defaultImageName:@"Common/pts.png"
                         highlightedImageName:nil
                             autoresizingMask:UIViewAutoresizingFlexibleTopMargin |
                            UIViewAutoresizingFlexibleLeftMargin];

    [ptsView alignWithRightSideOf:self.view offset:20];
    [ptsView alignWithBottomSideOf:self.view offset:136];


    CGRect frame = CGRectMake(0, 0, 130, 40);
    self.scoreView = [[CMBitmapNumberView alloc]initWithFrame:frame];
    _scoreView.letterSpacing = -0.2;
    _scoreView.opaque = NO;
    _scoreView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |
                                  UIViewAutoresizingFlexibleLeftMargin;
    _scoreView.alignment = NSTextAlignmentRight;
    _scoreView.digitsImage = [UIImage imageNamed:@"Digit/digit-level0-tiny.png"];
    _scoreView.value = _gameManager.score;
    [_scoreView space:4 fromLeftSideOf:ptsView];
    [_scoreView alignWithBottomSideOf:self.view offset:136];
    [self.view addSubview:_scoreView];
}


- (void)addSolverCountView {
    NSString *productId = [NSString stringWithFormat:@"%@.solvelevel.5",
                           _gameManager.gameBundleId];

    CGRect solverButtonFrame = _solverButton.frame;
    CGFloat width = solverButtonFrame.size.width;
    CGFloat a = 39;
    CGRect frame = (CGRect){{width - 40, 4}, {a, a}};

    MKStoreManager *storeManager = [MKStoreManager sharedManager];

    self.solverCountView = [[CMBitmapNumberView alloc]initWithFrame:frame];
    _solverCountView.hidesWhenValueIsZero = YES;
    _solverCountView.opaque = NO;
    _solverCountView.digitsImage = [UIImage imageNamed:@"Common/Pastille.png"];
    _solverCountView.value = [storeManager quantityOfProduct:productId];
    [_solverButton addSubview:_solverCountView];
}


- (void)addLevelTxtView {
    //-- create _levelTxtView;

    self.levelTxtView = [self addImageView:CGPointZero
                                    parent:self.view
                          defaultImageName:@"Common/level0.png"
                      highlightedImageName:nil
                          autoresizingMask:UIViewAutoresizingFlexibleLeftMargin |
                         UIViewAutoresizingFlexibleTopMargin];

    //-- create _levelView
    self.levelView = [[CMBitmapNumberView alloc] initWithFrame:CGRectZero];
    _levelView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                  UIViewAutoresizingFlexibleTopMargin;
    [self.view insertSubview:_levelView belowSubview:_levelTxtView];

    [self layoutLevelTxtView];
}


- (void)addTimeAttackCounterView {
    CGRect frame = (CGRect){{0, 0}, {300, 45}};

    self.counterView = [[CMBitmapNumberView alloc] initWithFrame:frame];
    _counterView.backgroundColor = [UIColor clearColor];
    [_groundViewController.view addSubview:_counterView];

    _counterView.digitsImage = [UIImage imageNamed:@"Digit/digit-level0-small.png"];
    _counterView.letterSpacing = -0.2;
    _counterView.value = _gameManager.counter;

    [self layoutTimeAttackCounterViewAnimated:NO];
}


- (void)layoutLevelTxtView {

    NSString *imageName = [NSString stringWithFormat:@"Digit/digit-level%lu.png",
                           (_gameManager.level / 10) % 5];
    _levelView.opaque = NO;
    _levelView.digitsImage = [UIImage imageNamed:imageName];
    _levelView.letterSpacing = -0.23;

    _levelView.value = _gameManager.level;
    _levelView.alignment = NSTextAlignmentRight;
    [_levelView sizeToFit];
    [_levelView alignWithRightSideOf:self.view offset:20];
    [_levelView alignWithBottomSideOf:self.view offset:20];


    _levelTxtView.image = [UIImage imageNamed:
                           [NSString stringWithFormat:@"Common/level%lu.png", (_gameManager.level / 10) % 5]];
    [_levelTxtView space:-42 fromLeftSideOf:_levelView];
    [_levelTxtView space:-26 fromBottomSideOf:_levelView];
}


- (void)layoutTimeAttackCounterViewAnimated:(BOOL)animated {
    BOOL isPortrait = self.view.bounds.size.width < 1000;
    [self layoutTimeAttackCounterViewAnimated:animated isPortrait:isPortrait];
}


- (void)layoutTimeAttackCounterViewAnimated:(BOOL)animated isPortrait:(BOOL)isPortrait {
    if (animated) {
        [UIView beginAnimations:@"buttons" context:NULL];
    }
    if (!_gameOverViewController) {
        _counterView.center = isPortrait ? (CGPoint){150, 800.5} : (CGPoint){10, 620.5};
    }

    if (animated) {
        [UIView commitAnimations];
    }
}


#pragma mark - Actions

- (IBAction)checkForRatingGame {
    //
    // test if we need to rate the game
    if (((_gameManager.level == 15) || (_gameManager.level == 50))
        && _gameManager.mode == kGameModeClassic) {

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSInteger level = [defaults integerForKey:@"levelForRating"];

        if (level == _gameManager.level) {
            NSString *title = NSLocalizedString(@"L_RateMeonTitle", );
            NSString *message = NSLocalizedString(@"L_RateMeonMessage", );
            NSString *cancelLabel = NSLocalizedString(@"L_RateMeonCancelButton", );
            NSString *okLabel = NSLocalizedString(@"L_RateMeonOkButton", );


            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                             message:message
                                                            delegate:self
                                                   cancelButtonTitle:cancelLabel
                                                   otherButtonTitles:okLabel, nil];
            alert.tag = kRateAlertView;
            [alert show];


            if (_gameManager.level == 15) {
                level = 50;
            }
            else if (_gameManager.level == 50) {
                level = -1;
            }

            [defaults setInteger:level forKey:@"levelForRating"];
            [defaults synchronize];
        }
    }
}


- (IBAction)forward:(id)sender {
    [self checkForRatingGame];

    //-- game is not over
    if (_gameManager.level < [_gameManager levelLimit]) {

        NSString *previousMusicPath = [_gameManager musicPathForControllerName:@"Play"];
        [self loadLevel:++_gameManager.level];

        NSString *newMusicPath = [_gameManager musicPathForControllerName:@"Play"];

        if (![previousMusicPath isEqualToString:newMusicPath] && newMusicPath) {
            [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:newMusicPath];
        }
        return;
    }


    //-- game is over

    // we don't save the last level state in Classic and TimeAttack Mode
    [_gameManager setSavedLevel:_gameManager.levelLimit];

    // if classic mode, start the congratulation animation
    if (_gameManager.mode == kGameModeClassic) {

        // be sure the level maximum is registered
        _gameManager.levelMaximum = _gameManager.levelLimit + 1;

#if defined(LITE)
        [_delegate playiPadDidFinishGame:self];
        return;
#endif
        self.groundViewController.touchesInteractionEnabled = NO;
        [self startCongratulationAnimation];
    }
    // if mode time attack, it's finished
    else {
        // stop the counter
        [self.counterTimer invalidate];
        self.counterTimer = nil;

#if defined(LITE)
        if ((_gameManager.mode == kGameModeTimeAttackMedium) ||
            (_gameManager.mode == kGameModeTimeAttackMarathon)) {
            [_delegate playiPadDidFinishGame:self];
            return;
        }
#endif

        // load the game over view controller
        GameOverViewController *gameOverController = [[GameOverViewController alloc]
                                                      init];
        gameOverController.gameManager = _gameManager;
        gameOverController.delegate = self;
        self.gameOverViewController = gameOverController;
        _gameOverViewController.view.y = 120;
        [_gameOverViewController gameOverViewControllerviewWillAppear:NO];
        [self.groundViewController.view addSubview:_gameOverViewController.view];
        [_gameOverViewController gameOverViewControllerDidAppear:NO];

        _completedAnimator.counterViewPositionTo = (CGPoint){520, 188.5};
        [_completedAnimator start];
    }
}


- (void)showTwitterError {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                        message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}


- (IBAction)share:(id)sender {
    CGPoint origin = CGPointZero;

    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        origin.x = button.center.x;
        origin.y = button.center.y;
    }

    BOOL isLandscape = self.view.width > self.view.height;

    self.shareViewController = [[CMShareViewController alloc] init];
    _shareViewController.popoverType = isLandscape ? CMSharePopoverLeft : CMSharePopoverBottom;
    _shareViewController.initialText = [self sharedText];
    _shareViewController.URLString = [[self sharedURL] absoluteString];

    [_shareViewController presentShareViewAtPoint:origin
                             parentViewController:self
                                       completion:^{
         self.shareViewController = nil;
     }];
}


- (NSURL *)sharedURL {
    NSString *urlString = [_gameManager appStoreURLString];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}


- (NSString *)sharedText {
    NSString *format = [_gameManager.currentLevel isCompleted] ?
                       NSLocalizedString(@"L_ShareByTweetCompleted", ) :
                       NSLocalizedString(@"L_ShareByTweetBlocked", );
    NSString *message = [NSString stringWithFormat:format, _gameManager.level];

    return message;
}


- (IBAction)goTo:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"GotoLevel" bundle:nil];
    CMGotoViewController *controller = [storyboard instantiateInitialViewController];
    controller.delegate = self;
    controller.currentLevel = self.gameManager.level;
    controller.maximumLevel = self.gameManager.levelMaximum;
    [self presentViewController:controller animated:YES completion:nil];
}


- (IBAction)goToMenu:(id)sender {
    // stop any pending animation
    [_counterTimer invalidate];
    _counterTimer = nil;

    if (((_gameManager.mode == kGameModeTimeAttackFlash) ||
         (_gameManager.mode == kGameModeTimeAttackMedium) ||
         (_gameManager.mode == kGameModeTimeAttackMarathon)) &&
        !_gameOverViewController) {

        NSString *message = NSLocalizedString(@"L_TimeAttackQuit", );
        NSString *yes = NSLocalizedString(@"L_Yes", );
        NSString *no = NSLocalizedString(@"L_No", );

        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                         message:message
                                                        delegate:self
                                               cancelButtonTitle:no
                                               otherButtonTitles:yes, nil];
        alert.tag = kLeftTimeAttackAlertView;
        [alert show];
    }
    else {
        [_gameOverViewController addCurrentScoreToHighscore];
        [_delegate playiPadDidTapMenu:self];
    }
}


- (IBAction)showAchievements:(id)sender {
    AchievementsiPadViewController * achievementsViewController = [[AchievementsiPadViewController alloc]
                                                                   init];

    NSArray *achievements = [_gameManager.gameCenterManager.achievements.allValues
                             sortedArrayUsingSelector:@selector(compare:)];

    achievementsViewController.achievements = achievements;
    achievementsViewController.delegate = self;
    achievementsViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    achievementsViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    [self presentViewController:achievementsViewController animated:YES completion:nil];
}


- (IBAction)showSolution:(id)sender {
    if (![self isTouchesInteractionEnabled]) { return; }

    NSString *productId = [NSString stringWithFormat:@"%@.solvelevel.5",
                           _gameManager.gameBundleId];


    // if level has already be passed, show solution
    // or if we have enough solver credit available
    BOOL canShowSolution = NO;

    if (_gameManager.level < _gameManager.levelMaximum) {
        canShowSolution = YES;
    }
    else {
        MKStoreManager *storeManager = [MKStoreManager sharedManager];
        if ([storeManager canConsumeProduct:productId quantity:1]) {

            NSString *titleString = NSLocalizedString(@"L_SolverTitle", );
            NSString *messageString = NSLocalizedString(@"L_SolverMessage", );
            NSString *cancelString = NSLocalizedString(@"L_SolverDontUse", );
            NSString *okString = NSLocalizedString(@"L_SolverUse", );

            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:titleString
                                                             message:messageString
                                                            delegate:self
                                                   cancelButtonTitle:cancelString
                                                   otherButtonTitles:okString, nil];
            alert.tag = kUseSolver;
            [alert show];
            return;
        }
    }

    if (canShowSolution) {
        self.solverAnimator = [SolverAnimator animator];
        _solverAnimator.level = _gameManager.currentLevel;
        [_solverAnimator setAnimatorDidStopSelector:@selector(solverAnimatorDidStop)
                                       withDelegate:self];
        [_hintsAnimator stop];
        [_solverAnimator start];
        _gameManager.levelsWithoutHintCount = 0;
        _groundViewController.touchesInteractionEnabled = NO;
    }
    else {
        SolveriPadViewController * solverViewController = [[SolveriPadViewController alloc]
                                                           init];
        solverViewController.delegate = self;
        solverViewController.productId = productId;
        solverViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        solverViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:solverViewController animated:YES completion:nil];
    }
}


- (IBAction)hints:(id)sender {
//    NSUbiquitousKeyValueStore* kvStore = [NSUbiquitousKeyValueStore defaultStore];
//    [kvStore setObject:@0 forKey:@"classic.levelMaximum"];
//    [kvStore synchronize];

    // if tutorial, dismiss
    if (_tutorialViewController && !_tutorialViewController.view.hidden) {
        [_tutorialViewController nextPage];
    }
    if (![self isTouchesInteractionEnabled]) { return; }

    [_hintsAnimator start];

    _gameManager.levelsWithoutHintCount = -1;
}


- (IBAction)buy:(id)sender {
    [_delegate playiPadDidSelectBuy:self];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    switch (alertView.tag) {
        case kRateAlertView:
            if (buttonIndex == alertView.firstOtherButtonIndex) {
                [[UIApplication sharedApplication] openURL:_gameManager.reviewsURL];
            }
            break;
        case kLeftTimeAttackAlertView:
            if (buttonIndex == alertView.firstOtherButtonIndex) {
                [_delegate playiPadDidTapMenu:self];
            }
            else {
                [self startCounter];
            }
            break;
        case kUseSolver:
            if (buttonIndex == alertView.firstOtherButtonIndex) {

                NSString *productId = [NSString stringWithFormat:@"%@.solvelevel.5",
                                       _gameManager.gameBundleId];

                MKStoreManager *storeManager = [MKStoreManager sharedManager];
                if ([storeManager canConsumeProduct:productId quantity:1]) {
                    [storeManager consumeProduct:productId quantity:1];

                    _solverCountView.value = [storeManager quantityOfProduct:productId];
                    _gameManager.levelMaximum++;

                    self.solverAnimator = [SolverAnimator animator];
                    _solverAnimator.level = _gameManager.currentLevel;
                    [_solverAnimator setAnimatorDidStopSelector:@selector(solverAnimatorDidStop)
                                                   withDelegate:self];
                    [_hintsAnimator stop];
                    [_solverAnimator start];
                    _gameManager.levelsWithoutHintCount = 0;
                    _groundViewController.touchesInteractionEnabled = NO;
                }
            }
            break;
        case kReceiveNewLevelFromiCloud:
            self.iCloudAlertView = nil;
            if (buttonIndex == alertView.firstOtherButtonIndex) {
                NSString *previousMusicPath = [_gameManager musicPathForControllerName:@"Play"];
                [self loadLevel:_gameManager.levelMaximumiCloud];
                NSString *newMusicPath = [_gameManager musicPathForControllerName:@"Play"];
                if (![previousMusicPath isEqualToString:newMusicPath] && newMusicPath) {
                    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:newMusicPath];
                }
            }
            break;

        default:
            break;
    }
}


#pragma mark - Achievements
- (void)displayAchievements {
    _scoreView.value = _gameManager.score;

    NSMutableArray * achievements = _gameManager.gameCenterManager.achievementsToDisplay;
    if (!achievements.count || _achievementViewController) { return; }

    Achievement * achievement = achievements[0];
    AchievementViewController *anAchievementViewController = [[AchievementViewController alloc]
                                                              init];
    self.achievementViewController = anAchievementViewController;
    [_achievementViewController.view alignWithHorizontalCenterOf:self.view];
    _achievementViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                                       UIViewAutoresizingFlexibleRightMargin;
    _achievementViewController.achievement = achievement;

    _achievementViewController.delegate = self;
    [_achievementViewController viewWillAppear:NO];
    [self.view addSubview:_achievementViewController.view];
    [_achievementViewController viewDidAppear:NO];

    DebugLog(@"displayAchievements %@", achievement);


    // display it, can be safely remove
    [_gameManager.gameCenterManager.achievementsToDisplay
     removeObject:_achievementViewController.achievement];
}


- (void)achievementViewControllerDidDismiss:(AchievementViewController *)controller {
    DebugLog(@"achievementViewControllerDidDismiss");

    _achievementViewController.achievement = nil;

    [_achievementViewController viewWillDisappear:NO];
    [_achievementViewController.view removeFromSuperview];
    [_achievementViewController viewDidDisappear:NO];
    self.achievementViewController = nil;

    // if remaining achievements, just display theme
    if (_gameManager.gameCenterManager.achievementsToDisplay.count) {
        [self displayAchievements];
    }
}


#pragma mark - Button

- (void)layoutButtonsAnimated:(BOOL)animated isPortrait:(BOOL)isPortrait {
    if (animated) {
        [UIView beginAnimations:@"buttons" context:NULL];
    }

    if (isPortrait) {
        _hintsButton.center = (CGPoint){79, 948};
        _gotoButton.center = (CGPoint){79 + 1 * 120, 948};
        _solverButton.center = (CGPoint){79 + 2 * 120, 948};
        _tweetButton.center = (CGPoint){79 + 3 * 120, 948};
    }
    else {
        if (self.isTweetButtonEnabled) {
            _hintsButton.center = (CGPoint){79, 677 - 3 * 120};
            _gotoButton.center = (CGPoint){79, 677 - 2 * 120};
            _solverButton.center = (CGPoint){79, 677 - 1 * 120};
            _tweetButton.center = (CGPoint){79, 677};
        }
        else {
            _hintsButton.center = (CGPoint){79, 677 - 2 * 120};
            _gotoButton.center = (CGPoint){79, 677 - 1 * 120};
            _solverButton.center = (CGPoint){79, 677};
        }
    }

    if (animated) {
        [UIView commitAnimations];
    }
}


- (void)layoutButtonsAnimated:(BOOL)animated {
    // Bug : freaking UIViewController self.interfaceOrientation is always portrait
    //if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)){
    //if (UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation])){
    BOOL isPortrait = (self.view.bounds.size.width < 1000);
    [self layoutButtonsAnimated:animated isPortrait:isPortrait];
}


- (void)addMenuButton {
    self.menuButton = [self addButton:CGPointZero
                                 parent:self.view
                                  title:@"Show hints"
                                 action:@selector(goToMenu:)
                       defaultImageName:@"Common/menuButton.png"
                   highlightedImageName:nil
                       autoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [_menuButton alignWithRightSideOf:self.view offset:2.0];
    _menuButton.y = 10;


    self.buyButton = [self addButton:CGPointZero
                                parent:self.view
                                 title:@"Buy Full Version"
                                action:@selector(buy:)
                      defaultImageName:@"Common/buy.png"
                  highlightedImageName:nil
                      autoresizingMask:0];
    _buyButton.hidden = YES;
}


- (void)addClassicButtons {
    self.hintsButton = [self addButton:CGPointZero
                                  parent:self.view
                                   title:@"Show hints"
                                  action:@selector(hints:)
                        defaultImageName:@"Common/hintsButton.png"
                    highlightedImageName:nil
                        autoresizingMask:0];

    self.gotoButton = [self addButton:CGPointZero
                                 parent:self.view
                                  title:@"Go to level"
                                 action:@selector(goTo:)
                       defaultImageName:@"Common/gotoButton.png"
                   highlightedImageName:nil
                       autoresizingMask:0];

    self.solverButton = [self addButton:CGPointZero
                                   parent:self.view
                                    title:@"Use solver"
                                   action:@selector(showSolution:)
                         defaultImageName:@"Common/solverButton.png"
                     highlightedImageName:nil
                         autoresizingMask:0];

    NSString *imageName = @"Common/shareButton.png";

    self.tweetButton = [self addButton:CGPointZero
                                  parent:self.view
                                   title:@"Share"
                                  action:@selector(share:)
                        defaultImageName:imageName
                    highlightedImageName:nil
                        autoresizingMask:0];
    _tweetButton.hidden = !self.isTweetButtonEnabled;

    [self layoutButtonsAnimated:NO];

    imageName = [[UIDevice currentDevice] isSystemVersionGreaterOrEqualThan:@"7.0"] ?
                @"Common/trophies-ios7.png" : @"Common/trophies.png";

    self.achievementButton = [self addButton:CGPointZero
                                        parent:self.view
                                         title:@"Show achievements"
                                        action:@selector(showAchievements:)
                              defaultImageName:imageName
                          highlightedImageName:nil
                              autoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [_achievementButton alignWithRightSideOf:self.view offset:-20];
    _achievementButton.y = 100;
}


#pragma mark - ModaliPadViewController Delegate
- (void)modaliPadViewControllerCancel:(ModaliPadViewController *)controller {
    if ([controller isKindOfClass:[SolveriPadViewController class]]) {
        self.solverAnimator = nil;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - SolveriPadViewController Delegate

- (void)solveriPadDidSelectBuy:(SolveriPadViewController *)controller {
}


- (void)solveriPadDidDisappear:(SolveriPadViewController *)controller {
    NSString *productId = [NSString stringWithFormat:@"%@.solvelevel.5",
                           _gameManager.gameBundleId];

    MKStoreManager *storeManager = [MKStoreManager sharedManager];

#if TARGET_IPHONE_SIMULATOR
    BOOL showSolution = YES;
#else
    BOOL showSolution = [storeManager canConsumeProduct:productId quantity:1];
#endif

    if (!showSolution) {
        return;
    }

    [storeManager consumeProduct:productId quantity:1];

    _solverCountView.value = [[MKStoreManager sharedManager] quantityOfProduct:productId];

    self.solverAnimator = [SolverAnimator animator];
    _solverAnimator.level = _gameManager.currentLevel;
    [_solverAnimator setAnimatorDidStopSelector:@selector(solverAnimatorDidStop)
                                   withDelegate:self];
    _groundViewController.touchesInteractionEnabled = NO;
    [_hintsAnimator stop];
    [_solverAnimator start];
}


- (void)solverAnimatorDidStop {
    [_tapToContinueAnimator start];
    [_gameManager didSolveNewLevel:_gameManager.level];

    if (_gameManager.level == _gameManager.levelMaximum) {
        _gameManager.levelMaximum++;
    }

    [self displayAchievements];
}


#pragma mark - CMGotoViewControllerDelegate delegate

- (void)didSelectLevel:(NSUInteger)level controller:(CMGotoViewController *)controller {
    if ((level != _gameManager.level) && (level <= _gameManager.levelMaximum)) {
        // raz of the hints manager;
        _gameManager.levelsWithoutHintCount = 0;

        NSString *previousMusicPath = [_gameManager musicPathForControllerName:@"Play"];

        [self loadLevel:level];

        NSString *newMusicPath = [_gameManager musicPathForControllerName:@"Play"];

        if (![previousMusicPath isEqualToString:newMusicPath] && newMusicPath) {
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:newMusicPath];
        }
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Tutorial managment

- (void)tutorialDidChangePage:(TutorialViewController *)controller {
}


- (void)tutorialDidChangeSection:(TutorialViewController *)controller {
    controller.view.hidden = YES;
    controller.textLabel.hidden = YES;
    _groundViewController.touchesInteractionEnabled = YES;
}


- (void)tutorialDidFinish:(TutorialViewController *)controller {
    [self.tutorialViewController.view removeFromSuperview];
    self.tutorialViewController = nil;

    // we have finish the tutorial
    [_gameManager.gameCenterManager reportAchievementIdentifier:@"tutorial"];

    [self displayAchievements];
}


- (void)addTutorialView {
    if (_tutorialViewController || (_gameManager.mode != kGameModeClassic)) {
        return;
    }

    self.tutorialViewController = [[TutorialViewController alloc] init];
    _tutorialViewController.gameManager = _gameManager;
    _tutorialViewController.delegate = self;

    // put the tutorial in the right bottom corner
    _tutorialViewController.view.x = self.view.width - _tutorialViewController.view.width;
    _tutorialViewController.view.y = self.view.height - _tutorialViewController.view.height;
    _tutorialViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                                    UIViewAutoresizingFlexibleTopMargin;

    [self.tutorialViewController loadFirstPage];
    [self.view addSubview:_tutorialViewController.view];

    [_tutorialViewController.view addParallaxEffect:20];
}


- (void)removeTutorialView {
    [self.tutorialViewController.view removeFromSuperview];
    self.tutorialViewController = nil;
}


- (void)addMeonHeader {
    UIImage *logoImage = [UIImage imageNamed:@"Common/banner-meon-logo~ipad.png"];
    UIImageView *aLogoView = [[UIImageView alloc] initWithImage:logoImage];
    aLogoView.contentMode = UIViewContentModeScaleToFill;
    aLogoView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |
                                 UIViewAutoresizingFlexibleBottomMargin;

    CGFloat width = logoImage.size.width;
    CGFloat height = logoImage.size.height;
    CGRect logoRect = (CGRect){{-250, -10}, {width * 0.8, height * 0.8}};

    aLogoView.frame = logoRect;
#if defined (LITE)
    [self.view insertSubview:aLogoView belowSubview:_buyButton];
#else
    [self.view addSubview:aLogoView];
#endif
}


- (void)setButtonsVisible:(BOOL)visible animated:(BOOL)animated {
    NSTimeInterval duration = 0.4;
    CGFloat toAlpha = visible ? 1.0 : 0.0;
    NSSet *views = [NSSet setWithObjects:
                    _gotoButton, _solverButton, _hintsButton,
                    _menuButton, _levelView, _levelTxtView,
                    _achievementButton, _tweetButton, nil];

    // if there is an animation we insure that the animation is
    // visible
    if (animated) {
        for (UIView *view in views) {
            view.hidden = NO;
        }

        [UIView animateWithDuration:duration animations:^{
             for (UIView *view in views) {
                 view.alpha = toAlpha;
             }
         }
                         completion:^(BOOL finished){
             for (UIView *view in views) {
                 view.hidden = !visible;
             }
         }];
    }
    else {
        for (UIView *view in views) {
            view.alpha = toAlpha;
            view.hidden = !visible;
        }
    }
}


- (void)setBuyButtonVisibleAnimated:(BOOL)animated {
    _buyButton.hidden = NO;
    if (animated) {
        NSTimeInterval duration = 0.4;
        _buyButton.x = -_buyButton.width;
        [UIView animateWithDuration:duration animations:^{
             _buyButton.x = 0;
         }];
    }
}


- (void)setBannerViewVisibleAnimated:(BOOL)animated {
    UIImage *logoImage = _logoView.image;
    CGRect logoFrame = (CGRect){{0, 0}, {logoImage.size.width, logoImage.size.height}};

    if (animated) {
        NSTimeInterval duration = 0.4;
        [UIView animateWithDuration:duration animations:^{
             _logoView.frame = logoFrame;
         } completion:^(BOOL finished){
#if defined (LITE)
             [self setBuyButtonVisibleAnimated:YES];
#endif
         }];
    }
    else {
        _logoView.frame = logoFrame;
#if defined (LITE)
        [self setBuyButtonVisibleAnimated:NO];
#endif
    }
}


- (void)setGroundViewVisibleAnimated:(BOOL)animated {
    if (!_groundViewController) {
        [self createGroundViewController];
    }

    DebugLog(@"setGroundViewVisibleAnimated view=(%.0f,%.0f,%.0f,%.0f) statusBarOrientation=%ld",
             self.view.bounds.origin.x,
             self.view.bounds.origin.y,
             self.view.bounds.size.width,
             self.view.bounds.size.height,
             [[UIApplication sharedApplication] statusBarOrientation]);


    CGFloat x = floor((self.view.width - _groundViewController.view.width) / 2);
    CGFloat y = (self.view.frame.size.width > 1000) ? 100 : 175;

    CGRect frame = (CGRect){{x, y},
                            {_groundViewController.view.frame.size.width,
                             _groundViewController.view.frame.size.height}};

    if (animated) {
        NSTimeInterval duration = 0.4;
        [UIView animateWithDuration:duration animations:^{
             _groundViewController.view.frame = frame;
         }];
    }
    else {
        _groundViewController.view.frame = frame;
    }
}


#pragma mark - Time Attack specific
- (void)startCounter {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                      target:self
                                                    selector:@selector(counterTimerFired:)
                                                    userInfo:nil
                                                     repeats:YES];
    [_counterTimer invalidate];
    self.counterTimer = timer;
    [self.counterTimer fire];
}


- (void)counterTimerFired:(NSTimer *)theTimer {
    if (![self isTouchesInteractionEnabled]) {return; }

    _gameManager.counter += 1;
    _counterView.value = _gameManager.counter;
}


#pragma mark - iCloud Notification

- (void)registerToiCloudNotification {
    if (_gameManager.mode == kGameModeClassic) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveNewLevelFromiCloud:)
                                                     name:GameManagerNewLevelFromiCloud
                                                   object:nil];
    }
}


- (void)unregisterFromiCloudNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GameManagerNewLevelFromiCloud
                                                  object:nil];
}


- (void)didReceiveNewLevelFromiCloud:(NSNotification *)theNotif {
    if (_iCloudAlertView) {
        DebugLog(@"Already received notification");
        return;
    }

#if defined(LITE)
    if (_gameManager.level == 31) {
        return;
    }
#else
    if (_gameManager.level == 120) {
        return;
    }
#endif

    NSString *title = NSLocalizedString(@"L_iCloudReceivedNewLevelTitle", );
    NSString *message = NSLocalizedString(@"L_iCloudReceivedNewLevelMessage", );
    NSString *cancelLabel = NSLocalizedString(@"L_iCloudReceivedNewLevelCancelButton", );
    NSString *okLabel = NSLocalizedString(@"L_iCloudReceivedNewLevelOkButton", );

    [_shareViewController dismissShareView];
    self.iCloudAlertView = [[UIAlertView alloc] initWithTitle:title
                                                      message:message
                                                     delegate:self
                                            cancelButtonTitle:cancelLabel
                                            otherButtonTitles:okLabel, nil];
    _iCloudAlertView.tag = kReceiveNewLevelFromiCloud;
    [_iCloudAlertView show];
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
    [_shareViewController dismissShareView];

    [_gameManager.currentLevel updateObjectSpritesForceRedraw:YES];
    if ([_gameManager.currentLevel isCompleted] && (_gameManager.mode == kGameModeClassic)) {
        [_tapToContinueAnimator stop];
        [_tapToContinueAnimator start];
    }
}


- (void)gameOverDidCompletedAnimation:(GameOverViewController *)controller {
    [self displayAchievements];
}


- (void)gameOverDidSelectReplay:(GameOverViewController *)controller {
    [_gameOverViewController addCurrentScoreToHighscore];

    // remove any animation
    [_sloganAnimator stop];
    [_completedAnimator stop];

    // remove gameOverViewController
    [_gameOverViewController.view removeFromSuperview];
    self.gameOverViewController = nil;

    self.groundViewController.groundView.transform = CGAffineTransformIdentity;

    [self layoutTimeAttackCounterViewAnimated:NO];

    // reset the counter
    [_gameManager resetCounter];
    _counterView.value = _gameManager.counter;


    [self loadLevel:0];

    NSString *newMusicPath = [_gameManager musicPathForControllerName:@"Play"];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:newMusicPath];

    [_startAnimator start];
    [self startCounter];
}


#pragma mark - Congratulation animation

- (void)startCongratulationAnimation {
    [_groundViewController rasterizeGroundView];

    self.completedGameAnimator = [CompletedGameAnimator animator];
    _completedGameAnimator.groundView = _groundViewController.rasterizedGroundView;
    NSArray *buttons = @[_gotoButton,
                         _solverButton,
                         _menuButton,
                         _hintsButton,
                         _achievementButton,
                         _buyButton,
                         _tweetButton];
    _completedGameAnimator.buttons = buttons;
    [_completedGameAnimator setAnimatorDidStopSelector:@selector(completedGameAnimationDidStop)
                                          withDelegate:self];

    [_completedGameAnimator start];
}


- (void)completedGameAnimationDidStop {
    [_delegate playiPadDidFinishGame:self];
}


@end

