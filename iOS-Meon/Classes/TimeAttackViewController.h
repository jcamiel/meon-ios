//
//  TimeAttackViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/13/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalViewController.h"

@protocol TimeAttackViewControllerDelegate;


@interface TimeAttackViewController : ModalViewController

- (IBAction)playFlash:(id)sender;
- (IBAction)playMedium:(id)sender;
- (IBAction)playMarathon:(id)sender;
- (IBAction)back:(id)sender;

@property (nonatomic, weak) id<TimeAttackViewControllerDelegate> delegate;
@property (nonatomic, strong) UILabel *textLabel;

@end


@protocol TimeAttackViewControllerDelegate

- (void)timeAttackDidSelectPlayFlash:(TimeAttackViewController*)controller;
- (void)timeAttackDidSelectPlayMedium:(TimeAttackViewController*)controller;
- (void)timeAttackDidSelectPlayMarathon:(TimeAttackViewController*)controller;
- (void)timeAttackDidSelectBack:(TimeAttackViewController*)controller;

@end