//
//  CongratulationiPadViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 6/22/12.
//  Copyright (c) 2012 Manbolo. All rights reserved.
//
#import "CongratulationiPadViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "CMScrollView.h"
#import "NSString+Constant.h"
#import "NSString+Constant.h"
#import "UIColor+Helper.h"
#import "UIView+Helper.h"
#import "UIView+Helper.h"
#import "UIViewController+Helper.h"

@interface CongratulationiPadViewController ()

@property (nonatomic, strong) NSMutableArray *meonViews;
@property (nonatomic, strong) UIView *meonContainerView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *scrollViewLabel;
@property (nonatomic, strong) UIView *scrollViewContainerView;
@property (nonatomic, strong) UIImageView *manboloView;
@property (nonatomic, strong) UIView *logoView;
@property (nonatomic, strong) UIButton *buyFullButton;

@end

@implementation CongratulationiPadViewController


- (void)dealloc {
    [self unregisterFromForegroundNotification];
}


- (void)loadView {
    CGRect frame = [UIViewController fullscreenFrame];

    UIView *aView = [[UIView alloc] initWithFrame:frame];
    aView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = aView;

    CGFloat scrollWidth = 680;
    CGFloat scrollHeight = 500;
    CGFloat scrollX = floorf((self.view.width - scrollWidth) / 2);
    CGFloat scrollY = floor(self.view.height - 650);
    CGRect scrollViewFrame = CGRectMake(scrollX, scrollY, scrollWidth, scrollHeight);

    [self addScrollView:scrollViewFrame];

    CGFloat width = 680;
    CGFloat height = 200;
    CGFloat x = floorf((self.view.width - width) / 2);
    CGFloat y = floor(self.view.height - 204);
    CGRect containerFrame = CGRectMake(x, y, width, height);

    self.meonContainerView = [[UIView alloc] initWithFrame:containerFrame];
    self.meonContainerView.backgroundColor = [UIColor clearColor];
    self.meonContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                              UIViewAutoresizingFlexibleRightMargin |
                                              UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.meonContainerView];

    [self addMeonViewForName:@"Common/final-3.png" frame:(CGRect){{14, 54}, {44 * 2, 38 * 2}}];
    [self addMeonViewForName:@"Common/final-2.png" frame:(CGRect){{118, 38}, {48 * 2, 44 * 2}}];
    [self addMeonViewForName:@"Common/final-0.png" frame:(CGRect){{264, 20}, {55 * 2, 55 * 2}}];
    [self addMeonViewForName:@"Common/final-0.png" frame:(CGRect){{48, 72}, {66 * 2, 66 * 2}}];
    [self addMeonViewForName:@"Common/final-0.png" frame:(CGRect){{374, 36}, {47 * 2, 47 * 2}}];
    [self addMeonViewForName:@"Common/final-1.png" frame:(CGRect){{172, 52}, {64 * 2, 63 * 2}}];
    [self addMeonViewForName:@"Common/final-1.png" frame:(CGRect){{520, 20}, {51 * 2, 50 * 2}}];
    [self addMeonViewForName:@"Common/final-2.png" frame:(CGRect){{316, 52}, {57 * 2, 53 * 2}}];
    [self addMeonViewForName:@"Common/final-3.png" frame:(CGRect){{446, 54}, {59 * 2, 52 * 2}}];
    [self addMeonViewForName:@"Common/final-3.png" frame:(CGRect){{412, 78}, {64 * 2, 63 * 2}}];
    [self addMeonViewForName:@"Common/final-2.png" frame:(CGRect){{560, 68}, {57 * 2, 53 * 2}}];

    [self addButtons];

    [self addLogoView];

    [self registerToForegroundNotification];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    //-- start the meons
    for(UIView *meon in self.meonViews) {
        [meon.layer removeAllAnimations];
        [self startMeonAnimation:meon];
    }
    [self startLogoAnimation];
}


#pragma mark - subviews

