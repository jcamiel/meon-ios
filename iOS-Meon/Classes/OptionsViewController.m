//
//  OptionsViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 5/1/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import "OptionsViewController.h"
#import "CustomUISwitch.h"
#import "BoardStore.h"
#import "GameManager.h"
#import "SimpleAudioEngine.h"
#import "UIDevice+Helper.h"
#import "UIView+Helper.h"
#import "UIViewController+Helper.h"

static NSString * const kEnabledParallaxEffect = @"enabledParallaxEffect";
static NSString * const kNumberOfHints = @"numberOfHints";
static NSString * const kPauseBetweenLevels = @"pauseBetweenLevels";
static NSString * const kEnabledSound = @"enabledSound";
static NSString * const kEnabledMusic = @"enabledMusic";

@implementation OptionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BOOL isOS7 = [[UIDevice currentDevice] isSystemVersionGreaterOrEqualThan:@"7.0"];
    BOOL isiPhone5FormFactor = (self.view.height == 568);

    [self addHeaderImageNamed:@"Common/header_options.png"];
    
    //make the switch
    CGFloat yMaster = 100;
    CGFloat xSrc  = 195;
    CGFloat ySrc  = isiPhone5FormFactor ? yMaster + 3 + 28 : yMaster;
    CGFloat deltaY = isiPhone5FormFactor ? 84 : 76;
    
    self.twoHintsSwitch = [self createSwitchWithFrame:(CGRect){{xSrc,ySrc},{100,33}}];
    self.pauseBetweenLevelSwitch = [self createSwitchWithFrame:(CGRect){{xSrc,ySrc+1*deltaY},{100,33}}];
    self.enableSoundSwitch = [self createSwitchWithFrame:(CGRect){{xSrc,ySrc+2*deltaY},{100,33}}];
    self.enableMusicSwitch = [self createSwitchWithFrame:(CGRect){{xSrc,ySrc+3*deltaY},{100,33}}];
    if (isOS7) {
        self.enableParallaxEffect = [self createSwitchWithFrame:(CGRect){{xSrc,ySrc+4*deltaY},{100,33}}];
    }

    _twoHintsSwitch.delegate = self;
    _pauseBetweenLevelSwitch.delegate = self;
    _enableSoundSwitch.delegate = self;
    _enableMusicSwitch.delegate = self;
    _enableParallaxEffect.delegate = self;
    
    [self.view addSubview:_twoHintsSwitch];
    [self.view addSubview:_pauseBetweenLevelSwitch];
    [self.view addSubview:_enableSoundSwitch];
    [self.view addSubview:_enableMusicSwitch];
    if (isOS7) {
        [self.view addSubview:_enableParallaxEffect];
    }
    
    [self addSwitchBackgroundBelowView:_twoHintsSwitch];
    [self addSwitchBackgroundBelowView:_pauseBetweenLevelSwitch];
    [self addSwitchBackgroundBelowView:_enableSoundSwitch];
    [self addSwitchBackgroundBelowView:_enableMusicSwitch];
    if (isOS7){
        [self addSwitchBackgroundBelowView:_enableParallaxEffect];
    }

    xSrc  = 10;
    ySrc  = isiPhone5FormFactor ? yMaster + 28 : yMaster;
    CGFloat width = 165;
    CGFloat height = 40;
    CGFloat normalFontSize = 22;
    UIFont *font = [UIFont fontWithName:@"BradyBunchRemastered" size:normalFontSize];
    [self addLabel:(CGRect){{xSrc,ySrc},{width,height}}
            parent:self.view
              text:NSLocalizedString(@"L_OptionsTwoHints",)
              font:font];
    [self addLabel:(CGRect){{xSrc,ySrc+1*deltaY-height},{width,3*height}}
            parent:self.view
              text:NSLocalizedString(@"L_OptionsPause",)
              font:font];
    [self addLabel:(CGRect){{xSrc,ySrc+2*deltaY},{width,height}}
            parent:self.view
              text:NSLocalizedString(@"L_OptionsSounds",)
              font:font];
    [self addLabel:(CGRect){{xSrc,ySrc+3*deltaY},{width,height}}
            parent:self.view
              text:NSLocalizedString(@"L_OptionsMusic",)
              font:font];
    if (isOS7) {
        [self addLabel:(CGRect){{xSrc,ySrc+4*deltaY},{width,height}}
                parent:self.view
                  text:NSLocalizedString(@"L_OptionsParallax",)
                  font:font];
    }
    
    
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	BOOL ret;
	ret = ([userDefaults integerForKey:kNumberOfHints] == 2 ) ? YES : NO;
	[_twoHintsSwitch setOn:ret animated:NO];
	
	ret = [userDefaults boolForKey:kPauseBetweenLevels];
	[_pauseBetweenLevelSwitch setOn:ret animated:NO];
	
	ret = [userDefaults boolForKey:kEnabledSound];
	[_enableSoundSwitch setOn:ret animated:NO];
    
	ret = [userDefaults boolForKey:kEnabledMusic];
	[_enableMusicSwitch setOn:ret animated:NO];

    if (isOS7) {
        ret = [userDefaults boolForKey:kEnabledParallaxEffect];
        [_enableParallaxEffect setOn:ret animated:NO];
    }

}


