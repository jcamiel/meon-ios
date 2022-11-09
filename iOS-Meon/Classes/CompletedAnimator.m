//
//  CompletedAnimator.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/8/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import "CompletedAnimator.h"
#import <QuartzCore/QuartzCore.h>


@interface CompletedAnimator ()
- (CAAnimation *)bounceAnimationForKeyPath:(NSString *)keyPath
                                 fromValue:(NSNumber *)fromValue
                                   toValue:(NSNumber *)toValue;
@end



@implementation CompletedAnimator

- (id)init {
    self = [super init];

    self.counterViewPositionTo = (CGPoint){230.5, 145};

    return self;
}

- (void)start {
    [super start];

    // ground view dezoom animation
    //
    CALayer * groundLayer = self.groundView.layer;

    CABasicAnimation *animation = [CABasicAnimation
                                   animationWithKeyPath:@"transform.scale"];
    animation.fromValue = @1.0f;
    animation.toValue = @0.001f;

    self.groundView.transform = CGAffineTransformMakeScale(0.001, 0.001);
    [groundLayer addAnimation:animation forKey:@""];


    // slogan zoom animation
    //
    CGImageRef imageRef = [self.sloganImage CGImage];
    CGFloat imageWidth = self.sloganImage.size.width;
    CGFloat imageHeight = self.sloganImage.size.height;

    // create the layer
    self.sloganLayer = [CALayer layer];
    self.sloganLayer.contents = (__bridge id)imageRef;
    [self.sloganLayer setBounds:CGRectMake(0, 0, imageWidth, imageHeight)];
    [self.sloganLayer setPosition:CGPointMake(self.superLayer.bounds.size.width/2, self.ySlogan)];
    [self.superLayer addSublayer:self.sloganLayer];

    CAAnimation *bounceAnimation = [self bounceAnimationForKeyPath:@"position.y"
                                                         fromValue:@0.0f
                                                           toValue:@((float)self.ySlogan)];

    [self.sloganLayer addAnimation:bounceAnimation forKey:nil];


    // score animation
    if (self.counterView) {
        CALayer * scoreLayer = self.counterView.layer;

        CGFloat xSrc = self.counterView.center.x;
        CGFloat ySrc = self.counterView.center.y;
        CGFloat xDst = self.counterViewPositionTo.x;
        CGFloat yDst = self.counterViewPositionTo.y;

        CABasicAnimation *scoreAnimation = [CABasicAnimation
                                            animationWithKeyPath:@"position"];
        scoreAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(xSrc, ySrc)];
        scoreAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(xDst, yDst)];
        scoreAnimation.duration = 0.5;

        scoreAnimation.timingFunction =
            [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [scoreLayer addAnimation:scoreAnimation forKey:nil];

        self.counterView.center = CGPointMake(xDst, yDst);

    }
}

- (void)stop {
    [self.sloganLayer removeFromSuperlayer];
    self.sloganLayer = nil;

    [super stop];
}

#pragma mark - boucing animation
- (CAAnimation *)bounceAnimationForKeyPath:(NSString *)keyPath
                                 fromValue:(NSNumber *)fromValue
                                   toValue:(NSNumber *)toValue {
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    animation.duration = 1.0;


    NSMutableArray *values = [NSMutableArray array];
    NSMutableArray *timings = [NSMutableArray array];

    float start = [fromValue floatValue];
    float end = [toValue floatValue];
    float currentStart = start;
    float range = fabs(end-start);
    float springTension = 0.5f;
    int step = 0;

    while (fabs(range)>5) {
        [values addObject:@(currentStart)];
        [values addObject:@(end)];

        [timings addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        [timings addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];

        step++;
        range *= springTension;
        currentStart = end - range;
    }
    animation.values = values;
    animation.timingFunctions = timings;
    animation.duration = 2.0;
    return animation;
}

@end