- (void)addMeonViewForName:(NSString *)imageName frame:(CGRect)frame {
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *anImageView = [[UIImageView alloc] initWithImage:image];
    anImageView.frame = frame;
    anImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                   UIViewAutoresizingFlexibleRightMargin |
                                   UIViewAutoresizingFlexibleBottomMargin;
    [self.meonContainerView addSubview:anImageView];

    if (anImageView) {
        if (!self.meonViews) {
            self.meonViews = [NSMutableArray array];
        }
        [self.meonViews addObject:anImageView];
    }
}


- (void)addButtons {
    UIButton *menuButton = [self addButton:CGPointZero
                                      parent:self.view
                                       title:@"Go to menu"
                                      action:@selector(goToMenu:)
                            defaultImageName:@"Common/menuButton.png"
                        highlightedImageName:nil
                            autoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [menuButton alignWithRightSideOf:self.view offset:2.0];
    menuButton.y = 10;

#if defined (LITE)
    self.buyFullButton = [self addButton:CGPointZero
                                    parent:self.view
                                     title:@"Buy Full"
                                    action:@selector(buyFullVersion:)
                          defaultImageName:@"Common/buyfull.png"
                      highlightedImageName:nil
                          autoresizingMask:UIViewAutoresizingFlexibleLeftMargin |
                          UIViewAutoresizingFlexibleTopMargin];
    [self.buyFullButton alignWithRightSideOf:self.view offset:40];
    [self.buyFullButton alignWithBottomSideOf:self.view offset:200];
    [self addBuyButtonAnimation:self.buyFullButton];
#endif
}


- (void)addMask {
    CAGradientLayer *mask = [CAGradientLayer layer];
    mask.locations = @[@0.0f,
                       @0.15f,
                       @0.85f,
                       @1.0f];

    mask.colors = @[(id)[UIColor clearColor].CGColor,
                    (id)[UIColor whiteColor].CGColor,
                    (id)[UIColor whiteColor].CGColor,
                    (id)[UIColor clearColor].CGColor];

    mask.frame = self.scrollViewContainerView.bounds;
    mask.startPoint = CGPointMake(0, 0);
    mask.endPoint = CGPointMake(0, 1);

    self.scrollViewContainerView.layer.mask = mask;
}


- (void)addScrollView:(CGRect)frame {
    self.scrollViewContainerView = [[UIView alloc] initWithFrame:frame];
    self.scrollViewContainerView.backgroundColor = [UIColor clearColor];
    self.scrollViewContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                                    UIViewAutoresizingFlexibleRightMargin |
                                                    UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.scrollViewContainerView];
    [self addMask];


    CGRect scrollViewFrame = (CGRect){{0, 0}, {frame.size.width, frame.size.height}};
    self.scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                       UIViewAutoresizingFlexibleHeight;
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;

    //-- add the m
    UIImage *image = [UIImage imageNamed:@"m.png"];
    self.manboloView = [[UIImageView alloc] initWithImage:image];
    [self.scrollView addSubview:self.manboloView];

    //-- add the label
    UIFont *font = [UIFont fontWithName:@"BradyBunchRemastered" size:30];

    self.scrollViewLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.scrollViewLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    self.scrollViewLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.scrollViewLabel.backgroundColor = [UIColor clearColor];
    self.scrollViewLabel.shadowColor = [UIColor darkGrayColor];
    self.scrollViewLabel.shadowOffset = (CGSize){1, 2};
    self.scrollViewLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollViewLabel.numberOfLines = 0;

#if defined (LITE)
    NSString *text = NSLocalizedString(@"L_CongratulationsLite", );
#else
    NSString *text = NSLocalizedString(@"L_Congratulations", );
#endif

    NSDictionary *attributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor whiteColor]};
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    NSRange searchRange = (NSRange){0, text.length};
    NSRange range = [text rangeOfString:@"Manbolo"
                                options:NSLiteralSearch
                                  range:searchRange];
    if (range.location != NSNotFound) {
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:[UIColor colorWithHexCode:0xcf8bff]
                        range:range];
    }
    self.scrollViewLabel.attributedText = attrStr;
    [self.scrollView addSubview:self.scrollViewLabel];
    [self layoutScrollViewContent];
    [self.scrollViewContainerView addSubview:self.scrollView];
}


