//
//  TapToContinueAnimator.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/7/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import "TapToContinueAnimator.h"
#import <QuartzCore/QuartzCore.h>

@implementation TapToContinueAnimator

- (id)init
{
    self = [super init];
    if  (self){
        _marginBottom = 100;
    }
    return self;
}


-(void)start
{
	[super start];

    CGPoint center = (CGPoint){self.superLayer.bounds.size.width / 2,
        self.superLayer.bounds.size.height-self.marginBottom};
    
    UIImage* image = [UIImage imageNamed:@"Common/click-to-continue.png"];
    CGImageRef imageRef = [image CGImage];
    CGFloat imageWidthInPoint = image.size.width;
    CGFloat imageHeightInPoint = image.size.height;
    
    // create the layer
    self.clickToContinueLayer = [CALayer layer];
    self.clickToContinueLayer.contents = (__bridge id)imageRef;
    self.clickToContinueLayer.bounds = CGRectMake(0, 0, imageWidthInPoint, imageHeightInPoint);
    
    CGPoint centerOnPixel = center;
    if (((int)imageWidthInPoint) % 2)
        centerOnPixel.x += 0.5;
    if (((int)imageHeightInPoint) % 2)
        centerOnPixel.y += 0.5;
    
    [self.clickToContinueLayer setPosition:centerOnPixel];
	
    [self.superLayer addSublayer:self.clickToContinueLayer];
    
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation 
                                      animationWithKeyPath:@"transform.scale"];
    
    NSArray *values = @[@1.0f,
                       @1.1f,
                       @1.0f,
                       @1.0f];
    
    
    NSArray *times = @[@0.0f,
                      @0.1f,
                      @0.2f,
                      @1.0f];
	
    NSArray *functions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
						  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
						  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    
	
    [animation setDuration:2.5];
    [animation setValues:values];
    [animation setKeyTimes:times];
    [animation setTimingFunctions:functions];
    animation.repeatCount = (float)HUGE_VAL;
    
    
    [self.clickToContinueLayer addAnimation:animation forKey:@"zoom"];

}

- (void)stop
{
	[self.clickToContinueLayer removeFromSuperlayer];
	self.clickToContinueLayer = nil;
	[super stop];
}

#pragma mark - dealloc
- (void)dealloc
{	
	[self.clickToContinueLayer removeFromSuperlayer];
}

@end


