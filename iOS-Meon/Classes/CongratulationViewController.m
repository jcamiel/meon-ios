//
//  CongratulationViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 5/1/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CongratulationViewController.h"
#import "UIColor+Helper.h"
#import "UIView+Helper.h"
#import "UIViewController+Helper.h"
#import "UIView+Helper.h"

@interface CongratulationViewController()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *scrollViewLabel;
@property (nonatomic, strong) UIView *scrollViewContainerView;
@property (nonatomic, strong) UIImageView *manboloView;
@property (nonatomic, strong) UIButton *buyFullButton;

@end


@implementation CongratulationViewController


- (void)dealloc
{
	[self unregisterFromForegroundNotification];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)loadView
{
    [super loadView];
	
    self.backButtonType = ModalViewControllerButtonNone;
    
    UIButton *menuButton = [self addButton:(CGPoint){104,0}
                                    parent:self.view
                                     title:@"Menu"
                                    action:@selector(onGoToMainMenu:)
                          defaultImageName:@"Common/menuButton.png"
                      highlightedImageName:nil
                          autoresizingMask:0];
    [menuButton alignWithBottomSideOf:self.view offset:-6];
    
    self.titleView = [self addImageView:(CGPoint){0,20}
                                 parent:self.view
                       defaultImageName:@"Common/you_did_it.png"
                   highlightedImageName:nil
                       autoresizingMask:0];
    
    self.meon0 = [self addImageView:(CGPoint){17,377}
                                 parent:self.view
                       defaultImageName:@"Common/final-3.png"
                   highlightedImageName:nil
                       autoresizingMask:0];
    self.meon0.width = 44;
    self.meon0.height = 38;
    [self.meon0 alignWithBottomSideOf:self.view offset:65];
    
    
    self.meon1 = [self addImageView:(CGPoint){69,369}
                             parent:self.view
                   defaultImageName:@"Common/final-2.png"
               highlightedImageName:nil
                   autoresizingMask:0];
    self.meon1.width = 48;
    self.meon1.height = 44;
    [self.meon1 alignWithBottomSideOf:self.view offset:65];

    
    self.meon2 = [self addImageView:(CGPoint){132,360}
                             parent:self.view
                   defaultImageName:@"Common/final-0.png"
               highlightedImageName:nil
                   autoresizingMask:0];
    self.meon2.width = 55;
    self.meon2.height = 55;
    [self.meon2 alignWithBottomSideOf:self.view offset:65];

    self.meon3 = [self addImageView:(CGPoint){34,386}
                             parent:self.view
                   defaultImageName:@"Common/final-0.png"
               highlightedImageName:nil
                   autoresizingMask:0];
    self.meon3.width = 66;
    self.meon3.height = 66;
    [self.meon3 alignWithBottomSideOf:self.view offset:65];

    self.meon4 = [self addImageView:(CGPoint){197,368}
                             parent:self.view
                   defaultImageName:@"Common/final-0.png"
               highlightedImageName:nil
                   autoresizingMask:0];
    self.meon4.width = 47;
    self.meon4.height = 47;
    [self.meon4 alignWithBottomSideOf:self.view offset:65];

    self.meon5 = [self addImageView:(CGPoint){96,376}
                             parent:self.view
                   defaultImageName:@"Common/final-1.png"
               highlightedImageName:nil
                   autoresizingMask:0];
    self.meon5.width = 64;
    self.meon5.height = 63;
    [self.meon5 alignWithBottomSideOf:self.view offset:65];

    self.meon6 = [self addImageView:(CGPoint){168,376}
                             parent:self.view
                   defaultImageName:@"Common/final-2.png"
               highlightedImageName:nil
                   autoresizingMask:0];
    self.meon6.width = 57;
    self.meon6.height = 53;
    [self.meon6 alignWithBottomSideOf:self.view offset:65];

    self.meon7 = [self addImageView:(CGPoint){233,377}
                             parent:self.view
                   defaultImageName:@"Common/final-3.png"
               highlightedImageName:nil
                   autoresizingMask:0];
    self.meon7.width = 59;
    self.meon7.height = 52;
    [self.meon7 alignWithBottomSideOf:self.view offset:65];
    
    self.meon8 = [self addImageView:(CGPoint){216,389}
                             parent:self.view
                   defaultImageName:@"Common/final-1.png"
               highlightedImageName:nil
                   autoresizingMask:0];
    self.meon8.width = 64;
    self.meon8.height = 63;
    [self.meon8 alignWithBottomSideOf:self.view offset:65];
    
    
	
	[self registerToForegroundNotification];
	
    CGRect scrollViewFrame = (CGRect){{20,120},{280,self.view.height-221}};
    [self addScrollView:scrollViewFrame];
    

	[UIView beginAnimations:@"" context:NULL];
	[UIView setAnimationDuration:30];
	self.scrollView.contentOffset = CGPointMake(0, 
            self.scrollView.contentSize.height - self.scrollView.height); 
	[UIView commitAnimations];
	
#if defined (LITE) 
    self.buyFullButton = [self addButton:(CGPoint){216,328}
                                  parent:self.view
                                   title:@"Buy Full"
                                  action:@selector(buyFullVersion:)
                        defaultImageName:@"Common/buyfull.png"
                    highlightedImageName:nil
                        autoresizingMask:0];
    [self.buyFullButton alignWithBottomSideOf:self.view offset:66];
    [self addBuyButtonAnimation];
#endif
}


- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self startLogoAnimation];
    
	NSArray * meons = @[self.meon0,self.meon1,self.meon2,self.meon3,self.meon4,self.meon5,self.meon6,self.meon7,self.meon8];
	for(UIImageView *meon in meons){
		[self startMeonAnimation:meon];		
	} 
	

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

	self.meon0 = nil;
	self.meon1 = nil;
	self.meon2 = nil;
	self.meon3 = nil;
	self.meon4 = nil;
	self.meon5 = nil;
	self.meon6 = nil;
	self.meon7 = nil;
	self.meon8 = nil;

}



- (IBAction)onGoToMainMenu:(id)sender
{
    [self.delegate congratulationDidTapGoToMainMenu:self];
}

#pragma mark - subviews

- (void)addScrollView:(CGRect)frame
{
    self.scrollViewContainerView = [[UIView alloc] initWithFrame:frame];
    self.scrollViewContainerView.backgroundColor = [UIColor clearColor];
    self.scrollViewContainerView.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin;
    [self.view insertSubview:self.scrollViewContainerView belowSubview:self.meon0];
    [self addMask];
    
    
    CGRect scrollViewFrame = (CGRect){{0,0},{frame.size.width, frame.size.height}};
    self.scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
    self.scrollView.autoresizingMask =  UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    //-- add the m
    UIImage *image = [UIImage imageNamed:@"m.png"];
    self.manboloView = [[UIImageView alloc] initWithImage:image];
    [self.scrollView addSubview:self.manboloView];
    
    //-- add the label
    UIFont *font = [UIFont fontWithName:@"BradyBunchRemastered" size:22];
    
    self.scrollViewLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.scrollViewLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    self.scrollViewLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.scrollViewLabel.backgroundColor = [UIColor clearColor];
    self.scrollViewLabel.shadowColor = [UIColor darkGrayColor];
    self.scrollViewLabel.shadowOffset = (CGSize){1,2};
    self.scrollViewLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollViewLabel.numberOfLines = 0;
    
#if defined (LITE)    
    NSString *text = NSLocalizedString(@"L_CongratulationsLite",);
#else
    NSString *text = NSLocalizedString(@"L_Congratulations",);
#endif
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: font};
    NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    NSRange searchRange = (NSRange){0, text.length};
    NSRange range = [text rangeOfString:@"Manbolo"
                                options:NSLiteralSearch
                                  range:searchRange];
    if (range.location != NSNotFound){
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexCode:0xcf8bff] range:range];
    }
    self.scrollViewLabel.attributedText = attrStr;
    [self.scrollView addSubview:self.scrollViewLabel];
    [self layoutScrollViewContent];
    [self.scrollViewContainerView addSubview:self.scrollView];
}

