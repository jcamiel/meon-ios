//
//  CompletedGameAnimator.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 6/20/12.
//  Copyright (c) 2012 Manbolo. All rights reserved.
//

#import "CompletedGameAnimator.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Helper.h"


@implementation CompletedGameAnimator


- (void)start
{
	[super start];
	
    for(UIButton *button in self.buttons){
        button.enabled = NO;
    }
    //
    // ground animation
    CALayer* groundLayer = self.groundView.layer;
    
	
    CABasicAnimation *zoomAnimation = [CABasicAnimation 
                                       animationWithKeyPath:@"transform.scale"];
    zoomAnimation.fromValue = @1.0F;
    zoomAnimation.toValue = @0.001F;
    zoomAnimation.duration = 5.0;
    
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation 
                                           animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.fromValue = @0.0F;
    rotationAnimation.toValue = @(2*3.14F);
    rotationAnimation.duration = 5.0;
    
    
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    [groupAnimation setDuration:5.0];
    groupAnimation.delegate = self;
    [groupAnimation setValue:@"congratulation" forKey:@"name"];
    [groupAnimation setAnimations:@[rotationAnimation,
                                   zoomAnimation]];
    
    self.groundView.scale = 0.001;
    [groundLayer addAnimation:groupAnimation forKey:nil];

}


- (void)stop
{	
    [self.groundView.layer removeAllAnimations];
	[super stop];
}



@end