- (void)addLogoView {
    UIImage *image = [UIImage imageNamed:@"Common/you_did_it.png"];
    self.logoView = [[UIImageView alloc] initWithImage:image];
    [self.logoView alignWithHorizontalCenterOf:self.view];
    self.logoView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
                                     UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleTopMargin;
    self.logoView.y = self.view.height - 750;
    [self.view addSubview:self.logoView];
}


- (void)layoutScrollViewContent {
    CGSize targetSize = (CGSize){_scrollView.width, 0};
    CGSize size = [_scrollViewLabel sizeThatFits:targetSize];

    _manboloView.y = _scrollView.height + size.height + 10;
    _manboloView.x = floor((_scrollView.width - _manboloView.width) / 2);

    _scrollViewLabel.frame = (CGRect){{0, _scrollView.height}, {size.width, size.height}};

    _scrollView.contentSize = (CGSize){_scrollView.width, _scrollView.height + _scrollViewLabel.height + 10 + _manboloView.image.size.height + 10};
    _scrollView.contentOffset = (CGPoint){0, 0};

    CGFloat speedInPointBySecond = 40;
    CGFloat distanceInPointToComplete = _scrollViewLabel.height + 10 + _manboloView.image.size.height + 10;
    NSTimeInterval durationInSecond = distanceInPointToComplete / speedInPointBySecond;
    DebugLog(@"animate scrollview on %.0f point in %.1f s", distanceInPointToComplete, durationInSecond);
    [UIView animateWithDuration:durationInSecond
                     animations:^{
         _scrollView.contentOffset = (CGPoint){0, distanceInPointToComplete};
     }
    ];
}


- (void)viewDidUnload {
    [super viewDidUnload];
}


#pragma mark - Rotation

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
    [self addMask];

    DebugLog(@"currentOrientation: %@", [NSString stringFromUIInterfaceOrientation:self.interfaceOrientation]);
}


#pragma mark - actions
- (IBAction)goToMenu:(id)sender {
    if ([self.delegate respondsToSelector:@selector(congratulationiPadDidTapGoToMenu:)]) {
        [self.delegate congratulationiPadDidTapGoToMenu:self];
    }
}


- (IBAction)buyFullVersion:(id)sender {
    if ([self.delegate respondsToSelector:@selector(congratulationiPadDidTapBuyFullVersion:)]) {

        [self.delegate congratulationiPadDidTapBuyFullVersion:self];
    }
}


#pragma mark -
#pragma mark You did it animation

- (void)addBuyButtonAnimation:(UIView *)button {

    [button.layer removeAllAnimations];

    CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                      animationWithKeyPath:@"transform.scale"];

    NSArray *values = @[@1.0,
                        @1.1,
                        @1.0,
                        @1.0];

    NSArray *times = @[@0.0,
                       @0.1,
                       @0.2,
                       @1.0];

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


- (void)startLogoAnimation {
    CALayer *titleLayer = self.logoView.layer;

    CABasicAnimation *zoomAnimation = [CABasicAnimation
                                       animationWithKeyPath:@"transform.scale"];
    zoomAnimation.fromValue = @8.0f;
    zoomAnimation.toValue = @1.0f;
    [zoomAnimation setDuration:1.0];

    [titleLayer addAnimation:zoomAnimation forKey:nil];
}


- (void)startMeonAnimation:(UIView *)meon {
    CALayer *layer = meon.layer;

    CGFloat height = meon.height;

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:
                                   @"position.y"];
    animation.fromValue = @(meon.center.y);
    animation.timingFunction = [CAMediaTimingFunction
                                functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.toValue = @((float)(meon.center.y - 0.2 * height));
    animation.autoreverses = YES;
    animation.repeatCount = HUGE_VAL;
    animation.beginTime = /*CACurrentMediaTime() */ (rand() * 1.0 / RAND_MAX);
    animation.duration = 0.3;

    [layer addAnimation:animation forKey:nil];
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
    for(UIView *meon in self.meonViews) {
        [meon.layer removeAllAnimations];
        [self startMeonAnimation:meon];
    }
    [self addBuyButtonAnimation:self.buyFullButton];
}


@end
