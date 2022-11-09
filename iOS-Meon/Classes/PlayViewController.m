//
//  PlayViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/2/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import "PlayViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <Twitter/Twitter.h>

#import "Achievement.h"
#import "AchievementViewController.h"
#import "BoardStore.h"
#import "CMBitmapNumberView.h"
#import "CMButton+Meon.h"
#import "CMShareViewController.h"
#import "Common.h"
#import "CompletedAnimator.h"
#import "GameCenterManager.h"
#import "GameManager.h"
#import "GameOverViewController.h"
#import "GotoViewController.h"
#import "GroundView.h"
#import "HintsAnimator.h"
#import "Level.h"
#import "LevelManager.h"
#import "MKStoreManager.h"
#import "PlayViewController+Animations.h"
#import "Score.h"
#import "SimpleAudioEngine.h"
#import "SloganAnimator.h"
#import "SolverAnimator.h"
#import "SolverViewController.h"
#import "Sprite.h"
#import "StartAnimator.h"
#import "TutorialViewController.h"
#import "UIColor+Helper.h"
#import "UIDevice+Helper.h"
#import "UIView+Helper.h"
#import "UIView+Motion.h"
#import "UIViewController+Helper.h"
#import "tile.h"

#define kRateAlertView 10
#define kLeftTimeAttackAlertView 11
#define kUseSolver 12
#define kReceiveNewLevelFromiCloud 13

@interface PlayViewController ()

@property (nonatomic, strong) NSTimer *counterTimer;
@property (nonatomic, strong) SolverAnimator *solverAnimator;
@property (nonatomic, strong) SloganAnimator *sloganAnimator;
@property (nonatomic, strong) StartAnimator *startAnimator;
@property (nonatomic, strong) TapToContinueAnimator *tapToContinueAnimator;
@property (nonatomic, strong) CompletedAnimator *completedAnimator;
@property (nonatomic, strong) HintsAnimator *hintsAnimator;
@property (nonatomic, strong) UIAlertView *iCloudAlertView;
@property (nonatomic, strong) NSMutableDictionary *selectedSprites;
@property (nonatomic, assign, readwrite) CGFloat groundViewScale;

@end



#pragma mark - PlayViewController implementation


@implementation PlayViewController

#pragma mark - UIViewController Stuff

