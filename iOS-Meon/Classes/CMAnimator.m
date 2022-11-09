//
//  CMAnimator.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/7/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import "CMAnimator.h"
#import <QuartzCore/QuartzCore.h>


@interface CMAnimator ()

@property (nonatomic, weak) id startDelegate;
@property (nonatomic, weak) id stopDelegate;
@property (nonatomic, assign) SEL startSelector;
@property (nonatomic, assign) SEL stopSelector;

@end


@implementation CMAnimator


+ (id)animator {
    return [[[self class] alloc] init];
}

- (void)start {
    if (self.running) {
        return;
    }
    self.running = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([self.startDelegate respondsToSelector:self.startSelector]) {
        [self.startDelegate performSelector:self.startSelector];
    }
#pragma clang diagnostic pop

}

- (void)stop {
    
    if (!self.running) {
        return;
    }
    self.running = NO;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([self.stopDelegate respondsToSelector:self.stopSelector]) {
        [self.stopDelegate performSelector:self.stopSelector];
    }
#pragma clang diagnostic pop

}

- (void)dealloc {
    if (self.running) {
        [self stop];
    }
    self.startSelector = NULL;
    self.stopSelector = NULL;
}

- (void)setAnimatorDidStopSelector:(SEL)selector withDelegate:(id)delegate {
    self.stopSelector = selector;
    self.stopDelegate = delegate;

}

- (void)setAnimatorDidStartSelector:(SEL)selector withDelegate:(id)delegate {
    self.startSelector = selector;
    self.startDelegate = delegate;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    [self stop];
}

@end
