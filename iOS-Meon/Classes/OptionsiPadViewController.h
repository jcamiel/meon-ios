//
//  OptionsiPadViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/25/12.
//  Copyright (c) 2012 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomUISwitch, GameManager;
#import "ModaliPadViewController.h"

@interface OptionsiPadViewController : ModaliPadViewController

@property (nonatomic, strong) CustomUISwitch *twoHintsSwitch;
@property (nonatomic, strong) CustomUISwitch *pauseBetweenLevelSwitch;
@property (nonatomic, strong) CustomUISwitch *enableSoundSwitch;
@property (nonatomic, strong) CustomUISwitch *enableMusicSwitch;
@property (nonatomic, strong) CustomUISwitch *enableParallaxEffect;

@property (nonatomic, strong) GameManager *gameManager;


@end