- (void)loadView {
    [self registerToForegroundNotification];
    [self registerToiCloudNotification];

    // Create the view.
    UIColor *backgroundColor = [UIColor colorWithHexCode:0x252c40];

    CGRect frame = [UIViewController fullscreenFrame];
    UIView *view = [[UIImageView alloc] initWithFrame:frame];
    view.opaque = YES;
    view.userInteractionEnabled = YES;
    view.backgroundColor = backgroundColor;
    self.view = view;


    // Add ground view.
    frame = CGRectMake(0, 38, 360, 360);
    self.groundView = [[GroundView alloc] initWithFrame:frame];
    self.groundView.opaque = YES;
    self.groundView.backgroundColor = backgroundColor;
    self.groundViewScale = 1;
    [self.view addSubview:self.groundView];

    if (self.view.height > 667) {
        self.groundViewScale = 1.25;
    }

    // On centre la groundView dans la vue restante, en enlevant la barre de
    // "menu haute et basse.
    self.groundView.scale = self.groundViewScale;
    CGFloat dy = (self.view.height - (64 + 106) - (360 * self.groundViewScale)) / 2;
    self.groundView.y = floor(64 + dy);

    // Add header & footer image.
    [self addImageView:CGPointZero
                   parent:self.view
         defaultImageName:@"header0"
     highlightedImageName:nil
         autoresizingMask:0];

    UIView *footerView = [self addImageView:CGPointZero
                                     parent:self.view
                           defaultImageName:@"Common/footer0.png"
                       highlightedImageName:nil
                           autoresizingMask:0];
    [footerView alignWithBottomSideOf:self.view];

    [self addButtons];

    // -- counter view
    CGRect counterViewFrame = (CGRect){{4, 374}, {131, 38}};
    self.counterView = [[CMBitmapNumberView alloc] initWithFrame:counterViewFrame];
    [self.view addSubview:self.counterView];
    self.counterView.backgroundColor = [UIColor clearColor];
    [self.counterView alignWithBottomSideOf:self.view offset:62];

    self.pointsView = [self addImageView:(CGPoint){289, 384}
                                  parent:self.view
                        defaultImageName:@"Common/pts.png"
                    highlightedImageName:nil
                        autoresizingMask:0];
    [self.pointsView alignWithBottomSideOf:self.view offset:79];

    self.levelTxtView = [self addImageView:(CGPoint){191, 458}
                                    parent:self.view
                          defaultImageName:@"Common/level0.png"
                      highlightedImageName:nil
                          autoresizingMask:0];
    [self.levelTxtView alignWithBottomSideOf:self.view];



    // some initialization
    self.selectedSprites = [[NSMutableDictionary alloc] init];

    // create animators
    self.sloganAnimator = [SloganAnimator animator];
    self.sloganAnimator.superLayer = self.view.layer;
    [self.sloganAnimator setAnimatorDidStopSelector:@selector(endLevelAnimationDidStop)
                                       withDelegate:self];

    if ((self.gameManager.mode == kGameModeTimeAttackFlash) ||
        (self.gameManager.mode == kGameModeTimeAttackMarathon) ||
        (self.gameManager.mode == kGameModeTimeAttackMedium)) {

        self.startAnimator = [StartAnimator animator];
        self.startAnimator.superLayer = self.view.layer;

        self.completedAnimator = [CompletedAnimator animator];
        self.completedAnimator.sloganImage = [UIImage imageNamed:@"Common/gameover.png"];
        self.completedAnimator.superLayer = self.view.layer;
        self.completedAnimator.groundView = self.groundView;
        self.completedAnimator.counterView = self.counterView;
        self.completedAnimator.ySlogan = 100.0;
    }
    else {
        self.tapToContinueAnimator = [TapToContinueAnimator animator];
        self.tapToContinueAnimator.superLayer = self.view.layer;

        self.hintsAnimator = [HintsAnimator animator];
    }

    self.groundView.dataSource = self.gameManager.currentLevel.cells;
    self.groundView.multipleTouchEnabled = YES;
    self.gameManager.currentLevel.layoutView = self.groundView;

    // add the big level image except in world mode
    if (self.gameManager.mode != kGameModeWorld) {
        self.levelView = [[CMBitmapNumberView alloc] initWithFrame:CGRectZero];
        [self.view insertSubview:self.levelView belowSubview:self.levelTxtView];
    }


    // add the counter in time attack mode
    if ((self.gameManager.mode == kGameModeTimeAttackFlash) ||
        (self.gameManager.mode == kGameModeTimeAttackMarathon) ||
        (self.gameManager.mode == kGameModeTimeAttackMedium)) {
        self.counterView.digitsImage = [UIImage imageNamed:@"Digit/digit-level0-small.png"];
        self.counterView.letterSpacing = -0.2;
        self.counterView.value = self.gameManager.counter;
    }
    // add the miniscore in classic mode
    else if (self.gameManager.mode == kGameModeClassic) {
        frame = CGRectMake(209, 378, 82, 32);

        self.scoreLabel = [[THLabel alloc] initWithFrame:frame];
        self.scoreLabel.textAlignment = NSTextAlignmentRight;
        self.scoreLabel.text = @"395";
        self.scoreLabel.font = [UIFont fontWithName:@"BradyBunchRemastered" size:33];
        self.scoreLabel.textColor = [UIColor colorWithHexCode:0x00ffff];
        self.scoreLabel.strokeSize = 2;
        self.scoreLabel.letterSpacing = 1.5;
        self.scoreLabel.strokeColor = [UIColor colorWithHexCode:0x0600ff];
        [self.scoreLabel alignWithBottomSideOf:self.view offset:75];
        [self.view addSubview:self.scoreLabel];



        // create the solver count
        NSString *productId = [NSString stringWithFormat:@"%@.solvelevel.5",
                               self.gameManager.gameBundleId];

        frame = CGRectMake(148, 393, 24, 24);
        self.solverCountView = [[CMBitmapNumberView alloc]initWithFrame:frame];
        self.solverCountView.hidesWhenValueIsZero = YES;
        self.solverCountView.opaque = NO;
        self.solverCountView.digitsImage = [UIImage imageNamed:@"Common/Pastille.png"];
        self.solverCountView.value = [[MKStoreManager sharedManager] quantityOfProduct:productId];
        [self.view addSubview:self.solverCountView];
        [self.solverCountView alignWithBottomSideOf:self.view offset:63];
    }

    // depending the game mode, switch visibility
    BOOL classic = self.gameManager.mode == kGameModeClassic;
    BOOL tweetButtonEnabled = (self.gameManager.mode == kGameModeClassic) &&
                              (NSClassFromString(@"TWTweetComposeViewController"));

    self.pointsView.hidden = !classic;
    self.counterView.hidden = classic;
    self.gotoButton.hidden = !classic;
    self.hintsButton.hidden = !classic;
    self.solverButton.hidden = !classic;
    self.tweetButton.hidden = !classic || !tweetButtonEnabled;
    if (!tweetButtonEnabled) {
        self.gotoButton.x += 8;
        self.solverButton.x += 2 * 8;
        self.solverCountView.x += 2 * 8;
    }

#if defined(LITE)
    self.buyButton.hidden = NO;
#else
    self.buyButton.hidden = YES;
#endif

    [self loadLevel:self.gameManager.level];
}


