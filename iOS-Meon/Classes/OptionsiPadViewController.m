//
//  OptionsiPadViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/25/12.
//  Copyright (c) 2012 Manbolo. All rights reserved.
//

#import "OptionsiPadViewController.h"
#import "CustomUISwitch.h"
#import "SimpleAudioEngine.h"
#import "GameManager.h"
#import "UIViewController+Helper.h"
#import "UIDevice+Helper.h"

static NSString * const kEnabledParallaxEffect = @"enabledParallaxEffect";
static NSString * const kNumberOfHints = @"numberOfHints";
static NSString * const kPauseBetweenLevels = @"pauseBetweenLevels";
static NSString * const kEnabledSound = @"enabledSound";
static NSString * const kEnabledMusic = @"enabledMusic";

@implementation OptionsiPadViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BOOL isOS7 = [[UIDevice currentDevice] isSystemVersionGreaterOrEqualThan:@"7.0"];
    
    [self addHeaderImageNamed:@"Common/header_options~ipad.png"];
    
    CGFloat xSrc  = 400;
    CGFloat yMaster = 144;
    CGFloat ySrc  = yMaster;
    CGFloat deltaY = 100;
    
    self.twoHintsSwitch = [self createSwitchWithFrame:(CGRect){{xSrc,ySrc},{100,33}}];
    self.pauseBetweenLevelSwitch = [self createSwitchWithFrame:(CGRect){{xSrc,ySrc+1*deltaY},{100,33}}];
    self.enableSoundSwitch = [self createSwitchWithFrame:(CGRect){{xSrc,ySrc+2*deltaY},{100,33}}];
    self.enableMusicSwitch = [self createSwitchWithFrame:(CGRect){{xSrc,ySrc+3*deltaY},{100,33}}];
    if (isOS7) {
        self.enableParallaxEffect = [self createSwitchWithFrame:(CGRect){{xSrc,ySrc+4*deltaY},{100,33}}];
    }

    self.twoHintsSwitch.delegate = self;
    self.pauseBetweenLevelSwitch.delegate = self;
    self.enableSoundSwitch.delegate = self;
    self.enableMusicSwitch.delegate = self;
    self.enableParallaxEffect.delegate = self;
    
    [self.view addSubview:self.twoHintsSwitch];
    [self.view addSubview:self.pauseBetweenLevelSwitch];
    [self.view addSubview:self.enableSoundSwitch];
    [self.view addSubview:self.enableMusicSwitch];
    if (isOS7) {
        [self.view addSubview:self.enableParallaxEffect];
    }
    
    [self addSwitchBackgroundBelowView:self.twoHintsSwitch];
    [self addSwitchBackgroundBelowView:self.pauseBetweenLevelSwitch];
    [self addSwitchBackgroundBelowView:self.enableSoundSwitch];
    [self addSwitchBackgroundBelowView:self.enableMusicSwitch];
    if (isOS7) {
        [self addSwitchBackgroundBelowView:self.enableParallaxEffect];
    }

    xSrc  = 10;
    ySrc  = yMaster + 2;
    CGFloat width = 340;
    CGFloat normalFontSize = 30;
    UIFont *font = [UIFont fontWithName:@"BradyBunchRemastered" size:normalFontSize];
    [self addLabel:(CGRect){{xSrc,ySrc},{width,30}}
            parent:self.view
              text:NSLocalizedString(@"L_OptionsTwoHints",)
              font:font];
    [self addLabel:(CGRect){{xSrc,ySrc+1*deltaY},{width,30}}
            parent:self.view
     
              text:NSLocalizedString(@"L_OptionsPause",)
              font:font];
    [self addLabel:(CGRect){{xSrc,ySrc+2*deltaY},{width,30}}
            parent:self.view
              text:NSLocalizedString(@"L_OptionsSounds",)
              font:font];
    [self addLabel:(CGRect){{xSrc,ySrc+3*deltaY},{width,30}}
            parent:self.view
              text:NSLocalizedString(@"L_OptionsMusic",)
              font:font];
    if (isOS7) {
        [self addLabel:(CGRect){{xSrc,ySrc+4*deltaY},{width,30}}
                parent:self.view
                  text:NSLocalizedString(@"L_OptionsParallax",)
                  font:font];
    }
    
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	BOOL ret;
	ret = ([userDefaults integerForKey:kNumberOfHints] == 2 ) ? YES : NO;
	[self.twoHintsSwitch setOn:ret animated:NO];
	
	ret = [userDefaults boolForKey:kPauseBetweenLevels];
	[self.pauseBetweenLevelSwitch setOn:ret animated:NO];
	
	ret = [userDefaults boolForKey:kEnabledSound];
	[self.enableSoundSwitch setOn:ret animated:NO];
    
	ret = [userDefaults boolForKey:kEnabledMusic];
	[self.enableMusicSwitch setOn:ret animated:NO];

    if (isOS7) {
        ret = [userDefaults boolForKey:kEnabledParallaxEffect];
        [self.enableParallaxEffect setOn:ret animated:NO];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
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

- (void)addLabelWithFrame:(CGRect)frame text:(NSString*)text font:(UIFont*)font
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = self.view.backgroundColor;
    label.opaque = YES;
    label.font = font;
    label.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:label];
    
}


#pragma mark - CustomUISwitch delegate
- (void)valueChangedInView:(CustomUISwitch*)aSwitch
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	if (aSwitch == self.twoHintsSwitch){
		if (aSwitch.isOn){
			[userDefaults setInteger:2 forKey:kNumberOfHints];
		}
		else {
			[userDefaults setInteger:1 forKey:kNumberOfHints];
		}
	}
	else if (aSwitch == self.pauseBetweenLevelSwitch){
		[userDefaults setBool:aSwitch.isOn forKey:kPauseBetweenLevels];
	}
	else if (aSwitch == self.enableSoundSwitch){
		[userDefaults setBool:aSwitch.isOn forKey:kEnabledSound];
        
        SimpleAudioEngine *audioEngine = [SimpleAudioEngine sharedEngine];
        audioEngine.effectsVolume = aSwitch.isOn ? kEffectsVolume : 0;
        
	}
    else if (aSwitch == self.enableMusicSwitch){
		[userDefaults setBool:aSwitch.isOn forKey:kEnabledMusic];
        
        SimpleAudioEngine *audioEngine = [SimpleAudioEngine sharedEngine];
        audioEngine.backgroundMusicVolume = aSwitch.isOn ? kBackgroundMusicVolume : 0;
        if (aSwitch.isOn){
            NSString* musicPath = [self.gameManager musicPathForControllerName:@"Options"];
            if (musicPath){
                [[SimpleAudioEngine sharedEngine] playBackgroundMusic:musicPath];
            }
        }
        
	}
    else if (aSwitch == self.enableParallaxEffect){
        [userDefaults setBool:aSwitch.isOn forKey:kEnabledParallaxEffect];
    }
    
}


@end
