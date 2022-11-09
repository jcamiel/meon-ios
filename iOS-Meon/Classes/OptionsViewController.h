//
//  OptionsViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 5/1/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomUISwitch.h"
#import "ModalViewController.h"

@protocol OptionsViewControllerDelegate;
@class GameManager;

@interface OptionsViewController : ModalViewController<CustomUISwitchDelegate>

@property (nonatomic, weak) id<OptionsViewControllerDelegate> delegate;

- (IBAction)back:(id)sender;

@property(nonatomic, strong) CustomUISwitch *twoHintsSwitch;
@property(nonatomic, strong) CustomUISwitch *pauseBetweenLevelSwitch;
@property(nonatomic, strong) CustomUISwitch *enableSoundSwitch;
@property(nonatomic, strong) CustomUISwitch *enableMusicSwitch;
@property(nonatomic, strong) CustomUISwitch *enableParallaxEffect;
@property(nonatomic, strong) GameManager *gameManager;

@end


@protocol OptionsViewControllerDelegate
-(void)optionsDidSelectBack:(OptionsViewController*)controller;
@end