- (void)addButtons {
    self.hintsButton = [self addButton:(CGPoint){-6, 391}
                                  parent:self.view
                                   title:@"Show hints"
                                  action:@selector(hints:)
                        defaultImageName:@"Common/hintsButton.png"
                    highlightedImageName:nil
                        autoresizingMask:0];
    [self.hintsButton alignWithBottomSideOf:self.view offset:17];


    self.gotoButton = [self addButton:(CGPoint){49, 391}
                                 parent:self.view
                                  title:@"Go to level"
                                 action:@selector(goTo:)
                       defaultImageName:@"Common/gotoButton.png"
                   highlightedImageName:nil
                       autoresizingMask:0];
    [self.gotoButton alignWithBottomSideOf:self.view offset:17];

    self.solverButton = [self addButton:(CGPoint){104, 391}
                                   parent:self.view
                                    title:@"Solver"
                                   action:@selector(showSolution:)
                         defaultImageName:@"Common/solverButton.png"
                     highlightedImageName:nil
                         autoresizingMask:0];
    [self.solverButton alignWithBottomSideOf:self.view offset:17];

    NSString *imageName = @"Common/shareButton.png";

    self.tweetButton = [self addButton:(CGPoint){159, 391}
                                  parent:self.view
                                   title:@"Share"
                                  action:@selector(share:)
                        defaultImageName:imageName
                    highlightedImageName:nil
                        autoresizingMask:0];
    [self.tweetButton alignWithBottomSideOf:self.view offset:17];


    CMButton *menuButton = [CMButton buttonWithStyle:CMButtonMeonStyleNormal];
    [menuButton setTitle:@"menu" forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menu:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:menuButton];
    menuButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[menuButton]-2-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(menuButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[menuButton]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(menuButton)]];


    self.buyButton = [self addButton:CGPointZero
                                parent:self.view
                                 title:@"Buy Full"
                                action:@selector(buy:)
                      defaultImageName:@"Common/buy.png"
                  highlightedImageName:nil
                      autoresizingMask:0];
}


- (void)loadLevel:(NSUInteger)level {
    //remove any animation
    [self.tapToContinueAnimator stop];

#if defined(LITE)
    level = MIN(level, 31);
#else
    level = MIN(level, 120);
#endif

    self.gameManager.level = level;

    [self.gameManager loadLevel];

    // On centre horizontalement le niveau dans la vue.
    CGFloat x = (self.view.width - (self.gameManager.currentLevel.levelWidthInPoint * self.groundViewScale)) / 2;
    self.groundView.x = floorf(x - (self.gameManager.currentLevel.levelDeltaXInPoint * self.groundViewScale));

    //-- set the hints
    self.hintsAnimator.hintsSprites = self.gameManager.currentLevel.hintsSprites;

    //-- add the level view
    NSString *imageName = [NSString stringWithFormat:@"Digit/digit-level%lu.png",
                           (self.gameManager.level / 10) % 5];
    BOOL isLevelViewShrinked = (self.gameManager.level > 99);

    self.levelView.opaque = NO;
    self.levelView.digitsImage = [UIImage imageNamed:imageName];
    self.levelView.letterSpacing = -0.23;
    self.levelView.value = self.gameManager.level;
    self.levelView.alignment = NSTextAlignmentRight;
    self.levelView.scale = (isLevelViewShrinked == YES) ? 0.8 : 1.0;
    self.levelView.userInteractionEnabled = NO;
    [self.levelView sizeToFit];

    self.levelView.x = self.view.width - self.levelView.width;
    [self.levelView alignWithBottomSideOf:self.view offset:75 - self.levelView.height];

    NSString *levelTxtImageName = [NSString stringWithFormat:@"Common/level%lu.png",
                                   (self.gameManager.level / 10) % 5];
    self.levelTxtView.image = [UIImage imageNamed:levelTxtImageName];
    self.levelTxtView.x = self.levelView.x - self.levelTxtView.width + 42;
    self.levelTxtView.accessibilityLabel = levelTxtImageName;
    self.levelTxtView.accessibilityValue = [NSString stringWithFormat:@"Level %lu",
                                            self.gameManager.level];
    if (isLevelViewShrinked) {self.levelTxtView.x += 40; }

    [self.groundView setNeedsDisplay];

    //-- achievements
    [self displayAchievements];

    //-- tutorial
    [self.tutorialViewController loadFirstPage];
    self.tutorialViewController.view.hidden = NO;
    if ((self.gameManager.level < [self.gameManager numberOfSectionForTutorial]) &&
        (![self.gameManager.currentLevel isCompleted])) {
        [self addTutorialView];
    }
    else {
        [self removeTutorialView];
    }
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.counterView = nil;
    self.gotoButton = nil;
    self.hintsButton = nil;
    self.solverButton = nil;
    self.levelTxtView = nil;
    self.pointsView = nil;
    self.buyButton = nil;
    self.tweetButton = nil;
}


