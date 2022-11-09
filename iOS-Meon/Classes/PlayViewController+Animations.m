//
//  PlayViewController+Animations.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/27/10.
//  Copyright 2010 Manbolo. All rights reserved.
//
#import "PlayViewController+Animations.h"
#import "Common.h"
#import "GameManager.h"
#import "GroundView.h"
#import "CMBitmapNumberView.h"
#import "Sprite.h"
#import "Common.h"
#import "UIView+Helper.h"
#import "SloganAnimator.h"

@implementation PlayViewController(Animations)

#pragma mark - Animation Stop
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSString* animationName = [anim valueForKey:@"name"];
    if ([animationName isEqualToString:@"congratulation"]){
        [self.delegate playDidFinishGame:self];
    }
}

#pragma mark - Congratulations
- (void)startCongratulationAnimation
{
    
    UIImage *image = [self.groundView rasterizedImage];
    self.rasterizedGroundView = [[UIImageView alloc] initWithImage:image];
    self.rasterizedGroundView.frame = self.groundView.frame;
    [self.view insertSubview:self.rasterizedGroundView 
                belowSubview:self.groundView];
    [self.groundView removeFromSuperview];
    self.groundView = nil;

    
    //
    // ground animation
    CALayer* groundLayer = self.rasterizedGroundView.layer;
    
	
    CABasicAnimation *zoomAnimation = [CABasicAnimation 
                                         animationWithKeyPath:@"transform.scale"];
    zoomAnimation.fromValue = @1.0f;
    zoomAnimation.toValue = @0.001f;
    zoomAnimation.duration = 5.0;


    CABasicAnimation *rotationAnimation = [CABasicAnimation 
                                       animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.fromValue = @0.0f;
    rotationAnimation.toValue = @(2*3.14);
    rotationAnimation.duration = 5.0;
    
    
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    [groupAnimation setDuration:5.0];
    groupAnimation.delegate = self;
    [groupAnimation setValue:@"congratulation" forKey:@"name"];
    [groupAnimation setAnimations:@[rotationAnimation,
                                   zoomAnimation]];
    
    self.rasterizedGroundView.scale = 0.001;
    [groundLayer addAnimation:groupAnimation forKey:nil];
  

}








@end
