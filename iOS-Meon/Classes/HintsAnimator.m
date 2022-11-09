//
//  HintsAnimator.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/14/11.
//  Copyright 2011 Manbolo. All rights reserved.
//
#import "HintsAnimator.h"

#import <QuartzCore/QuartzCore.h>
#import "Sprite.h"

@interface HintsAnimator ()

@property (nonatomic, assign) unsigned int index;

@end


@implementation HintsAnimator


- (void)start {
    [super start];

    Sprite * hintSprite = self.hintsSprites[self.index];
    NSInteger numberOfHints = [[NSUserDefaults standardUserDefaults] integerForKey:@"numberOfHints"];
    self.index = (numberOfHints == 1) ? 0 : (self.index + 1) % 2;

    // fix: the updateFrame has never been called
    [hintSprite updateFrames];

    CALayer * hintLayer = hintSprite.layer;
    hintLayer.zPosition = 2.0f;    //place the layer in front of everybody


    CABasicAnimation *zoomAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    zoomAnimation.fromValue = @1.0f;
    zoomAnimation.toValue = @1.4f;
    zoomAnimation.duration = 0.15;
    zoomAnimation.autoreverses = YES;
    zoomAnimation.timingFunction = [CAMediaTimingFunction functionWithName:
                                    kCAMediaTimingFunctionEaseOut];

    CABasicAnimation *hiddenAnimation = [CABasicAnimation animationWithKeyPath:@"hidden"];
    hiddenAnimation.fromValue = @NO;
    hiddenAnimation.toValue = @YES;
    hiddenAnimation.duration = 1.0;
    hiddenAnimation.repeatCount = 5;


    CAAnimationGroup *animation = [CAAnimationGroup animation];
    [animation setDuration:5.0];

    [animation setAnimations:@[hiddenAnimation,
                               zoomAnimation]];

    [hintLayer addAnimation:animation forKey:nil];
//    [hintLayer addAnimation:hiddenAnimation forKey:@"hidden"];

}

- (void)stop {
    for(Sprite *sprite in self.hintsSprites) {
        [sprite.layer removeAllAnimations];
    }

    [super stop];
}

@end