- (void)dealloc {
    DebugLog(@"dealloc PlayViewController");

    [self unregisterFromForegroundNotification];
    [self unregisterFromiCloudNotification];

    [self.completedAnimator setAnimatorDidStopSelector:NULL withDelegate:nil];
    [self.tapToContinueAnimator setAnimatorDidStopSelector:NULL withDelegate:nil];
    [self.startAnimator setAnimatorDidStopSelector:NULL withDelegate:nil];
    [self.sloganAnimator setAnimatorDidStopSelector:NULL withDelegate:nil];
    [self.solverAnimator setAnimatorDidStopSelector:NULL withDelegate:nil];
    [self.hintsAnimator setAnimatorDidStopSelector:NULL withDelegate:nil];

    [self.counterTimer invalidate];
}


- (void)transitionAnimationDidStopFrom:(NSString *)from to:(NSString *)to {
    //do something
    if (self.gameManager.mode != kGameModeClassic) {
        [self.startAnimator start];
        [self startCounter];
    }
    else {
        // Sync with iCloud
        if ((self.gameManager.level < self.gameManager.levelMaximumiCloud)) {
            DebugLog(@"Level in iCloud %lu is greater than current level %lu",
                     self.gameManager.levelMaximumiCloud, self.gameManager.level);
            [self didReceiveNewLevelFromiCloud:nil];
        }

        // first, we test if the level is already ended
        if ([self.gameManager.currentLevel isCompleted]) {
            [self.tapToContinueAnimator start];
            return;
        }
        if(self.gameManager.level < [self.gameManager numberOfSectionForTutorial]) {
            [self addTutorialView];
        }
    }
}


#pragma mark -
#pragma mark Touch Managment

- (BOOL)isTouchesInteractionEnabled {
    // if tutorial is visible, can't do anything
    // if animation running don't do anything
    if ((self.tutorialViewController && !self.tutorialViewController.view.hidden) ||
        self.sloganAnimator.isRunning ||
        self.startAnimator.isRunning ||
        self.tapToContinueAnimator.isRunning ||
        self.completedAnimator.isRunning ||
        self.solverAnimator.isRunning) {
        return NO;
    }
    else {
        return YES;
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![self isTouchesInteractionEnabled]) {return; }

    for(UITouch *touch in touches) {
        CGPoint pt = [touch locationInView:self.groundView];
        Sprite *sprite = [self.gameManager.currentLevel nearestSprite:pt
                                                             inRadius:1.5 * 30
                                                         meonFiltered:YES];
        if (!sprite) {continue; }

        NSNumber *key = @((unsigned int)touch.self);
        self.selectedSprites[key] = sprite;
        [sprite touchesBegan];
    }

    [self touchesMoved:touches withEvent:event];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![self isTouchesInteractionEnabled]) {return; }

    int colDst, rowDst, colSrc, rowSrc;

    for(UITouch *touch in touches) {

        NSNumber *key = @((unsigned int)touch.self);
        Sprite *selectedSprite = self.selectedSprites[key];
        CGPoint pt = [touch locationInView:self.groundView];

        colDst = pt.x / 30;
        rowDst = pt.y / 30;
        colSrc = selectedSprite.center.x / 30;
        rowSrc = selectedSprite.center.y / 30;


        //DebugLog(@"colDst= %d rowDst= %d", colDst, rowDst);

        if (((colDst == colSrc) && (rowDst == rowSrc)) ||
            ([self.gameManager.currentLevel tileAtCol:colDst row:rowDst] >= kTilePlain) ||
            (colDst <= 0) || (colDst >= 11) ||
            (rowDst <= 0) || (rowDst >= 11) ||
            !selectedSprite) {
            continue;
        }


        selectedSprite.center = (CGPoint){(colDst * 30) + 15, (rowDst * 30) + 15};

        [self.gameManager.currentLevel moveSprite:selectedSprite
                                           colSrc:colSrc
                                           rowSrc:rowSrc
                                           colDst:colDst
                                           rowDst:rowDst];
    }

    if ([self.gameManager.currentLevel isCompleted]) {

        [self.selectedSprites removeAllObjects];
        [self.gameManager didSolveNewLevel:self.gameManager.level];
        [self.hintsAnimator stop];
        [self.sloganAnimator start];
        [self displayAchievements];
    }
}


