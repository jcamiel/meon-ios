//
//  AchievementViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 11/14/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import "AchievementViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Achievement.h"
#import "UIView+Helper.h"


@interface AchievementViewController()
- (void)startAnimation;
- (void)updateSubviews;
@end



@implementation AchievementViewController


- (void)dealloc 
{
	DebugLog(@"dealloc AchievementViewController");
	
	[self.view.layer removeAllAnimations];
    self.delegate = nil;
    
}

- (void)loadView
{
    CGRect frameView;
    CGRect frameBackground;
    CGRect frameIcon;
    CGRect frameLabel;
    CGRect frameDescription;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        frameView = (CGRect){{0,0},{540,122}};
        frameBackground = (CGRect){{0,-4},{540,130}};
        frameIcon = (CGRect){{28,20},{82,82}};
        frameLabel = (CGRect){{118,20},{413,52}};
        frameDescription = (CGRect){{118,73},{413,28}};
    }
    else{
        frameView = (CGRect){{0,0},{320,73}};
        frameBackground = (CGRect){{14,0},{296,73}};
        frameIcon = (CGRect){{31,16},{41,41}};
        frameLabel = (CGRect){{75,18},{226,26}};
        frameDescription = (CGRect){{77,44},{228,14}};
    }
    
    
    self.view = [[UIView alloc] initWithFrame:frameView];
    self.view.backgroundColor = [UIColor clearColor];

    // background view
    UIImage *backgroundImage = [UIImage imageNamed:@"fondAchievement"];
    UIImageView *aView = [[UIImageView alloc] initWithImage:backgroundImage];
    aView.frame = frameBackground;

    aView.autoresizingMask =    UIViewAutoresizingFlexibleWidth | 
                                UIViewAutoresizingFlexibleHeight |
                                UIViewAutoresizingFlexibleLeftMargin |
                                UIViewAutoresizingFlexibleRightMargin; 
    aView.opaque = YES;
    
    
    [self.view addSubview:aView];
    
    self.view.y = -(self.view.height + 1);
    
    
     // iconImageView
    self.iconImageView = [[UIImageView alloc] initWithFrame:frameIcon];
    self.iconImageView.autoresizingMask = UIViewAutoresizingNone;
    self.iconImageView.opaque = YES;
    [self.view addSubview:self.iconImageView];
    
    // labelImageView
    self.labelImageView = [[UIImageView alloc] initWithFrame:frameLabel];
    self.labelImageView.autoresizingMask = UIViewAutoresizingNone;
    self.labelImageView.contentMode = UIViewContentModeTopLeft;
    self.labelImageView.opaque = YES;
    [self.view addSubview:self.labelImageView];
    
    CGFloat fontSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ?
        25.0 : 14.0;
    
    UIFont *font = [UIFont fontWithName:@"BradyBunchRemastered" size:fontSize];

    
    self.descriptionLabel = [[UILabel alloc] initWithFrame:frameDescription];
    self.descriptionLabel.textColor = [UIColor whiteColor];
    self.descriptionLabel.backgroundColor = [UIColor clearColor];
    self.descriptionLabel.font = font;
    [self.view addSubview:self.descriptionLabel];
    
}





// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    [super viewDidLoad];
	
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *plistPath = [mainBundle pathForResource:@"achievements_description" 
                                               ofType:@"plist"];
    self.achievementsDescription = [NSDictionary dictionaryWithContentsOfFile:plistPath];

    
    [self updateSubviews];

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
	self.labelImageView = nil;
	self.iconImageView = nil;
}



- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self startAnimation];
}

- (void)startAnimation
{
    // if there is already this animation, skip
    if ([self.view.layer animationForKey:@"reveal"])
        return;
    
	// remove previous animation
	[self.view.layer removeAllAnimations];

	// add new animation
	CAKeyframeAnimation *animation =  [CAKeyframeAnimation 
									  animationWithKeyPath:@"position.y"];

	CGFloat yStart, yStop;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        yStart = -123;
        yStop = 65;
    }
    else{
        yStart = -74;
        yStop = 40.5;
    }
    
	NSArray *values = @[@(yStart),@(yStop),@(yStop),@(yStart)];
	NSArray *times = @[@0.0f,@0.1f,@0.9f,@1.0f];
	NSArray *functions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
						  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
						  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
	
	animation.duration = 4.0;
	animation.values = values;
	animation.keyTimes = times;
	animation.timingFunctions = functions;
	animation.delegate = self;
	
	[self.view.layer addAnimation:animation forKey:@"reveal"];
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
	DebugLog(@"animationDidStop");
	[self.delegate achievementViewControllerDidDismiss:self];
}



- (void)setAchievement:(Achievement*)newAchievement
{
	_achievement = newAchievement;

    [self updateSubviews];
}


- (void)updateSubviews
{
    if (!self.achievement)
        return;
    
    self.labelImageView.image = [UIImage imageNamed:self.achievement.labelFileName];

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [self.labelImageView sizeToFit];
        self.labelImageView.x = 120;
    }

    self.iconImageView.image = [UIImage imageNamed:self.achievement.iconFileName];
    
    NSDictionary *achievementLabel = self.achievementsDescription[self.achievement.identifier];
    self.descriptionLabel.text = achievementLabel[@"done"];
    
}


@end
