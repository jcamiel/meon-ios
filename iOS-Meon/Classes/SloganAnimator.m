//
//  SloganAnimator.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/7/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import "SloganAnimator.h"
#import <QuartzCore/QuartzCore.h>


@interface SloganAnimator()
@property (nonatomic, assign) NSTimeInterval duration;
@end



@implementation SloganAnimator



- (id)init
{
    self = [super init];
    _isUsingSuperSuperLayerWidth = NO;
    _duration = 2.5;
    
    return self;
}


- (void)start
{
	[super start];
	
    int index = (rand() % 12 );
//    
    NSString *imageName = [NSString stringWithFormat:@"Slogans/slogan%d", index];
    
    UIImage* image = [UIImage imageNamed:imageName];
    CGImageRef imageRef = [image CGImage];
    CGFloat imageWidthInPoint = image.size.width;
    CGFloat imageHeightInPoint = image.size.height;

    CGFloat animationWidth = self.superLayer.bounds.size.width;
    CGFloat animationHeight = self.superLayer.bounds.size.height; 
    
    // create the layer
    self.sloganLayer = [CALayer layer];
    self.sloganLayer.contents = (__bridge id)imageRef;
    self.sloganLayer.bounds = (CGRect){{0, 0}, {imageWidthInPoint, imageHeightInPoint}};
    
    CGFloat xCenter, yCenter;
    if (self.isUsingSuperSuperLayerWidth){
        CALayer *superSuperLayer = self.superLayer.superlayer; 
        CGRect superBounds = superSuperLayer.bounds;
        CGRect superBoundsInSloganLayerCoordinates = [self.superLayer convertRect:superBounds
                                                                     fromLayer:superSuperLayer];
        xCenter = superBoundsInSloganLayerCoordinates.origin.x + 
            superBoundsInSloganLayerCoordinates.size.width + (imageWidthInPoint/2);
    }
    else{
        xCenter = animationWidth + (imageWidthInPoint/2);
    }
    yCenter = (animationHeight/2) - 40;
    
    self.sloganLayer.position = (CGPoint){xCenter, yCenter}; 
    [self.superLayer addSublayer:self.sloganLayer];
    
    CAAnimation *xAnimation = [self xAnimationForSlogan:self.sloganLayer];
    CAAnimation *zoomAnimation = [self zoomAnimationForSlogan:self.sloganLayer];
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    [groupAnimation setDuration:self.duration];
    
    [groupAnimation setAnimations:@[xAnimation,
                                   zoomAnimation]];
    groupAnimation.delegate = self;
    groupAnimation.fillMode = kCAFillModeForwards;
    groupAnimation.removedOnCompletion = NO;
    [self.sloganLayer addAnimation:groupAnimation forKey:nil];


}


- (void)stop
{	
    [self.sloganLayer removeAllAnimations];
	[self.sloganLayer removeFromSuperlayer];
    self.sloganLayer = nil;
	[super stop];
}


- (void)dealloc
{
    [self.sloganLayer removeAllAnimations];
	[self.sloganLayer removeFromSuperlayer];
}


- (CAAnimation*)xAnimationForSlogan:(CALayer*)layer
{
    CGFloat imageWidth = layer.frame.size.width;
    CGFloat x0, x1, x2, x3;
    if (self.isUsingSuperSuperLayerWidth){
        CALayer *superSuperLayer = self.superLayer.superlayer; 
        CGRect superBounds = superSuperLayer.bounds;
        CGRect superBoundsInSloganLayerCoordinates = [self.superLayer convertRect:superBounds
                                                                    fromLayer:superSuperLayer];
        x0 = superBoundsInSloganLayerCoordinates.origin.x + 
            superBoundsInSloganLayerCoordinates.size.width + (imageWidth/2);
        x3 = superBoundsInSloganLayerCoordinates.origin.x - (imageWidth/2);
    }
    else{
        CGFloat widthAnimation = self.superLayer.bounds.size.width;
        x0 = widthAnimation + (imageWidth / 2);
        x3 = -imageWidth / 2;
    }
    x1 = (x0 + x3) / 2;
    x2 = (x0 + x3) / 2;

    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation 
                                      animationWithKeyPath:@"position.x"];
    
    
    NSArray *values = @[@((float)x0),
                       @((float)x1),
                       @((float)x2),
                       @((float)x3)];
    
    
    NSArray *times = @[@0.0f,
                      @0.08f,
                      @0.92f,
                      @1.0f];
    
    [animation setCalculationMode:kCAAnimationLinear];
    [animation setDuration:self.duration];
    [animation setValues:values];
    [animation setKeyTimes:times];
    
    return animation;
}


- (CAAnimation*)zoomAnimationForSlogan:(CALayer*)layer
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation 
                                      animationWithKeyPath:@"transform.scale"];
    
    NSArray *values = @[@1.0f,
                       @1.0f,
                       @2.0f,
                       @1.0f,
                       @1.0f,
                       @1.0f];
    
    
    NSArray *times = @[@0.0f,
                      @0.08f,
                      @0.15f,
                      @0.22f,
                      @0.92f,
                      @1.0f];
    
    [animation setCalculationMode:kCAAnimationLinear];
    [animation setDuration:self.duration];
    [animation setValues:values];
    [animation setKeyTimes:times];
    
    return animation;
}




@end
