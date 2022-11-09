//
//  TimeAttackiPadViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/29/12.
//  Copyright (c) 2012 Manbolo. All rights reserved.
//

#import "ModaliPadViewController.h"

@class TimeAttackiPadViewController;

@protocol TimeAttackiPadViewControllerDelegate <ModaliPadViewControllerDelegate>
- (void)timeAttackiPadDidSelectPlayFlash:(TimeAttackiPadViewController*)controller;
- (void)timeAttackiPadDidSelectPlayMedium:(TimeAttackiPadViewController*)controller;
- (void)timeAttackiPadDidSelectPlayMarathon:(TimeAttackiPadViewController*)controller;
@end



@interface TimeAttackiPadViewController : ModaliPadViewController

@property (nonatomic, weak) id<TimeAttackiPadViewControllerDelegate> delegate;

@end

