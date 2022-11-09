//
//  ThumbnailAnimator.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/7/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import "ThumbnailAnimator.h"
#import <QuartzCore/QuartzCore.h>


@implementation ThumbnailAnimator


- (void)start
{
	const CGFloat backgroundColor[] = {37.0f/255, 44.0f/255, 64.0f/255, 1.0};
    
    [super start];
    
    self.backgroundLayer = [CALayer layer];
    
    CGColorSpaceRef colorRGBRef = CGColorSpaceCreateDeviceRGB();
    CGColorRef color = CGColorCreate(colorRGBRef,backgroundColor);
    self.backgroundLayer.backgroundColor = color;
    CGColorRelease(color);
    CGColorSpaceRelease(colorRGBRef);
    
    self.backgroundLayer.frame = self.thumbnailFrameFrom;
    //[self.superLayer addSublayer:self.backgroundLayer];
    
    CGRect oldBounds = self.backgroundLayer.bounds;
    CGRect newBounds = CGRectMake(0, 0, 320, 480);
    CGPoint oldPosition = CGPointMake(self.backgroundLayer.position.x, self.backgroundLayer.position.y);
    CGPoint newPosition = CGPointMake(320/2, 480/2);
    
    CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:
								   @"bounds"];
    boundsAnimation.fromValue = [NSValue valueWithCGRect:oldBounds];
    boundsAnimation.toValue = [NSValue valueWithCGRect:newBounds];

    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:
                                         @"position"];
    positionAnimation.fromValue = [NSValue valueWithCGPoint:oldPosition];
    positionAnimation.toValue = [NSValue valueWithCGPoint:newPosition];

    self.backgroundLayer.bounds = newBounds;
    self.backgroundLayer.position = newPosition;
    
    [self.backgroundLayer addAnimation:boundsAnimation forKey:@"bounds"];
    [self.backgroundLayer addAnimation:positionAnimation forKey:@"position"];

    // create the level layer
    
    self.thumbnailLayer = [CALayer layer];
    [self.superLayer addSublayer:self.thumbnailLayer];
    self.thumbnailLayer.contents = (id)self.thumbnailImage.CGImage;
    self.thumbnailLayer.frame = self.thumbnailFrameFrom;
    self.thumbnailLayer.opaque = YES;
    
    oldBounds = CGRectMake(0, 0, self.thumbnailFrameFrom.size.width, self.thumbnailFrameFrom.size.height);
    newBounds = CGRectMake(0, 0, self.thumbnailFrameTo.size.width, self.thumbnailFrameTo.size.height);
    oldPosition = CGPointMake(self.thumbnailFrameFrom.origin.x + (self.thumbnailFrameFrom.size.width)/2,
                              self.thumbnailFrameFrom.origin.y + (self.thumbnailFrameFrom.size.height)/ 2);
    newPosition = CGPointMake(self.thumbnailFrameTo.origin.x + (self.thumbnailFrameTo.size.width)/2,
                              self.thumbnailFrameTo.origin.y + (self.thumbnailFrameTo.size.height)/ 2);

    self.thumbnailLayer.bounds = oldBounds;
    self.thumbnailLayer.position = oldPosition;

    boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    boundsAnimation.fromValue = [NSValue valueWithCGRect:oldBounds];
    boundsAnimation.toValue = [NSValue valueWithCGRect:newBounds];
    
    positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnimation.fromValue = [NSValue valueWithCGPoint:oldPosition];
    positionAnimation.toValue = [NSValue valueWithCGPoint:newPosition];
    positionAnimation.delegate = self; 
    

    self.thumbnailLayer.bounds = newBounds;
    self.thumbnailLayer.position = newPosition;

    [self.thumbnailLayer addAnimation:boundsAnimation forKey:@"bounds"];
    [self.thumbnailLayer addAnimation:positionAnimation forKey:@"position"];

    
    
}


- (void)stop
{
	[self.thumbnailLayer removeFromSuperlayer];
    self.thumbnailLayer = nil;

    [self.backgroundLayer removeFromSuperlayer];
    self.backgroundLayer = nil;

	[super stop];
}


- (void)dealloc
{
    [self.thumbnailLayer removeFromSuperlayer];

    [self.backgroundLayer removeFromSuperlayer];

}



@end