- (CustomUISwitch*)createSwitchWithFrame:(CGRect)frame
{
    CustomUISwitch *customSwitch = [[CustomUISwitch alloc] initWithFrame:frame];
    return customSwitch;
}

- (void)addSwitchBackgroundBelowView:(UIView*)view
{
    UIImage *image = [UIImage imageNamed:@"Common/switch_back.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.center = view.center;
    [self.view insertSubview:imageView belowSubview:view];
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
}


- (void)dealloc
{
    _delegate = nil;

	_gameManager = nil;
	_twoHintsSwitch = nil;
	_pauseBetweenLevelSwitch = nil;
	_enableSoundSwitch = nil;
    _enableMusicSwitch = nil;
    _enableParallaxEffect = nil;
}

- (IBAction)back:(id)sender
{
    [_delegate optionsDidSelectBack:self];
}

#pragma mark - CustomUISwitch delegate

- (void)valueChangedInView:(CustomUISwitch*)aSwitch
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	if (aSwitch == _twoHintsSwitch){
		if (aSwitch.isOn){
			[userDefaults setInteger:2 forKey:kNumberOfHints];
		}
		else {
			[userDefaults setInteger:1 forKey:kNumberOfHints];
		}
	}
	else if (aSwitch == _pauseBetweenLevelSwitch){
		[userDefaults setBool:aSwitch.isOn forKey:kPauseBetweenLevels];
	}
	else if (aSwitch == _enableSoundSwitch){
		[userDefaults setBool:aSwitch.isOn forKey:kEnabledSound];

        SimpleAudioEngine *audioEngine = [SimpleAudioEngine sharedEngine];
        audioEngine.effectsVolume = aSwitch.isOn ? kEffectsVolume : 0;

	}
    else if (aSwitch == _enableMusicSwitch){
		[userDefaults setBool:aSwitch.isOn forKey:kEnabledMusic];
        
        SimpleAudioEngine *audioEngine = [SimpleAudioEngine sharedEngine];
        audioEngine.backgroundMusicVolume = aSwitch.isOn ? kBackgroundMusicVolume : 0;
        if (aSwitch.isOn){
            NSString* musicPath = [_gameManager musicPathForControllerName:@"Options"];
            if (musicPath){
                [[SimpleAudioEngine sharedEngine] playBackgroundMusic:musicPath];
            }

        }
	}
    else if (aSwitch == _enableParallaxEffect){
        [userDefaults setBool:aSwitch.isOn forKey:kEnabledParallaxEffect];
    }

}


@end