- (void)endLevelAnimationDidStop {

    BOOL pauseBetweenLevels = [[NSUserDefaults standardUserDefaults]
                               boolForKey:@"pauseBetweenLevels"];
    if (pauseBetweenLevels && (self.gameManager.mode == kGameModeClassic)) {
        [self.tapToContinueAnimator start];
    }
    else {
        [self forward:nil];
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // click on view while tutorial is shown
    if (self.tutorialViewController && !self.tutorialViewController.view.hidden) {
        [self.tutorialViewController nextPage];
        return;
    }

    // click on view while click-to-continue is shown
    if (self.tapToContinueAnimator.isRunning) {
        [self.tapToContinueAnimator stop];
        [self forward:nil];
        return;
    }

    for(UITouch *touch in touches) {
        NSNumber *key = @((unsigned int)touch.self);
        [self.selectedSprites removeObjectForKey:key];
    }
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}


#pragma mark - Action

- (IBAction)goTo:(id)sender {

    if (self.gameManager.mode != kGameModeWorld) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"GotoLevel" bundle:nil];
        CMGotoViewController *controller = [storyboard instantiateInitialViewController];
        controller.delegate = self;
        controller.currentLevel = self.gameManager.level;
        controller.maximumLevel = self.gameManager.levelMaximum;
        [self presentViewController:controller animated:YES completion:nil];
    }
    else {
        [self.delegate playDidFinishWorldLevel:self];
    }
}


- (void)back:(id)sender {
    if (self.gameManager.level > 0) {
        [self loadLevel:--self.gameManager.level];
    }
}


- (void)forward:(id)sender {
    //
    // test if we need to rate the game
    if (((self.gameManager.level == 15) || (self.gameManager.level == 50))
        && self.gameManager.mode == kGameModeClassic) {

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSInteger level = [defaults integerForKey:@"levelForRating"];

        if (level == self.gameManager.level) {
            NSString *title = NSLocalizedString(@"Lself.RateMeonTitle", );
            NSString *message = NSLocalizedString(@"L_RateMeonMessage", );
            NSString *cancelLabel = NSLocalizedString(@"L_RateMeonCancelButton", );
            NSString *okLabel = NSLocalizedString(@"L_RateMeonOkButton", );


            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:cancelLabel
                                                  otherButtonTitles:okLabel, nil];
            alert.tag = kRateAlertView;
            [alert show];


            if (self.gameManager.level == 15) {
                level = 50;
            }
            else if (self.gameManager.level == 50) {
                level = -1;
            }

            [defaults setInteger:level forKey:@"levelForRating"];
            [defaults synchronize];
        }
    }

    //
    // test if we've reached the maximum number of level
    if (self.gameManager.level < [self.gameManager levelLimit]) {

        NSString *previousMusicPath = [self.gameManager musicPathForControllerName:@"Play"];

        [self loadLevel:++self.gameManager.level];

        NSString *newMusicPath = [self.gameManager musicPathForControllerName:@"Play"];

        if (![previousMusicPath isEqualToString:newMusicPath] && newMusicPath) {
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:newMusicPath];
        }

        if (self.gameManager.level < [self.gameManager numberOfSectionForTutorial]) {
            [self addTutorialView];
        }
        else {
            [self removeTutorialView];
        }
    }
    else {
        // we don't save the last level state in Classic and TimeAttack Mode
        if (self.gameManager.mode != kGameModeWorld) {
            [self.gameManager setSavedLevel:self.gameManager.levelLimit];
        }


        // if classic mode, start the congratulation animation
        if (self.gameManager.mode == kGameModeClassic) {

            // be sure the level maximum is registered
            self.gameManager.levelMaximum = self.gameManager.levelLimit + 1;

#if defined(LITE)
            [self.delegate playDidFinishGame:self];
            return;
#endif
            self.view.userInteractionEnabled = NO;
            [self startCongratulationAnimation];
        }
        // if world mode, go to the world selection
        else if (self.gameManager.mode == kGameModeWorld) {

            // TODO: better way to do this ? with serialize ?
            // save the string level inside the original
            NSArray *levels = [[LevelManager sharedLevelManager] worldLevels];
            NSMutableDictionary *level = levels[self.gameManager.level];
            NSString *compressedLevel = [self.gameManager.currentLevel string];
            level[kLevelOriginalKey] = compressedLevel;


            [self.delegate playDidFinishWorldLevel:self];
        }
        // if mode time attack, it's finished
        else {
            // stop the counter
            [self.counterTimer invalidate];
            self.counterTimer = nil;

#if defined(LITE)
            if ((self.gameManager.mode == kGameModeTimeAttackMedium) ||
                (self.gameManager.mode == kGameModeTimeAttackMarathon)) {
                [self.delegate playDidFinishGame:self];
                return;
            }
#endif

            // load the game over view controller
            GameOverViewController *gameOverController = [[GameOverViewController alloc]
                                                          init];
            gameOverController.gameManager = self.gameManager;
            gameOverController.delegate = self;
            self.gameOverViewController = gameOverController;
            self.gameOverViewController.view.y = 120;
            [self.gameOverViewController gameOverViewControllerviewWillAppear:NO];
            [self.view addSubview:self.gameOverViewController.view];
            [self.gameOverViewController gameOverViewControllerDidAppear:NO];

            [self.completedAnimator start];
        }
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case kRateAlertView:
            if (buttonIndex == alertView.firstOtherButtonIndex) {
                [[UIApplication sharedApplication] openURL:self.gameManager.reviewsURL];
            }
            break;
        case kLeftTimeAttackAlertView:
            if (buttonIndex == alertView.firstOtherButtonIndex) {
                [self.delegate playDidSelectMenu:self];
            }
            else {
                [self startCounter];
            }
            break;
        case kUseSolver:
            if (buttonIndex == alertView.firstOtherButtonIndex) {

                NSString *productId = [NSString stringWithFormat:@"%@.solvelevel.5",
                                       self.gameManager.gameBundleId];

                if ([[MKStoreManager sharedManager] canConsumeProduct:productId quantity:1]) {
                    [[MKStoreManager sharedManager] consumeProduct:productId quantity:1];

                    self.solverCountView.value = [[MKStoreManager sharedManager] quantityOfProduct:productId];

                    self.gameManager.levelMaximum++;

                    self.solverAnimator = [SolverAnimator animator];
                    self.solverAnimator.level = self.gameManager.currentLevel;
                    [self.solverAnimator setAnimatorDidStopSelector:@selector(solverAnimatorDidStop)
                                                       withDelegate:self];
                    [self.hintsAnimator stop];
                    [self.solverAnimator start];
                    self.gameManager.levelsWithoutHintCount = 0;
                }
            }
            break;
        case kReceiveNewLevelFromiCloud:
            self.iCloudAlertView = nil;
            if (buttonIndex == alertView.firstOtherButtonIndex) {
                NSString *previousMusicPath = [self.gameManager musicPathForControllerName:@"Play"];
                [self loadLevel:self.gameManager.levelMaximum];
                NSString *newMusicPath = [self.gameManager musicPathForControllerName:@"Play"];
                if (![previousMusicPath isEqualToString:newMusicPath] && newMusicPath) {
                    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:newMusicPath];
                }
            }
            break;
        default:
            break;
    }
}


