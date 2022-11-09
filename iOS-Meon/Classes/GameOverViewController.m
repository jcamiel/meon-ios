//
//  GameOverViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 5/20/10.
//  Copyright 2010 Manbolo. All rights reserved.
//
#import "GameOverViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "BoardStore.h"
#import "CMBitmapNumberView.h"
#import "GameManager.h"
#import "Score.h"
#import "UIView+Helper.h"
#import "UIViewController+Helper.h"


#pragma mark Implementation

@implementation GameOverViewController

#pragma mark - dealloc
- (void)dealloc {
    self.gameManager.boardStore.delegate = nil;
}


- (void)loadView {
    BOOL isiPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    CGFloat viewWidth = isiPad ? 720 : 320.0;
    CGFloat viewHeight = isiPad ? 400 : 191;

    CGRect viewFrame = (CGRect){{0, 0}, {viewWidth, viewHeight}};

    UIView *aView = [[UIView alloc] initWithFrame:viewFrame];
    aView.backgroundColor = [UIColor clearColor];
    self.view = aView;

    CGFloat xSrc = 10;
    CGFloat ySrc = isiPad ? 50 : 20;
    CGFloat width = (viewWidth / 2) - xSrc;
    CGFloat normalFontSize = isiPad ? 40 : 22;
    CGFloat deltaY = isiPad ? 50 : 36;
    UIFont *font = [UIFont fontWithName:@"BradyBunchRemastered" size:normalFontSize];
    self.labels = [NSMutableArray array];
    UILabel *label = nil;

    label = [self addLabel:(CGRect){{xSrc, ySrc}, {width, normalFontSize}}
                    parent:self.view
                      text:NSLocalizedString(@"L_GameOverYourScore", )
                      font:font];
    [self.labels addObject:label];

    label = [self addLabel:(CGRect){{xSrc, ySrc + 1 * deltaY}, {width, normalFontSize}}
                    parent:self.view
                      text:NSLocalizedString(@"L_GameOverHighScore", )
                      font:font];
    [self.labels addObject:label];

    label = [self addLabel:(CGRect){{xSrc, ySrc + 2 * deltaY}, {width, normalFontSize}}
                    parent:self.view
                      text:NSLocalizedString(@"L_GameOverYourName", )
                      font:font];
    [self.labels addObject:label];

    CGRect replayFrame = isiPad ? (CGRect){{102, 230}, {264, 106}} : (CGRect){{0, 120}, {165, 66}};
    self.replayButton = [self addButtonWithFrame:replayFrame
                                      imageNamed:@"Common/replay.png"
                                          action:@selector(replay:)];

    CGRect submitFrame = isiPad ? (CGRect){{402, 230}, {264, 106}} : (CGRect){{155, 120}, {165, 66}};

    self.submitButton = [self addButtonWithFrame:submitFrame
                                      imageNamed:@"Common/submit_score.png"
                                          action:@selector(submitScore:)];

    CGRect userNameFrame = isiPad ? (CGRect){{370, 146}, {350, 50}} : (CGRect){{165, 90}, {147, 31}};
    CGFloat userNameFontSize = isiPad ? 38 : 20;

    self.userNameField = [self addUserNameTextFieldWithFrame:userNameFrame
                                                    fontSize:userNameFontSize];

    CGRect maxScoreFrame = isiPad ? (CGRect){{370, 95}, {300, 45}} : (CGRect){{165, 43}, {131, 38}};
    self.maxScoreView = [self addHighScoreViewWithFrame:maxScoreFrame];

    self.submitIndicatorView = [[UIActivityIndicatorView alloc]
                                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGFloat offset = isiPad ? 30 : 15;
    [self.submitIndicatorView alignWithLeftSideOf:self.submitButton offset:offset];
    [self.submitIndicatorView alignWithVerticalCenterOf:self.submitButton];

    [self.view addSubview:self.submitIndicatorView];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    self.submitButton.enabled = (self.gameManager.userName.length > 0);
    self.userNameField.text = self.gameManager.userName;
    self.gameManager.boardStore.delegate = self;

    self.maxScoreView.digitsImage = [UIImage imageNamed:@"Digit/digit-level0-small.png"];
    self.maxScoreView.letterSpacing = -0.2;

    NSString *localBoardName = [NSString stringWithFormat:@"local.%@",
                                [GameManager stringFromGameMode:self.gameManager.mode]];

    Score *maxScore = [self.gameManager.boardStore
                       highScoreForBoardNamed:localBoardName];
    self.maxScoreView.value = maxScore.value.intValue;
}


/*
   // Override to allow orientations other than the default portrait orientation.
   - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
   }
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.userNameField = nil;
    self.submitButton = nil;
    self.submitIndicatorView = nil;
    self.replayButton = nil;
}


- (void)gameOverViewControllerviewWillAppear:(BOOL)animated {
    [self startGameOverAnimation];
}


- (void)gameOverViewControllerDidAppear:(BOOL)animated {
    if (!self.gameManager.userName.length) {
        [self.userNameField becomeFirstResponder];
    }
}


- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    NSString *boardName = [NSString stringWithFormat:@"local.%@",
                           [GameManager stringFromGameMode:self.gameManager.mode]];

    Score *maxScore = [self.gameManager.boardStore highScoreForBoardNamed:boardName];
    self.maxScoreView.hidden = !maxScore.isValid;

    Score * score = [[Score alloc] init];
    score.type = [GameManager stringFromGameMode:self.gameManager.mode];
    score.user = self.gameManager.userName;
    score.value = [NSString stringWithFormat:@"%lu", (unsigned long)self.gameManager.counter];

    [self.gameManager.boardStore checkAchievementsAndScore:score];

    [self.delegate gameOverDidCompletedAnimation:self];
}


#pragma mark - add subviews
- (UIButton *)addButtonWithFrame:(CGRect)frame imageNamed:(NSString *)name action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button addTarget:self
               action:action
     forControlEvents:UIControlEventTouchUpInside];

    UIImage *defaultImage = [UIImage imageNamed:name];
    [button setImage:defaultImage forState:UIControlStateNormal];

    [self.view addSubview:button];
    return button;
}


- (UITextField *)addUserNameTextFieldWithFrame:(CGRect)frame fontSize:(CGFloat)fontSize {
    UIFont *font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:fontSize];

    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.textColor = [UIColor whiteColor];
    textField.returnKeyType = UIReturnKeyDone;
    textField.clearsOnBeginEditing = NO;
    textField.clearButtonMode = UITextFieldViewModeNever;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.adjustsFontSizeToFitWidth = NO;
    textField.delegate = self;
    textField.font = font;
    [self.view addSubview:textField];
    return textField;
}


- (CMBitmapNumberView *)addHighScoreViewWithFrame:(CGRect)frame {
    CMBitmapNumberView *highScoreView = [[CMBitmapNumberView alloc] initWithFrame:frame];
    highScoreView.hidden = YES;
    highScoreView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:highScoreView];
    return highScoreView;
}


#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newUserName = [textField.text stringByReplacingCharactersInRange:range
                                                                    withString:string];
    self.gameManager.userName = newUserName;
    self.submitButton.enabled = (self.gameManager.userName.length > 0);
    return YES;
}


- (IBAction)submitScore:(id)sender {
    self.submitButton.enabled = NO;
    [self.submitIndicatorView startAnimating];

    Score *score = [[Score alloc] init];
    score.type = [GameManager stringFromGameMode:self.gameManager.mode];
    score.user = self.gameManager.userName;
    score.value = [NSString stringWithFormat:@"%lu", (unsigned long)self.gameManager.counter];

    [self.gameManager.boardStore requestSubmitScore:score];
}


- (IBAction)replay:(id)sender {
    [self.delegate gameOverDidSelectReplay:self];
}


- (void)boardScoreSubmitDidSucceed:(BoardStore *)boardStore {
    [self.submitIndicatorView stopAnimating];
    self.submitButton.enabled = NO;
    self.userNameField.enabled = NO;
    [self startStampAnimation];
}


- (void)boardScoreSubmitDidFailed:(BoardStore *)boardStore {
    [self.submitIndicatorView stopAnimating];
    self.submitButton.enabled = YES;
}


#pragma mark - Animations

- (void)startStampAnimation {
    [self.stampLayer removeFromSuperlayer];
    self.stampLayer = nil;

    UIImage * image = [UIImage imageNamed:@"Common/stamp.png"];
    CGImageRef imageRef = [image CGImage];
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;

    // create the layer
    self.stampLayer = [CALayer layer];
    self.stampLayer.contents = (__bridge id)imageRef;
    [self.stampLayer setBounds:CGRectMake(0, 0, imageWidth, imageHeight)];

    CGPoint center = self.submitButton.center;
    center.x += 35;
    center.y -= 10;

    if (((int)imageWidth) % 2) {
        center.x += 0.5;
    }
    if (((int)imageHeight) % 2) {
        center.y += 0.5;
    }
    [self.stampLayer setPosition:center];
    [self.view.layer addSublayer:self.stampLayer];


    CABasicAnimation *animation = [CABasicAnimation
                                   animationWithKeyPath:@"transform.scale"];
    animation.fromValue = @8.0f;
    animation.toValue = @1.0f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 0.2;


    [self.stampLayer addAnimation:animation forKey:@"zoom"];
}


- (void)startGameOverAnimation {
    DebugLog(@"startGameOverAnimation");

    BOOL firstAnimation = YES;
    // subtitle animation))
    for(UIView *label in self.labels) {
        CABasicAnimation *animation;
        animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
        animation.fromValue = @-50.0f;
        animation.timingFunction = [CAMediaTimingFunction
                                    functionWithName:kCAMediaTimingFunctionEaseOut];
        animation.toValue = @100.0f;

        if (firstAnimation) {
            animation.delegate = self;
            [animation setValue:@"gameOver" forKey:@"name"];
            firstAnimation = NO;
        }
        [label.layer addAnimation:animation forKey:nil];
    }
}


- (void)addCurrentScoreToHighscore {
    Score * score = [[Score alloc] init];
    score.type = [GameManager stringFromGameMode:self.gameManager.mode];
    score.user = self.gameManager.userName;
    score.value = [NSString stringWithFormat:@"%lu", (unsigned long)self.gameManager.counter];

    NSString *localBoardName = [NSString stringWithFormat:@"local.%@", score.type];

    [self.gameManager.boardStore addScore:score toBoardNamed:localBoardName];
}


@end
