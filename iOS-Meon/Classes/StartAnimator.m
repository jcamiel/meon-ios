 //
//  StartAnimator.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/7/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import "StartAnimator.h"
#import <QuartzCore/QuartzCore.h>

@implementation StartAnimator

- (id)init
{
    self = [super init];
    _yCenter = 100;
    return self;
}

-(void)start
{
	[super start];
	
    NSTimeInterval duration = 3.0;
    
    UIImage *ready = [UIImage imageNamed:@"Common/ready.png"];
    UIImage *go = [UIImage imageNamed:@"Common/go.png"];
    
    self.sloganLayer = [CALayer layer];
    self.sloganLayer.contents = (id)(go.CGImage);
    CGFloat imageWidth = go.size.width;
    CGFloat imageHeight = go.size.height;
    CGFloat x = self.superLayer.bounds.size.width;
    [self.sloganLayer setBounds:CGRectMake(0, 0, imageWidth, imageHeight)];
    [self.sloganLayer setPosition:CGPointMake(x/2, self.yCenter)];
    [self.superLayer addSublayer:self.sloganLayer];
	
    // content animation
    CAKeyframeAnimation *contentAnimation = [CAKeyframeAnimation 
											 animationWithKeyPath:@"contents"];
    
    NSArray *values = @[(id)ready.CGImage,
                       (id)ready.CGImage,
                       (id)ready.CGImage,                       
                       (id)go.CGImage,
                       (id)go.CGImage,
                       (id)go.CGImage];
    
    
    NSArray *times = @[@0.0f,
                      @0.25f,
                      @0.5f,
                      @0.50000001f,
                      @0.75f,
                      @1.0f];
    
    [contentAnimation setCalculationMode:kCAAnimationLinear];
    [contentAnimation setValues:values];
    [contentAnimation setKeyTimes:times];
    
    
    // zoom animation
    CAKeyframeAnimation *zoomAnimation = [CAKeyframeAnimation 
										  animationWithKeyPath:@"transform.scale"];
    
    values = @[@8.0f,
			  @1.0f,
			  @1.0f,
			  @8.0f,
			  @1.0f,
			  @1.0f];
    
    [zoomAnimation setCalculationMode:kCAAnimationLinear];
    [zoomAnimation setValues:values];
    [zoomAnimation setKeyTimes:times];
    
    // opacity animation
    CAKeyframeAnimation *alphaAnimation = [CAKeyframeAnimation 
										   animationWithKeyPath:@"opacity"];
    
    values = @[@0.5f,
              @1.0f,
              @1.0f,
              @0.5f,
              @1.0f,
              @1.0f];
    
    [alphaAnimation setCalculationMode:kCAAnimationLinear];
    [alphaAnimation setValues:values];
    [alphaAnimation setKeyTimes:times];
    
    
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    [animation setDuration:duration];
    
    [animation setAnimations:@[contentAnimation,
							  zoomAnimation, 
							  alphaAnimation]];
    animation.delegate = self;
    
    [self.sloganLayer addAnimation:animation forKey:nil];
    

}

- (void)stop
{
	[self.sloganLayer removeFromSuperlayer];
	self.sloganLayer = nil;
	
	[super stop];
}

#pragma mark -
#pragma mark dealloc
- (void)dealloc
{	
	[self.sloganLayer removeFromSuperlayer];
}

@end