- (void)last:(id)sender {
    if (self.gameManager.level < self.gameManager.levelMaximum) {
        [self loadLevel:self.gameManager.levelMaximum];
    }
}


- (IBAction)hints:(id)sender {
    if (![self isTouchesInteractionEnabled]) {return; }

    [self.hintsAnimator start];

    self.gameManager.levelsWithoutHintCount = -1;
}


- (IBAction)menu:(id)sender {
    // stop any pending animation
    [self.counterTimer invalidate];
    self.counterTimer = nil;

    if (((self.gameManager.mode == kGameModeTimeAttackFlash) ||
         (self.gameManager.mode == kGameModeTimeAttackMedium) ||
         (self.gameManager.mode == kGameModeTimeAttackMarathon)) &&
        !self.gameOverViewController) {
        NSString *message = NSLocalizedString(@"L_TimeAttackQuit", );
        NSString *yes = NSLocalizedString(@"L_Yes", );
        NSString *no = NSLocalizedString(@"L_No", );


        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:no
                                              otherButtonTitles:yes, nil];
        alert.tag = kLeftTimeAttackAlertView;
        [alert show];
    }
    else {
        [self.gameOverViewController addCurrentScoreToHighscore];
        [self.delegate playDidSelectMenu:self];
    }
}


- (IBAction)buy:(id)sender {
    [self.delegate playDidSelectBuy:self];
}