- (void)layoutScrollViewContent
{
    CGSize targetSize = (CGSize){self.scrollView.width,0};
    CGSize size = [self.scrollViewLabel sizeThatFits:targetSize];

    self.manboloView.y = self.scrollView.height + size.height + 10;
    self.manboloView.x = floor((self.scrollView.width - self.manboloView.width)/2);
    
    self.scrollViewLabel.frame = (CGRect){{0,self.scrollView.height}, {size.width, size.height}};

    self.scrollView.contentSize = (CGSize){self.scrollView.width, self.scrollView.height + self.scrollViewLabel.height + 10 + self.manboloView.image.size.height + 10};
    self.scrollView.contentOffset = (CGPoint){0,0};
    
    CGFloat speedInPointBySecond = 40;
    CGFloat distanceInPointToComplete = self.scrollViewLabel.height + 10 + self.manboloView.image.size.height + 10;
    NSTimeInterval durationInSecond = distanceInPointToComplete / speedInPointBySecond;
    DebugLog(@"animate scrollview on %.0f point in %.1f s",distanceInPointToComplete, durationInSecond);
    [UIView animateWithDuration:durationInSecond 
                     animations:^{
                         self.scrollView.contentOffset = (CGPoint){0, distanceInPointToComplete}; 
                     }
     ];
    
    
}


- (void)addMask
{
    CAGradientLayer *mask = [CAGradientLayer layer];
    mask.locations = @[@0.0f,
                      @0.15f,
                      @0.85f,
                      @1.0f];
    
    mask.colors = @[(id)[UIColor clearColor].CGColor,
                   (id)[UIColor whiteColor].CGColor,
                   (id)[UIColor whiteColor].CGColor,
                   (id)[UIColor clearColor].CGColor];
    
    mask.frame = self.scrollViewContainerView.bounds ;
    mask.startPoint = CGPointMake(0, 0); 
    mask.endPoint = CGPointMake(0, 1);
    
    self.scrollViewContainerView.layer.mask = mask;
}



#pragma mark - You did it animation

- (void)startLogoAnimation
{
    CALayer *titleLayer = self.titleView.layer;

	CABasicAnimation *zoomAnimation = [CABasicAnimation 
								animationWithKeyPath:@"transform.scale"];
	zoomAnimation.fromValue = @8.0f;
	zoomAnimation.toValue = @1.0f;
   [zoomAnimation setDuration:1.0];
	
    [titleLayer addAnimation:zoomAnimation forKey:nil];
    
}


- (void)startMeonAnimation:(UIView*)meon
{
    CALayer *layer = meon.layer;
	
	CGFloat height = meon.height;
	
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:
							  @"position.y"];
    animation.fromValue = @(meon.center.y);
    animation.timingFunction = [CAMediaTimingFunction 
                                functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.toValue = @(meon.center.y - 0.2*height);
	animation.autoreverses = YES;
	animation.repeatCount = HUGE_VAL;
	animation.beginTime = /*CACurrentMediaTime() */ (rand()*1.0/RAND_MAX);
	animation.duration = 0.3;
    
    [layer addAnimation:animation forKey:nil];
}

- (void)addBuyButtonAnimation
{
	[self.buyFullButton.layer removeAnimationForKey:@"zoom"];
	
	CAKeyframeAnimation *animation = [CAKeyframeAnimation 
									  animationWithKeyPath:@"transform.scale"];
	
	NSArray *values = @[@1.0f,@1.1f,@1.0f,@1.0f];
	NSArray *times = @[@0.0f,@0.1f,@0.2f,@1.0f];
	NSArray *functions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
						  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
						  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
	animation.duration = 2.5;
	animation.values = values;
	animation.keyTimes = times;
	animation.timingFunctions = functions;
	animation.repeatCount = HUGE_VAL;
	
	
	[self.buyFullButton.layer addAnimation:animation forKey:@"zoom"];
	
}

#pragma mark - Enter Foreground managment
- (void)registerToForegroundNotification
{
	if (&UIApplicationWillEnterForegroundNotification)
		[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(willEnterForeground:) 
												 name:UIApplicationWillEnterForegroundNotification
											   object:nil];
}
- (void)unregisterFromForegroundNotification
{
	if (&UIApplicationWillEnterForegroundNotification)
		[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIApplicationWillEnterForegroundNotification
												  object:nil];
}

- (void)willEnterForeground:(NSNotification*)theNotification
{
	NSArray * meons = @[self.meon0,self.meon1,self.meon2,self.meon3,self.meon4,self.meon5,self.meon6,self.meon7,self.meon8];
	for(UIImageView *meon in meons){
		[meon.layer removeAllAnimations];
		
		[self startMeonAnimation:meon];		
	} 
    [self addBuyButtonAnimation];
}

- (IBAction)buyFullVersion:(id)sender
{
    [self.delegate congratulationDidTapBuyFullVersion:self];
}
@end
