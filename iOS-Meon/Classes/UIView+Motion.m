//
//  UIView+Motion.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 8/19/13.
//  Copyright (c) 2013 Manbolo. All rights reserved.
//

#import "UIView+Motion.h"
#import "UIDevice+Helper.h"

@implementation UIView (Motion)

- (void)addParallaxEffect:(CGFloat)value {
    
    if (![[UIDevice currentDevice] isSystemVersionGreaterOrEqualThan:@"7.0"]) {
        return;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:@"enabledParallaxEffect"]) {
        return;
    }
    
    
    UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                                                         type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    xAxis.minimumRelativeValue = [NSNumber numberWithFloat:-value];
    xAxis.maximumRelativeValue = [NSNumber numberWithFloat:value];

    UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                                                         type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    yAxis.minimumRelativeValue = [NSNumber numberWithFloat:-value];
    yAxis.maximumRelativeValue = [NSNumber numberWithFloat:value];

    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[xAxis, yAxis];
    [self addMotionEffect:group];
}

@end