- (IBAction)showSolution:(id)sender {
    if (![self isTouchesInteractionEnabled]) {return; }

    NSString *productId = [NSString stringWithFormat:@"%@.solvelevel.5",
                           self.gameManager.gameBundleId];


    // if level has already be passed, show solution
    // or if we have enough solver credit available
    BOOL canShowSolution = NO;

    if (self.gameManager.level < self.gameManager.levelMaximum) {
        canShowSolution = YES;
    }
    else {
        MKStoreManager *storeManager = [MKStoreManager sharedManager];
        if ([storeManager canConsumeProduct:productId quantity:1]) {

            //-- ask to use
            NSString *titleString = NSLocalizedString(@"L_SolverTitle", );
            NSString *messageString = NSLocalizedString(@"L_SolverMessage", );
            NSString *cancelString = NSLocalizedString(@"L_SolverDontUse", );
            NSString *okString = NSLocalizedString(@"L_SolverUse", );

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleString
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
        self.solverAnimator.level = self.gameManager.currentLevel;
        [self.solverAnimator setAnimatorDidStopSelector:@selector(solverAnimatorDidStop)
                                           withDelegate:self];
        [self.hintsAnimator stop];
        [self.solverAnimator start];
        self.gameManager.levelsWithoutHintCount = 0;
    }
    else {
        SolverViewController *solverViewController = [[SolverViewController alloc]
                                                      initWithNibName:nil bundle:nil];
        solverViewController.delegate = self;
        solverViewController.productId = productId;
        [self presentViewController:solverViewController animated:YES completion:nil];
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

    self.shareViewController = [[CMShareViewController alloc] init];
    self.shareViewController.popoverType = CMSharePopoverBottom;
    self.shareViewController.initialText = [self sharedText];
    self.shareViewController.URLString = [[self sharedURL] absoluteString];

    [self.shareViewController presentShareViewAtPoint:origin
                                 parentViewController:self
                                           completion:^{
         self.shareViewController = nil;
     }];
}


- (NSURL *)sharedURL {
    NSString *urlString = [self.gameManager appStoreURLString];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}


- (NSString *)sharedText {
    NSString *format = [self.gameManager.currentLevel isCompleted] ?
                       NSLocalizedString(@"L_ShareByTweetCompleted", ) :
                       NSLocalizedString(@"L_ShareByTweetBlocked", );
    NSString *message = [NSString stringWithFormat:format, self.gameManager.level];

    return message;
}


#pragma mark - SolverViewController delegate

- (void)solverDidSelectBuy:(SolverViewController *)controller {
}


- (void)solverDidSelectCancel:(SolverViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
    self.solverAnimator = nil;
}


- (void)solverDidDisappear:(SolverViewController *)controller {

    NSString *productId = [NSString stringWithFormat:@"%@.solvelevel.5",
                           self.gameManager.gameBundleId];
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

    self.solverCountView.value = [storeManager quantityOfProduct:productId];

    self.solverAnimator = [SolverAnimator animator];
    self.solverAnimator.level = self.gameManager.currentLevel;
    [self.solverAnimator setAnimatorDidStopSelector:@selector(solverAnimatorDidStop)
                                       withDelegate:self];
    [self.hintsAnimator stop];
    [self.solverAnimator start];
}


- (void)solverAnimatorDidStop {
    [self.tapToContinueAnimator start];
    [self.gameManager didSolveNewLevel:self.gameManager.level];

    if (self.gameManager.level == self.gameManager.levelMaximum) {
        self.gameManager.levelMaximum++;
    }

    [self displayAchievements];
}


#pragma mark - Time Attack specific

- (void)startCounter {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                      target:self
                                                    selector:@selector(counterTimerFired:)
                                                    userInfo:nil
                                                     repeats:YES];
    [self.counterTimer invalidate];
    self.counterTimer = timer;
    [self.counterTimer fire];
}


- (void)counterTimerFired:(NSTimer *)theTimer {
    if (![self isTouchesInteractionEnabled]) {return; }

    self.gameManager.counter += 1;
    self.counterView.value = self.gameManager.counter;
}


#pragma mark - Tutorial managment

- (void)tutorialDidChangePage:(TutorialViewController *)controller {
}


- (void)tutorialDidChangeSection:(TutorialViewController *)controller {
    controller.view.hidden = YES;
    controller.textLabel.hidden = YES;
}


- (void)tutorialDidFinish:(TutorialViewController *)controller {
    [self.tutorialViewController.view removeFromSuperview];
    self.tutorialViewController = nil;

    // we have finish the tutorial
    [self.gameManager.gameCenterManager reportAchievementIdentifier:@"tutorial"];

    [self displayAchievements];
}


- (void)addTutorialView {
    if (self.tutorialViewController || (self.gameManager.mode != kGameModeClassic)) {
        return;
    }

    self.tutorialViewController = [[TutorialViewController alloc] init];
    self.tutorialViewController.gameManager = self.gameManager;
    self.tutorialViewController.delegate = self;
    self.tutorialViewController.view.y = self.view.height - self.tutorialViewController.view.height;
    [self.tutorialViewController.view addParallaxEffect:10];

    [self.tutorialViewController loadFirstPage];
    [self.view addSubview:self.tutorialViewController.view];
}


- (void)removeTutorialView {
    [self.tutorialViewController.view removeFromSuperview];
    self.tutorialViewController = nil;
}


#pragma mark - CMGotoViewController delegate

- (void)didSelectLevel:(NSUInteger)level controller:(CMGotoViewController *)controller {

    if ((level != self.gameManager.level) && (level <= self.gameManager.levelMaximum)) {
        // raz of the hints manager;
        self.gameManager.levelsWithoutHintCount = 0;

        NSString *previousMusicPath = [self.gameManager musicPathForControllerName:@"Play"];

        [self loadLevel:level];

        NSString *newMusicPath = [self.gameManager musicPathForControllerName:@"Play"];

        if (![previousMusicPath isEqualToString:newMusicPath] && newMusicPath) {
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:newMusicPath];
        }
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - GameOverViewController delegate

- (void)gameOverDidCompletedAnimation:(GameOverViewController *)controller {
    [self displayAchievements];
}


- (void)gameOverDidSelectReplay:(GameOverViewController *)controller {
    [self.gameOverViewController addCurrentScoreToHighscore];

    // remove any animation
    [self.sloganAnimator stop];
    [self.completedAnimator stop];

    // remove gameOverViewController
    [self.gameOverViewController.view removeFromSuperview];
    self.gameOverViewController = nil;

    self.groundView.transform = CGAffineTransformIdentity;

    CGFloat xSrc = (131 / 2) + 4;
    CGFloat ySrc = (38 / 2) + 374;
    self.counterView.center = CGPointMake(xSrc, ySrc);

    // reset the counter
    [self.gameManager resetCounter];
    self.counterView.value = self.gameManager.counter;


    [self loadLevel:0];

    NSString *newMusicPath = [self.gameManager musicPathForControllerName:@"Play"];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:newMusicPath];

    [self.startAnimator start];
    [self startCounter];
}


#pragma mark - iCloud Notification

- (void)registerToiCloudNotification {
    if (self.gameManager.mode == kGameModeClassic) {
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
    if (self.iCloudAlertView) {
        DebugLog(@"Already received notification");
        return;
    }

#if defined(LITE)
    if (self.gameManager.level == 31) {
        return;
    }
#else
    if (self.gameManager.level == 120) {
        return;
    }
#endif

    NSString *title = NSLocalizedString(@"L_iCloudReceivedNewLevelTitle", );
    NSString *message = NSLocalizedString(@"L_iCloudReceivedNewLevelMessage", );
    NSString *cancelLabel = NSLocalizedString(@"L_iCloudReceivedNewLevelCancelButton", );
    NSString *okLabel = NSLocalizedString(@"L_iCloudReceivedNewLevelOkButton", );

    [self.shareViewController dismissShareView];
    self.iCloudAlertView = [[UIAlertView alloc] initWithTitle:title
                                                      message:message
                                                     delegate:self
                                            cancelButtonTitle:cancelLabel
                                            otherButtonTitles:okLabel, nil];
    self.iCloudAlertView.tag = kReceiveNewLevelFromiCloud;
    [self.iCloudAlertView show];
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
    [self.shareViewController dismissShareView];

    [self.gameManager.currentLevel updateObjectSpritesForceRedraw:YES];
    if ([self.gameManager.currentLevel isCompleted] && (self.gameManager.mode == kGameModeClassic)) {
        [self.tapToContinueAnimator stop];
        [self.tapToContinueAnimator start];
    }
}


#pragma mark - Achievements
- (void)displayAchievements {
    DebugLog(@"displayAchievements");

    self.scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)self.gameManager.score];

    NSMutableArray *achievements = self.gameManager.gameCenterManager.achievementsToDisplay;
    if (!achievements.count || self.achievementViewController) {
        return;
    }

    Achievement *achievement = achievements[0];
    AchievementViewController *anAchievementViewController = [[AchievementViewController alloc]
                                                              init];


    self.achievementViewController = anAchievementViewController;
    self.achievementViewController.achievement = achievement;

    self.achievementViewController.delegate = self;
    [self.achievementViewController viewWillAppear:NO];
    [self.view addSubview:self.achievementViewController.view];
    [self.achievementViewController viewDidAppear:NO];

    // display it, can be safely remove
    [self.gameManager.gameCenterManager.achievementsToDisplay
     removeObject:self.achievementViewController.achievement];
}


- (void)achievementViewControllerDidDismiss:(AchievementViewController *)controller {
    DebugLog(@"achievementViewControllerDidDismiss");

    self.achievementViewController.achievement = nil;

    [self.achievementViewController viewWillDisappear:NO];
    [self.achievementViewController.view removeFromSuperview];
    [self.achievementViewController viewDidDisappear:NO];
    self.achievementViewController = nil;

    // if remaining achievements, just display theme
    if (self.gameManager.gameCenterManager.achievementsToDisplay.count) {
        [self displayAchievements];
    }
}


@end
