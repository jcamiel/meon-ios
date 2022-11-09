//
//  CMScrollView.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 6/29/12.
//  Copyright (c) 2012 Manbolo. All rights reserved.
//

#import "CMScrollView.h"
#import <QuartzCore/QuartzCore.h>

@implementation CMScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addMask];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addMask];
    }
    return self;
}


- (void)addMask {
    CAGradientLayer *mask = [CAGradientLayer layer];
    mask.locations = @[@0.0,
                       @0.5,
                       @0.95,
                       @1.0];

    mask.colors = @[(id)[UIColor clearColor].CGColor,
                    (id)[UIColor whiteColor].CGColor,
                    (id)[UIColor whiteColor].CGColor,
                    (id)[UIColor clearColor].CGColor];

    mask.frame = self.bounds;
    mask.startPoint = CGPointMake(0, 0);
    mask.endPoint = CGPointMake(0, 1);

    self.layer.mask = mask;
}


- (void)layoutSubviews {
    [super layoutSubviews];

    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

    CGRect layerMaskFrame = self.layer.mask.frame;
    layerMaskFrame.origin = [self convertPoint:self.bounds.origin toView:self];
    self.layer.mask.frame = layerMaskFrame;

    [CATransaction commit];
}


@end
