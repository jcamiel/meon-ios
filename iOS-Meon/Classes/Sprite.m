//
//  Sprite.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/3/10.
//  Copyright 2010 Manbolo. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "Sprite.h"
#import "tile.h"
#import "Common.h"
#import "SimpleAudioEngine.h"


@implementation Sprite

#pragma mark - init / dealloc
-(id)init
{
    self = [super init];
    if (self){
        _layer = [CALayer layer];
        
        NSMutableDictionary *newActions = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           [NSNull null], @"contents",
                                           [NSNull null], @"position",
                                           [NSNull null], @"frame",
                                           [NSNull null], @"bounds",
                                           [NSNull null], @"hidden",
                                           [NSNull null], @"contentsRect",
                                           nil];
        _layer.actions = newActions;
        _light = (unsigned int) -1;
        _moveable = YES;
        _dirty = YES;
        _framesCount = 1;
    }
    return self;
}





- (void)setType:(unsigned int)type
{
    if (type == _type)
        return;
    _type = type;
    _dirty = YES;
}

- (void)setLight:(unsigned int)newLight
{
    if (newLight == _light)
        return;
    _light = newLight;
    _dirty = YES;
}


- (void)updateFrames
{
    if (!self.isDirty) return;
    self.dirty = NO;
}


- (void)touchesBegan
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"Sounds/hit.caf"];
}

- (void)touchesMoved
{
}

- (void)touchesEnded
{
}

- (void)touchesCancelled
{
}


- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ type=%d light=%d direction=%d", [self class],
                self.type, self.light, self.direction];
    
}


- (void)setCenter:(CGPoint)center
{
    _center = center;
    _layer.position = (CGPoint){center.x, center.y};
}

- (void)setSuperlayer:(CALayer*)layer
{
    [_layer removeFromSuperlayer];
    [layer addSublayer:_layer];
}

- (CALayer*)superlayer
{
    return _layer.superlayer;
}

- (BOOL)hidden
{
    return _layer.hidden;
}

- (void)setHidden:(BOOL)hidden
{
    _layer.hidden = hidden;
}

@end
